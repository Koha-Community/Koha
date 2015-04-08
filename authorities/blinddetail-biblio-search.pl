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
        template_name   => "authorities/blinddetail-biblio-search.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 'edit_catalogue' },
    }
);

# fill arrays
my @subfield_loop;
my ($indicator1, $indicator2);
if ($authid) {
    my @fields = $record->field( $auth_type->{auth_tag_to_report} );
    my $repet = ($query->param('repet') || 1) - 1;
    my $field = $fields[$repet];

    # Get all values for each distinct subfield
    my %subfields;
    for ( $field->subfields ) {
        next if $_->[0] eq '9'; # $9 will be set with authid value
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
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        $indicator1 = $field->indicator('1');
        $indicator2 = $field->indicator('2');
    } elsif (C4::Context->preference('marcflavour') eq 'MARC21') {
        my $tag_from = $auth_type->{auth_tag_to_report};
        my $tag_to = $index;
        $tag_to =~ s/^tag_(\d*)_.*$/$1/;
        if ($tag_to =~ /^6/) {  # subject heading
            my %thes_mapping = qw / a 0
                                    b 1
                                    c 2
                                    d 3
                                    k 5
                                    n 4
                                    r 7
                                    s 7
                                    v 6
                                    z 7
                                    | 4 /;
            my $thes_008_11 = '';
            $thes_008_11 = substr($record->field('008')->data(), 11, 1) if $record->field('008')->data();
            $indicator2 = defined $thes_mapping{$thes_008_11} ? $thes_mapping{$thes_008_11} : $thes_008_11;
            if ($indicator2 eq '7') {
                if ($thes_008_11 eq 'r') {
                    $subfields{'2'} = ['aat'];
                } elsif ($thes_008_11 eq 's') {
                    $subfields{'2'} = ['sears'];
                }
            }
        }
        if ($tag_from eq '130') {  # unified title -- the special case
            if ($tag_to eq '830' || $tag_to eq '240') {
                $indicator2 = $field->indicator('2');
            } else {
                $indicator1 = $field->indicator('2');
            }
        } else {
            $indicator1 = $field->indicator('1');
        }
    }
}
else {
    # authid is empty => the user want to empty the entry.
    $template->param( "clear" => 1 );
}

# Extract the tag number from the index
my $tag_number = $index;
$tag_number =~ s/^tag_(\d*)_.*$/$1/;

# Remove spaces in indicators
$indicator1 =~ s/\s//g;
$indicator2 =~ s/\s//g;

$template->param(
    authid          => $authid ? $authid : "",
    index           => $index,
    tagid           => $tagid,
    indicator1      => $indicator1,
    indicator2      => $indicator2,
    SUBFIELD_LOOP   => \@subfield_loop,
    tag_number      => $tag_number,
);

output_html_with_http_headers $query, $cookie, $template->output;

