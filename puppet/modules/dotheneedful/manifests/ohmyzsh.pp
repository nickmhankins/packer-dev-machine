class dotheneedful::ohmyzsh {

  $user = 'vagrant'
  $base_uri = 'https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master'
  $installsource = "${base_uri}/tools/install.sh"
  $repos = $dotheneedful::ohmyzsh_plugin_repos

  user { $user:
    shell   => '/bin/zsh',
    require => Package['zsh']
  }

  -> exec { 'install_ohmyzsh':
    command => "/usr/bin/curl -fsSL ${installsource} | /usr/bin/bash",
    user    => $user
  }

  $repos.each |String $repo| {
    $name = split($repo, '/')[-1]
    exec {"${repo}_install":
      command => "/usr/bin/git clone ${repo} /home/${user}/.oh-my-zsh/custom/plugins/${name}",
      require => Exec['install_ohmyzsh']
    }
  }

  file { "/home/${user}/.zshrc":
    ensure  => 'file',
    content => epp('dotheneedful/zshrc.epp'),
    mode    => '0600',
    owner   => $user,
    require => Exec['install_ohmyzsh']
  }

}
