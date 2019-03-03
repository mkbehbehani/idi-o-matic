# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request_review_comment do
    pull_request_id { Faker::Number.number(3) }
    repo_full_name { "#{Faker::Lorem.word}/#{Faker::Lorem.word}" }
    body { Faker::Lorem.sentence }
    commit_id { Faker::Crypto.sha256 }
    path { "#{Faker::Lorem.word}/#{Faker::Lorem.word}.md" }
    position { Faker::Number.number(2) }
    initialize_with { new(pull_request_id: pull_request_id, repo_full_name: repo_full_name, body: body, commit_id: commit_id, path: path, position: position) }
  end
end
