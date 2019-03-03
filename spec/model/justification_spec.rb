# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Justification, type: :model do
  subject { Justification.new(match: 0.87, forks_count: 32, stargazers_count: 31, organization_followers_count: 1522, influential_org: true, org_name: 'alpha', repo_name: 'beta') }
  it 'returns a justification comment' do
    expect(subject.to_s).to eq("**Why is this being recommended?**\n* 87% match\n* Beta is a popular repo, with 31 stargazers and 32 forks.\n* Alpha is an influential organization.\n")
  end
  context 'with a low forks count' do
    describe 'does not mention the forks in the justification' do
      subject { Justification.new(attributes_for(:justification).merge(forks_count: 3)).to_s }
      it { is_expected.not_to include('forks') }
    end
  end
  context 'with an uninfluential organization' do
    describe "does not mention the organization's influence in the justification" do
      subject { Justification.new(attributes_for(:justification).merge(influential_org: false)).to_s }
      it { is_expected.not_to include('influential') }
    end
  end
  context 'with a blank match' do
    subject { Justification.new(attributes_for(:justification).merge(match: '')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a non-numeric match' do
    subject { Justification.new(attributes_for(:justification).merge(match: 'abcd')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a blank forks_count' do
    subject { Justification.new(attributes_for(:justification).merge(forks_count: '')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a non-numeric forks_count' do
    subject { Justification.new(attributes_for(:justification).merge(forks_count: 'abcd')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a blank stargazers_count' do
    subject { Justification.new(attributes_for(:justification).merge(stargazers_count: '')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a non-numeric stargazers_count' do
    subject { Justification.new(attributes_for(:justification).merge(stargazers_count: 'abcd')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a blank organization_followers_count' do
    subject { Justification.new(attributes_for(:justification).merge(organization_followers_count: '')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a non-numeric organization_followers_count' do
    subject { Justification.new(attributes_for(:justification).merge(organization_followers_count: 'abcd')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a blank org_name' do
    subject { Justification.new(attributes_for(:justification).merge(org_name: '')) }
    it { expect(subject).to_not be_valid }
  end
  context 'with a blank repo_name' do
    subject { Justification.new(attributes_for(:justification).merge(repo_name: '')) }
    it { expect(subject).to_not be_valid }
  end
end
