json.array!(@bugs) do |bug|
  json.extract! bug, :id, :title, :description, :tags, :closed
  json.url bug_url(bug, format: :json)
end
