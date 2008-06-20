#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


=head1 NAME

newordersuggestion.pl

=head1 DESCRIPTION

this script allow to add an order from a existing suggestion.
The suggestion must have 'ACCEPTED' as status.

=head1 CGI PARAMETERS

=over 4

=item basketno

    the number of this basket.

=item booksellerid

    the bookseller who sells this record.

=item title

    to filter on title when searching among ACCEPTED suggestion.

=item author

    to filter on author when searching among ACCEPTED suggestion.

=item note

    to filter on note when searching among ACCEPTED suggestion.

=item copyrightdate

=item publishercode

=item volumedesc

=item publicationyear

the publication year of this record.

=item place

=item isbn

the isbn of this suggestion.

=item duplicateNumber

is the biblionumber to put to the new suggestion.

=item suggestionid

the id of the suggestion to select.

=item op

can be equal to
    * connectDuplicate :
        then call to the function : ConnectSuggestionAndBiblio.
        i.e set the biblionumber of this suggestion.
    * else :
        is the default value.

=back

=cut

use strict;
require Exporter;
use CGI;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Suggestions;
use C4::Bookseller;
use C4::Biblio;

my $input = new CGI;

# getting the CGI params
my $basketno        = $input->param('basketno');
my $supplierid      = $input->param('booksellerid');
my $author          = $input->param('author');
my $title           = $input->param('title');
my $publishercode   = $input->param('publishercode');
my $op              = $input->param('op');
my $suggestionid    = $input->param('suggestionid');
my $duplicateNumber = $input->param('duplicateNumber');

$op = 'else' unless $op;

my $dbh = C4::Context->dbh;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/newordersuggestion.tmpl",
        type            => "intranet",
        query           => $input,
        authnotrequired => 1,
        flagsrequired   => { acquisition => 1 },
    }
);

if ( $op eq 'connectDuplicate' ) {
    ConnectSuggestionAndBiblio( $suggestionid, $duplicateNumber );
}

# getting all suggestions.
my $suggestions_loop =
  &SearchSuggestion( $borrowernumber, $author, $title, $publishercode,'ACCEPTED',
    -1 );
my $vendor = GetBookSellerFromId($supplierid);
$template->param(
    suggestions_loop        => $suggestions_loop,
    basketno                => $basketno,
    supplierid              => $supplierid,
	name					=> $vendor->{'name'},
    "op_$op"                => 1,
);

output_html_with_http_headers $input, $cookie, $template->output;
