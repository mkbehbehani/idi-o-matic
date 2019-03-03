# frozen_string_literal: true

class CodeAnalyzer
  include ActiveModel::Validations
  validates_presence_of :code_recommender
  attr_reader :code_recommender

  def initialize(code_recommender:)
    @code_recommender = code_recommender
    validate!
  end

  def analyze_code(code_descriptions:)
    code_descriptions.map { |description| code_recommender.recommend_code(code_description: description) }
  end
end
