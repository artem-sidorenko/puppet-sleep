#puppet-sleep
#Author: Artem Sidorenko <artem@2realities.com>
class sleep(
  $period=15,
  $ports='22,80,443',
  $suspend_command='UNSET'
  ) {

  #some defaults
  $script_name = 'sleep'
  $template_name = "${module_name}/sleep.erb"

  case $::osfamily {
    Archlinux: {
      $supported = true
      $script_location = '/usr/local/libexec'
      $packages_requiered = 'UNSET'
      if ($suspend_command == 'UNSET') {
        $suspend_command = 'systemctl suspend'
      }
    }

      default: {
        fail("The ${module_name} module is not supported on ${::osfamily} based systems")
      }

    }

  if ( $packages_requiered != 'UNSET' ) {
    package { 'puppet-sleep':
      ensure => present,
      name   => $packages_requiered,
    }
  }

  file { "${module_name}-script":
    path    => "${script_location}/${script_name}",
    content => template('modules/sleep.erb'),
    mode    => '0755',
  }
  cron { "${module_name}-cron":
    command => "${script_location}/${script_name}",
    user    => root,
    minute  => $period,
    require => File["${module_name}-script"],
  }

}
