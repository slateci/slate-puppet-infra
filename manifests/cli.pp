# @summary
#   This class handles installation of the SLATE CLI.
#
# @param slate_client_token
#   The client token obtained for your user from the SLATE portal.
# @param slate_endpoint_url
#   The endpoint to use for the SLATE CLI.
#
class slate::cli (
  String $slate_client_token,
  String $slate_endpoint_url = 'https://api.slateci.io:18080',
) {
  file { '/root/.slate':
    ensure => directory,
  }
  -> file { '/root/.slate/endpoint':
    content => $slate_endpoint_url,
    mode    => '0600',
  }
  -> file { '/root/.slate/token':
    content => $slate_client_token,
    mode    => '0600',
  }

  -> exec { 'download SLATE CLI':
    path        => ['/usr/sbin', '/usr/bin', '/bin', '/sbin', '/usr/local/bin'],
    command     => 'curl -L https://jenkins.slateci.io/artifacts/client/slate-linux.tar.gz | tar -xz -C /usr/local/bin',
    # Do not run if the SLATE binary is present and it's version is equal to the server's reported version.
    unless      => 'test -f /usr/local/bin/slate && \
    test $(slate version | grep -Pzo "Client Version.*\\n\\K(\\d+)(?=.*)") = \
    $(curl -L https://jenkins.slateci.io/artifacts/client/latest.json | \
    jq -r ".[0].version")',
    environment => ['HOME=/root'],
  }

  ~> exec { 'setup SLATE completions':
    path        => ['/usr/sbin', '/usr/bin', '/bin', '/sbin', '/usr/local/bin'],
    command     => 'slate completion > /etc/bash_completion.d/slate',
    refreshonly => true,
    environment => ['HOME=/root'],
  }
}
