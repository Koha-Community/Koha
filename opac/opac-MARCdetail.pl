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

MARCdetail.pl : script to show a biblio in MARC format

=head1 SYNOPSIS


=head1 DESCRIPTION

This script needs a biblionumber as  parameter

It shows the biblio in a (nice) MARC format depending on MARC
parameters tables.

The template is in <templates_dir>/catalogue/MARCdetail.tmpl.
this template must be divided into 11 "tabs".

The first 10 tabs present the biblio, the 11th one presents
the items attached to the biblio

=cut

use strict;
use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use MARC::Record;
use C4::Biblio;
use C4::Acquisition;
use C4::Koha;

my $query = new CGI;

my $dbh = C4::Context->dbh;

my $biblionumber = $query->param('biblionumber');
my $itemtype     = &GetFrameworkCode($biblionumber);
my $tagslib      = &GetMarcStructure( 0, $itemtype );
my $biblio = GetBiblioData($biblionumber);
my $record = GetMarcBiblio($biblionumber);

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-MARCdetail.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
    }
);

$template->param(
    bibliotitle => $biblio->{title},
);

# adding the $RequestOnOpac param
my $RequestOnOpac;
if (C4::Context->preference("RequestOnOpac")) {
	$RequestOnOpac = 1;
}

# fill arrays
my @loop_data = ();
my $tag;

# loop through each tab 0 through 9
for ( my $tabloop = 0 ; $tabloop <= 10 ; $tabloop++ ) {

    # loop through each tag
    my @loop_data = ();
    my @subfields_data;

    # deal with leader
    unless ( $tagslib->{'000'}->{'@'}->{tab} ne $tabloop
        or $tagslib->{'000'}->{'@'}->{hidden} > 0 )
    {
        my %subfield_data;
        $subfield_data{marc_lib}      = $tagslib->{'000'}->{'@'}->{lib};
        $subfield_data{marc_value}    = $record->leader();
        $subfield_data{marc_subfield} = '@';
        $subfield_data{marc_tag}      = '000';
        push( @subfields_data, \%subfield_data );
        my %tag_data;
        $tag_data{tag} = '000 -' . $tagslib->{'000'}->{lib};
        my @tmp = @subfields_data;
        $tag_data{subfield} = \@tmp;
        push( @loop_data, \%tag_data );
        undef @subfields_data;
    }
    my @fields = $record->fields();
    for ( my $x_i = 0 ; $x_i <= $#fields ; $x_i++ ) {

        # if tag <10, there's no subfield, use the "@" trick
        if ( $fields[$x_i]->tag() < 10 ) {
            next
              if (
                $tagslib->{ $fields[$x_i]->tag() }->{'@'}->{tab} ne $tabloop );
            next if ( $tagslib->{ $fields[$x_i]->tag() }->{'@'}->{hidden} > 0 );
            my %subfield_data;
            $subfield_data{marc_lib} =
              $tagslib->{ $fields[$x_i]->tag() }->{'@'}->{lib};
            $subfield_data{marc_value}    = $fields[$x_i]->data();
            $subfield_data{marc_subfield} = '@';
            $subfield_data{marc_tag}      = $fields[$x_i]->tag();
            push( @subfields_data, \%subfield_data );
        }
        else {
            my @subf = $fields[$x_i]->subfields;
            my $previous;
            # loop through each subfield
            for my $i ( 0 .. $#subf ) {
                $subf[$i][0] = "@" unless $subf[$i][0];
                next
                  if (
                    $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{tab}
                    ne $tabloop );
                next
                  if ( $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{hidden} > 0 ); 
                my %subfield_data;
                $subfield_data{marc_lib} =
                                ($tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{lib} eq $previous) ?
                                '--' :
                                $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{lib};
                $previous = $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{lib};
                $subfield_data{link} =
                  $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{link};
                $subf[$i][1] =~ s/\n/<br\/>/g;
                if ( $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }
                    ->{isurl} )
                {
                    $subfield_data{marc_value} =
                      "<a href=\"$subf[$i][1]\">$subf[$i][1]</a>";
                }
                elsif ( $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }
                    ->{kohafield} eq "biblioitems.isbn" )
                {

#                    warn " tag : ".$tagslib->{$fields[$x_i]->tag()}." subfield :".$tagslib->{$fields[$x_i]->tag()}->{$subf[$i][0]}. "ISBN : ".$subf[$i][1]."PosttraitementISBN :".DisplayISBN($subf[$i][1]);
                    $subfield_data{marc_value} = $subf[$i][1];
                }
                else {
                    if ( $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }
                        ->{authtypecode} )
                    {
                        $subfield_data{authority} = $fields[$x_i]->subfield(9);
                    }
                    $subfield_data{marc_value} =
                      GetAuthorisedValueDesc( $fields[$x_i]->tag(),
                        $subf[$i][0], $subf[$i][1], '', $tagslib );
                }
                $subfield_data{marc_subfield} = $subf[$i][0];
                $subfield_data{marc_tag}      = $fields[$x_i]->tag();
                push( @subfields_data, \%subfield_data );
            }
        }
        if ( $#subfields_data >= 0 ) {
            my %tag_data;
            if (   ( $fields[$x_i]->tag() eq $fields[ $x_i - 1 ]->tag() )
                && ( C4::Context->preference('LabelMARCView') eq 'economical' )
              )
            {
                $tag_data{tag} = "";
            }
            else {
                if ( C4::Context->preference('hide_marc') ) {
                    $tag_data{tag} = $tagslib->{ $fields[$x_i]->tag() }->{lib};
                }
                else {
                    $tag_data{tag} =
                        $fields[$x_i]->tag() 
                      . ' '
                      . C4::Koha::display_marc_indicators($fields[$x_i])
                      . ' - '
                      . $tagslib->{ $fields[$x_i]->tag() }->{lib};
                }
            }
            my @tmp = @subfields_data;
            $tag_data{subfield} = \@tmp;
            push( @loop_data, \%tag_data );
            undef @subfields_data;
        }
    }
    $template->param( $tabloop . "XX" => \@loop_data );
}


# now, build item tab !
# the main difference is that datas are in lines and not in columns : thus, we build the <th> first, then the values...
# loop through each tag
# warning : we may have differents number of columns in each row. Thus, we first build a hash, complete it if necessary
# then construct template.
my @fields = $record->fields();
my %witness
  ; #---- stores the list of subfields used at least once, with the "meaning" of the code
my @big_array;
foreach my $field (@fields) {
    next if ( $field->tag() < 10 );
    my @subf = $field->subfields;
    my %this_row;

    # loop through each subfield
    for my $i ( 0 .. $#subf ) {
        next if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{tab} ne 10 );
		next if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{hidden} > 0 );
        $witness{ $subf[$i][0] } =
          $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{lib};

        if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{isurl} ) {
            $this_row{ $subf[$i][0] } =
              "<a href=\"$subf[$i][1]\">$subf[$i][1]</a>";
        }
        elsif ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{kohafield} eq
            "biblioitems.isbn" )
        {
            $this_row{ $subf[$i][0] } = $subf[$i][1];
        }
        else {
            $this_row{ $subf[$i][0] } =
              GetAuthorisedValueDesc( $field->tag(), $subf[$i][0],
                $subf[$i][1], '', $tagslib );
        }
    }
    if (%this_row) {
        push( @big_array, \%this_row );
    }
}
my ( $holdingbrtagf, $holdingbrtagsubf ) =
  &GetMarcFromKohaField( "items.holdingbranch", $itemtype );
@big_array =
  sort { $a->{$holdingbrtagsubf} cmp $b->{$holdingbrtagsubf} } @big_array;

#fill big_row with missing datas
foreach my $subfield_code ( keys(%witness) ) {
    for ( my $i = 0 ; $i <= $#big_array ; $i++ ) {
        $big_array[$i]{$subfield_code} = "&nbsp;"
          unless ( $big_array[$i]{$subfield_code} );
    }
}

# now, construct template !
my @item_value_loop;
my @header_value_loop;
for ( my $i = 0 ; $i <= $#big_array ; $i++ ) {
    my $items_data;
    foreach my $subfield_code ( keys(%witness) ) {
        $items_data .= "<td>" . $big_array[$i]{$subfield_code} . "</td>";
    }
    my %row_data;
    $row_data{item_value} = $items_data;
    push( @item_value_loop, \%row_data );
}

foreach my $subfield_code ( keys(%witness) ) {
    my %header_value;
    $header_value{header_value} = $witness{$subfield_code};
    push( @header_value_loop, \%header_value );
}

if(C4::Context->preference("ISBD")) {
	$template->param(ISBD => 1);
}

$template->param(
    item_loop        => \@item_value_loop,
    item_header_loop => \@header_value_loop,
    biblionumber     => $biblionumber,
);

output_html_with_http_headers $query, $cookie, $template->output;
