#!/usr/bin/perl
#
# This script should be used only with UNIMARC flavour
# It is designed to report some missing information from biblio
# table into marc data
#
use strict;
use warnings;

BEGIN {
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Biblio;
use Getopt::Long;

sub _read_marc_code {
    my $input = shift;
    my ( $field, $subfield );
    if ( $input =~ /^(\d{3})$/ ) {
        $field = $1;
    }
    elsif ( $input =~ /^(\d{3})(\w)$/ ) {
        $field    = $1;
        $subfield = $2;
    }
    return ( $field, $subfield );
}

my ( $run, $help, $verbose, $where, $date_created_marc, $date_modified_marc );
GetOptions(
    'help|h'                 => \$help,
    'verbose|v'              => \$verbose,
    'run'                    => \$run,
    'where:s'                => \$where,
    'date-created-marc|c:s'  => \$date_created_marc,
    'date-modified-marc|m:s' => \$date_modified_marc,
);
my $debug = $ENV{DEBUG};
$verbose = 1 if $debug;

# display help ?
if ($help) {
    print_usage();
    exit 0;
}

$verbose and print "================================\n";

# date created MARC field/subfield
$date_created_marc = '099c' unless $date_created_marc;
my ( $c_field, $c_subfield ) = _read_marc_code($date_created_marc);
die "date-created-marc '$date_created_marc' is not correct." unless $c_field;
if ($verbose) {
    print "Date created on $c_field";
    print $c_subfield if defined $c_subfield;    # use of defined to allow 0
    print "\n";
}

# date last modified MARC field/subfield
$date_modified_marc = '099d' unless $date_modified_marc;
my ( $m_field, $m_subfield ) = _read_marc_code($date_modified_marc);
die "date-modified-marc '$date_modified_marc' is not correct." unless $m_field;
die
"When date-created-marc and date-modified-marc are on same field, they should have distinct subfields"
  if ( $c_field eq $m_field )
  && ( !defined $c_subfield
    || !defined $m_subfield
    || $c_subfield eq $m_subfield );
if ($verbose) {
    print "Date last modified on $m_field";
    print $m_subfield if defined $m_subfield;    # use of defined to allow 0
    print "\n";
}

my $dbh;
my $sth_prepared;

sub updateMarc {
    my $id     = shift;
    my $biblio = GetMarcBiblio($id);

    unless ($biblio) {
        $debug and warn '[ERROR] GetMarcBiblio did not return any biblio.';
        return;
    }

    my $c_marc_field = $biblio->field($c_field);
    my $m_marc_field = $biblio->field($m_field);

    my $c_marc_value;
    if ($c_marc_field) {
        $c_marc_value =
          defined $c_subfield
          ? $c_marc_field->subfield($c_subfield)
          : $c_marc_field->data();
    }
    $c_marc_value = '' unless defined $c_marc_value;

    my $m_marc_value;
    if ($m_marc_field) {
        $m_marc_value =
          defined $m_subfield
          ? $m_marc_field->subfield($m_subfield)
          : $m_marc_field->data();
    }
    $m_marc_value ||= '';

    $sth_prepared = $dbh->prepare(
        q{
        SELECT
            DATE_FORMAT(datecreated,'%Y-%m-%d') AS datecreatediso,
            DATE_FORMAT(timestamp,'%Y-%m-%d') AS datemodifiediso,
            frameworkcode
        FROM biblio
        WHERE biblionumber = ?
    }
    ) unless $sth_prepared;
    $sth_prepared->execute($id);
    my $bibliorow     = $sth_prepared->fetchrow_hashref;
    my $frameworkcode = $bibliorow->{'frameworkcode'};
    my $c_db_value    = $bibliorow->{'datecreatediso'} || '';
    my $m_db_value    = $bibliorow->{'datemodifiediso'} || '';

    # do nothing if already sync
    return if ( $c_marc_value eq $c_db_value && $m_marc_value eq $m_db_value );

    # do apply to database ?
    return 1 unless $run;

    # update MARC record

    # date created field
    unless ($c_marc_field) {
        $biblio->add_fields( new MARC::Field( $c_field, '', '' ) );
        $debug and warn "[WARN] $c_field did not exist.";
        $c_marc_field = $biblio->field($c_field);

        # when on same field
        if ( $m_field eq $c_field ) {
            $m_marc_field = $c_marc_field;
        }
    }
    if ( defined $c_subfield ) {
        $c_marc_field->update( $c_subfield, $c_db_value );
    }
    else {
        $c_marc_field->update($c_db_value);
    }

    # date last modified field
    unless ($m_marc_field) {
        $biblio->add_fields( new MARC::Field( $m_field, '', '' ) );
        $debug and warn "[WARN] $m_field did not exist.";
        $m_marc_field = $biblio->field($m_field);
    }
    if ( defined $m_subfield ) {
        $m_marc_field->update( $m_subfield, $m_db_value );
    }
    else {
        $m_marc_field->update($m_db_value);
    }

    # apply to databse
    if ( &ModBiblio( $biblio, $id, $frameworkcode ) ) {
        return 1;
    }

    $debug and warn '[ERROR] ModBiblio failed.';
    return;
}

sub process {

    $dbh = C4::Context->dbh;
    my $mod_count = 0;

    my $query = q{
        SELECT biblionumber
        FROM biblio
        JOIN biblioitems USING (biblionumber)
    };
    $query .= qq{ WHERE $where} if $where;
    my $sth = $dbh->prepare($query);
    $sth->execute();

    $verbose and print "Number of concerned biblios: " . $sth->rows . "\n";

    while ( my $biblios = $sth->fetchrow_hashref ) {
        $verbose and print 'Bib ' . $biblios->{'biblionumber'} . ':';
        my $ret = updateMarc( $biblios->{'biblionumber'} );
        if ($ret) {
            $verbose and print 'modified';
            $mod_count++;
        }
        $verbose and print "\n";
    }

    $verbose and print "Number of modified biblios: " . $mod_count . "\n";
}

if ( lc( C4::Context->preference('marcflavour') ) eq "unimarc" ) {
    $verbose
      and !$run
      and print "*** Not in run mode, modifications will not be applyed ***\n";

    $verbose and print "================================\n";
    process();
}
else {
    print
"This script is UNIMARC only and should be used only on UNIMARC databases\n";
}

sub print_usage {
    print <<_USAGE_;
Synchronizes date created and date last modified from biblio table to MARC data.
Does not update biblio if dates are already synchronized.
UNIMARC specific.

Parameters:
    --help or -h                show this message
    --verbose or -v             verbose logging
    --run                       run the command else modifications will not be applyed to database
    --where                     (optional) use this to limit execution to some biblios :
                                write a SQL where clause using biblio and/or biblioitems fields
    --date-created-marc or c    (optional) date created MARC field and optional subfield,
                                099c by default
    --date-modified-marc or m   (optional) date last modified MARC field and optional subfield,
                                099d by default
_USAGE_
}
