json.array!(@consults) do |consult|
  json.extract! consult,
  json.url consult_url(consult, format: :json)
end