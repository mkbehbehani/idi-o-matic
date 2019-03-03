# frozen_string_literal: true

FactoryBot.define do
  factory :pull_request_review do
    repo_id { Faker::Number.number(3) }
    pr_number { Faker::Number.number(3) }
    repo_full_name { "#{Faker::Lorem.word}/#{Faker::Lorem.word}" }
    comments { build_list(:pull_request_review_comment, 2) }
    initialize_with { new(repo_id: repo_id, pr_number: pr_number, repo_full_name: repo_full_name, comments: comments) }
  end
end
