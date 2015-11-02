class oas-localhost {

  class { 'oas-localhost::prereqs': } ->
  class { 'oas-localhost::install': } ->
#  class { 'oas-localhost::service': } 
  ssoreg { 'oastest10.mercurio.com': 
           partnerapp => 'oastest10.mercurio.com',
         } ->

  ssocfg { 'sso.mercurio.com':
           ssohost  => 'sso.mercurio.com',
           ssoproto => 'http',
           ssoport  => '80',
         }

}
