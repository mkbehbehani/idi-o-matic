# frozen_string_literal: true

FactoryBot.define do
  factory :code_recommendation_comment do
    commit_message { Faker::Lorem.sentence }
    commit_sha { Faker::Crypto.sha256 }
    repo_name { "#{Faker::Lorem.word}/#{Faker::Lorem.word}" }
    repo_url { Faker::Internet.url }
    code_sample { Faker::Lorem.sentence }
  end
end
