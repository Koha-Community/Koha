#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
use CGI;
use MARC::Record;
use C4::Koha;

my $query = new CGI;

my $dbh = C4::Context->dbh;

my $authid       = $query->param('authid');
my $index        = $query->param('index');
my $tagid        = $query->param('tagid');
my $relationship = $query->param('relationship');
my $authtypecode = &GetAuthTypeCode($authid);
my $tagslib      = &GetTagsLabels( 1, $authtypecode );

my $auth_type = GetAuthType($authtypecode);
my $record;
if ($authid) {
    $record = GetAuthority($authid);
}

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "authorities/blinddetail-biblio-search.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 'edit_catalogue' },
    }
);

# fill arrays
my @subfield_loop;
if ($authid) {
    my @fields = $record->field( $auth_type->{auth_tag_to_report} );
    my $repet = ($query->param('repet') || 1) - 1;
    my $field = $fields[$repet];

    # Get all values for each distinct subfield
    my %subfields;
    for ( $field->subfields ) {
        my $letter = $_->[0];
        next if defined $subfields{$letter};
        my @values = $field->subfield($letter);
        $subfields{$letter} = \@values;
    }

    # Add all subfields to the subfield_loop
    for( keys %subfields ) {
        my $letter = $_ || '@';
        push( @subfield_loop, {marc_subfield => $letter, marc_values => $subfields{$_}} );
    }

    push( @subfield_loop, { marc_subfield => 'w', marc_values => $relationship } ) if ( $relationship );
}
else {
    # authid is empty => the user want to empty the entry.
    $template->param( "clear" => 1 );
}

# Extract the tag number from the index
my $tag_number = $index;
$tag_number =~ s/^tag_(\d*)_.*$/$1/;

$template->param(
    authid          => $authid ? $authid : "",
    index           => $index,
    tagid           => $tagid,
    SUBFIELD_LOOP   => \@subfield_loop,
    tag_number      => $tag_number,
);

output_html_with_http_headers $query, $cookie, $template->output;

