define oas-localhost::ssocfg (  $ssoproto = 'http' , $ssohost = undef , $ssoport = '80', $oraclehome = '/u02/app/oracle/product/oas/10.1.2' ) {

         file { "${oraclehome}/operationUrl.txt":
                ensure => present,
                source => 'puppet:///modules/oas-localhost/operationUrl.txt',
                mode   => '0755',
                owner  => 'root'
              } ->

         
         exec { $ssohost :
                command    => "$oraclehome/sso/bin/ssoreg.sh -oracle_home_path ${oraclehome} -site_name ${ssohost} -config_mod_osso TRUE -mod_osso_url http://${ssohost} -config_file ${oraclehome}/Apache/Apache/conf/osso/${ssohost}.conf",
                cwd        => $oraclehome,
                environment => ["ORACLE_HOME=${oraclehome}"],
                path       => ["${oraclehome}/bin","${oraclehome}/opmn/bin","${oraclehome}/dcm/bin","/usr/bin/","/usr/sbin","/bin"],
                timeout    => 0,
                creates    => "${oraclehome}/Apache/Apache/conf/osso/${ssohost}.conf",
#                notify     => service['oas'],
                user       => 'oracle',
              }




         exec { 'ldapmodify':
                command => "${oraclehome}/bin/ldapmodify -D \"cn=orcladmin\" -w \"manager1\" -h oas-tnt-teste -p 389 -f ${oraclehome}/operationUrl.txt",
                cwd     => $oraclehome,
                environment => ["ORACLE_HOME=${oraclehome}"],
                path       => ["${oraclehome}/bin","${oraclehome}/opmn/bin","${oraclehome}/dcm/bin","/usr/bin/","/usr/sbin","/bin"],
                timeout => 0,
                creates => "${oraclehome}/Apache/Apache/conf/osso/${ssohost}.conf",
              } ->

          
         exec { 'ssocfg':
                command => "${oraclehome}/sso/bin/ssocfg.sh ${ssoproto} ${ssohost} ${ssoport}",
                cwd     => $oraclehome,
                environment => ["ORACLE_HOME=${oraclehome}"],
                path       => ["${oraclehome}/bin","${oraclehome}/opmn/bin","${oraclehome}/dcm/bin","/usr/bin/","/usr/sbin","/bin"],
                timeout => 0,
                creates => "${oraclehome}/Apache/Apache/conf/osso/${ssohost}.conf",   
              } 

}
