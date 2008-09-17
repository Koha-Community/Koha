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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 NAME

blinddetail-biblio-search.pl : script to show an authority in MARC format

=head1 SYNOPSIS


=head1 DESCRIPTION

This script needs an authid

It shows the authority in a (nice) MARC format depending on authority MARC
parameters tables.

=head1 FUNCTIONS

=over 2

=cut

use strict;

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
my $authtypecode = &GetAuthTypeCode($authid);
my $tagslib      = &GetTagsLabels( 1, $authtypecode );

my $auth_type = GetAuthType($authtypecode);
my $record = GetAuthority($authid) if $authid;

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "authorities/blinddetail-biblio-search.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
    }
);

# fill arrays
my $tag;
my @loop_data = ();
if ($authid) {
    foreach my $field ( $record->field( $auth_type->{auth_tag_to_report} ) ) {
        my @subfields_data;
        my @subf = $field->subfields;

        # loop through each subfield
        my %result;
        for my $i ( 0 .. $#subf ) {
            $subf[$i][0] = "@" unless $subf[$i][0];
            $result{ $subf[$i][0] } .= $subf[$i][1] . "|";
        }
        foreach ( keys %result ) {
            my %subfield_data;
            chop $result{$_};
            $subfield_data{marc_value}    = $result{$_};
            $subfield_data{marc_subfield} = $_;

            # $subfield_data{marc_tag}=$field->tag();
            push( @subfields_data, \%subfield_data );
        }
        if ( $#subfields_data >= 0 ) {
            my %tag_data;
            $tag_data{tag} = $field->tag() . ' -' . $tagslib->{ $field->tag() }->{lib};
            $tag_data{subfield} = \@subfields_data;
            push( @loop_data, \%tag_data );
        }
    }
} else {
    # authid is empty => the user want to empty the entry.
    $template->param( "clear" => 1 );
#     warn Data::Dumper::Dumper(\@loop_data);
}

$template->param( "0XX" => \@loop_data );

$template->param(
    authid => $authid ? $authid : "",
    index  => $index,
    tagid  => $tagid,
);

output_html_with_http_headers $query, $cookie, $template->output;

