require 'rails_helper'

describe User do
  it { is_expected.to have_many(:created_tasks)}


  it { is_expected.to have_and_belong_to_many(:assigned_tasks)}


  it { is_expected.to have_many(:user_project_participations)}
  it { is_expected.to have_many(:projects)}
end
