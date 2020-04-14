# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/nomad'

# Implementation for the nomad_job type using the Resource API.
class Puppet::Provider::NomadJob::NomadJob < Puppet::ResourceApi::SimpleProvider
  def initialize
    connection_info = {
      :host => 'localhost',
      :port => 4646,
      :enable_ssl => false,
      :token => ENV['NOMAD_TOKEN']
    }
    @inner = Puppet::Util::Nomad.new(connection_info)
  end

  def get(context, _names = nil)
    @inner.get('/v1/jobs').map do |job|
      {
        name: job['ID'],
        job: @inner.get("/v1/job/#{job['ID']}"),
        ensure: 'present',
      }
    end
  end

  def create(context, _name, should)
    @inner.post('/v1/jobs', should[:job])
  end

  def update(context, name, should)
    @inner.post("/v1/job/#{name}", should[:job])
  end

  def delete(context, name)
    @inner.delete("/v1/job/#{name}")
  end
end
