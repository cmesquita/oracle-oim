class oas-localhost::prereqs {

 if $operatingsystemrelease == '5.5' {

         $pcklist = ['binutils-2.*','glibc-2*','glibc-common-2.*','libaio-0*','libgcc-4.*','libstdc++-4.*','make-3*','setarch-2*','glibc-devel-2.*','gcc-4*','gcc-c++-4.*','libstdc++-devel-4.*','compat-db-4*','compat-gcc-34-3*','compat-gcc-34-c++-3*','compat-libstdc++-33-3*','libaio-devel-0.*','libXp-1*','openmotif-2*','sysstat-7.*']

         package{ $pcklist :
                  ensure => installed
                } ->


         file { '/tmp/openmotif21-2.1.30-11.EL5.i386.rpm':
                 ensure => present,
                 source => 'puppet:///modules/oas-localhost/openmotif21-2.1.30-11.EL5.i386.rpm',
                 mode   => '0755'
              }  ->


         exec { "rpm -ivh /tmp/openmotif21-2.1.30-11.EL5.i386.rpm":
                cwd     => "/tmp",
                path    => ["/usr/bin", "/usr/sbin" , "/bin"],
                timeout => 0,
                unless  => "rpm -qa | grep -i openmotif21-2.1.30-11"

              } ->



         file { '/etc/sysctl.conf':
                 ensure => present,
                 source => 'puppet:///modules/oas-localhost/sysctl.conf',
                 mode   => '0755'
              }  ->



        file { '/etc/pam.d/login':
                 ensure => present,
                 source => 'puppet:///modules/oas-localhost/login',
                 mode   => '0755'
              }  ->



        file { '/etc/security/limits.conf':
                 ensure => present,
                 source => 'puppet:///modules/oas-localhost/limits.conf',
                 mode   => '0755'
              }  ->



         group { "oinstall":
                gid    => 505,
               } ->


         user { 'oracle':
                home => '/u01/app/oracle',
                ensure => 'present',
                uid => '505',
                shell => '/bin/bash',
                password_max_age => '99999',
                password => 'manager',
                gid => '505',
                groups => ['oinstall'],
              } ->


        host { 'oas-localhost':
               ensure => 'present',
               target => '/etc/hosts',
               ip => $ipaddress_eth0,
               host_aliases =>  $hostname,
             } ->



        file { '/usr/lib/libdb.so.2':
               ensure => 'link',
               target => '/usr/lib/libgdbm.so.2.0.0',
             }
  }

}
