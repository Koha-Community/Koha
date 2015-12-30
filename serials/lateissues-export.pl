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
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Serials;
use C4::Acquisition;
use C4::Output;
use C4::Context;

use Koha::CsvProfiles;

use Text::CSV_XS;

my $query = new CGI;
my $supplierid = $query->param('supplierid');
my @serialids = $query->multi_param('serialid');
my $op = $query->param('op') || q{};

my $csv_profile_id = $query->param('csv_profile');
my $csv_profile = Koha::CsvProfiles->find( $csv_profile_id );
die "There is no valid csv profile given" unless $csv_profile;

my $csv = Text::CSV_XS->new({
    'quote_char'  => '"',
    'escape_char' => '"',
    'sep_char'    => $csv_profile->csv_separator,
    'binary'      => 1
});

my $content = $csv_profile->content;
my ( @headers, @fields );
while ( $content =~ /
    ([^=]+) # header
    =
    ([^\|]+) # fieldname (table.row or row)
    \|? /gxms
) {
    push @headers, $1;
    my $field = $2;
    $field =~ s/[^\.]*\.?//; # Remove the table name if exists.
    push @fields, $field;
}

my @rows;
for my $serialid ( @serialids ) {
    my @missingissues = GetLateOrMissingIssues($supplierid, $serialid);
    my $issue = $missingissues[0];
    my @row;
    for my $field ( @fields ) {
        push @row, $issue->{$field};
    }
    push @rows, \@row;

    # update claim date to let one know they have looked at this missing item
    updateClaim($serialid);
}

print $query->header(
    -type       => 'plain/text',
    -attachment => "serials-claims.csv",
);

print join( $csv_profile->csv_separator, @headers ) . "\n";

for my $row ( @rows ) {
    $csv->combine(@$row);
    my $string = $csv->string;
    print $string, "\n";
}
