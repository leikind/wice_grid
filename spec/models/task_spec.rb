require 'rails_helper'

describe Task do
  it { should belong_to(:created_by)}
  it { should belong_to(:project)}
  it { should belong_to(:priority)}
  it { should belong_to(:status)}
  it { should belong_to(:relevant_version)}
  it { should belong_to(:expected_version)}

  it { should have_and_belong_to_many(:assigned_users)}
end
