# frozen_string_literal: true

class SearchResultOrganizer
  def organize_search_results(results:)
    results.each { |result| result['distance'] = (result['distance']).to_f }.sort_by { |r| r['distance'] }.take(3)
  end
end
