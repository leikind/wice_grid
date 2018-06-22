require 'rails_helper'

describe UserProjectParticipation do
  it { is_expected.to belong_to(:user)}
  it { is_expected.to belong_to(:project)}
  it { is_expected.to belong_to(:project_role)}
end
