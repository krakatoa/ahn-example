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

class ruby::params {

  $repo_path          = 'git://github.com/sstephenson/ruby-build.git'
  $repo_name          = 'ruby-build'
  $install_prefix     = '/usr/local'
  $install_dir        = "${install_prefix}/${repo_name}"

}

class ruby {

  include ruby::params

  define setup() {

    exec { "git clone ${ruby::params::repo_name}":
      command   => "/usr/bin/git clone \
                    ${ruby::params::repo_path} \
                    ${ruby::params::install_dir}",
      path      => $ruby::params::install_prefix,
      creates   => $ruby::params::install_dir
    }

    file { [
      $ruby::params::install_dir #,
      #"${rbenv::params::install_dir}/plugins",
      #"${rbenv::params::install_dir}/shims",
      #"${rbenv::params::install_dir}/versions"
    ]:
      ensure    => directory,
      owner     => 'root',
      group     => 'root',
      mode      => '0775',
      notify    => Exec['install-ruby-build']
    }

    exec { 'install-ruby-build':
      cwd     => $ruby::params::install_dir,
      command => "${ruby::params::install_dir}/install.sh",
      refreshonly => true
    }
    
    #file { '/etc/profile.d/rbenv.sh':
    #  ensure    => file,
    #  content   => template('rbenv/rbenv.sh'),
    #  mode      => '0775'
    #}

    Exec["git clone ${ruby::params::repo_name}"] -> File['/usr/local/ruby-build']
  
  }

}
