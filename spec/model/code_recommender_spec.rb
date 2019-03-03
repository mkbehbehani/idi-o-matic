# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CodeRecommender, type: :model do
  let(:example_code_searcher) { instance_double('CodeSearcher') }
  let(:example_search_result_organizer) { instance_double('SearchResultOrganizer') }
  let(:example_code_description) { 'add database config' }
  let(:example_search_results) { JSON.parse(file_fixture('semantic_search_response.json').read)['results'] }
  let(:example_organized_results) { %w[result1 result2 result3] }
  subject { CodeRecommender.new(code_searcher: example_code_searcher, search_result_organizer: example_search_result_organizer) }
  before do
    allow(example_code_searcher).to receive(:find_similar_code) { example_search_results }
    allow(example_search_result_organizer).to receive(:organize_search_results) { example_organized_results }
  end
  it 'has a code searcher' do
    expect(subject.code_searcher).to eq(example_code_searcher)
  end
  context 'without a code searcher' do
    it { expect { CodeRecommender.new(code_searcher: nil, search_result_organizer: example_search_result_organizer) }.to raise_error(ActiveModel::ValidationError) }
  end
  it 'has a search result organizer' do
    expect(subject.search_result_organizer).to eq(example_search_result_organizer)
  end
  context 'without a search result organizer' do
    it { expect { CodeRecommender.new(code_searcher: example_code_searcher, search_result_organizer: nil) }.to raise_error(ActiveModel::ValidationError) }
  end
  describe '#recommend_code' do
    it 'queries the code searcher for similar code' do
      expect(example_code_searcher).to receive(:find_similar_code).with(code_description: example_code_description)
      subject.recommend_code(code_description: example_code_description)
    end
    it 'sends the search results to an organizer' do
      expect(example_search_result_organizer).to receive(:organize_search_results).with(results: example_search_results)
      subject.recommend_code(code_description: example_code_description)
    end
    it 'returns the organized search results' do
      expect(subject.recommend_code(code_description: example_code_description)).to eq(example_organized_results)
    end
  end
end
