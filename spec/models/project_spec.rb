require 'rails_helper'

describe Project do
  it {should have_many(:tasks)}
  it { should have_many(:tasks)}
  it { should have_many(:user_project_participations)}
  it { should have_many(:users)}
  it { should have_many(:versions)}
  it { should belong_to(:customer)}
  it { should belong_to(:supplier)}
end
