#puppet-sleep
#Author: Artem Sidorenko <artem@2realities.com>
class sleep(
  $period=15,
  $ports='22,80,443',
  $suspend_command='systemctl suspend'
  ) {

  file { '/usr/local/libexec/sleep':
    content => template('modules/sleep.erb'),
    mode    => '0755',
  }
  cron { 'sleep':
    command => '/usr/local/libexec/sleep',
    user    => root,
    minute  => $period,
    require => File['/usr/local/libexec/sleep'],
  }

}
