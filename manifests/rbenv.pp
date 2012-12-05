# == Class: rbenv
#
# Install rbenv.
#
# === Parameters
#
# $rbenv::params::repo_path
#   The repository to clone from
#   Defaults to 'git://github.com/sstephenson/rbenv.git'
# $rbenv::params::repo_name
#   The name of the new local directory to clone into
#   Defaults to 'rbenv'
# $rbenv::params::install_prefix
#   The name of the existing parent directory to clone into
#   Defaults to '/usr/local'
# $rbenv::params::install_dir
#   The full path to the newly created directory
#   Defaults to $install_prefix/$repo_name
#
# === Variables
#
# === Examples
#
#  class { 'rbenv':  }
#
# === Authors
#
# Brendan O'Donnell <brendan.james.odonnell@gmail.com>
#
# === Copyright
#
# Copyright (C) 2012 Brendan O'Donnell
#
class rbenv::params {

  #$user               = ''
  #$group              = 'rbenv'
  $repo_path          = 'git://github.com/sstephenson/rbenv.git'
  $repo_name          = 'rbenv'
  $install_prefix     = '/usr/local'
  $install_dir        = "${install_prefix}/${repo_name}"

}

class rbenv {

  include rbenv::params
  
  define setup($prefix) {
  
    exec { "git clone ${rbenv::params::repo_name}":
      command   => "git clone \
                    ${rbenv::params::repo_path} \
                    ${rbenv::params::install_dir}",
      path      => ["/usr/bin", $prefix],
      creates   => $rbenv::params::install_dir,
      notify => File['/etc/profile.d/rbenv.sh'],
      before => File['/etc/profile.d/rbenv.sh']
    }
  
    file { [
      $rbenv::params::install_dir,
      "${rbenv::params::install_dir}/plugins",
      "${rbenv::params::install_dir}/shims",
      "${rbenv::params::install_dir}/versions"
    ]:
      ensure    => directory,
      owner     => 'root',
      group     => 'root',
      mode      => '0775'
    }
  
    file { '/etc/profile.d/rbenv.sh':
      ensure    => file,
      content   => template("${build_dir}/rbenv.sh.erb"),
      mode      => '0775',
      require   => Exec["git clone ${rbenv::params::repo_name}"],
      notify    => Exec["source rbenv.sh"],
      subscribe => Exec["git clone ${rbenv::params::repo_name}"]
    }
  
    exec { "source rbenv.sh":
      command => "bash -c 'source /etc/profile.d/rbenv.sh'",
      path => ["/bin", "/usr/bin", "/usr/local/bin"],
      #user => $user,
      #group => $group,
      subscribe => File["/etc/profile.d/rbenv.sh"],
      #notify => Exec["rbenv::compile ${user} ${ruby}"],
      refreshonly => true
    }
    
  
    #Exec["git clone ${rbenv::params::repo_name}"] -> File['/usr/local/rbenv/bin/rbenv']
  
  }

  define install($ruby_version) {

    exec { "rbenv::compile ${user} ${ruby_version}":
      command     => "rbenv install ${ruby_version}", # && touch ${root_path}/.rehash",
      # timeout     => 0,
      #user        => $user,
      #group       => $group,
      # environment => [ "HOME=${home_path}" ],
      #creates     => "${versions}/${ruby}",
      path        => ["/usr/local/rbenv/bin"],
      subscribe      => Exec["source rbenv.sh"],
      refreshonly => true
    }

    #exec { "rbenv::rehash ${user} ${ruby}":
    #  command     => "rbenv rehash && rm -f ${root_path}/.rehash",
    #  user        => $user,
    #  group       => $group,
    #  cwd         => $home_path,
    #  onlyif      => "[ -e '${root_path}/.rehash' ]",
    #  environment => [ "HOME=${home_path}" ],
    #  path        => $path,
    #}

  }
}
