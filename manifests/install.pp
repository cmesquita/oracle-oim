class oas-localhost::install {

 if $operatingsystemrelease == '5.5' {


         file { '/tmp/u01.tar.gz':
                 ensure => present,
                 source => 'puppet:///modules/oas-localhost/u01.tar.gz',
                 mode   => '0755'
              } ->



         archive::extract {"u01":
                 timeout=>0,
                 ensure => present,
                 src_target => "/tmp",
                 target => "/",
                 } ->


         exec { "/bin/chown oracle:oinstall -R /u01":
                 unless => "/bin/sh -c '[ $(/usr/bin/stat -c %U /u01) == oracle ]'",
              } ->
        

         exec { "/bin/chown oracle:oinstall -R /u02":
                 unless => "/bin/sh -c '[ $(/usr/bin/stat -c %U /u02) == oracle ]'",
              } ->


         file { '/u02/app/oracle/product/oas/10.1.2/root.sh':
                 ensure => present,
                 source => 'puppet:///modules/oas-localhost/root.sh',
                 mode   => '0755'
              } ->


         exec { "/u02/app/oracle/product/oas/10.1.2/root.sh":
                cwd     => "/u02/app/oracle/product/oas/10.1.2",
                path    => ["/u02/app/oracle/product/oas/10.1.2"],
                timeout => 0,
                user => "root",                
                unless => "/bin/sh -c '[ $(/usr/bin/stat -c %U oidldapd) == oracle ]'"
              } ->


         file { '/etc/oratab':
                ensure => present,
                source => 'puppet:///modules/oas-localhost/oratab',
                mode   => '0755',
                owner  => 'root',
              } ->



         file { '/etc/init.d/oracle':
                ensure => present,
                source => 'puppet:///modules/oas-localhost/oracle',
                mode   => '0755',
                owner  => 'root'
              } ->


          file { '/etc/rc3.d/S100oracle':
               ensure => 'link',
               target => '/etc/init.d/oracle',
             } ->


          file { '/etc/rc3.d/K100oracle':
               ensure => 'link',
               target => '/etc/init.d/oracle',
             } ->


         file { '/etc/init.d/oas':
                ensure => present,
                source => 'puppet:///modules/oas-localhost/oas',
                mode   => '0755',
                owner  => 'root'
              } ->


          file { '/etc/rc3.d/S100oas':
               ensure => 'link',
               target => '/etc/init.d/oas',
             } ->


          file { '/etc/rc3.d/K100oas':
               ensure => 'link',
               target => '/etc/init.d/oas',
             } 

  }

}
