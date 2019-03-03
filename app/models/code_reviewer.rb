# frozen_string_literal: true

class CodeReviewer
  include ActiveModel::Validations
  validates_presence_of :repository_service, :code_analyzer
  attr_reader :repository_service, :code_analyzer

  def initialize(repository_service:, code_analyzer:)
    @repository_service = repository_service
    @code_analyzer = code_analyzer
    validate!
  end

  def review_pull_request(repository_id:, pull_request_id:, repo_name:, repo_url:)
    raw_commit_messages = repository_service.get_commit_messages(repo_name, pull_request_id)
    code_analyses = code_analyzer.analyze_code(code_descriptions: raw_commit_messages.pluck(:message)).map { |result_set| result_set.map(&:symbolize_keys) }.map(&:first)
    comments = raw_commit_messages.zip(code_analyses).keep_if(&:all?).map { |pair| pair.first.merge(pair.last) }.map do |analysis|
      match = 1 - analysis[:distance]
      justification = Justification.new(justification_for_recommendation(match: match, recommendation_repo: analysis[:nwo]))
      if justification.valid?
        CodeRecommendationComment.new(repo_name: analysis[:nwo], repo_url: analysis[:url], commit_message: analysis[:message], commit_sha: analysis[:sha], code_sample: analysis[:function_blob]).to_s +
          justification.to_s
      end
    end
    pull_request_review = PullRequestReview.new(repo_id: repository_id, pr_number: pull_request_id, repo_full_name: repo_name, comments: comments)
    repository_service.sync_pull_request_review(repo_full_name: pull_request_review.repo_full_name, pr_number: pull_request_review.pr_number, comments: pull_request_review.comments.flatten)
  end

  private

  def recommendation_justified?(justification)
    (justification.match > 0.79) && (justification.stargazers_count > 29 || justification.forks_count > 29 || justification.influential_org)
  end

  def justification_for_recommendation(match:, recommendation_repo:)
    repo_info = repository_service.repository(recommendation_repo)
    if repo_info[:organization].present?
      organization_info = repository_service.organization(repo_info[:organization][:id])
      {
        match: match,
        forks_count: repo_info[:forks_count],
        stargazers_count: repo_info[:stargazers_count],
        organization_followers_count: organization_info[:followers],
        influential_org: influential_organization?(name: organization_info[:name], followers_count: organization_info[:followers], repos_count: organization_info[:public_repos], influential_list: influential_orgs),
        org_name: organization_info[:name],
        repo_name: repo_info[:name]
      }
    else
      {
        match: match,
        forks_count: repo_info[:forks_count],
        stargazers_count: repo_info[:stargazers_count],
        organization_followers_count: 0,
        influential_org: false,
        org_name: '',
        repo_name: repo_info[:name]
      }
    end
  end

  def influential_orgs
    []
  end

  def influential_organization?(name:, followers_count:, repos_count:, influential_list:)
    (followers_count > 50) || (repos_count > 50) || influential_list.include?(name)
  end
end
