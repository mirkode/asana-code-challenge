class OSM
  def endpoint(address)
    "#{ENV['OSM_ENDPOINT']}?q=#{address}&format=json&addressdetails=1"
  end

  def has_no_results?(response)
    response.empty?
  end

  def parsed_response(response)
    response.map do |result|
      {
        latitude:  result["lat"].to_f,
        longitude: result["lon"].to_f,
        formatted: format_address(result["address"])
      }
    end
  end

  def format_address(details)
    # Note:
    # The 'city' line is due to some really detailed mapping by OSM.
    # The response does not necessarily include a city field.
    [
      "#{details['road']} #{details['house_number']}",
      "#{details['postcode']} #{details['city'] || details['county'] || details['state']}",
      details["country"]
    ].join(', ')
  end
end
