$build_dir = "/vagrant/manifests"

$rbenv_prefix = "/usr/local/"
$ruby_version = "1.9.3-p194"

class ivr {

  include rbenv
  include ruby

  rbenv::setup { "rbenv-setup":
    prefix => $rbenv_prefix
  }

  ruby::setup { "ruby-setup":
  
  }

  rbenv::install { "rbenv-install":
    ruby_version => $ruby_version
  }

  Rbenv::Setup['rbenv-setup'] -> Ruby::Setup["ruby-setup"] -> Rbenv::Install['rbenv-install']
}

require 'ivr'
