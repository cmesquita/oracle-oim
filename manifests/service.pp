class oas-localhost::service {

 if $operatingsystemrelease == '5.5' {

          service { "oracle":
               ensure => "running",
               } 


          service { "oas":
               ensure => "running",
             }


  }

}
