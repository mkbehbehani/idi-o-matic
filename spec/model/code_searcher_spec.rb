# frozen_string_literal: true

require 'rails_helper'
require 'net/http'

RSpec.describe CodeSearcher, type: :model do
  let(:successful_search_response) { File.new('spec/fixtures/semantic-search-fixture.txt') }
  before(:context) do
    WebMock.disable_net_connect!
  end
  before(:each) do
    stub_request(:post, 'https://experiments.github.com/search/')
      .with(body: '{"query":"execute sql query and return results"}',
            headers: { 'Accept' => 'application/json', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Connection' => 'keep-alive', 'Content-Type' => 'application/json', 'Host' => 'experiments.github.com', 'Origin' => 'https://experiments.github.com', 'Referer' => 'https://experiments.github.com/semantic-code-search', 'User-Agent' => 'Ruby' })
      .to_return(successful_search_response)
  end

  describe '#find_similar_code' do
    subject { CodeSearcher.new.find_similar_code(code_description: 'execute sql query and return results') }
    it "returns the top results from GitHub's experimental search" do
      expect(subject).to eq([{ 'distance' => '0.5385', 'function_blob' => "def _run_sql_query(self, sql):\n    if not self.utils.sql_url:\n        Log.error(\n            'This test requires a `sql_url` parameter in the settings file')\n    test = Data(data=simple_test_data)\n    self.utils.fill_container(test)\n    sql = sql.replace(TEST_TABLE, test.query['from'])\n    url = URL(self.utils.sql_url)\n    response = self.utils.post_till_response(str(url), json={'meta': {\n        'testing': True}, 'sql': sql})", 'nwo' => 'klahnakoski/ActiveData', 'url' => "https://github.com/klahnakoski/ActiveData/blob/master/tests/test_sql.py#L84\n" }, { 'distance' => '0.5403', 'function_blob' => "def execute_sql(self, query, *, explain=False):\n    if explain is True:\n        from ws.db.database import explain\n        result = self.db.engine.execute(explain(query))\n        print(query)\n        for row in result:\n            print(row[0])\n    return self.db.engine.execute(query)\n", 'nwo' => 'lahwaacz/wiki-scripts', 'url' => "https://github.com/lahwaacz/wiki-scripts/blob/master/ws/db/selects/SelectBase.py#L32\n" }, { 'distance' => '0.5524', 'function_blob' => "def execute_query_on_table(filedb, tablename, post_process_func,\n    expected_result):\n    results = filedb.execute_query(tablename, 10, post_process_func=\n        post_process_func)\n    assert results.fetchall() == expected_result\n", 'nwo' => 'iagcl/data_pipeline', 'url' => "https://github.com/iagcl/data_pipeline/blob/master/tests/db/test_filedb.py#L85\n" }])
    end
  end
end
