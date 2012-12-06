# === Authors
#
# Fernando Alonso <fedario@gmail.com>, Brendan O'Donnell <brendan.james.odonnell@gmail.com>
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

  define line($file, $line, $ensure = 'present') {
    case $ensure {
      default : { err ( "unknown ensure value ${ensure}" ) }
      present: {
        exec { "/bin/echo '${line}' >> '${file}'":
          unless => "/bin/grep -qFx '${line}' '${file}'"
        }
      }
      absent: {
        exec { "/bin/grep -vFx '${line}' '${file}' | /usr/bin/tee '${file}' > /dev/null 2>&1":
          onlyif => "/bin/grep -qFx '${line}' '${file}'"
        }
      }
    }
  }

  define download($prefix) {
  
    exec { "git clone ${rbenv::params::repo_name}":
      command   => "git clone \
                    ${rbenv::params::repo_path} \
                    ${rbenv::params::install_dir}",
      path      => ["/usr/bin", $prefix],
      creates   => $rbenv::params::install_dir
    }
    
  }
  
  define setup($prefix, $profile_path, $user, $group) {
    
    file { "${rbenv::params::install_dir}":
      group => $group,
      mode => 775,
      recurse => true
    }
  
    #file { [
    #  $rbenv::params::install_dir,
    #  "${rbenv::params::install_dir}/plugins",
    #  "${rbenv::params::install_dir}/shims",
    #  "${rbenv::params::install_dir}/versions"
    #]:
    #  ensure    => directory,
    #  owner     => 'root',
    #  group     => 'root',
    #  mode      => '0775'
    #}

    group { "rbenv":
      ensure => "present"
    }

    user { "set user rbenv group ${group}":
      name => $user,
      groups => $group,
      shell => "/bin/zsh"
    }
  
    line { "source lines ${profile_path}":
      file => $profile_path,
      line => template("${build_dir}/rbenv.sh.erb")
    }
  
    Line["source lines ${profile_path}"] -> Exec["source ${profile_path}"]
    
  }

  define install($ruby_version, $user, $group) {
    
    exec { "source ${profile_path}":
      command => "zsh -c 'source ${profile_path}' && rbenv install ${ruby_version}",
      cwd     => "/home/vagrant",
      user    => $user,
      logoutput => true,
      timeout => 0,
      environment => ["HOME=/home/vagrant", "RBENV_ROOT=/usr/local/rbenv"],
      path => ["/bin", "/usr/bin", "/usr/local/bin", "/usr/local/rbenv/bin"]
    }

    exec { "rbenv global ${ruby_version}":
      command => "rbenv global ${ruby_version}",
      user    => $user,
      environment => ["HOME=/home/vagrant", "RBENV_ROOT=/usr/local/rbenv"],
      path => ["/bin", "/usr/bin", "/usr/local/bin", "/usr/local/rbenv/bin"]
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
    
    Exec["source ${profile_path}"] -> Exec["rbenv global ${ruby_version}"]

  }
}
