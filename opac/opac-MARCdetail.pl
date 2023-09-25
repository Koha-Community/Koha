#!/usr/bin/perl

# This file is part of Koha.
#
#       Copyright (C) 2000-2002 Katipo Communications
# Parts Copyright (C) 2010      BibLibre
# Parts Copyright (C) 2013      Mark Tompsett
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

opac-MARCdetail.pl : script to show a biblio in MARC format

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This script needs a biblionumber as  parameter

It shows the biblio in a (nice) MARC format depending on MARC
parameters tables.

The template is in <templates_dir>/catalogue/MARCdetail.tt.
this template must be divided into 11 "tabs".

The first 10 tabs present the biblio, the 11th one presents
the items attached to the biblio

=cut

use Modern::Perl;

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( parametrized_url output_html_with_http_headers );
use CGI qw ( -utf8 );
use C4::Biblio qw(
    CountItemsIssued
    GetAuthorisedValueDesc
    GetMarcControlnumber
    GetMarcFromKohaField
    GetMarcISSN
    GetMarcStructure
    TransformMarcToKoha
);
use C4::Reserves qw( IsAvailableForItemLevelRequest );
use C4::Members;
use C4::Koha qw( GetNormalizedISBN );
use List::MoreUtils qw( uniq );
use Koha::Biblios;
use Koha::CirculationRules;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Patrons;
use Koha::RecordProcessor;
use Koha::DateUtils qw( output_pref );
use Koha::Util::MARC;

my $query = CGI->new();

my $biblionumber = $query->param('biblionumber');
if ( ! $biblionumber ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}
$biblionumber = int($biblionumber);

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-MARCdetail.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $patron = Koha::Patrons->find($loggedinuser);
my $biblio = Koha::Biblios->find($biblionumber);
my $record = $biblio->metadata->record;

if ( ! $record ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

unless ( $patron and $patron->category->override_hidden_items ) {
    # only skip this check if there's a logged in user
    # and its category overrides OpacHiddenItems
    if ( $biblio->hidden_in_opac({ rules => C4::Context->yaml_preference('OpacHiddenItems') }) ) {
        print $query->redirect('/cgi-bin/koha/errors/404.pl'); # escape early
        exit;
    }
}

my $items = $biblio->items->filter_by_visible_in_opac({ patron => $patron });
my $framework = $biblio ? $biblio->frameworkcode : q{};
my $tagslib   = &GetMarcStructure( 0, $framework );

my $record_processor = Koha::RecordProcessor->new({
    filters => [ 'EmbedItems', 'ViewPolicy' ],
    options => {
        interface     => 'opac',
        frameworkcode => $framework,
        items         => [ $items->as_list ],
    }
});
$record_processor->process($record);

# get biblionumbers stored in the cart
if(my $cart_list = $query->cookie("bib_list")){
    my @cart_list = split(/\//, $cart_list);
    if ( grep {$_ eq $biblionumber} @cart_list) {
        $template->param( incart => 1 );
    }
}

my ($bt_tag,$bt_subtag) = GetMarcFromKohaField( 'biblio.title' );
$template->param(
    bibliotitle => $biblio->title,
) if $tagslib->{$bt_tag}->{$bt_subtag}->{hidden} <= 0 && # <=0 OPAC visible.
     $tagslib->{$bt_tag}->{$bt_subtag}->{hidden} > -8;   # except -8;

my $can_item_be_reserved = 0;
$items->reset;

while ( my $item = $items->next ) {
    $can_item_be_reserved = $can_item_be_reserved || $patron && IsAvailableForItemLevelRequest( $item, $patron, undef );
}

if( $can_item_be_reserved || CountItemsIssued($biblionumber) || $biblio->has_items_waiting_or_intransit ) {
    $template->param( ReservableItems => 1 );
}

# fill arrays
my @loop_data = ();

# loop through each tab 0 through 9
for ( my $tabloop = 0 ; $tabloop <= 9 ; $tabloop++ ) {

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
            my $previous = '';
            # loop through each subfield
            for my $i ( 0 .. $#subf ) {
                $subf[$i][0] = "@" unless defined($subf[$i][0]);
                my $sf_def = $tagslib->{ $fields[$x_i]->tag() };
                $sf_def = $sf_def->{ $subf[$i][0] } if defined($sf_def);
                my ($tab,$hidden,$lib);
                $tab = $sf_def->{tab} if defined($sf_def);
                $tab = $tab // int($fields[$x_i]->tag()/100);
                $hidden = $sf_def->{hidden} if defined($sf_def);
                $hidden = $hidden // 0;
                next if ( $tab != $tabloop );
                next if ( $hidden > 0 );
                my %subfield_data;
                $lib = $sf_def->{lib} if defined($sf_def);
                $lib = $lib // '--';
                $subfield_data{marc_lib} = ($lib eq $previous) ?  '--' : $lib;
                $previous = $lib;
                $subfield_data{link} = $sf_def->{link};
                $subf[$i][1] =~ s/\n/<br\/>/g;
                if ( $sf_def->{isurl} ) {
                    $subfield_data{marc_value} = "<a href=\"$subf[$i][1]\">$subf[$i][1]</a>";
                }
                elsif ( defined($sf_def->{kohafield}) && $sf_def->{kohafield} eq "biblioitems.isbn" ) {
                    $subfield_data{marc_value} = $subf[$i][1];
                }
                else {
                    if ( $sf_def->{authtypecode} ) {
                        $subfield_data{authority} = $fields[$x_i]->subfield(9);
                    }
                    $subfield_data{marc_value} = GetAuthorisedValueDesc( $fields[$x_i]->tag(),
                        $subf[$i][0], $subf[$i][1], '', $tagslib, '', 'opac' );
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
                    my $sf_def = $tagslib->{ $fields[$x_i]->tag() };
                    my $lib;
                    $lib = $sf_def->{lib} if defined($sf_def);
                    $lib = $lib // '';
                    $tag_data{tag} = $fields[$x_i]->tag() . ' '
                      . C4::Koha::display_marc_indicators($fields[$x_i])
                      . " - $lib";
                }
            }
            my @tmp = @subfields_data;
            $tag_data{subfield} = \@tmp;
            push( @loop_data, \%tag_data );
            undef @subfields_data;
        }
    }
    $template->param( "tab" . $tabloop . "XX" => \@loop_data );
}


# now, build item tab !
# the main difference is that datas are in lines and not in columns : thus, we build the <th> first, then the values...
# loop through each tag
# warning : we may have differents number of columns in each row. Thus, we first build a hash, complete it if necessary
# then construct template.
# $record has already had all the item fields filtered above.
my @fields = $record->fields();
my %witness
  ; #---- stores the list of subfields used at least once, with the "meaning" of the code
my @item_subfield_codes;
my @item_loop;
foreach my $field (@fields) {
    next if ( $field->tag() < 10 );
    my @subf = $field->subfields;
    my $item;

    # loop through each subfield
    for my $i ( 0 .. $#subf ) {
        my $sf_def = $tagslib->{ $field->tag() }->{ $subf[$i][0] };
        next if ( ($sf_def->{tab}||0) != 10 );
        next if ( ($sf_def->{hidden}||0) > 0 );

        push @item_subfield_codes, $subf[$i][0];
        $witness{ $subf[$i][0] } = $sf_def->{lib};

        # Allow repeatables (BZ 13574)
        if( $item->{$subf[$i][0]} ) {
            $item->{$subf[$i][0]} .= ' | ';
        } else {
            $item->{$subf[$i][0]} = q{};
        }

        if ( $sf_def->{isurl} ) {
            $item->{ $subf[$i][0] } .= "<a href=\"$subf[$i][1]\">$subf[$i][1]</a>";
        }
        elsif ( $sf_def->{kohafield} eq "biblioitems.isbn" ) {
            $item->{ $subf[$i][0] } .= $subf[$i][1];
        }
        else {
            $item->{ $subf[$i][0] } .= GetAuthorisedValueDesc( $field->tag(), $subf[$i][0],
                $subf[$i][1], '', $tagslib, '', 'opac' ) // q{};
        }

        my $kohafield = $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{kohafield};
        $item->{ $subf[$i][0] } = output_pref( { str => $item->{ $subf[$i][0] }, dateonly => 1 } )
          if grep { $kohafield eq $_ }
              qw( items.dateaccessioned items.onloan items.datelastseen items.datelastborrowed items.replacementpricedate );

    }
    push @item_loop, $item if $item;
}
my ( $holdingbrtagf, $holdingbrtagsubf ) =
  &GetMarcFromKohaField( "items.holdingbranch" );
@item_loop =
  sort { ($a->{$holdingbrtagsubf}||'') cmp ($b->{$holdingbrtagsubf}||'') } @item_loop;

@item_subfield_codes = uniq @item_subfield_codes;
# fill item info
my @item_header_loop;
for my $subfield_code ( @item_subfield_codes ) {
    push @item_header_loop, $witness{$subfield_code};
    for my $item_data ( @item_loop ) {
        $item_data->{$subfield_code} ||= "&nbsp;"
     }
}

if ( C4::Context->preference("OPACISBD") ) {
    $template->param( ISBD => 1 );
}

#Search for title in links
my $marcflavour  = C4::Context->preference("marcflavour");
my $dat = TransformMarcToKoha({ record => $record });
my $isbn = GetNormalizedISBN(undef,$record,$marcflavour);
my $marccontrolnumber   = GetMarcControlnumber ($record, $marcflavour);
my $marcissns = GetMarcISSN( $record, $marcflavour );
my $issn = $marcissns->[0] || '';

if (my $search_for_title = C4::Context->preference('OPACSearchForTitleIn')){
    $dat->{title} =~ s/\/+$//; # remove trailing slash
    $dat->{title} =~ s/\s+$//; # remove trailing space
    my $oclc_no = Koha::Util::MARC::oclc_number( $record );
    $search_for_title = parametrized_url(
        $search_for_title,
        {
            TITLE         => $dat->{title},
            AUTHOR        => $dat->{author},
            ISBN          => $isbn,
            ISSN          => $issn,
            CONTROLNUMBER => $marccontrolnumber,
            BIBLIONUMBER  => $biblionumber,
            OCLC_NO       => $oclc_no,
        }
    );
    $template->param('OPACSearchForTitleIn' => $search_for_title);
}

if( C4::Context->preference('ArticleRequests') ) {
    my $itemtype = Koha::ItemTypes->find($biblio->itemtype);
    my $artreqpossible = $patron
        ? $biblio->can_article_request( $patron )
        : $itemtype
        ? $itemtype->may_article_request
        : q{};
    $template->param( artreqpossible => $artreqpossible );
}

my $norequests = ! $biblio->items->filter_by_for_hold->count;
$template->param(
    item_loop           => \@item_loop,
    item_header_loop    => \@item_header_loop,
    item_subfield_codes => \@item_subfield_codes,
    biblio              => $biblio,
    norequests          => $norequests,
);

output_html_with_http_headers $query, $cookie, $template->output;
