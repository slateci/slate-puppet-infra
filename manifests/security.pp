# @summary
#   This class handles setting (and disabling) security settings for SLATE, such as
#   the firewall, selinux, and ssh login settings.
#
# @param disable_root_ssh
#   Ensures 'PermitRootLogin no' is set in `/etc/ssh/sshd_config`.
#
class slate::security (
  Boolean $disable_root_ssh = true,
) {
  # TODO(emersonf): Investigate if we actually need to disable SELinux.
  class { 'selinux':
    mode => 'permissive',
  }

  # TODO(emersonf): Change this to a specific port list.
  class { 'firewalld':
    service_enable => false,
    service_ensure => stopped,
  }

  if $disable_root_ssh {
    ensure_resource('service', 'sshd', {})

    file_line { 'PermitRootLogin no':
      line   => 'PermitRootLogin no',
      path   => '/etc/ssh/sshd_config',
      notify => Service['sshd'],
    }

    file_line { 'PermitRootLogin yes':
      ensure => absent,
      line   => 'PermitRootLogin yes',
      path   => '/etc/ssh/sshd_config',
      notify => Service['sshd'],
    }
  }
}