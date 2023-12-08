class Api::BuildDataResponse
  def initialize(params)
    @url, @fields = params[:url], params[:fields]
  end

  def call
    scrapers.map(&:call).reduce({}, :merge)
  end

  protected

  def document
    @document ||= GetHtmlDocument.new(@url).call
  end

  def scrapers
    return @scrapers if @scrapers

    @scrapers = []
    @scrapers << ScrapeHtml::CssSelector.new(document, css_selectors)

    @scrapers
  end

  def css_selectors
    @fields
  end
end
