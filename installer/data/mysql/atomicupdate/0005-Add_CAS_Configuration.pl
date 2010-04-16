#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;

$dbh->do("INSERT INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('casAuthentication', '1', '', 'Enable or disable CAS authentication', 'YesNo'), ('casLogout', '1', '', 'Does a logout from Koha should also log out of CAS ?', 'YesNo'), ('casServerUrl', 'https://localhost:8443/cas', '', 'URL of the cas server', 'Free')");
print "Upgrade done (added CAS authentication system preferences)\n";
