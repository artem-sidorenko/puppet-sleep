class sleep( $period, $ports, $suspend_command ) {

  file { "/usr/local/libexec/sleep":
    content => template("modules/sleep.erb"),
    mode    => '0755',
  }
  cron { "sleep":
    command => "/usr/local/libexec/sleep",
    user    => root,
    minute  => $period,
    require => File["/usr/local/libexec/sleep"],
  }

}
