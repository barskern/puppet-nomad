# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/nomad_job'

RSpec.describe 'the nomad_job type' do
  it 'loads' do
    expect(Puppet::Type.type(:nomad_job)).not_to be_nil
  end
end
