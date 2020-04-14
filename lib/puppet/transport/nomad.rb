# frozen_string_literal: true

require 'puppet/util/nomad'

module Puppet::Transport
  # The main connection class to a Nomad endpoint
  class Nomad
    # Initialise this transport with a set of credentials
    def initialize(context, connection_info)
      @inner = Puppet::Util::Nomad.new(context, connection_info)
    end

    # Verifies that the stored credentials are valid, and that we can talk to the target
    def verify(context)
      @inner.verify(context)
    end

    # Retrieve facts from the target and return in a hash
    def facts(context)
      context.debug('Retrieving facts')
      facts = @inner.get('/v1/agent/self')
      return { 'nomad' => facts.select {|k, v| ['config', 'member'].include?(k) } }
    end

    # Close the connection and release all resources
    def close(context)
      @inner.close(context)
    end

    def inner()
      @inner
    end
  end
end
