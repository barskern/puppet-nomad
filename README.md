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

### Deploying jobs to nomad cluster (experimental)

_DISCLAIMER: This is not meant for production. The code is brittle and was
developed by a Ruby noob. Use at your own risk! (Contributions, tips and tricks
are more than welcome!)_

The `nomad_job` resource provides a way to launch jobs into a nomad cluster on
the current node (e.g. host hardcoded to `http://localhost:4646`).

1. Create a `.nomad` file which contains a job description and place it into
   `profile/files/job/http-echo.nomad`.

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

2. Ensure the file is uploaded to the server at a consistent spot.

```puppet
file { ['/opt', '/opt/nomad', '/opt/nomad/jobs']:
  ensure => 'directory',
}
-> file { '/opt/nomad/job/http-echo.nomad':
  ensure  => 'present',
  content => file("profile/jobs/http-echo.nomad"),
}
```

3. Apply load the job using `nomad::loadhcl` and apply it.

```puppet
nomad_job { 'http-echo':
  job => nomad::loadhcl('/opt/nomad/jobs/http-echo.nomad'),
}
```

## Limitations

Depends on the JSON gem, or a modern ruby. (Ruby 1.8.7 is not officially supported)

## Development
Open an [issue](https://github.com/dudemcbacon/puppet-nomad/issues) or
[fork](https://github.com/dudemcbacon/puppet-nomad/fork) and open a
[Pull Request](https://github.com/dudemcbacon/puppet-nomad/pulls)

## Acknowledgement

Must of this module was refactored from Kyle Anderson's great [consul](https://github.com/solarkennedy/puppet-consul) module available on the puppet forge. Go give him stars and likes and what not -- he deserves them!
