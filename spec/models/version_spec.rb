require 'rails_helper'

describe Version do
  it { should belong_to(:project)}
end
