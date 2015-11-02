class oas-localhost::httpd ( $oraclehome = '/u02/app/oracle/product/oas/10.1.2' ) {

         file { "${oraclehome}/Apache/Apache/conf/httpd.conf":
                 ensure => present,
                 source => 'puppet:///modules/oas-localhost/httpd.conf',
                 mode   => '0755',
                 onwer  => 'oracle'
              } 

}
