# frozen_string_literal: true

require 'spec_helper'

require 'puppet/transport/nomad'

RSpec.describe Puppet::Transport::Nomad do
  subject(:transport) { described_class.new(context, connection_info) }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }
  let(:connection_info) do
    {
      host: 'valid.org',
      enable_ssl: false,
    }
  end

  before(:each) do
    allow(context).to receive(:debug)
    allow(context).to receive(:info)
  end

  describe '#initialize(context, connection_info)' do
    it { expect { transport }.not_to raise_error }
  end

  describe '#verify(context)' do
    subject(:verify) { transport.verify(context) }

    before(:each) do
      stub_request(:get, 'http://valid.org:4646/v1/agent/health')
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(body: '{"server":{"ok":true}}')
    end

    context 'with valid host' do
      it { expect { verify }.not_to raise_error }
    end

    context 'with invalid host' do
      let(:connection_info) { { host: 'invalid.org' } }

      it { expect { verify }.to raise_error WebMock::NetConnectNotAllowedError }
    end
  end

  describe '#facts(context)' do
    subject(:facts) { transport.facts(context) }

    before(:each) do
      stub_request(:get, 'http://valid.org:4646/v1/agent/self')
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(body: '{"config":{}, "member":{}, "stats":{}}')
    end

    it { is_expected.to include('nomad' => {"config" => {}, "member" => {}}) }

    it { is_expected.not_to include('nomad' => {"stats" => {}}) }
  end

  describe '#close(context)' do
    subject(:close) { transport.close(context) }

    it 'releases resources' do
      close
      expect(transport.instance_variable_get(:@client)).to be_nil
    end
  end

  describe '#get(path)' do
    before(:each) do
      stub_request(:get, 'http://valid.org:4646/v1/agent/members')
        .with(headers: { 'Accept' => 'application/json' })
        .to_return(status: 200, body: '{"ServerName":"test"}')
    end

    it { expect(transport.get('/v1/agent/members')).to eq('ServerName' => 'test') }
  end

  describe '#post(path, data)' do
    before(:each) do
      stub_request(:post, 'http://valid.org:4646/v1/jobs')
        .with(headers: { 'Content-Type' => 'application/json' }, body: '{"Job":{}}')
        .to_return(status: 200, body: '{"Job":{}}')
    end

    it { expect(transport.post('/v1/jobs', 'Job' => {})).to eq('Job' => {}) }
  end

  describe '#put(path, data)' do
    before(:each) do
      stub_request(:put, 'http://valid.org:4646/v1/jobs')
        .with(headers: { 'Content-Type' => 'application/json' }, body: '{"Job":{}}')
        .to_return(status: 200, body: '{"Job":{}}')
    end

    it { expect(transport.put('/v1/jobs', 'Job' => {})).to eq('Job' => {}) }
  end

  describe '#delete(path)' do
    before(:each) do
      stub_request(:delete, 'http://valid.org:4646/v1/job/abc')
        .to_return(status: 200, body: '{"EvalID":"1234"}')
    end

    it { expect(transport.delete('/v1/job/abc')).to eq('EvalID' => '1234') }
  end
end
