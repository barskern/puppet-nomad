# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the nomad_job type using the Resource API.
class Puppet::Provider::NomadJob::NomadJob < Puppet::ResourceApi::SimpleProvider
  def initialize
    require 'net/http'

    @@BASE_URL = "http://servie.lan:4646"
  end

  def get(context, names = nil)
    HTTP.get("#{BASE_URL}/v1/jobs").parse.map do |job|
      {
        :name => job["ID"],
        :job  => HTTP.get("#{BASE_URL}/v1/job/#{job["ID"]}").parse,
        :ensure => 'present',
      }
    end
  end

  def create(context, name, should)
    res = HTTP.post("#{BASE_URL}/v1/jobs", :json => should[:job]).parse
    print res, "\n"
  end

  def update(context, name, should)
    res = HTTP.post("#{BASE_URL}/v1/job/#{should[:name]}", :json => should[:job]).parse
    print res, "\n"
  end

  def delete(context, name)
    res = HTTP.delete("#{BASE_URL}/v1/job/#{should[:name]}").parse
    print res, "\n"
  end
end
