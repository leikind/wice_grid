require 'rails_helper'

describe Company do
  it { should have_many(:supplier_projects)}
  it { should have_many(:customer_projects)}
end
