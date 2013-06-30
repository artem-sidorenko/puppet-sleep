# == Class: sleep
#
# This package allows to suspend or shutdown the system if you don't have
# specified running network connections. I've created this script for my system
# running as NAS at home to save power consumption. Wakeup of the systems
# happens usually via WakeOnLan, see the examples in the README.
#
# === Parameters
# This module is used just as a class with following parameters:
#
# [*period*]
#   time period to check in minutes, is used for the cron job
#
# [*ports*]
#   hash with UDP/TCP ports to check for active established sessions, netstat is used to retrieve the information
#
# [*suspend_command*]
#   command to run if no active sessions present
#
# === Examples
#
#  class { sleep:
#    period => 15,
#    ports  => ['80','443'],
#    suspend_command => 'systemctl suspend',
#  }
#
# === Authors
#
# Artem Sidorenko <artem@2realities.com>
#
# === Copyright
#
#  Copyright [2013] [Artem Sidorenko]
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#
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
      $packages_requiered = 'net-tools'
      $suspend_command_os = 'systemctl suspend'
    }

    default: {
      fail("The ${module_name} module is not supported on ${::osfamily} based systems")
    }

  }

  if ($suspend_command == 'UNSET') {
    $suspend_command_real = $suspend_command_os
  } else {
    $suspend_command_real = $suspend_command
  }


  if ( $packages_requiered != 'UNSET' ) {
    package { "${module_name}-package":
      ensure => present,
      name   => $packages_requiered,
    }
  }

  file { "${module_name}-script":
    path    => "${script_location}/${script_name}",
    content => template("modules/${module_name}/sleep.erb"),
    mode    => '0755',
  }
  cron { "${module_name}-cron":
    command => "${script_location}/${script_name}",
    user    => root,
    minute  => $period,
    require => File["${module_name}-script"],
  }

}
