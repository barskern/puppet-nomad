# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'nomad_job',
  docs: <<-EOS,
@summary a nomad_job type
@example
nomad_job { 'foo':
  ensure => 'present',
}

This type provides Puppet with the capabilities to manage ...

If your type uses autorequires, please document as shown below, else delete
these lines.
**Autorequires**:
* `Package[foo]`
EOS
  features: ['simple_get_filter'],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    name: {
      type:      'String',
      desc:      'The name of the resource you want to manage.',
      behaviour: :namevar,
    },
    job: {
      type: 'Hash',
      desc: 'The job specification in JSON. See https://nomadproject.io/api-docs/json-jobs/#job',
    },
  },
)
