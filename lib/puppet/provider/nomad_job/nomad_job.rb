# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/transport/nomad'

# Implementation for the nomad_job type using the Resource API.
class Puppet::Provider::NomadJob::NomadJob < Puppet::ResourceApi::SimpleProvider
  def initialize
  end

  def get(context, names = nil)
    context.transport.get('/v1/jobs').map do |job|
      {
        :name => job["ID"],
        :job  => context.transport.get("/v1/job/#{job["ID"]}"),
        :ensure => 'present',
      }
    end
  end

  def create(context, name, should)
    context.transport.post('/v1/jobs', should[:job])
  end

  def update(context, name, should)
    context.transport.post("/v1/job/#{name}", should[:job])
  end

  def delete(context, name)
    context.transport.delete("/v1/job/#{name}")
  end
end
