# Puppet-sleep

[![Build Status](https://travis-ci.org/artem-sidorenko/puppet-sleep.png?branch=master)](https://travis-ci.org/artem-sidorenko/puppet-sleep)

This package allows to suspend or shutdown the system if you don't have
specified running network connections. I've created this script for my system
running as NAS at home to save power consumption. Wakeup of the systems
happens usually via WakeOnLan, see the examples in the README.

## Parameters
This module is used just as a class with following parameters:

**period**
time period to check in minutes, is used for the cron job

**ports**
hash with UDP/TCP ports to check for active established sessions, netstat is used to retrieve the information

**suspend_command**
command to run if no active sessions present

## Examples

### Puppet module

    class { sleep:
      period => 15,
      ports  => ['80','443'],
      suspend_command => 'systemctl suspend',
    }

### WakeOnLan configuration on MikroTik router
We create one subnet and put the system there. The firewall rule on the router will increment the packet counter for specific packets and scheduled script started all 1-5 seconds checks the counter and sends WakeOnLan if any packets are there.
Example firewall rules:

    /ip firewall filter
    add chain=input connection-state=established
    add chain=input connection-state=related
    add chain=input connection-state=new dst-port=22 protocol=tcp
    add chain=input connection-state=new dst-port=443 protocol=tcp
    add chain=input connection-state=new protocol=icmp
    add action=log chain=input disabled=yes log-prefix=input
    add action=drop chain=input
    add chain=forward connection-state=established
    add chain=forward connection-state=related
    add action=passthrough chain=forward comment=PINGWOL connection-state=new dst-address=<<DST IP>> dst-port=22 protocol=tcp src-address=<<some allowed source>>
    add chain=forward connection-state=new dst-address=<<DST IP>> protocol=icmp src-address=<<some allowed source>>
    add chain=forward connection-state=new dst-address=<<DSP IP>> dst-port=22 protocol=tcp src-address=<<some allowed source>> tcp-flags=""
    add action=log chain=forward disabled=yes log-prefix=forward
    add action=drop chain=forward

Example WakeOnLan script:
    /system scheduler
    add interval=2s name=check-wol on-event=":local packet [/ip firewall filter get [find comment=\"PINGWOL\"] packets]\
    \n\
    \n:if ( \$\"packet\"  > 0) do={\
    \n /ip firewall filter reset-counters [/ip firewall filter find comment=\"PINGWOL\"]\
    \n :log info \"Waking up via WOL\"\
    \n /tool wol interface=<<interface for WOL>> mac=<<target MAC for WOL>>\
    \n} else={\
    \n# :log error \"No packets, yet\"\
    \n}" policy=read,write,test start-date=jun/21/2013 start-time=18:51:52

### WakeOnLan configuration with iptables


## Authors

Artem Sidorenko <artem@2realities.com>

## Copyright

 Copyright [2013] [Artem Sidorenko]

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
