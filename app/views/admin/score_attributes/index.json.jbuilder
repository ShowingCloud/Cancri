json.array!(@score_attributes) do |sa|
  json.extract! sa, :name
  json.url score_attribute_url(sa, format: :json)
end