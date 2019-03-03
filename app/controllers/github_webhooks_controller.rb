# frozen_string_literal: true

class GithubWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  include GithubWebhook::Processor

  # We're deviating from the standard rails controller actions only because this is the recommended technique when using the github_webhook gem.
  def github_pull_request(payload)
    return unless supported_action?(payload[:action])
    @installation_id = payload['installation']['id']
    code_reviewer.review_pull_request(repository_id: payload['repository']['id'], pull_request_id: payload['pull_request']['number'], repo_name: payload['repository']['full_name'], repo_url: payload['repository']['url'])
  end

  private

  def code_analyzer
    CodeAnalyzer.new(code_recommender: code_recommender)
  end

  def code_recommender
    CodeRecommender.new(code_searcher: code_searcher, search_result_organizer: search_result_organizer)
  end

  def code_searcher
    CodeSearcher.new
  end

  def code_reviewer
    CodeReviewer.new(repository_service: repository_service, code_analyzer: code_analyzer)
  end

  attr_reader :installation_id

  def repository_service
    GithubService.new(installation_id: installation_id)
  end

  def search_result_organizer
    SearchResultOrganizer.new
  end

  def supported_action?(action)
    action.include? 'open'
  end

  def webhook_secret(_payload)
    Rails.configuration.github_webhook_secret
  end
end
