require 'rails_helper'

describe Bug do
  it { should belong_to(:reporter) }
  it { should belong_to(:assignee) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }

  it 'validates associated reporter' do
    bug = Bug.new(title: 'foo', description: 'bar')
    bug.build_reporter(id: 9999, email: nil)
    expect(bug.save).to(eq false)
    expect(bug.errors.full_messages_for(:reporter)[0]).to(eq 'Reporter is invalid')
  end
end
