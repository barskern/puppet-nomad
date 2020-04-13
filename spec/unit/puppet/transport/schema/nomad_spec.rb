# frozen_string_literal: true

require 'spec_helper'
require 'puppet/transport/schema/nomad'

RSpec.describe 'the nomad transport' do
  schema = Puppet::ResourceApi::Transport.list['nomad']

  it 'loads' do
    expect(schema).not_to be_nil
  end
end
