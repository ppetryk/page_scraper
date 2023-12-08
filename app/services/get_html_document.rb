class GetHtmlDocument
  ZEN_ROWS_API_KEY = "ed99895737ff355d8eb66eabe86ecfd4bb39a78c".freeze

  def initialize(url)
    @url = url
  end

  def call
    Nokogiri::HTML(response_body(zen_rows_get))
  end

  protected

  # Some pages may be protected by security tools like Cloudflare
  # And regular HTTP requests will be blocked and return 403 Forbidden
  # To bypass the security check will need to use ZenRows
  def zen_rows_get
    proxy = "http://#{ZEN_ROWS_API_KEY}:@proxy.zenrows.com:8001"
    connection = Faraday.new(proxy: proxy, ssl: { verify: false })
    connection.options.timeout = 180

    connection.get(@url, nil, nil)
  end

  def response_body(response)
    response.status == 200 ? response.body : nil
  end
end
