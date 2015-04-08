#!/usr/bin/perl

# Copyright 2011 BibLibre
#
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

# Script to export borrowers

use Modern::Perl;
use Text::CSV;
use Getopt::Long qw(:config no_ignore_case);

use C4::Context;
use C4::Members;

binmode STDOUT, ":encoding(UTF-8)";

sub print_usage {
    ( my $basename = $0 ) =~ s|.*/||;
    print <<USAGE;

$basename
    Export patron informations in CSV format.
    It prints to standard output. Use redirection to save CSV in a file.

Usage:
$0 [--field=FIELD [--field=FIELD [...]]] [--separator=CHAR] [--show-header] [--where=CONDITION]
$0 -h

    -f, --field=FIELD       Field to export. It is repeatable and has to match
                            keys returned by the GetMemberDetails function.
                            If no field is specified, then all fields will be
                            exported.
    -s, --separator=CHAR    This character will be used to separate fields.
                            Some characters like | or ; will need to be escaped
                            in the parameter setting, like -s=\\| or -s=\\;
                            If no separator is specifield, a comma will be used.
    -H, --show-header       Print field names on first row
    -w, --where=CONDITION   Condition to filter borrowers to export
                            (SQL where clause).
                            CONDITION must be enclosed by double quotes and
                            if needed, where value by single quotes.
                            example : --where "surname='De Lattre'"
    -h, --help              Show this help

USAGE
}

# Getting parameters
my @fields;
my $separator;
my $show_header;
my $where;
my $help;

GetOptions(
    'field|f=s'     => \@fields,
    'separator|s=s' => \$separator,
    'show-header|H' => \$show_header,
    'where|w=s'       => \$where,
    'help|h'        => \$help
) or print_usage, exit 1;

if ($help) {
    print_usage;
    exit;
}

# Getting borrowers
my $dbh   = C4::Context->dbh;
my $query = "SELECT borrowernumber FROM borrowers";
$query .= " WHERE $where" if ($where);
$query .= " ORDER BY borrowernumber";
my $sth   = $dbh->prepare($query);
$sth->execute;

my $csv = Text::CSV->new( { sep_char => $separator, binary => 1 } );

# If the user did not specify any field to export, we assume he wants them all
# We retrieve the first borrower informations to get field names
my ($borrowernumber) = $sth->fetchrow_array or die "No borrower to export";
my $member = GetMemberDetails($borrowernumber);
@fields = keys %$member unless (@fields);

if ($show_header) {
    $csv->combine(@fields);
    print $csv->string . "\n";
}

$csv->combine(
    map {
        ( defined $member->{$_} and !ref $member->{$_} )
          ? $member->{$_}
          : ''
      } @fields
);
die "Invalid character at borrower $borrowernumber: ["
  . $csv->error_input . "]\n"
  if ( !defined( $csv->string ) );
print $csv->string . "\n";

while ( my $borrowernumber = $sth->fetchrow_array ) {
    $member = GetMemberDetails($borrowernumber);
    $csv->combine(
        map {
            ( defined $member->{$_} and !ref $member->{$_} )
              ? $member->{$_}
              : ''
          } @fields
    );
    die "Invalid character at borrower $borrowernumber: ["
      . $csv->error_input . "]\n"
      if ( !defined( $csv->string ) );
    print $csv->string . "\n";
}
