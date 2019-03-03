# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SearchResultOrganizer, type: :model do
  let(:raw_results) { JSON.parse(file_fixture('semantic_search_response.json').read)['results'] }
  describe '#organize_search_results' do
    context 'when the results are randomly ordered' do
      subject { SearchResultOrganizer.new.organize_search_results(results: raw_results.shuffle) }
      it 'orders the search results by distance' do
        expect(subject).to eq([{ 'distance' => 0.5385, 'function_blob' => "def _run_sql_query(self, sql):\n    if not self.utils.sql_url:\n        Log.error(\n            'This test requires a `sql_url` parameter in the settings file')\n    test = Data(data=simple_test_data)\n    self.utils.fill_container(test)\n    sql = sql.replace(TEST_TABLE, test.query['from'])\n    url = URL(self.utils.sql_url)\n    response = self.utils.post_till_response(str(url), json={'meta': {\n        'testing': True}, 'sql': sql})", 'nwo' => 'klahnakoski/ActiveData', 'url' => "https://github.com/klahnakoski/ActiveData/blob/master/tests/test_sql.py#L84\n" }, { 'distance' => 0.5403, 'function_blob' => "def execute_sql(self, query, *, explain=False):\n    if explain is True:\n        from ws.db.database import explain\n        result = self.db.engine.execute(explain(query))\n        print(query)\n        for row in result:\n            print(row[0])\n    return self.db.engine.execute(query)\n", 'nwo' => 'lahwaacz/wiki-scripts', 'url' => "https://github.com/lahwaacz/wiki-scripts/blob/master/ws/db/selects/SelectBase.py#L32\n" }, { 'distance' => 0.5524, 'function_blob' => "def execute_query_on_table(filedb, tablename, post_process_func,\n    expected_result):\n    results = filedb.execute_query(tablename, 10, post_process_func=\n        post_process_func)\n    assert results.fetchall() == expected_result\n", 'nwo' => 'iagcl/data_pipeline', 'url' => "https://github.com/iagcl/data_pipeline/blob/master/tests/db/test_filedb.py#L85\n" }])
      end
      it { expect(subject.length).to eq(3) }
    end
  end
end
