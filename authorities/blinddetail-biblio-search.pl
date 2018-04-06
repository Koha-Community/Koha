#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

=head1 NAME

blinddetail-biblio-search.pl : script to show an authority in MARC format

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This script needs an authid

It shows the authority in a (nice) MARC format depending on authority MARC
parameters tables.

=head1 FUNCTIONS

=cut

use strict;
use warnings;

use C4::AuthoritiesMarc;
use C4::Auth;
use C4::Context;
use C4::Output;
use CGI qw ( -utf8 );
use MARC::Record;
use C4::Koha;

use Koha::Authorities;
use Koha::Authority::Types;

my $query = new CGI;

my $dbh = C4::Context->dbh;

my $authid       = $query->param('authid');
my $index        = $query->param('index');
my $tagid        = $query->param('tagid');
my $relationship = $query->param('relationship');

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "authorities/blinddetail-biblio-search.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 'edit_catalogue' },
    }
);

# Extract the tag number from the index
my $tag_number = $index;
$tag_number =~ s/^tag_(\d*)_.*$/$1/;

# fill arrays
my @subfield_loop;
my ($indicator1, $indicator2);
if ($authid) {
    my $auth = Koha::Authorities->find( $authid );
    my $authtypecode = $auth ? $auth->authtypecode : q{};
    my $auth_type = Koha::Authority::Types->find($authtypecode);
    my $record = GetAuthority($authid);
    my @fields = $record->field( $auth_type->auth_tag_to_report );
    my $repet = ($query->param('repet') || 1) - 1;
    my $field = $fields[$repet];

    # Get all values for each distinct subfield and add to subfield loop
    my %done_subfields;
    for ( $field->subfields ) {
        next if $_->[0] eq '9'; # $9 will be set with authid value
        my $letter = $_->[0];
        $letter ||= '@';
        next if defined $done_subfields{$letter};
        my @values = $field->subfield($letter);
        push @subfield_loop, {marc_subfield => $letter, marc_values => @values };
        $done_subfields{$letter} = 1;
    }

    push( @subfield_loop, { marc_subfield => 'w', marc_values => $relationship } ) if ( $relationship );

    my $controlled_ind = $auth->controlled_indicators({ record => $record, biblio_tag => $tag_number });
    $indicator1 = $controlled_ind->{ind1};
    $indicator2 = $controlled_ind->{ind2};
    if( defined $controlled_ind->{sub2} ) {
        my $v = $controlled_ind->{sub2};
        push @subfield_loop, { marc_subfield => '2', marc_values => [ $v ] };
    }
} else {
    # authid is empty => the user want to empty the entry.
    $template->param( "clear" => 1 );
}



$template->param(
    authid          => $authid ? $authid : "",
    index           => $index,
    tagid           => $tagid,
    update_ind1     => defined($indicator1),
    indicator1      => $indicator1,
    update_ind2     => defined($indicator2),
    indicator2      => $indicator2,
    SUBFIELD_LOOP   => \@subfield_loop,
    tag_number      => $tag_number,
    rancor          => $index =~ /rancor$/,
);


output_html_with_http_headers $query, $cookie, $template->output;
