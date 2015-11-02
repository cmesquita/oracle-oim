define oas-localhost::ssoreg ( $partnerapp = undef , $oraclehome = '/u02/app/oracle/product/oas/10.1.2' ) {



         exec { 'parterapp':
                command    => "$oraclehome/sso/bin/ssoreg.sh -oracle_home_path ${oraclehome} -site_name ${partnerapp} -config_mod_osso TRUE -mod_osso_url http://${partnerapp} -config_file ${oraclehome}/Apache/Apache/conf/osso/${partnerapp}.conf",
                cwd        => $oraclehome,
                environment => ["ORACLE_HOME=${oraclehome}"],
                path       => ["${oraclehome}/bin","${oraclehome}/opmn/bin","${oraclehome}/dcm/bin","/usr/bin/","/usr/sbin","/bin"],
                timeout    => 0,
                creates    => "${oraclehome}/Apache/Apache/conf/osso/${partnerapp}.conf",   
#                notify     => service['oas'],
                user       => 'oracle',
              } 
}
