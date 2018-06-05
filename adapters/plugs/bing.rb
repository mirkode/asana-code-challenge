class Bing
  def endpoint(address)
    [
      ENV['BING_ENDPOINT'],
      "?query=#{address}",
      "&key=#{ENV['BING_API_KEY']}"
    ].join
  end

  def parse_response(response)
    # ...
  end
end
