# frozen_string_literal: true

require 'puppet/http'
require 'puppet/util/json'
require 'puppet/pops'
require 'uri'

module Puppet::Transport
  # The main connection class to a Nomad endpoint
  class Nomad
    # Initialise this transport with a set of credentials
    def initialize(context, connection_info)
      @uri = URI("http#{connection_info[:enable_ssl] ? 's' : ''}://#{connection_info[:host]}:#{connection_info[:port] || 4646}")
      @token = connection_info[:token]
      @client = Puppet::HTTP::Client.new

      context.info("Connecting to #{@uri}")
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

    # Retrieve facts from the target and return in a hash
    def facts(context)
      context.debug('Retrieving facts')
      facts = get('/v1/agent/self')
      return facts.reject {|k, v| k == 'stats'}
    end

    # Close the connection and release all resources
    def close(context)
      context.debug('Closing connection')
      @client.close
      @client = nil
    end

    ### Methods used to commuicate with Nomad API ###

    def get(path)
      @client.connect(@uri) do |http|
        res = http.get(path, default_headers)
        if res.code == '200'
          return Puppet::Util::Json.load(res.body)
        else
          raise RuntimeError, "Error from '#{@uri}': #{res.code} #{res.message} - #{res.body}"
        end
      end
    end

    def post(path, data)
      @client.connect(@uri) do |http|
        headers = Puppet::Pops::MergeStrategy.
          strategy(:hash).
          merge({'Content-Type' => 'application/json'}, default_headers)

        res = http.post(path, Puppet::Util::Json.dump(data), headers)
        if res.code == '200'
          return Puppet::Util::Json.load(res.body)
        else
          raise RuntimeError, "Error from '#{@uri}': #{res.code} #{res.message} - #{res.body}"
        end
      end
    end

    def put(path, data)
      @client.connect(@uri) do |http|
        headers = Puppet::Pops::MergeStrategy.
          strategy(:hash).
          merge({'Content-Type' => 'application/json'}, default_headers)

        res = http.put(path, Puppet::Util::Json.dump(data), headers)
        if res.code == '200'
          return Puppet::Util::Json.load(res.body)
        else
          raise RuntimeError, "Error from '#{@uri}': #{res.code} #{res.message} - #{res.body}"
        end
      end
    end

    def delete(path)
      @client.connect(@uri) do |http|
        res = http.delete(path, default_headers)
        if res.code == '200'
          return Puppet::Util::Json.load(res.body)
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
