require 'rails_helper'

describe Task do
  it { is_expected.to belong_to(:created_by)}
  it { is_expected.to belong_to(:project)}
  it { is_expected.to belong_to(:priority)}
  it { is_expected.to belong_to(:status)}
  it { is_expected.to belong_to(:relevant_version)}
  it { is_expected.to belong_to(:expected_version)}

  it { is_expected.to have_and_belong_to_many(:assigned_users)}
end
