if @errors
  json.errors do
    json.array! @errors
  end
else
  json.ark do
    json.partial! '/arks/ark', ark: @ark
  end
end
