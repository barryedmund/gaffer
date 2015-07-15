json.array!(@teams) do |team|
  json.extract! team, :id, :title
  json.url team_url(team, format: :json)
end
