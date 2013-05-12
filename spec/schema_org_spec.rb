require 'rspec'
require 'microformat'

describe Microformat::SchemaOrg do
  describe 'a strict implementation' do
    let(:html) {
      <<-HTML
      <div itemscope itemtype="http://schema.org/Product">
        <h1 itemprop="name">Product</h1>
        <div itemprop="offers" itemscope itemtype="http://schema.org/Offer">
          <meta itemprop="currency" content="AUD" />
          <meta itemprop="availability" content="OutOfStock" />
          Price: $<span itemprop="price">12.99</span>
        </div>
      </div>
      HTML
    }
    let(:result) { Microformat::SchemaOrg.parse html, strict: true }
    let(:product) { result.products.first }

    it 'should find a product' do
      product.should_not be_nil
    end

    it 'should parse name' do
      product['name'].should eq ['Product']
    end

    it 'should parse offer' do
      product['offers'].first['currency'].should eq ['AUD']
      product['offers'].first['availability'].should eq ['OutOfStock']
      product['offers'].first['price'].should eq ['12.99']
    end
  end

  describe 'a weak implementation' do
    let(:html) {
      <<-HTML
      <div itemscope itemtype="http://schema.org/Product">
        <h1 itemprop="name">Product</h1>
        <div itemprop="offers" itemscope itemtype="http://schema.org/Offer">
          <span itemprop="currency" content="AUD" />
          <span itemprop="availability" href="OutOfStock" />
          Price: $<span itemprop="price">12.99</span>
        </div>
      </div>
      HTML
    }
    let(:result) { Microformat::SchemaOrg.parse html, strict: false }
    let(:product) { result.products.first }

    it 'should find a product' do
      product.should_not be_nil
    end

    it 'should parse name' do
      product['name'].should eq ['Product']
    end

    it 'should parse offer' do
      product['offers'].first['currency'].should eq ['AUD']
      product['offers'].first['availability'].should eq ['OutOfStock']
      product['offers'].first['price'].should eq ['12.99']
    end
  end

  describe 'a weird weak implementation' do
    let(:html) {
      <<-HTML
      <div itemscope itemtype="http://schema.org/Product">
        <h1 itemprop="name">Product</h1>
        <div itemprop="offers" itemscope itemtype="http://schema.org/Offer">
          <span itemprop="currency" content="AUD">
            <span itemprop="availability" href="OutOfStock">
              Price: $<span itemprop="price">12.99</span>
            </span>
          </span>
        </div>
      </div>
      HTML
    }
    let(:result) { Microformat::SchemaOrg.parse html, strict: false }
    let(:product) { result.products.first }

    it 'should find a product' do
      product.should_not be_nil
    end

    it 'should parse name' do
      product['name'].should eq ['Product']
    end

    it 'should parse offer' do
      product['offers'].first['currency'].should eq ['AUD']
      product['offers'].first['availability'].should eq ['OutOfStock']
      product['offers'].first['price'].should eq ['12.99']
    end
  end
end