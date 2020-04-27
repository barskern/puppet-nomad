# frozen_string_literal: true

require 'puppet/pops'
require 'net/http'
require 'json'
require 'uri'

module Barskern
  # The main connection class to a Nomad endpoint
  class Nomad
    # Initialise this transport with a set of credentials
    def initialize(connection_info)
      @uri = URI("http#{connection_info[:enable_ssl] ? 's' : ''}://#{connection_info[:host]}:#{connection_info[:port] || 4646}")
      @token = connection_info[:token]
    end

    # Verifies that the stored credentials are valid, and that we can talk to the target
    def verify(context)
      context.debug("Checking connection to '#{@uri}'")

      # TODO validate nomad token aswell
      response = get('/v1/agent/health')
      if response['server']['ok'] || response['client']['ok']
        context.info("'#{@uri}' reported to be ok")
      end
    end

    # Close the connection and release all resources
    def close(context)
    end

    ### Methods used to commuicate with Nomad API ###

    def get(path)
      Net::HTTP.start(@uri.host, @uri.port) do |http|
        res = http.get(path, default_headers)
        if res.code == '200'
          return JSON.parse(res.body)
        else
          raise RuntimeError, "Error from '#{@uri}': #{res.code} #{res.message} - #{res.body}"
        end
      end
    end

    def post(path, data)
      Net::HTTP.start(@uri.host, @uri.port) do |http|
        headers = Puppet::Pops::MergeStrategy.
          strategy(:hash).
          merge({'Content-Type' => 'application/json'}, default_headers)

        res = http.post(path, data.to_json, headers)
        if res.code == '200'
          return JSON.parse(res.body)
        else
          raise RuntimeError, "Error from '#{@uri}': #{res.code} #{res.message} - #{res.body}"
        end
      end
    end

    def put(path, data)
      Net::HTTP.start(@uri.host, @uri.port) do |http|
        headers = Puppet::Pops::MergeStrategy.
          strategy(:hash).
          merge({'Content-Type' => 'application/json'}, default_headers)

        res = http.put(path, Puppet::Util::Json.dump(data), headers)
        if res.code == '200'
          return JSON.parse(res.body)
        else
          raise RuntimeError, "Error from '#{@uri}': #{res.code} #{res.message} - #{res.body}"
        end
      end
    end

    def delete(path)
      Net::HTTP.start(@uri.host, @uri.port) do |http|
        res = http.delete(path, default_headers)
        if res.code == '200'
          return JSON.parse(res.body)
        else
          raise RuntimeError, "Error from '#{@uri}': #{res.code} #{res.message} - #{res.body}"
        end
      end
    end

    def default_headers
      # compact ensures that we remove all nil (e.g. when token is empty)
      {
        'X-Nomad-Token' => @token&.unwrap,
        'Accept'        => 'application/json',
      }.compact
    end

  end
end
