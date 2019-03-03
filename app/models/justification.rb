# frozen_string_literal: true

class Justification
  include ActiveModel::Validations
  include ActionView::Helpers

  validates_presence_of :match, :forks_count, :stargazers_count, :organization_followers_count, :org_name, :repo_name
  validates_numericality_of :match, greater_than_or_equal_to: 0.49
  validates_numericality_of :forks_count, :stargazers_count, :organization_followers_count
  attr_reader :match, :forks_count, :stargazers_count, :organization_followers_count, :influential_org, :org_name, :repo_name, :description

  def initialize(match:, forks_count:, stargazers_count:, organization_followers_count:, influential_org:, org_name:, repo_name:)
    @match = match
    @forks_count = forks_count
    @stargazers_count = stargazers_count
    @organization_followers_count = organization_followers_count
    @influential_org = influential_org
    @org_name = org_name
    @repo_name = repo_name
  end

  def to_s
    description
  end

  private

  def build_description
    description = ['**Why is this being recommended?**']
    description << "* #{number_to_percentage(match * 100, precision: 0)} match"
    description << repo_popularity
    description << org_popularity
    description.compact.join("\n") + "\n"
  end

  def description
    @description ||= build_description
  end

  def org_popularity
    "* #{org_name.capitalize} is an influential organization." if influential_org
  end

  def repo_popularity
    if stargazers_count > 29 && forks_count.to_i > 28
      "* #{repo_name.capitalize} is a popular repo, with #{stargazers_count} stargazers and #{forks_count} forks."
    elsif stargazers_count > 29
      "* #{repo_name.capitalize} is a popular repo, with #{stargazers_count} stargazers."
    elsif forks_count > 29
      "* #{repo_name.capitalize} is a popular repo, with #{forks_count} forks."
    end
  end
end
