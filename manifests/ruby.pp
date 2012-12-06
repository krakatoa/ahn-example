class ruby::params {

  $repo_path          = 'git://github.com/sstephenson/ruby-build.git'
  $repo_name          = 'ruby-build'
  $install_prefix     = '/usr/local'
  $install_dir        = "${install_prefix}/${repo_name}"

}

class ruby {

  include ruby::params

  define setup() {

    package {
      "build-essential":
        ensure => present;
      "libssl-dev":
        ensure => present;
      "libreadline6":
        ensure => present;
      "libreadline6-dev":
        ensure => present;
      "zlib1g":
        ensure => present;
      "zlib1g-dev":
        ensure => present;
      "curl":
        ensure => present;
      "libcurl4-openssl-dev":
        ensure => present;
      "libxslt-dev":
        ensure => present;
      "libxml2-dev":
        ensure => present;
    }

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
      refreshonly => true,
      require => [
        Package["build-essential"],
        Package["libssl-dev"],
        Package["libreadline6"],
        Package["libreadline6-dev"],
        Package["zlib1g"],
        Package["zlib1g-dev"],
        Package["curl"],
        Package["libcurl4-openssl-dev"],
        Package["libxslt-dev"],
        Package["libxml2-dev"]
      ]
    }
    
    Exec["git clone ${ruby::params::repo_name}"] -> File['/usr/local/ruby-build']
  
  }

}
