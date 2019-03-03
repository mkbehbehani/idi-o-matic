# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CodeAnalyzer, type: :model do
  let(:example_code_recommender) { instance_double('CodeRecommender') }
  let(:example_code_descriptions) { %w[description1 description2 description3] }
  subject { CodeAnalyzer.new(code_recommender: example_code_recommender) }

  it 'has a code recommender' do
    expect(subject.code_recommender).to eq(example_code_recommender)
  end
  context 'without a code recommender' do
    it { expect { CodeAnalyzer.new(code_recommender: nil) }.to raise_error(ActiveModel::ValidationError) }
  end

  describe '#analyze_code' do
    subject do
      CodeAnalyzer.new(code_recommender: example_code_recommender)
                  .analyze_code(code_descriptions: example_code_descriptions)
    end
    it 'sends each description to the code recommender' do
      expect(example_code_recommender).to receive(:recommend_code).with(code_description: 'description1')
      expect(example_code_recommender).to receive(:recommend_code).with(code_description: 'description2')
      expect(example_code_recommender).to receive(:recommend_code).with(code_description: 'description3')
      subject
    end
    it 'returns code recommendations for each description' do
      allow(example_code_recommender).to receive(:recommend_code).with(code_description: 'description1') { 'recommendation1' }
      allow(example_code_recommender).to receive(:recommend_code).with(code_description: 'description2') { 'recommendation2' }
      allow(example_code_recommender).to receive(:recommend_code).with(code_description: 'description3') { 'recommendation3' }
      expect(subject).to eq(%w[recommendation1 recommendation2 recommendation3])
    end
  end
end
