# puppet-nomad

### What This Module Affects

* Installs the nomad daemon (via url or package)
  * If installing from zip, you *must* ensure the unzip utility is available.
* Optionally installs a user to run it under
* Installs a configuration file (/etc/nomad/config.json)
* Manages the nomad service via upstart, sysv, or systemd

## Usage

To set up a single nomad server, with several agents attached:
On the server:
```puppet
class { '::nomad':
  config_hash = {
    'region'     => 'us-west',
    'datacenter' => 'ptk',
    'log_level'  => 'INFO',
    'bind_addr'  => '0.0.0.0',
    'data_dir'   => '/opt/nomad',
    'server'     => {
      'enabled'          => true,
      'bootstrap_expect' => 3,
    }
  }
}
```
On the agent(s):
```puppet
class { 'nomad':
  config_hash   => {
    'region'     => 'us-west',
    'datacenter' => 'ptk',
    'log_level'  => 'INFO',
    'bind_addr'  => '0.0.0.0',
    'data_dir'   => '/opt/nomad',
    'client'     => {
      'enabled'    => true,
      'servers'    => [
        "nomad01.your-org.pvt:4647",
        "nomad02.your-org.pvt:4647",
        "nomad03.your-org.pvt:4647"
      ]
    }
  },
}

```
Disable install and service components:
```puppet
class { '::nomad':
  install_method => 'none',
  init_style     => false,
  manage_service => false,
  config_hash   => {
    'region'     => 'us-west',
    'datacenter' => 'ptk',
    'log_level'  => 'INFO',
    'bind_addr'  => '0.0.0.0',
    'data_dir'   => '/opt/nomad',
    'client'     => {
      'enabled'    => true,
      'servers'    => [
        "nomad01.your-org.pvt:4647",
        "nomad02.your-org.pvt:4647",
        "nomad03.your-org.pvt:4647"
      ]
    }
  },
}
```

### Deploying jobs using `puppet device` (experimental)

_DISCLAIMER: This is not meant for production. The code is brittle and was
developed by a Ruby noob. Use at your own risk! (Contributions, tips and tricks
are more than welcome!)_

The `nomad_job` resource provides a way to launch jobs into a nomad cluster. To
use the feature we have to handle the cluster as a [puppet
device](https://puppet.com/docs/puppet/latest/puppet_device.html) with a device
proxy. This is a rather complex setup that is probably not worth it, however
it's been a great learning experience developing it.

The following setup assumes that you have a `nomad` cluster already running on
the server you will be using as a proxy for the device.

1. Create a `.nomad` file which contains a job description. Something like the
   following code. For simplicity I have uploaded it to `/tmp/http-echo.nomad`
   on the proxy agent.

```hcl
job "http-echo" {
  datacenters = ["dc1"]
  group "test" {
    task "server" {
      driver = "docker"
      config {
        image = "hashicorp/http-echo"
        args = [
          "-listen", ":${NOMAD_PORT_http}",
          "-text", "hello world",
        ]
      }
      resources {
        network {
          port "http" {}
        }
      }
    }
  }
}
```
2. Setup the device configuration. I will be using
   [`device_manager`](https://forge.puppet.com/puppetlabs/device_manager) which
   will manage the configuration and application of our rules. The
   `device_manager` has to be setup on the proxy agent:

```puppet
node 'myproxy.domain' {
  device_manager { 'nomad.myproxy.domain':
    type        => 'nomad',
    credentials => {
      host       => '127.0.0.1', # This is the address of the nomad cluster
      enable_ssl => false,
    },
    # Uncomment this to make the device run regularly
    # run_interval => '15',
  }
}
```

3. Add the `nomad_job` rule to the node configuration of the device:

```puppet
node 'nomad.myproxy.domain' {
  nomad_job { 'http-echo':
    job => nomad::loadhcl('/tmp/http-echo.nomad'),
  }
}
```

4. Ensure the updates propagate to the puppetserver (e.g. using
   [`r10k`](https://github.com/puppetlabs/r10k)) and then apply the
   configuration to the proxy using `puppet agent -t`.

5. Run `puppet device --verbose` on the proxy agent to see the job being applied
   to the cluster. This is automated when `run_interval` is specified. If you
   have [`autosign`](https://puppet.com/docs/puppet/latest/ssl_autosign.html)
   disabled you need to `ssh` to your puppet master and sign the certificate for
   the device.

## Limitations

Depends on the JSON gem, or a modern ruby. (Ruby 1.8.7 is not officially supported)

## Development
Open an [issue](https://github.com/dudemcbacon/puppet-nomad/issues) or
[fork](https://github.com/dudemcbacon/puppet-nomad/fork) and open a
[Pull Request](https://github.com/dudemcbacon/puppet-nomad/pulls)

## Acknowledgement

Must of this module was refactored from Kyle Anderson's great [consul](https://github.com/solarkennedy/puppet-consul) module available on the puppet forge. Go give him stars and likes and what not -- he deserves them!
