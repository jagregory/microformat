require 'rspec'
require 'microformat'

describe Microformat::SchemaOrg do
  let(:html) {
    <<-HTML
    <div itemscope itemtype="http://schema.org/Product">
      <h1 itemprop="name">Product</h1>
      <div itemprop="offers" itemscope itemtype="http://schema.org/Offer">
        <meta itemprop="currency" content="AUD" />
        Price: $<span itemprop="price">12.99</span>
      </div>
    </div>
    HTML
  }
  let(:result) { Microformat::SchemaOrg.parse html }
  let(:product) { result.products.first }

  it 'should find a product' do
    product.should_not be_nil
  end

  it 'should parse name' do
    product['name'].should eq ['Product']
  end

  it 'should parse offer' do
    product['offers'].first['currency'].should eq ['AUD']
    product['offers'].first['price'].should eq ['12.99']
  end
end