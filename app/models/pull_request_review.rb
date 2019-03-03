# frozen_string_literal: true

class PullRequestReview
  include ActiveModel::Validations
  attr_reader :repo_id, :pr_number, :repo_full_name, :comments
  validates_presence_of :repo_id, :pr_number, :repo_full_name, :comments
  validates_numericality_of :repo_id, :pr_number

  attr_reader :repo_full_name, :pr_number, :comments, :repo_id

  def initialize(repo_id:, pr_number:, repo_full_name:, comments:)
    @repo_id = repo_id
    @pr_number = pr_number
    @repo_full_name = repo_full_name
    @comments = comments
    validate!
  end
end
