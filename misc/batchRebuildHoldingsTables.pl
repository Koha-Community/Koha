#!/usr/bin/perl
# Small script that rebuilds the non-MARC Holdings DB

use strict;
use warnings;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used
use MARC::Record;
use C4::Context;
use C4::Holdings;

use Getopt::Long;

my ($input_marc_file, $number) = ('', 0);
my ($help, $confirm, $test_parameter);
GetOptions(
    'c' => \$confirm,
    'h' => \$help,
    't' => \$test_parameter,
);

if ($help || !$confirm) {
    print <<EOF
This script rebuilds the non-MARC Holdings DB from the MARC values.
You can/must use it when you change the mappings.

Example: you decide to map holdings.callnumber to 852\$k\$l\$m (it was previously mapped to 852\$k).

Syntax:
\t./batchRebuildHoldingsTables.pl -h (or without arguments => shows this screen)
\t./batchRebuildHoldingsTables.pl -c (c like confirm => rebuild non-MARC DB (may takes long)
\t-t => test only, change nothing in DB
EOF
;
    exit;
}

my $dbh = C4::Context->dbh;
my $i = 0;
my $starttime = time();

$| = 1; # flushes output
$starttime = time();

my $sth = $dbh->prepare("SELECT holding_id FROM holdings");
$sth->execute();
my @errors;
while (my ($holding_id) = $sth->fetchrow()) {
    my $record = C4::Holdings::GetMarcHolding($holding_id);
    if (not defined $record) {
        push @errors, $holding_id;
        next;
    }
    my $rowData = C4::Holdings::TransformMarcHoldingToKoha($record);
    my $frameworkcode = C4::Holdings::GetHoldingFrameworkCode($holding_id);
    C4::Holdings::_koha_modify_holding($dbh, $holding_id, $rowData, $frameworkcode) unless $test_parameter;
    ++$i;
}
$sth->finish();
my $timeneeded = time() - $starttime;
print "$i MARC records done in $timeneeded seconds\n";
if (scalar(@errors) > 0) {
    print 'Records that could not be processed: ', join(' ', @errors);
}
