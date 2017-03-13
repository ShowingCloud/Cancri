json.array!(@event_volunteers) do |role|
  json.extract! role, :name
  json.url event_volunteer_url(role, format: :json)
end