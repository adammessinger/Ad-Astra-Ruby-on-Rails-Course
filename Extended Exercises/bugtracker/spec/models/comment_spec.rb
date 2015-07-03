require 'rails_helper'

describe Comment, type: :model do
  it { should belong_to(:bug) }
  it { should belong_to(:author) }
end
