class HtmlDocumentNotFound < StandardError; end

class GetHtmlDocument
  ZEN_ROWS_API_KEY = "ed99895737ff355d8eb66eabe86ecfd4bb39a78c".freeze # TOD0: move API key outside of the repo

  def initialize(url)
    @url = url
  end

  def call
    Nokogiri::HTML(zen_rows_get_with_caching)
  end

  protected

  # Some pages may be protected by security tools like Cloudflare
  # And regular HTTP requests will be blocked and return 403 Forbidden
  # To bypass the security check, we need to use ZenRows
  def zen_rows_get
    proxy = "http://#{ZEN_ROWS_API_KEY}:@proxy.zenrows.com:8001"
    connection = Faraday.new(proxy:, ssl: { verify: false })
    connection.options.timeout = 180

    response = connection.get(@url, nil, nil)

    raise(HtmlDocumentNotFound, 'The specified page cannot be found') unless response.status == 200

    response.body
  end

  def zen_rows_get_with_caching
    Rails.cache.fetch(@url, expires_in: 6.hours) { zen_rows_get }
  end
end
