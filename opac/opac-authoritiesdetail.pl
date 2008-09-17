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

opac-authoritiesdetail.pl : script to show an authority in MARC format

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
my $authtypecode = &GetAuthTypeCode( $authid );
my $tagslib      = &GetTagsLabels( 1, $authtypecode );

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-authoritiesdetail.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
    }
);

my $record;
if (C4::Context->preference("AuthDisplayHierarchy")){
  my $trees=BuildUnimarcHierarchies($authid);
  my @trees = split /;/,$trees ;
  push @trees,$trees unless (@trees);
  my @loophierarchies;
  foreach my $tree (@trees){
    my @tree=split /,/,$tree;
    push @tree,$tree unless (@tree);
    my $cnt=0;
    my @loophierarchy;
    foreach my $element (@tree){
      my $cell;
      my $elementdata = GetAuthority($element);
      $record= $elementdata if ($authid==$element);
      push @loophierarchy, BuildUnimarcHierarchy($elementdata,"child".$cnt, $authid);
      $cnt++;
    }
    push @loophierarchies, { 'loopelement' =>\@loophierarchy};
  }
  $template->param(
    'displayhierarchy' =>C4::Context->preference("AuthDisplayHierarchy"),
    'loophierarchies' =>\@loophierarchies,
  );
}
else {
    $record = GetAuthority( $authid );
}
my $count = CountUsage($authid);

# find the marc field/subfield used in biblio by this authority
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

# loop through each tab 0 through 9
# for (my $tabloop = 0; $tabloop<=10;$tabloop++) {
# loop through each tag
my @fields    = $record->fields();
foreach my $field (@fields) {
    my @subfields_data;

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
    else {
        my @subf = $field->subfields;

        # loop through each subfield
        for my $i ( 0 .. $#subf ) {
            $subf[$i][0] = "@" unless $subf[$i][0];
            next if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{hidden} );
            my %subfield_data;
            $subfield_data{marc_lib} =
              $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{lib};
            if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{isurl} ) {
                $subfield_data{marc_value} =
                  "<a href=\"$subf[$i][1]\">$subf[$i][1]</a>";
            }
            else {
                $subfield_data{marc_value} = $subf[$i][1];
            }
            $subfield_data{marc_subfield} = $subf[$i][0];
            $subfield_data{marc_tag}      = $field->tag();
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
$template->param( "0XX" => \@loop_data );

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype ( keys %$authtypes ) {
    my $selected = 1 if $thisauthtype eq $authtypecode;
    my %row = (
        value        => $thisauthtype,
        selected     => $selected,
        authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
    );
    push @authtypesloop, \%row;
}

$template->param(
    authid               => $authid,
    count                => $count,
    biblio_fields        => $biblio_fields,
    authtypetext         => $authtypes->{$authtypecode}{'authtypetext'},
    authtypesloop        => \@authtypesloop,
    LibraryName          => C4::Context->preference("LibraryName"),
    OpacNav              => C4::Context->preference("OpacNav"),
    opaccredits          => C4::Context->preference("opaccredits"),
    opacsmallimage       => C4::Context->preference("opacsmallimage"),
    opaclayoutstylesheet => C4::Context->preference("opaclayoutstylesheet"),
    opaccolorstylesheet  => C4::Context->preference("opaccolorstylesheet"),
);
output_html_with_http_headers $query, $cookie, $template->output;

