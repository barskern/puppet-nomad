# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::NomadJob')
require 'puppet/provider/nomad_job/nomad_job'

RSpec.describe Puppet::Provider::NomadJob::NomadJob do
  subject(:provider) { described_class.new }

  let(:connection_info) { { host: 'valid.org', enable_ssl: false } }
  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  before (:each) do
    allow(context).to receive_messages([:info, :debug])

    allow(context).to receive(:transport).and_return(Puppet::Transport::Nomad.new(context, connection_info))

    stub_request(:get, 'http://valid.org:4646/v1/jobs').
      to_return(body: '[{"ID": "abc"}]')

    uri_template = Addressable::Template.new "http://valid.org:4646/v1/job/{id}"
    stub_request(:get, uri_template).
      to_return(body: '{"ID": "abc"}')
    stub_request(:post, uri_template).
      to_return(body: '{"ID": "abc"}')
    stub_request(:delete, uri_template).
      to_return(body: '{"ID": "abc"}')

    stub_request(:post, 'http://valid.org:4646/v1/jobs').
      to_return(body: lambda { |request| request.body })
  end

  # TODO Figure out how to test this
  describe '#get' do
    it 'processes resources' do
      expect(provider.get(context)).to eq [
        {:job => { 'ID' => 'abc'}, :ensure => 'present', :name => 'abc'}
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      provider.create(context, 'xxx', name: 'xxx', ensure: 'present', job: {'ID' => 'xxx'})

      expect(a_request(:post, "http://valid.org:4646/v1/jobs").with(body: '{"ID":"xxx"}')).
  to have_been_made
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      provider.update(context, 'xxx', name: 'xxx', ensure: 'present', job: {'ID' => 'xxx'})

      expect(a_request(:post, "http://valid.org:4646/v1/job/xxx").with(body: '{"ID":"xxx"}')).
  to have_been_made
    end
  end

  describe 'delete(context, name)' do
    it 'updates the resource' do
      provider.delete(context, 'xxx')

      expect(a_request(:delete, "http://valid.org:4646/v1/job/xxx")).to have_been_made
    end
  end
end
