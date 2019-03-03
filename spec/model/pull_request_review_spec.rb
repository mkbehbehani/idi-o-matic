# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PullRequestReview, type: :model do
  # validation specs below are needed due to an attr_reader bug in shoulda: https://github.com/thoughtbot/shoulda-matchers/issues/764
  describe '#initialize' do
    context 'with repo_id: 3' do
      subject { PullRequestReview.new(attributes_for(:pull_request_review).merge(repo_id: 3)) }
      it { is_expected.to have_attributes(repo_id: 3) }
      it { is_expected.to be_valid }
    end
    context 'with a non-numeric repo_id' do
      it { expect { PullRequestReview.new(attributes_for(:pull_request_review).merge(repo_id: 'abcd')) }.to raise_error(ActiveModel::ValidationError) }
    end
    context 'without a repo_id' do
      it { expect { PullRequestReview.new(attributes_for(:pull_request_review).merge(repo_id: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
    context 'with pr_number: 3' do
      subject { PullRequestReview.new(attributes_for(:pull_request_review).merge(pr_number: 3)) }
      it { is_expected.to have_attributes(pr_number: 3) }
      it { is_expected.to be_valid }
    end
    context 'with a non-numeric pr_number' do
      it { expect { PullRequestReview.new(attributes_for(:pull_request_review).merge(pr_number: 'abcd')) }.to raise_error(ActiveModel::ValidationError) }
    end
    context 'without a pr_number' do
      it { expect { PullRequestReview.new(attributes_for(:pull_request_review).merge(pr_number: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
    context "with a repo_full_name: 'example/repo'" do
      subject { PullRequestReview.new(attributes_for(:pull_request_review).merge(repo_full_name: 'example/repo')) }
      it { is_expected.to have_attributes(repo_full_name: 'example/repo') }
      it { is_expected.to be_valid }
    end
    context 'without a repo_full_name' do
      it { expect { PullRequestReview.new(attributes_for(:pull_request_review).merge(repo_full_name: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
    context 'with comments' do
      let(:example_comments) { build_list(:pull_request_review_comment, 2) }
      subject { PullRequestReview.new(attributes_for(:pull_request_review).merge(comments: example_comments)) }
      it 'has the expected comments' do
        is_expected.to have_attributes(comments: example_comments)
      end
    end
    context 'without comments' do
      it { expect { PullRequestReview.new(attributes_for(:pull_request_review).merge(comments: [])) }.to raise_error(ActiveModel::ValidationError) }
      it { expect { PullRequestReview.new(attributes_for(:pull_request_review).merge(comments: nil)) }.to raise_error(ActiveModel::ValidationError) }
    end
  end
end
