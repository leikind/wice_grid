require 'rails_helper'

describe User do
  it { should have_many(:created_tasks)}


  it { should have_and_belong_to_many(:assigned_tasks)}


  it { should have_many(:user_project_participations)}
  it { should have_many(:projects)}
end
