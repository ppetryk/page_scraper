class Api::BuildDataResponse
  SUCCESS_STATUS = 200
  BAD_REQUEST_STATUS = 400
  NOT_FOUND_STATUS = 404

  def initialize(params)
    @url, @fields = params[:url], params[:fields]
  end

  def call
    response = build_response
    [SUCCESS_STATUS, response]
  rescue HtmlDocumentNotFound => err
    [NOT_FOUND_STATUS, { 'error' => err.message }]
  rescue StandardError
    [BAD_REQUEST_STATUS, { 'error' => 'Something went wrong' }]
  end

  protected

  def document
    @document ||= GetHtmlDocument.new(@url).call
  end

  def scrapers
    return @scrapers if @scrapers

    @scrapers = []
    @scrapers << ScrapeHtml::CssSelector.new(document, css_selectors)
    @scrapers << ScrapeHtml::MetaTag.new(document, meta_tags)

    @scrapers
  end

  def css_selectors
    @fields.reject { |field| field == 'meta' }
  end

  def meta_tags
    @fields.select { |field| field == 'meta' }
  end

  def build_response
    scrapers.map(&:call).reduce({}, :merge)
  end
end
