# frozen_string_literal: true

class CodeRecommendationComment
  include ActiveModel::Validations
  validates_presence_of :repo_name, :repo_url, :commit_message, :commit_sha, :code_sample
  def initialize(repo_name:, repo_url:, commit_message:, commit_sha:, code_sample:)
    @repo_name = repo_name
    @repo_url = repo_url
    @commit_message = commit_message
    @commit_sha = commit_sha
    @code_sample = code_sample
    validate!
  end

  def to_s
    "Here's how the [#{repo_name}](#{repo_url}) repo has done something similar to '#{commit_message}' in #{commit_sha}: \n```\n#{code_sample}\n```\n"
  end

  private

  attr_reader :repo_name, :repo_url, :commit_message, :commit_sha, :code_sample
end
