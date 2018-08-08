#! /usr/bin/perl

use Modern::Perl;
use C4::Context;

my $dbh=C4::Context->dbh;

################
# IntranetCoce #
################

# validate systempreferences.Coce and save the config for OpacCoce
my $current_coce_pref = C4::Context->preference('Coce') || 0;

# add two new systempreferences in order to have distinct behavior between intranet and OPAC
$dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
        ('IntranetCoce','0', NULL, 'If on, enables cover retrieval from the configured Coce server in the staff client', 'YesNo'),
        ('OpacCoce','$current_coce_pref', NULL, 'If on, enables cover retrieval from the configured Coce server in the OPAC', 'YesNo')
        ;") or die "Error applying Bug 18421: error inserting new values into database: ". $dbh->errstr . "\n";

$dbh->do("DELETE IGNORE FROM systempreferences WHERE variable = 'Coce';")
    or die "Error applying Bug 18421: error deleting the old syspref 'Coce': ". $dbh->errstr . "\n";

print "Upgrade to XX.XX done (Bug 18421: Add Coce image cache to the Intranet)\n";
