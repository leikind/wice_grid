require 'rails_helper'

describe Company do
  it { is_expected.to have_many(:supplier_projects)}
  it { is_expected.to have_many(:customer_projects)}
end
