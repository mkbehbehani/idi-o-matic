# frozen_string_literal: true

class GithubService
  include ActiveModel::Validations
  extend Forwardable
  validates_presence_of :installation_id
  def_delegators :installation_client, :commit, :repository, :organization, :organization_public_members

  def initialize(installation_id:)
    @installation_id = installation_id
    validate!
  end

  def sync_pull_request_review(repo_full_name:, pr_number:, comments:)
    installation_client.create_pull_request_review(repo_full_name, pr_number, event: 'COMMENT', body: comments.join("\n"))
  end

  def get_commit_messages(repo_name, pr_number)
    raw_commits = installation_client.pull_request_commits(repo_name, pr_number, {})
    diff = installation_client.pull_request(repo_name, pr_number)
    return unless raw_commits
    raw_commits.each_with_object([]) do |raw_response, collection|
      raw_commit = raw_response.to_attrs
      collection << { message: raw_commit[:commit][:message], sha: raw_commit[:sha] }
    end
  end

  private

  attr_reader :installation_id

  def github_jwt
    JWT.encode(
      { iat: Time.now.to_i, exp: Time.now.to_i + (10 * 60), iss: Rails.configuration.github_app_identifier },
      Rails.configuration.github_private_key,
      'RS256'
    )
  end

  def app_level_octokit_client
    Octokit::Client.new(bearer_token: github_jwt)
  end

  def installation_token
    app_level_octokit_client.create_app_installation_access_token(installation_id)[:token]
  end

  def installation_client
    @installation_client ||= Octokit::Client.new(bearer_token: installation_token)
  end
end
