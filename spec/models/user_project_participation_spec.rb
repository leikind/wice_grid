require 'rails_helper'

describe UserProjectParticipation do
  it { should belong_to(:user)}
  it { should belong_to(:project)}
  it { should belong_to(:project_role)}
end
