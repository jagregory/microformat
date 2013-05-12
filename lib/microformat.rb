require 'microformat/version'
require 'nokogiri'
require 'andand'

module Microformat
  class ItemProp
    def self.parse(node, strict)
      # If the element has no itemprop attribute
      # The attribute must return null on getting and must throw an INVALID_ACCESS_ERR exception on setting.
      return nil unless node.attribute('itemprop')

      # If the element has an itemscope attribute
      # The attribute must return the element itself on getting and must throw an INVALID_ACCESS_ERR exception on setting.
      return ItemScope.new(node, strict) if node.attribute('itemscope')

      if strict
        parse_strict node
      else
        parse_weak node
      end
    end

    private
    ATTRIBUTES = ['content', 'src', 'href', 'data', 'datetime']

    def self.parse_strict(node)
      # If the element is a meta element
      # The attribute must act as it would if it was reflecting the element's content content attribute
      return node.attribute('content').andand.value if node.name == 'meta'

      # If the element is an audio, embed, iframe, img, source, track, or video element
      # The attribute must act as it would if it was reflecting the element's src content attribute.
      return node.attribute('src').andand.value if ['audio', 'embed', 'iframe', 'img', 'source', 'track', 'video'].include? node.name

      # If the element is an a, area, or link element
      # The attribute must act as it would if it was reflecting the element's href content attribute.
      return node.attribute('href').andand.value if ['a', 'area', 'link'].include? node.name

      # If the element is an object element
      # The attribute must act as it would if it was reflecting the element's data content attribute.
      return node.attribute('data').andand.value if node.name == 'object'

      # If the element is a time element with a datetime attribute
      # The attribute must act as it would if it was reflecting the element's datetime content attribute.
      return node.attribute('datetime').andand.value if node.name == 'time' && node.attribute('datetime')

      # Otherwise
      # The attribute must act the same as the element's textContent attribute.
      return node.text.chomp.strip
    end

    def self.parse_weak(node)
      ATTRIBUTES.map { |attr| node.attribute(attr).andand.value }.compact.first || node.text.chomp.strip
    end
  end

  class ItemScope
    attr_reader :type, :id

    def initialize(node, strict)
      @type = attr 'itemtype', node
      @id = attr 'itemid', node
      @properties = {}
      @strict = strict

      parse_elements node.search './*'
    end

    def [](name)
      @properties[name]
    end

    private
    def attr(name, node)
      val = node.attribute name
      val ? val.value : nil
    end

    def parse_elements(elements)
      elements.each do |el|
        itemprop = attr('itemprop', el)
        prop = ItemProp.parse el, @strict

        if prop
          @properties[itemprop] ||= []
          @properties[itemprop] << prop
        end

        parse_elements el.search('./*')
      end
    end
  end

  class ItemDocument
    attr_reader :scopes

    def initialize(scopes)
      @scopes = scopes
    end

    def products
      @scopes.select { |x| x.type =~ /\/product$/i }
    end
  end

  class SchemaOrg
    def self.parse(html, opts={})
      strict = opts.has_key? :strict ? opts[:strict] : true
      html = Nokogiri::HTML.parse html unless html.respond_to? :search
      scopes = html.search('//*[@itemscope and not(@itemprop)]')
        .map { |node| ItemScope.new node, strict }

      if scopes.any?
        ItemDocument.new scopes
      else
        nil
      end
    end
  end
end