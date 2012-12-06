$build_dir = "/vagrant/manifests"

$rbenv_prefix = "/usr/local/"
$ruby_version = "1.9.3-p194"
$user         = "vagrant"
$rbenv_group  = "rbenv"
# $profile_path = "/etc/zsh/zshenv"
$profile_path = "/home/vagrant/.zshrc"

class ivr {

  include rbenv
  include ruby

  rbenv::download { "rbenv-download": 
    prefix => $rbenv_prefix
  }

  rbenv::setup { "rbenv-setup":
    prefix => $rbenv_prefix,
    profile_path => $profile_path,
    user    => $user,
    group  => $rbenv_group
  }
  
  ruby::setup { "ruby-setup":
  }

  rbenv::install { "rbenv-install":
    ruby_version => $ruby_version,
    user          => $user,
    group         => $rbenv_group
  }

  Rbenv::Download["rbenv-download"] -> Rbenv::Setup['rbenv-setup'] -> Ruby::Setup["ruby-setup"] -> Rbenv::Install['rbenv-install']
}

require 'ivr'
