require 'rails_helper'

describe Priority do
  it { is_expected.to have_many(:tasks)}

end
