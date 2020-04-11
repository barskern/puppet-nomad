# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::NomadJob')
require 'puppet/provider/nomad_job/nomad_job'

RSpec.describe Puppet::Provider::NomadJob::NomadJob do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  # TODO Figure out how to test this
  # describe '#get' do
  #   it 'processes resources' do
  #     expect(context).to receive(:debug).with('Returning pre-canned example data')

  #     expect(provider.get(context)).to eq []
  #   end
  # end

  # describe 'create(context, name, should)' do
  #   it 'creates the resource' do
  #     expect(context).to receive(:notice).with(%r{\ACreating 'a'})

  #     provider.create(context, 'a', name: 'a', ensure: 'present')
  #   end
  # end

  # describe 'update(context, name, should)' do
  #   it 'updates the resource' do
  #     expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})

  #     provider.update(context, 'foo', name: 'foo', ensure: 'present')
  #   end
  # end

  # describe 'delete(context, name)' do
  #   it 'deletes the resource' do
  #     expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})

  #     provider.delete(context, 'foo')
  #   end
  # end
end
