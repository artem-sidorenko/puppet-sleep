puppet-sleep
============

This package allows to suspend or shutdown the system, if you don't have specified active network connections. I've created this script for my system running as NAS at home to save power consumption. Wakeup of the systems happens usually via WakeOnLan, see the example below with MicroTik router.

Parameters
==========
This module is used just as a class with following parameters:

  * period - number - time period to check in minutes, is used for the cron job
  * ports - hash with numbers - UDP/TCP ports to check for active established sessions, netstat is used to retrieve the information
  * suspend_command - string - command to run if no active sessions are where

Usage examples
==============

Wakeonlan with MikroTik router
==============================