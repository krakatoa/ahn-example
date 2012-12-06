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

        # Use this resource instead if your platform's grep doesn't support -vFx;
        # note that this command has been known to have problems with lines containing quotes.
        # exec { "/usr/bin/perl -ni -e 'print unless /^\\Q${line}\\E\$/' '${file}'":
        #     onlyif => "/bin/grep -qFx '${line}' '${file}'"
        # }
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
      mode => 774,
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
      groups => $group
    }
  
    # file { '/etc/profile.d/rbenv.sh':
    #   ensure    => file,
    #   content   => template("${build_dir}/rbenv.sh.erb"),
    #   mode      => '0775',
    #   #require   => Exec["git clone ${rbenv::params::repo_name}"],
    #   #notify    => Line["source rbenv.sh"],
    #   subscribe => Exec["git clone ${rbenv::params::repo_name}"]
    # }

    line { "source lines ${profile_path}":
      file => $profile_path,
      line => template("${build_dir}/rbenv.sh.erb")
      #line => "source /etc/profile.d/rbenv.sh"
    }
  
    exec { "source ${profile_path}":
      command => "zsh -c 'source ${profile_path}'",
      path => ["/bin", "/usr/bin", "/usr/local/bin"] #,
      #subscribe => File["/etc/profile.d/rbenv.sh"],
      #refreshonly => true
    }

    Line["source lines ${profile_path}"] -> Exec["source ${profile_path}"]
    
  }

  define install($ruby_version, $user, $group) {

    exec { "rbenv::compile ${user} ${ruby_version}":
      command     => "rbenv install ${ruby_version}", # && touch ${root_path}/.rehash",
      timeout     => 0,
      user        => "root",
      group       => $group,
      #environment => [ "HOME=/home/vagrant" ],
      environment => [ "HOME=/usr/local/rbenv"],
      #creates     => "${versions}/${ruby}",
      path        => ["/bin", "/usr/bin", "/usr/local/bin", "/usr/local/rbenv/bin"]
      #subscribe      => Exec["source rbenv.sh"],
      #refreshonly => true
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
