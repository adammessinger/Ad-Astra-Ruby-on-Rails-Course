# require 'rails_helper'
#
# RSpec.describe "comments/new", type: :view do
#   before(:each) do
#     assign(:comment, Comment.new(
#       :author_id => 1,
#       :bug_id => 1,
#       :body => "MyText"
#     ))
#   end
#
#   it "renders new comment form" do
#     render
#
#     assert_select "form[action=?][method=?]", comments_path, "post" do
#
#       assert_select "input#comment_author_id[name=?]", "comment[author_id]"
#
#       assert_select "input#comment_bug_id[name=?]", "comment[bug_id]"
#
#       assert_select "textarea#comment_body[name=?]", "comment[body]"
#     end
#   end
# end
