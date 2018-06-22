require 'rails_helper'

describe Project do
  it {is_expected.to have_many(:tasks)}
  it { is_expected.to have_many(:tasks)}
  it { is_expected.to have_many(:user_project_participations)}
  it { is_expected.to have_many(:users)}
  it { is_expected.to have_many(:versions)}
  it { is_expected.to belong_to(:customer)}
  it { is_expected.to belong_to(:supplier)}
end
