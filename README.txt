Koha - award-winning GPL Integrated Library System.

Koha is a full-featured . Developed initially in New Zealand by Katipo
Communications Ltd and first deployed in January of 2000 for Horowhenua
Library Trust, it is currently maintained by a team of software providers
and library technology staff from around the globe.


STRUCTURE
=========

Koha 3.0 has been restructured from Koha 2.2 to use Zebra,
a high-performance, general-purpose structured text indexing and
retrieval engine.  Zebra speaks Z39.50, building on one of Koha's most
useful features.

General library data is held in MySQL, and Koha 3.0 supports MySQL 5,
using foreign keys and other recent features.

Apache 2 is the recommended web server and VirtualHost configuration
files are generated for it.


INSTALLATION
============

Koha 3.0 comes with a new installer, based on MakeMaker, the tool that
is usually used to install CPAN modules.  This means that if you know
how to customise CPAN-installed modules, the same things should work
for you with Koha.

You need to have a server running MySQL 5, Zebra and some webserver
(preferably Apache) before installing Koha.  Create a database in
MySQL called koha and 

Default installation instructions:

1. perl Makefile.PL
2. make
3. sudo make install
4. ln -s /usr/lib/perl5/site-perl/*/koha/etc/koha-httpd.conf /etc/apache2/sites-available/koha
5. a2ensite koha && /etc/init.d/apache reload
6. zebrasrv -c /usr/lib/perl5/site-perl/*/koha/etc/koha-conf.xml
7. Browse to http://servername:8080/ and answer the questions

OR if you want to install all dependencies from CPAN and are root, you can
replace steps 1-3 with "perl install-CPAN.pl" but this is non-standard and
may not be safe.  Nevertheless, it's pretty cool when it works.

For instructions on how to override the default settings, run
perldoc rewrite-config.PL


DEVELOPER NOTES

For instructions on how to package releases, run perldoc Makefile.PL
