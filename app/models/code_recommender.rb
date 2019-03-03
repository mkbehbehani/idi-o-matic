# frozen_string_literal: true

class CodeRecommender
  include ActiveModel::Validations
  validates_presence_of :code_searcher, :search_result_organizer
  attr_reader :code_searcher, :search_result_organizer

  def initialize(code_searcher:, search_result_organizer:)
    @code_searcher = code_searcher
    @search_result_organizer = search_result_organizer
    validate!
  end

  def recommend_code(code_description:)
    search_results = code_searcher.find_similar_code(code_description: code_description)
    search_result_organizer.organize_search_results(results: search_results)
  end
end
