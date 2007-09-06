
Koha Configuration Files:

The following files specify the base configuration for Koha ZOOM:

 * koha-httpd.conf  
In a debian system, this apache configuration file will be symlinked
from /etc/apache2/sites-enabled
Specify Koha's IP address with NameVirtualHost
Set ServerName, etc

 * koha-production.xml  
 * koha-testing.xml 
These are the production and testing configurations for zebrasrv and for Koha.
The first part of each file specifies Zebra server names, indexing configuration files,
and query language configurations.  Koha configuration directives follow. 

 * zebra-authorities.cfg  
 * zebra-biblios.cfg

