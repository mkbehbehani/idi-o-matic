# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubService, type: :model do
  let(:example_installation_id) { 'hi' }
  let(:example_pull_request_review) { OpenStruct.new(attributes_for(:pull_request_review)) }
  let(:example_github_access_token_response) { { token: 'abc' } }
  let(:example_repo_id) { 123 }
  let(:example_pr_number) { 456 }
  let(:example_sha_1) { Faker::Crypto.sha256 }
  let(:example_sha_2) { Faker::Crypto.sha256 }
  before(:context) do
    WebMock.disable_net_connect!
  end
  subject { GithubService.new(installation_id: example_installation_id) }
  before(:each) do
    @app_level_octokit = object_double(Octokit::Client.new, create_app_installation_access_token: example_github_access_token_response, create_pull_request_review: true)
    @octokit = class_double('Octokit::Client').as_stubbed_const
    allow(@octokit).to receive(:new).and_return(@app_level_octokit)
    allow(JWT).to receive(:encode) { 'example JWT' }
    commits = [instance_double('Sawyer::Resource', to_attrs: { sha: 'sha1', commit: { message: 'message 1' } }), instance_double('Sawyer::Resource', to_attrs: { sha: 'sha2', commit: { message: 'message 2' } })]
    allow(@app_level_octokit).to receive(:pull_request_commits).with(example_repo_id, example_pr_number, {}).and_return(commits)
    allow(@app_level_octokit).to receive(:pull_request).with(example_repo_id, example_pr_number).and_return(commits)
  end
  context 'with a blank installation_id' do
    it { expect { GithubService.new(installation_id: '') }.to raise_error(ActiveModel::ValidationError) }
  end

  describe '#sync_pull_request_review' do
    it 'creates a pull request review on github' do
      expect(@app_level_octokit).to receive(:create_pull_request_review).with(example_pull_request_review.repo_full_name,
                                                                              example_pull_request_review.pr_number,
                                                                              body: example_pull_request_review.comments.join("\n"), event: 'COMMENT')
      subject.sync_pull_request_review(repo_full_name: example_pull_request_review.repo_full_name,
                                       pr_number: example_pull_request_review.pr_number,
                                       comments: example_pull_request_review.comments)
    end
    describe 'lazily initializes the GitHub connection dependencies' do
      context 'on first invocation' do
        subject do
          GithubService.new(installation_id: example_installation_id)
                       .sync_pull_request_review(repo_full_name: example_pull_request_review.repo_full_name,
                                                 pr_number: example_pull_request_review.pr_number,
                                                 comments: example_pull_request_review.comments)
        end
        it 'creates a JWT for the application' do
          example_private_key = Rails.configuration.github_private_key
          expected_iat = Time.now.to_i
          expected_expiration = Time.now.to_i + (10 * 60)
          expected_iss = 1
          expect(JWT).to receive(:encode).with({ iat: expected_iat, exp: expected_expiration, iss: expected_iss }, example_private_key, 'RS256')
          subject
        end
        it 'creates an app-level GitHub client' do
          expect(@octokit).to receive(:new).with(bearer_token: 'example JWT')
          subject
        end
        it 'creates a GitHub app installation token' do
          expect(@app_level_octokit).to receive(:create_app_installation_access_token).with(example_installation_id)
          subject
        end

        it 'creates an installation-level GitHub client' do
          expect(@octokit).to receive(:new).with(bearer_token: 'example JWT').ordered # needed due to the 2-stage calls to @octokit
          expect(@octokit).to receive(:new).with(bearer_token: 'abc').ordered
          subject
        end
      end
      context 'on subsequent invocations' do
        let(:service) { GithubService.new(installation_id: example_installation_id) }
        subject do
          service.sync_pull_request_review(repo_full_name: example_pull_request_review.repo_full_name,
                                           pr_number: example_pull_request_review.pr_number,
                                           comments: example_pull_request_review.comments)
          service.sync_pull_request_review(repo_full_name: example_pull_request_review.repo_full_name,
                                           pr_number: example_pull_request_review.pr_number,
                                           comments: example_pull_request_review.comments)
        end
        it 'does not attempt to recreate a JWT for the application' do
          example_private_key = Rails.configuration.github_private_key
          allow(OpenSSL::PKey::RSA).to receive(:new) { example_private_key }
          jwt = class_double(JWT).as_stubbed_const
          expected_iat = Time.now.to_i
          expected_expiration = Time.now.to_i + (10 * 60)
          expected_iss = 1
          expect(jwt).to receive(:encode).with({ iat: expected_iat, exp: expected_expiration, iss: expected_iss }, example_private_key, 'RS256').once
          subject
        end
        it 'does not attempt to recreate an app-level GitHub client' do
          expect(@octokit).to receive(:new).with(bearer_token: 'example JWT').once
          subject
        end
        it 'does not attempt to recreate a GitHub app installation token' do
          expect(@app_level_octokit).to receive(:create_app_installation_access_token).with(example_installation_id).once
          subject
        end

        it 'does not attempt to recreate an installation-level GitHub client' do
          expect(@octokit).to receive(:new).with(bearer_token: 'example JWT').ordered.once # needed due to the 2-stage calls to @octokit
          expect(@octokit).to receive(:new).with(bearer_token: 'abc').ordered.once
          subject
        end
      end
    end
  end
  describe '#get_commit_messages' do
    it "retrieves the GitHub pull request's commit messages" do
      expect(@app_level_octokit).to receive(:pull_request_commits).with(example_repo_id, example_pr_number, {})
      subject.get_commit_messages(example_repo_id, example_pr_number)
    end
    it "extracts the GitHub pull request's commit messages from the response" do
      expect(subject.get_commit_messages(example_repo_id, example_pr_number)).to eq([{ message: 'message 1', sha: 'sha1' }, { message: 'message 2', sha: 'sha2' }])
    end
    describe 'lazily initializes the GitHub connection dependencies' do
      context 'on first invocation' do
        it 'creates a JWT for the application' do
          example_private_key = Rails.configuration.github_private_key
          allow(OpenSSL::PKey::RSA).to receive(:new) { example_private_key }
          jwt = class_double(JWT).as_stubbed_const
          expected_iat = Time.now.to_i
          expected_expiration = Time.now.to_i + (10 * 60)
          expected_iss = 1
          expect(jwt).to receive(:encode).with({ iat: expected_iat, exp: expected_expiration, iss: expected_iss }, example_private_key, 'RS256')
          subject.get_commit_messages(example_repo_id, example_pr_number)
        end
        it 'creates an app-level GitHub client' do
          expect(@octokit).to receive(:new).with(bearer_token: 'example JWT')
          subject.get_commit_messages(example_repo_id, example_pr_number)
        end
        it 'creates a GitHub app installation token' do
          expect(@app_level_octokit).to receive(:create_app_installation_access_token).with(example_installation_id)
          subject.get_commit_messages(example_repo_id, example_pr_number)
        end

        it 'creates an installation-level GitHub client' do
          expect(@octokit).to receive(:new).with(bearer_token: 'example JWT').ordered # needed due to the 2-stage calls to @octokit
          expect(@octokit).to receive(:new).with(bearer_token: 'abc').ordered
          subject.get_commit_messages(example_repo_id, example_pr_number)
        end
      end
      context 'on subsequent invocations' do
        it 'does not attempt to recreate a JWT for the application' do
          example_private_key = Rails.configuration.github_private_key
          allow(OpenSSL::PKey::RSA).to receive(:new) { example_private_key }
          jwt = class_double(JWT).as_stubbed_const
          expected_iat = Time.now.to_i
          expected_expiration = Time.now.to_i + (10 * 60)
          expected_iss = 1
          expect(jwt).to receive(:encode).with({ iat: expected_iat, exp: expected_expiration, iss: expected_iss }, example_private_key, 'RS256').once
          subject.get_commit_messages(example_repo_id, example_pr_number)
          subject.get_commit_messages(example_repo_id, example_pr_number)
        end
        it 'does not attempt to recreate an app-level GitHub client' do
          expect(@octokit).to receive(:new).with(bearer_token: 'example JWT').once
          subject.get_commit_messages(example_repo_id, example_pr_number)
          subject.get_commit_messages(example_repo_id, example_pr_number)
        end
        it 'does not attempt to recreate a GitHub app installation token' do
          expect(@app_level_octokit).to receive(:create_app_installation_access_token).with(example_installation_id).once
          subject.get_commit_messages(example_repo_id, example_pr_number)
          subject.get_commit_messages(example_repo_id, example_pr_number)
        end

        it 'does not attempt to recreate an installation-level GitHub client' do
          expect(@octokit).to receive(:new).with(bearer_token: 'example JWT').ordered.once # needed due to the 2-stage calls to @octokit
          expect(@octokit).to receive(:new).with(bearer_token: 'abc').ordered.once
          subject.get_commit_messages(example_repo_id, example_pr_number)
          subject.get_commit_messages(example_repo_id, example_pr_number)
        end
      end
    end
  end
end
