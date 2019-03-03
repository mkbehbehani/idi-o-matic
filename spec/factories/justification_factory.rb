# frozen_string_literal: true

FactoryBot.define do
  factory :justification do
    match { Faker::Number.decimal(1, 2) }
    forks_count { Faker::Number.between(50, 1000) }
    stargazers_count { Faker::Number.between(50, 1000) }
    organization_followers_count { Faker::Number.number(4) }
    influential_org { Faker::Boolean.boolean }
    org_name { Faker::Lorem.word }
    repo_name { Faker::Lorem.word }
    initialize_with { new(match: match, forks_count: forks_count, stargazers_count: stargazers_count, organization_followers_count: organization_followers_count, influential_org: influential_org, org_name: org_name, repo_name: repo_name) }
  end
end
