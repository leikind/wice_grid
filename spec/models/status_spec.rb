require 'rails_helper'

describe Status do
  it {is_expected.to have_many(:tasks) }
end

