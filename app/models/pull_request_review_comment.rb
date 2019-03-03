# frozen_string_literal: true

class PullRequestReviewComment
  include ActiveModel::Validations
  attr_reader :pull_request_id, :repo_full_name, :body, :commit_id, :path, :position
  validates_presence_of :pull_request_id, :repo_full_name, :body, :commit_id, :path, :position
  validates_numericality_of :pull_request_id, :position

  def initialize(pull_request_id:, repo_full_name:, body:, commit_id:, path:, position:)
    @pull_request_id = pull_request_id
    @repo_full_name = repo_full_name
    @body = body
    @commit_id = commit_id
    @path = path
    @position = position
    validate!
  end
end
