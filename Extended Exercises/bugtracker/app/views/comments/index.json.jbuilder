json.array!(@comments) do |comment|
  json.extract! comment, :id, :author_id, :bug_id, :body
  json.url comment_url(comment, format: :json)
end
