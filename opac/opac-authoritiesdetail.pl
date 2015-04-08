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

opac-authoritiesdetail.pl : script to show an authority in MARC format

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

my $display_hierarchy = C4::Context->preference("AuthDisplayHierarchy");
my $show_marc = $query->param('marc');

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => $show_marc ? "opac-auth-MARCdetail.tt" : "opac-auth-detail.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        debug           => 1,
    }
);

my $authid = $query->param('authid');
$authid = int($authid);
my $record = GetAuthority( $authid );
if ( ! $record ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl"); # escape early
    exit;
}

my $authtypecode = &GetAuthTypeCode( $authid );

if ($display_hierarchy){
    $template->{VARS}->{'displayhierarchy'} = $display_hierarchy;
    $template->{VARS}->{'loophierarchies'} = GenerateHierarchy($authid);
}

my $count = CountUsage($authid);


my $authtypes     = getauthtypes();
my @authtypesloop = ();
foreach my $thisauthtype ( keys %{$authtypes} ) {
    push @authtypesloop,
         { value        => $thisauthtype,
           selected     => $thisauthtype eq $authtypecode,
           authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
         };
}
$template->{VARS}->{'authtypesloop'} = \@authtypesloop;
$template->{VARS}->{'authtypetext'}  = $authtypes->{$authtypecode}{'authtypetext'};
$template->{VARS}->{'authid'}        = $authid;
$template->{VARS}->{'count'}         = $count;

# find the marc field/subfield used in biblio by this authority
if ($show_marc) {
    my $tagslib = &GetTagsLabels( 0, $authtypecode );
    my $sth =
        $dbh->prepare(
                "select distinct tagfield from marc_subfield_structure where authtypecode=?"
                );
    $sth->execute($authtypecode);
    my $biblio_fields;
    while ( my ($tagfield) = $sth->fetchrow ) {
        $biblio_fields .= $tagfield . "9,";
    }
    chop $biblio_fields;

# fill arrays
    my @loop_data = ();
    my $tag;

# loop through each tag
    my @fields    = $record->fields();
    foreach my $field (@fields) {
        my @subfields_data;

# skip UNIMARC fields <200, they are useless for a patron
        next if C4::Context->preference('marcflavour') eq 'UNIMARC' && $field->tag() <200;

# if tag <10, there's no subfield, use the "@" trick
        if ( $field->tag() < 10 ) {
            next if ( $tagslib->{ $field->tag() }->{'@'}->{hidden} );
            my %subfield_data;
            $subfield_data{marc_lib}   = $tagslib->{ $field->tag() }->{'@'}->{lib};
            $subfield_data{marc_value} = $field->data();
            $subfield_data{marc_subfield} = '@';
            $subfield_data{marc_tag}      = $field->tag();
            push( @subfields_data, \%subfield_data );
        }
        elsif ( C4::Context->preference('marcflavour') eq 'MARC21' && $field->tag() eq 667 ) {
            # tagfield 667 is a nonpublic general note in MARC21, which shouldn't be shown in the OPAC
        }
        else {
            my @subf = $field->subfields;

# loop through each subfield
            for my $i ( 0 .. $#subf ) {
                $subf[$i][0] = "@" unless defined $subf[$i][0];
                next if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{hidden} );
# skip useless subfields (for patrons)
                next if $subf[$i][0] =~ /7|8|9/;
                my %subfield_data;
                $subfield_data{marc_lib} =
                    $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{lib};
                $subfield_data{marc_subfield} = $subf[$i][0];
                $subfield_data{marc_tag}      = $field->tag();
                $subfield_data{isurl} =  $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{isurl};
                $subfield_data{marc_value} = $subf[$i][1];
                push( @subfields_data, \%subfield_data );
            }
        }
        if ( $#subfields_data >= 0 ) {
            my %tag_data;
            $tag_data{tag} =
                $field->tag()
                . ' '
                . C4::Koha::display_marc_indicators($field)
                . ' - ' . $tagslib->{ $field->tag() }->{lib};
            $tag_data{subfield} = \@subfields_data;
            push( @loop_data, \%tag_data );
        }
    }
    $template->param( "Tab0XX" => \@loop_data );
} else {
    my $summary = BuildSummary($record, $authid, $authtypecode);
    $template->{VARS}->{'summary'} = $summary;
}

output_html_with_http_headers $query, $cookie, $template->output;
