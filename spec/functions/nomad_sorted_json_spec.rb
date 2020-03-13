require 'spec_helper'

RSpec.shared_examples 'handling_simple_types' do |pretty|
  it 'handles nil' do
    expect(pretty({'key' => nil })).to eql('{"key":null}')
  end
  it 'handles true' do
    expect(pretty({'key' => true })).to eql('{"key":true}')
  end
  it 'handles nil' do
    expect(pretty({'key' => false })).to eql('{"key":false}')
  end
  it 'handles positive integer' do
    expect(pretty({'key' => 1 })).to eql('{"key":1}')
  end
  it 'handles negative integer' do
    expect(pretty({'key' => -1 })).to eql('{"key":-1}')
  end
  it 'handles positive float' do
    expect(pretty({'key' => 1.1 })).to eql('{"key":1.1}')
  end
  it 'handles negative float' do
    expect(pretty({'key' => -1.1 })).to eql('{"key":-1.1}')
  end
  it 'handles integer in a string' do
    expect(pretty({'key' => '1' })).to eql('{"key":1}')
  end
  it 'handles negative integer in a string' do
    expect(pretty({'key' => '-1' })).to eql('{"key":-1}')
  end
  it 'handles simple string' do
    expect(pretty({'key' => 'aString' })).to eql("{\"key\":\"aString\"}")
  end
end
describe 'nomad_sorted_json', :type => :puppet_function do

  let(:test_hash){ { 'z' => 3, 'a' => '1', 'p' => '2', 's' => '-7' } }
  before do
    @json = nomad::sorted_json(test_hash, true)
  end
  it "sorts keys" do
    expect( @json.index('a') ).to be < @json.index('p')
    expect( @json.index('p') ).to be < @json.index('s')
    expect( @json.index('s') ).to be < @json.index('z')
  end

  it "prints pretty json" do
    expect(@json.split("\n").size).to eql(test_hash.size + 2) # +2 for { and }
  end

  it "prints ugly json" do
    json = nomad::sorted_json(test_hash) # pretty=false by default
    expect(json.split("\n").size).to eql(1)
  end

  it "validate ugly json" do
    json = nomad::sorted_json([test_hash]) # pretty=false by default
    expect(json).to match("{\"a\":1,\"p\":2,\"s\":-7,\"z\":3}")
  end

  context 'nesting' do

    let(:nested_test_hash){ { 'z' => [{'l' => 3, 'k' => '2', 'j'=> '1'}],
                              'a' => {'z' => '3', 'x' => '1', 'y' => '2'},
                              'p' => [ '9','8','7'] } }
    before do
      @json = nomad::sorted_json([nested_test_hash, true])
    end

    it "sorts nested hashes" do
      expect( @json.index('x') ).to be < @json.index('y')
      expect( @json.index('y') ).to be < @json.index('z')
    end

  end
  context 'test simple behavior' do
    context 'sorted' do
      include_examples 'handling_simple_types', false
    end
    context 'sorted pretty' do
      include_examples 'handling_simple_types', true
    end
  end
end
