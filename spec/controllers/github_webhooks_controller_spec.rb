# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubWebhooksController, type: :controller do
  let(:example_code_reviewer) { instance_double('CodeReviewer') }
  let(:payload) { { 'installation': { 'id': 1 }, 'repository': { 'full_name': 'a', 'id': 2, 'url': 'abc' }, 'pull_request': { 'number': 7 }, 'action': 'open' }.with_indifferent_access }
  describe '#github_pull_request' do
    it { expect(response).to have_http_status(:ok) }
    subject { GithubWebhooksController.new }

    # This is a bit different from a typical rspec controller spec, due to the github_webhook gem
    it 'creates a pull request review' do
      allow(CodeReviewer).to receive(:new).and_return(example_code_reviewer)
      allow(subject).to receive(:repository_service) { instance_double('GithubService') }
      expect(example_code_reviewer).to receive(:review_pull_request).with(repository_id: 2, pull_request_id: 7, repo_name: 'a', repo_url: 'abc')
      subject.github_pull_request(payload)
    end
  end
end
