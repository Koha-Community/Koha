#!/usr/bin/perl

# Copyright 2006 Biblibre
# Parts Copyright 2011 PTFS Europe
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

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

use Modern::Perl;

use CGI             qw ( -utf8 );
use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_html_with_http_headers );
use C4::Suggestions qw( ConnectSuggestionAndBiblio ModSuggestion );
use C4::Budgets;

use Koha::Acquisition::Booksellers;
use Koha::Suggestions;

my $input = CGI->new;

# getting the CGI params
my $basketno        = $input->param('basketno');
my $booksellerid    = $input->param('booksellerid');
my $author          = $input->param('author');
my $title           = $input->param('title');
my $publishercode   = $input->param('publishercode');
my $op              = $input->param('op');
my $suggestionid    = $input->param('suggestionid');
my $duplicateNumber = $input->param('duplicateNumber');
my $uncertainprice  = $input->param('uncertainprice');
my $link_order      = $input->param('link_order');

$op = 'else' unless $op;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "acqui/newordersuggestion.tt",
        type          => "intranet",
        query         => $input,
        flagsrequired => { acquisition => 'order_manage' },
    }
);

if ( $op eq 'connectDuplicate' ) {
    ConnectSuggestionAndBiblio( $suggestionid, $duplicateNumber );
}

if ( $op eq 'cud-link_order' and $link_order ) {
    my $order = Koha::Acquisition::Orders->find($link_order);

    if ( $order->biblionumber ) {
        ModSuggestion(
            {
                suggestionid => $suggestionid,
                biblionumber => $order->biblionumber,
                STATUS       => 'ORDERED',
            }
        );
        if ( C4::Context->preference('PlaceHoldsOnOrdersFromSuggestions') ) {
            my $suggestion = Koha::Suggestions->find($suggestionid);
            if ($suggestion) {
                $suggestion->place_hold();
            }
        }
    }

    print $input->redirect( "/cgi-bin/koha/acqui/basket.pl?basketno=" . $basketno );
}

my $suggestions = [
    Koha::Suggestions->search_limited(
        {
            ( $author        ? ( author        => $author )        : () ),
            ( $title         ? ( title         => $title )         : () ),
            ( $publishercode ? ( publishercode => $publishercode ) : () ),
            STATUS => 'ACCEPTED'
        },
        { prefetch => [ 'managedby', 'suggestedby' ] },
    )->as_list
];

my $vendor = Koha::Acquisition::Booksellers->find($booksellerid);
$template->param(
    suggestions  => $suggestions,
    basketno     => $basketno,
    booksellerid => $booksellerid,
    name         => $vendor->name,
    "op_$op"     => 1,
    link_order   => $link_order,
);

output_html_with_http_headers $input, $cookie, $template->output;
