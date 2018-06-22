require 'rails_helper'

describe Version do
  it { is_expected.to belong_to(:project)}
end
