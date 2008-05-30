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

use strict;
require Exporter;
use CGI;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Suggestions;

my $input           = new CGI;
my $title           = $input->param('title');
my $author          = $input->param('author');
my $note            = $input->param('note');
my $copyrightdate   = $input->param('copyrightdate');
my $publishercode   = $input->param('publishercode');
my $volumedesc      = $input->param('volumedesc');
my $publicationyear = $input->param('publicationyear');
my $place           = $input->param('place');
my $isbn            = $input->param('isbn');
my $status          = $input->param('status');
my $suggestedbyme   = (defined $input->param('suggestedbyme')? $input->param('suggestedbyme'):1);
my $op              = $input->param('op');
$op = 'else' unless $op;

my ( $template, $borrowernumber, $cookie );

my $dbh = C4::Context->dbh;

if ( C4::Context->preference("AnonSuggestions") ) {
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-suggestions.tmpl",
            query           => $input,
            type            => "opac",
            authnotrequired => 1,
        }
    );
    if ( !$borrowernumber ) {
        $borrowernumber = C4::Context->preference("AnonSuggestions");
    }
}
else {
    ( $template, $borrowernumber, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-suggestions.tmpl",
            query           => $input,
            type            => "opac",
            authnotrequired => 0,
        }
    );
}

if ( $op eq "add_confirm" ) {
    &NewSuggestion(
        $borrowernumber, $title,         $author,     $publishercode,
        $note,           $copyrightdate, $volumedesc, $publicationyear,
        $place,          $isbn,          ''
    );

    # empty fields, to avoid filter in "SearchSuggestion"
    $title           = '';
    $author          = '';
    $publishercode   = '';
    $copyrightdate   = '';
    $volumedesc      = '';
    $publicationyear = '';
    $place           = '';
    $isbn            = '';
    $op              = 'else';
}

if ( $op eq "delete_confirm" ) {
    my @delete_field = $input->param("delete_field");
    foreach my $delete_field (@delete_field) {
        &DelSuggestion( $borrowernumber, $delete_field );
    }
    $op = 'else';
}

my $suggestions_loop =
  &SearchSuggestion( $borrowernumber, $author, $title, $publishercode, $status,
    $suggestedbyme );
$template->param(
    suggestions_loop => $suggestions_loop,
    title            => $title,
    author           => $author,
    publishercode    => $publishercode,
    status           => $status,
    suggestedbyme    => $suggestedbyme,
    "op_$op"         => 1,
	suggestionsview => 1
);

output_html_with_http_headers $input, $cookie, $template->output;
