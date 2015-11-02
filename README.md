# Oracle-OIM
repository to install an oracle identity management product (needs the template binaries called oas-localhost.tar.gz) 

## CLASS  Prereqs , install and service 
Checks operating system prereqs, install Oracle Identity Management and creates the required operating system services. 
The classes has hardcoded the installation path and it requires the "oas-locahost" /etc/hosts entry.  


class  { 'oas-localhost::prereqs': }

class { 'oas-localhost::install': }

class { 'oas-localhost::service': }


## RESOURCE TYPES

### TYPE: SSOREG
Creates partnerapps dinamically ( runs ssoreg command )

ssoreg { 'oastest10.mercurio.com':
           partnerapp => 'oastest10.mercurio.com',
         } ->

### TYPE: SSOCFG 
Creates sso configuration site ( runs ssocfg command )

		 ssocfg { 'sso.mercurio.com':
           ssohost  => 'sso.mercurio.com',
           ssoproto => 'http',
           ssoport  => '80',
         }

}