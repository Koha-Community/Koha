#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Script;

use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );
use MARC::Field;

use C4::Biblio;
use Koha::Biblios;
use Koha::DateUtils qw( dt_from_string );

my ( $verbose, $help, $confirm, $where, @fields, $date_field, $unless_exists_field );
my $dbh = C4::Context->dbh;

GetOptions(
    'help|h'    => \$help,
    'verbose|v' => \$verbose,
    'confirm|c' => \$confirm,
    'where=s'   => \$where,
    'field=s@'  => \@fields,
    'date-field=s' => \$date_field,
    'unless-exists=s' => \$unless_exists_field,
) || podusage(1);

pod2usage(1) if $help;
pod2usage("Parameter field is mandatory") unless @fields;

say "Confirm flag not passed, running in dry-run mode..." unless $confirm;

my @fields_to_add;
unless ( $date_field ) {
    my $dt = dt_from_string;
    for my $field (@fields) {
        my ( $f_sf, $value )    = split '=',  $field;
        my ( $tag,  $subfield ) = split '\$', $f_sf;
        push @fields_to_add,
          MARC::Field->new( $tag, '', '', $subfield => $dt->strftime($value) );
    }

    if ($verbose) {
        say "The following MARC fields will be added:";
        say "\t" . $_->as_formatted for @fields_to_add;
    }
}

$where = $where ? "WHERE $where" : '';
my $sth =
  $dbh->prepare("SELECT biblionumber, frameworkcode FROM biblio $where");
$sth->execute();

while ( my ( $biblionumber, $frameworkcode ) = $sth->fetchrow_array ) {
    my $biblio = Koha::Biblios->find($biblionumber);
    my $marc_record = $biblio->metadata->record;
    next unless $marc_record;
    if ( $unless_exists_field ) {
        my ( $tag,  $subfield ) = split '\$', $unless_exists_field;
        next if $marc_record->subfield($tag, $subfield);
    }
    if ( $date_field ) {
        my ( $tag,  $subfield ) = split '\$', $date_field;
        my $date = $marc_record->subfield($tag, $subfield);
        next unless $date;
        warn $date;
        my $dt = dt_from_string($date);
        for my $field (@fields) {
            my ( $f_sf, $value )    = split '=',  $field;
            my ( $tag,  $subfield ) = split '\$', $f_sf;
            push @fields_to_add,
              MARC::Field->new( $tag, '', '', $subfield => $dt->strftime($value) );
        }
        if ($verbose) {
            say sprintf "The following MARC fields will be added to record %s:", $biblionumber;
            say "\t" . $_->as_formatted for @fields_to_add;
        }
    }

    $marc_record->append_fields(@fields_to_add);

    if ($confirm) {
        my $modified =
          C4::Biblio::ModBiblio( $marc_record, $biblionumber, $frameworkcode );
        say "Bibliographic record $biblionumber has been modified"
          if $verbose and $modified;
    }
    elsif ($verbose) {
        say "Bibliographic record $biblionumber would have been modified";
    }
}

=head1 NAME

add_date_fields_to_marc_records.pl

=head1 SYNOPSIS

  perl add_date_fields_to_marc_records.pl --help

  perl add_date_fields_to_marc_records.pl --field='905$a=0/%Y' --field='905$a=1/%Y/%b-%m' --field='905$a=2/%Y/%b-%m/%d' --unless-exists='905$a' --verbose --confirm

  perl add_date_fields_to_marc_records.pl --field='905$a=0/%Y' --field='905$a=1/%Y/%b-%m' --field='905$a=2/%Y/%b-%m/%d' --unless-exists='905$a' --where "biblionumber=42" --verbose --confirm

  perl add_date_fields_to_marc_records.pl --field='905$a=0/%Y' --field='905$a=1/%Y/%b-%m' --field='905$a=2/%Y/%b-%m/%d' --date-field='908$a' --verbose --confirm

=head1 DESCRIPTION

Add some MARC fields to bibliographic records.

The replacement tokens are the ones used by strftime.

=head1 OPTIONS

=over 8

=item B<--help>

Prints this help

=item B<--verbose>

Verbose mode.

=item B<--confirm>

Confirmation flag, the script will be running in dry-run mode if set not.

=item B<--where>

Limits the search on bibliographic records with a user-specified WHERE clause.

Only the columns from the biblio table are available.

=item B<--field>

Fields to add to the bibliographic records.

Must be formatted as 'tag' $ 'subfield' = 'value'

For instance:

905$a=0/%Y will add a new field 905$a with the value '0/2019' (if run in 2019)

905$a=2/%Y/%b-%m/%d'will a a new field 905$a with the value '2/2019/Mar-03/13' if run on March 13th 2019

=item B<--unless-exists>

Will only create the new fields if this field does not exist.

For instance, if --field='905$a=0/%Y' and --unless-exists='905$a' are provided, a 905$a will be created unless there is already one.
If --unless-exists is not passed, a new 905$a will be created in any case.

=item B<--date-field>

The date will be picked from a specific marc field.

For instance, if the record contains a date formatted YYYY-MM-DD in 908$a, you can pass --date-field='908$a'
Note that the date format used will be the one defined in the syspref 'dateformat', or iso format.

=back

=cut
