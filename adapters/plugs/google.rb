class Google
  def endpoint(address)
    "#{ENV['GOOGLE_ENDPOINT']}?address=#{address}&key=#{ENV['GOOGLE_API_KEY']}"
  end

  def has_no_results?(response)
    response.dig("status") == "ZERO_RESULTS"
  end

  def parsed_response(response)
    response["results"].map do |result|
      {
        latitude:  result["geometry"]["location"]["lat"],
        longitude: result["geometry"]["location"]["lng"],
        formatted: result["formatted_address"],
        types:     result["types"]
      }
    end
  end
end
