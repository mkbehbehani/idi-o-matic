# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CodeReviewer, type: :model do
  let(:example_pull_request_review) { instance_double('PullRequestReview') }
  let(:example_code_analyzer) { instance_double('CodeAnalyzer') }
  let(:example_repository_service) { instance_double('GithubService') }
  let(:example_commits) { [{ message: 'message 1', sha: 'sha1' }, { message: 'message 2', sha: 'sha2' }] }
  let(:example_code_descriptions) { ['message 1', 'message 2'] }
  let(:example_code_analyses) { [[{ 'distance' => 0.5385, 'function_blob' => 'function blob 1', 'nwo' => 'klahnakoski/ActiveData', 'url' => 'https://github.com/klahnakoski/ActiveData/blob/master/tests/test_sql.py#L84' }], [{ 'distance' => 0.5403, 'function_blob' => 'function blob 2', 'nwo' => 'lahwaacz/wiki-scripts', 'url' => 'https://github.com/lahwaacz/wiki-scripts/blob/master/ws/db/selects/SelectBase.py#L32' }]] }
  subject { CodeReviewer.new(repository_service: example_repository_service, code_analyzer: example_code_analyzer) }

  it 'has a repository service' do
    expect(subject.repository_service).to eq(example_repository_service)
  end
  context 'without a repository service' do
    it { expect { CodeReviewer.new(repository_service: nil, code_analyzer: example_code_analyzer) }.to raise_error(ActiveModel::ValidationError) }
  end
  it 'has a code analyzer' do
    expect(subject.code_analyzer).to eq(example_code_analyzer)
  end
  context 'without a code analyzer' do
    it { expect { CodeReviewer.new(repository_service: example_repository_service, code_analyzer: nil) }.to raise_error(ActiveModel::ValidationError) }
  end
  describe '#review_pull_request' do
    before(:each) do
      allow(example_repository_service).to receive(:get_commit_messages).with('alpha/beta', 456).and_return(example_commits)
      allow(example_code_analyzer).to receive(:analyze_code).with(code_descriptions: example_code_descriptions).and_return(example_code_analyses)
      allow_any_instance_of(CodeReviewer).to receive(:justification_for_recommendation).and_return(attributes_for(:justification))
      allow(CodeRecommendationComment).to receive(:new).and_return(nil)
      allow(example_repository_service).to receive(:sync_pull_request_review)
      allow(example_pull_request_review).to receive(:repo_full_name) { 'alpha/beta' }
      allow(example_pull_request_review).to receive(:pr_number) { 456 }
      allow(example_pull_request_review).to receive(:comments) { %w[1 2] }
    end
    subject { CodeReviewer.new(repository_service: example_repository_service, code_analyzer: example_code_analyzer).review_pull_request(repository_id: 123, pull_request_id: 456, repo_name: 'alpha/beta', repo_url: 'https://www.github.com/alpha/beta') }
    it 'gets the pull request commit messages' do
      expect(example_repository_service).to receive(:get_commit_messages).exactly(:once).with('alpha/beta', 456)
      subject
    end
    it 'sends the commit messages to the CodeAnalyzer' do
      allow(example_repository_service).to receive(:get_commit_messages).with('alpha/beta', 456).and_return(example_commits)
      expect(example_code_analyzer).to receive(:analyze_code).with(code_descriptions: example_code_descriptions)
      subject
    end
    it 'uses the commit analyses to create code recommendation comments' do
      expect(CodeRecommendationComment).to receive(:new).with(repo_name: 'klahnakoski/ActiveData', repo_url: 'https://github.com/klahnakoski/ActiveData/blob/master/tests/test_sql.py#L84', commit_message: 'message 1', commit_sha: 'sha1', code_sample: 'function blob 1').ordered
      expect(CodeRecommendationComment).to receive(:new).with(repo_name: 'lahwaacz/wiki-scripts', repo_url: 'https://github.com/lahwaacz/wiki-scripts/blob/master/ws/db/selects/SelectBase.py#L32', commit_message: 'message 2', commit_sha: 'sha2', code_sample: 'function blob 2').ordered
      subject
    end
    it 'puts the code recommendation comments into a pull request review' do
      allow(CodeRecommendationComment).to receive(:new).with(repo_name: 'klahnakoski/ActiveData', repo_url: 'https://github.com/klahnakoski/ActiveData/blob/master/tests/test_sql.py#L84', commit_message: 'message 1', commit_sha: 'sha1', code_sample: 'function blob 1').and_return('comment 1')
      allow(CodeRecommendationComment).to receive(:new).with(repo_name: 'lahwaacz/wiki-scripts', repo_url: 'https://github.com/lahwaacz/wiki-scripts/blob/master/ws/db/selects/SelectBase.py#L32', commit_message: 'message 2', commit_sha: 'sha2', code_sample: 'function blob 2').and_return('comment 2')
      allow_any_instance_of(Justification).to receive(:to_s).and_return(', justification comment')
      allow(PullRequestReview).to receive(:new).and_return(example_pull_request_review)
      expect(PullRequestReview).to receive(:new).with(repo_id: 123, pr_number: 456, repo_full_name: 'alpha/beta', comments: ['comment 1, justification comment', 'comment 2, justification comment'])
      subject
    end
    it 'sends the pull request review to the repository service for syncing' do
      allow(PullRequestReview).to receive(:new).and_return(example_pull_request_review)
      expect(example_repository_service).to receive(:sync_pull_request_review).with(repo_full_name: example_pull_request_review.repo_full_name, pr_number: example_pull_request_review.pr_number, comments: example_pull_request_review.comments)
      subject
    end
  end
end
