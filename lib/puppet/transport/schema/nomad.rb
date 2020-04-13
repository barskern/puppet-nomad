# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_transport(
  name: 'nomad',
  desc: <<-EOS,
      This transport provides Puppet with the capability to connect to Nomad clusters.
    EOS
  features: [],
  connection_info: {
    host: {
      type: 'String',
      desc: 'The hostname or IP address to connect to for this target.',
    },
    port: {
      type: 'Optional[Integer]',
      desc: 'The port to connect to. Defaults to 4646.',
    },
    token: {
      type:      'Optional[String[1]]',
      desc:      'The nomad token for authentication when enabled',
      sensitive: true,
    },
    enable_ssl: {
      type:    'Boolean',
      desc:    'Wether to enabled SSL.',
      default: true,
    },
  },
)
