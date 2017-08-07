# == Class nomad::params
#
# This class is meant to be called from nomad
# It sets variables according to platform
#
class nomad::params {

  $install_method        = 'url'
  $package_name          = 'nomad'
  $package_ensure        = 'latest'
  $download_url_base     = 'https://releases.hashicorp.com/nomad/'
  $download_extension    = 'zip'
  $version               = '0.9.1'
  $config_mode           = '0660'

  case $::facts['os']['architecture'] {
    'x86_64', 'amd64': { $arch = 'amd64' }
    'i386':            { $arch = '386'   }
    'armv7l':          { $arch = 'arm'   }
    default:           {
      fail("Unsupported kernel architecture: ${::facts['os']['architecture']}")
    }
  }

  $os = downcase($::kernel)

  case $::facts['os']['family'] {
    'Ubuntu': {
      if versioncmp($::facts['os']['release']['full'], '8.04') < 1 {
        $init_style = 'debian'
      } elsif versioncmp($::facts['os']['release']['full'], '15.04') < 0 {
        $init_style = 'upstart'
      } else {
        $init_style = 'systemd'
      }
    }
    /Scientific|CentOS|RedHat|OracleLinux/: {
      if versioncmp($::facts['os']['release']['full'], '7.0') < 0 {
        $init_style = 'sysv'
      } else {
        $init_style  = 'systemd'
      }
    }
    'Fedora': {
      if versioncmp($::facts['os']['release']['full'], '12') < 0 {
        $init_style = 'sysv'
      } else {
        $init_style = 'systemd'
      }
    }
    'Debian': {
      if versioncmp($::facts['os']['release']['full'], '8.0') < 0 {
        $init_style = 'debian'
      } else {
        $init_style = 'systemd'
      }
    }
    /Archlinux|OpenSuSE/: {
      $init_style = 'systemd'
    }
    /SLE[SD]/: {
      if versioncmp($::facts['os']['release']['full'], '12.0') < 0 {
        $init_style = 'sles'
      } else {
        $init_style = 'systemd'
      }
    }
    'Darwin': {
      $init_style = 'launchd'
    }
    'Amazon': {
      $init_style = 'sysv'
    }
    default: {
      fail('Unsupported OS')
    }
  }
}
