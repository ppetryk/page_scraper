module ScrapeHtml
  class MetaTag < Base
    def initialize(document, meta_tags)
      super document
      @meta_tags = meta_tags
    end

    def call
      @meta_tags.transform_values do |name_attrs|
        name_attrs
          .map { |name_attr| { name_attr => fetch_meta_content(name_attr) } }
          .reduce({}, :merge)
      end
    end

    protected

    def fetch_meta_content(name_attr)
      @document
        .search("meta[name='#{name_attr}']")
        .map { |meta_tag| meta_tag[:content] }
        .join ' '
    end
  end
end
