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
