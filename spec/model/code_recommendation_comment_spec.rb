# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CodeRecommendationComment, type: :model do
  subject { CodeRecommendationComment.new(repo_name: 'alpha/beta', repo_url: 'https://www.github.com/alpha/beta', commit_message: 'example message', commit_sha: '123', code_sample: 'example code') }
  it 'returns a review comment' do
    expect(subject.to_s).to eq("Here's how the [alpha/beta](https://www.github.com/alpha/beta) repo has done something similar to 'example message' in 123: \n```\nexample code\n```\n")
  end
  context 'with a blank repo_name' do
    it { expect { CodeRecommendationComment.new(attributes_for(:code_recommendation_comment).merge(repo_name: '')) }.to raise_error(ActiveModel::ValidationError) }
  end
  context 'with a blank repo_url' do
    it { expect { CodeRecommendationComment.new(attributes_for(:code_recommendation_comment).merge(repo_url: '')) }.to raise_error(ActiveModel::ValidationError) }
  end
  context 'with a blank commit_message' do
    it { expect { CodeRecommendationComment.new(attributes_for(:code_recommendation_comment).merge(commit_message: '')) }.to raise_error(ActiveModel::ValidationError) }
  end
  context 'with a blank commit_sha' do
    it { expect { CodeRecommendationComment.new(attributes_for(:code_recommendation_comment).merge(commit_sha: '')) }.to raise_error(ActiveModel::ValidationError) }
  end
  context 'with a blank code_sample' do
    it { expect { CodeRecommendationComment.new(attributes_for(:code_recommendation_comment).merge(code_sample: '')) }.to raise_error(ActiveModel::ValidationError) }
  end
end
