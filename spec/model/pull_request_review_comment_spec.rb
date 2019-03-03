# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PullRequestReviewComment, type: :model do
  describe '#initialize' do
    context 'with pull_request_id: 3' do
      subject { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(pull_request_id: 3)) }
      it { is_expected.to have_attributes(pull_request_id: 3) }
      it { is_expected.to be_valid }
    end

    context 'with a non-numeric pull_request_id' do
      it { expect { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(pull_request_id: 'abcd')) }.to raise_error(ActiveModel::ValidationError) }
    end

    context 'without a pull_request_id' do
      it { expect { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(pull_request_id: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
    context "with a repo_full_name: 'example/repo'" do
      subject { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(repo_full_name: 'example/repo')) }
      it { is_expected.to have_attributes(repo_full_name: 'example/repo') }
      it { is_expected.to be_valid }
    end
    context 'without a repo_full_name' do
      it { expect { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(repo_full_name: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
    context "with a body: 'hi'" do
      subject { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(body: 'hi')) }
      it { is_expected.to have_attributes(body: 'hi') }
      it { is_expected.to be_valid }
    end
    context 'without a body' do
      it { expect { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(body: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
    context "with commit_id: 'd670460b4b4aece5915caf5c68d12f560a9fe3e4'" do
      subject { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(commit_id: 'd670460b4b4aece5915caf5c68d12f560a9fe3e4')) }
      it { is_expected.to have_attributes(commit_id: 'd670460b4b4aece5915caf5c68d12f560a9fe3e4') }
      it { is_expected.to be_valid }
    end
    context 'without a commit_id' do
      it { expect { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(commit_id: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
    context "with path: 'example/path.md'" do
      subject { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(path: 'example/path.md')) }
      it { is_expected.to have_attributes(path: 'example/path.md') }
      it { is_expected.to be_valid }
    end
    context 'without path' do
      it { expect { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(path: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end

    context 'with position: 21' do
      subject { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(position: 21)) }
      it { is_expected.to have_attributes(position: 21) }
      it { is_expected.to be_valid }
    end

    context 'with a non-numeric position' do
      it { expect { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(position: 'abcd')) }.to raise_error(ActiveModel::ValidationError) }
    end

    context 'without a position' do
      it { expect { PullRequestReviewComment.new(attributes_for(:pull_request_review_comment).merge(position: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
  end
end
