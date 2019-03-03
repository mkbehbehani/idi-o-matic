# frozen_string_literal: true

class CodeSearcher
  def find_similar_code(code_description:, limit: 3)
    response = Net::HTTP.start(experimental_search_uri.hostname, experimental_search_uri.port, use_ssl: true) do |http|
      http.request(build_experimental_search_request(code_description))
    end
    JSON.parse(response.body)['results'].take(limit)
  end

  private

  def build_experimental_search_request(code_description)
    request = Net::HTTP::Post.new(experimental_search_uri)
    request.content_type = 'application/json'
    request['Origin'] = 'https://experiments.github.com'
    request['Accept'] = 'application/json'
    request['Referer'] = 'https://experiments.github.com/semantic-code-search'
    request['Connection'] = 'keep-alive'
    request.body = JSON.dump(
      'query' => code_description
    )
    request
  end

  def experimental_search_uri
    URI.parse('https://experiments.github.com/search/')
  end
end
