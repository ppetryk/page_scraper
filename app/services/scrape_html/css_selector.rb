module ScrapeHtml
  class CssSelector < Base
    def initialize(document, css_selectors)
      super(document)
      @css_selectors = css_selectors
    end

    def call
      @css_selectors.transform_values do |css_selector|
        @document.search(css_selector).text
      end
    end
  end
end
