# Install and set a simple REST server that you can use to communicate with
# MCollective (rpc communication).
# Used with KermIT
# See
# https://puppetlabs.com/mcollective/introduction/
# http://www.kermit.fr

class kermitrest {
    include yum
    include yum::kermit

    # cf puppetlabs-apache
    include apache
    # the puppetlabs base apache module v. 0.6.0 does not open the http port
    include apachefw

    package { 'kermit-restmco' :
        ensure  => present,
        require => [ Yumrepo['kermit-custom', 'kermit-thirdpart'], ],
    }

    file { 'RPM-GPG-KEY-passenger' :
        ensure => present,
        path   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-passenger',
        source => 'puppet:///modules/kermitrest/RPM-GPG-KEY-passenger',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }

    yumrepo { 'passenger' :
        baseurl    =>
            'http://passenger.stealthymonkeys.com/rhel/$releasever/$basearch',
        mirrorlist => 'http://passenger.stealthymonkeys.com/rhel/mirrors',
        descr      => 'Red Hat Enterprise $releasever - Phusion Passenger',
        enabled    => 1,
        gpgcheck   => 1,
        gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-passenger',
    }

    package { 'mod_passenger' :
        ensure  => present,
        require => [ Yumrepo['passenger'], File['RPM-GPG-KEY-passenger'], ],
    }

    service { 'kermit-restmco' :
        ensure => stopped,
        enable => false,
    }

    # File['/etc/kermit'] is set in the module 'kermit'.
    # This avoids unnecessary module dependency :
    exec { 'mkdir /etc/kermit' :
            path    => '/bin/',
            command => 'mkdir -p /etc/kermit',
            creates => '/etc/kermit',
    }

    file { '/etc/kermit/kermit-restmco.cfg' :
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/kermitrest/kermit-restmco.cfg',
        require => Exec['mkdir /etc/kermit'],
    }

    file { '/var/log/kermit-restmco.log' :
        ensure => present,
        owner  => 'nobody',
        group  => 'nobody',
        mode   => '0640',
    }

    file { '/var/www/restmco' :
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { '/var/www/restmco/tmp' :
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/var/www/restmco'],
    }

    file { '/var/www/restmco/public' :
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => File['/var/www/restmco'],
    }

    file { '/var/www/restmco/tmp/restart.txt' :
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File['/var/www/restmco/tmp'],
    }

    file { 'mc-rpc-restserver.rb' :
        ensure  => present,
        path    => '/var/www/restmco/mc-rpc-restserver.rb',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/kermitrest/mc-rpc-restserver.rb',
        require => File['/var/www/restmco'],
    }

    file { 'config.ru' :
        ensure  => present,
        path    => '/var/www/restmco/config.ru',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/kermitrest/config.ru',
        require => File['/var/www/restmco'],
    }

    file { 'restmco.conf' :
        ensure  => present,
        path    => '/etc/httpd/conf.d/restmco.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/kermitrest/restmco.conf',
        require => Package['httpd'],
    }

}
