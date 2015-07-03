require 'rails_helper'

describe User do
  it { should have_many(:reports) }
  it { should have_many(:assignments) }
  it { should have_many(:comments) }
end
