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
    @scrapers << ScrapeHtml::MetaTag.new(document, meta_tags)

    @scrapers
  end

  def css_selectors
    @fields.reject { |field| field == 'meta' }
  end

  def meta_tags
    @fields.select { |field| field == 'meta' }
  end
end
