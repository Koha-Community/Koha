#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
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

MARCdetail.pl : script to show a biblio in MARC format

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This script needs a biblionumber as parameter

It shows the biblio in a (nice) MARC format depending on MARC
parameters tables.

The template is in <templates_dir>/catalogue/MARCdetail.tt.
this template must be divided into 11 "tabs".

The first 10 tabs present the biblio, the 11th one presents
the items attached to the biblio

=head1 FUNCTIONS

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use HTML::Entities;

use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Koha;
use MARC::Record;
use C4::Biblio;
use C4::Items;
use C4::Acquisition;
use C4::Serials;    #uses getsubscriptionsfrombiblionumber GetSubscriptionsFromBiblionumber
use C4::Search;		# enabled_staff_search_views

use Koha::Biblios;
use Koha::BiblioFrameworks;
use Koha::Patrons;

use List::MoreUtils qw( uniq );

my $query        = new CGI;
my $dbh          = C4::Context->dbh;
my $biblionumber = $query->param('biblionumber');
$biblionumber = HTML::Entities::encode($biblionumber);
my $frameworkcode = $query->param('frameworkcode');
$frameworkcode = GetFrameworkCode( $biblionumber ) unless ($frameworkcode);
my $popup        =
  $query->param('popup')
  ;    # if set to 1, then don't insert links, it's just to show the biblio
my $subscriptionid = $query->param('subscriptionid');

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/MARCdetail.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $record = GetMarcBiblio({
    biblionumber => $biblionumber,
    embed_items  => 1 });
$template->param( ocoins => GetCOinSBiblio($record) );

if ( not defined $record ) {
    # biblionumber invalid -> report and exit
    $template->param( unknownbiblionumber => 1,
                biblionumber => $biblionumber
    );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

my $biblio_object = Koha::Biblios->find( $biblionumber ); # FIXME Should replace $biblio
my $tagslib = &GetMarcStructure(1,$frameworkcode);
my $biblio = GetBiblioData($biblionumber);

if($query->cookie("holdfor")){ 
    my $holdfor_patron = Koha::Patrons->find( $query->cookie("holdfor") );
    $template->param(
        holdfor => $query->cookie("holdfor"),
        holdfor_surname => $holdfor_patron->surname,
        holdfor_firstname => $holdfor_patron->firstname,
        holdfor_cardnumber => $holdfor_patron->cardnumber,
    );
}

#count of item linked
my $itemcount = $biblio_object->items->count;
$template->param( count => $itemcount,
					bibliotitle => $biblio->{title}, );

my $frameworks = Koha::BiblioFrameworks->search( {}, { order_by => ['frameworktext'] } );
$template->param(
    frameworks    => $frameworks,
    frameworkcode => $frameworkcode,
);
# fill arrays
my @loop_data = ();

# loop through each tab 0 through 9
for ( my $tabloop = 0 ; $tabloop <= 10 ; $tabloop++ ) {

    # loop through each tag
    my @fields    = $record->fields();
    my @loop_data = ();
    my @subfields_data;

    # deal with leader
    unless ( $tagslib->{'000'}->{'@'}->{tab} ne $tabloop )
    {    #  or ($tagslib->{'000'}->{'@'}->{hidden} =~ /-7|-4|-3|-2|2|3|5|8/ )) {
        my %subfield_data;
        $subfield_data{marc_lib}      = $tagslib->{'000'}->{'@'}->{lib};
        $subfield_data{marc_value}    = $record->leader();
        $subfield_data{marc_subfield} = '@';
        $subfield_data{marc_tag}      = '000';
        push( @subfields_data, \%subfield_data );
        my %tag_data;
        $tag_data{tag} = '000';
        $tag_data{tag_desc} = $tagslib->{'000'}->{lib};
        my @tmp = @subfields_data;
        $tag_data{subfield} = \@tmp;
        push( @loop_data, \%tag_data );
        undef @subfields_data;
    }
    @fields = $record->fields();
    for ( my $x_i = 0 ; $x_i <= $#fields ; $x_i++ ) {

        # if tag <10, there's no subfield, use the "@" trick
        if ( $fields[$x_i]->tag() < 10 ) {
            next
              if (
                $tagslib->{ $fields[$x_i]->tag() }->{'@'}->{tab} ne $tabloop );
            next if ( $tagslib->{ $fields[$x_i]->tag() }->{'@'}->{hidden} =~ /-7|-4|-3|-2|2|3|5|8/);
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

            # loop through each subfield
            for my $i ( 0 .. $#subf ) {
                $subf[$i][0] = "@" unless defined $subf[$i][0];
                next
                  if (
                    $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{tab}
                    ne $tabloop );
                next
                  if ( $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }
                    ->{hidden} =~ /-7|-4|-3|-2|2|3|5|8/);
                my %subfield_data;
                $subfield_data{short_desc} = $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{lib};
                $subfield_data{long_desc} =
                  $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{lib};
                $subfield_data{link} =
                  $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }->{link};

#                 warn "tag : ".$tagslib->{$fields[$x_i]->tag()}." subfield :".$tagslib->{$fields[$x_i]->tag()}->{$subf[$i][0]}."lien koha? : "$subfield_data{link};
                if ( $tagslib->{ $fields[$x_i]->tag() }->{ $subf[$i][0] }
                    ->{isurl} )
                {
                    $subfield_data{marc_value} = $subf[$i][1];
					$subfield_data{is_url} = 1;
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
                        $subf[$i][0], $subf[$i][1], '', $tagslib) || $subf[$i][1];

                }
                $subfield_data{marc_subfield} = $subf[$i][0];
                $subfield_data{marc_tag}      = $fields[$x_i]->tag();
                push( @subfields_data, \%subfield_data );
            }
        }
        if ( $#subfields_data == 0 ) {
            $subfields_data[0]->{marc_lib}      = '';
#            $subfields_data[0]->{marc_subfield} = '';
        }
        if ( $#subfields_data >= 0) {
            my %tag_data;
            if ( $fields[$x_i]->tag() eq $fields[ $x_i - 1 ]->tag() && (C4::Context->preference('LabelMARCView') eq 'economical')) {
                $tag_data{tag} = "";
            }
            else {
                if ( C4::Context->preference('hide_marc') ) {
                    $tag_data{tag} = $tagslib->{ $fields[$x_i]->tag() }->{lib};
                }
                else {
                    $tag_data{tag} = $fields[$x_i]->tag();
            $tag_data{tag_ind} = C4::Koha::display_marc_indicators($fields[$x_i]);
            $tag_data{tag_desc} = $tagslib->{ $fields[$x_i]->tag() }->{lib};
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
my @fields = $record->fields();
my %witness
  ; #---- stores the list of subfields used at least once, with the "meaning" of the code
my @item_subfield_codes;
my @item_loop;
my $norequests = 1;
foreach my $field (@fields) {
    next if ( $field->tag() < 10 );
    my @subf = $field->subfields;
    my $item;

    # loop through each subfield
    for my $i ( 0 .. $#subf ) {
        next if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{tab} ne 10 );
        next if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{hidden} =~ /-7|-4|-3|-2|2|3|5|8/);
        push @item_subfield_codes, $subf[$i][0];
        $witness{ $subf[$i][0] } =
        $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{lib};
        $item->{ $subf[$i][0] } = GetAuthorisedValueDesc( $field->tag(),
                        $subf[$i][0], $subf[$i][1], '', $tagslib) || $subf[$i][1];
        $norequests = 0 if $subf[$i][1] ==0 and $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{kohafield} eq 'items.notforloan';
    }
    push @item_loop, $item if $item;
}

my ($holdingbrtagf,$holdingbrtagsubf) = &GetMarcFromKohaField("items.holdingbranch",$frameworkcode);
@item_loop = sort {$a->{$holdingbrtagsubf} cmp $b->{$holdingbrtagsubf}} @item_loop;

@item_subfield_codes = uniq @item_subfield_codes;
# fill item info
my @item_header_loop;
for my $subfield_code ( @item_subfield_codes ) {
    push @item_header_loop, $witness{$subfield_code};
    for my $item_data ( @item_loop ) {
        $item_data->{$subfield_code} ||= "&nbsp;"
    }
}

my $subscriptionscount = CountSubscriptionFromBiblionumber($biblionumber);

if ($subscriptionscount) {
    my $subscriptions = GetSubscriptionsFromBiblionumber($biblionumber);
    my $subscriptiontitle = $subscriptions->[0]{'bibliotitle'};
    $template->param(
        subscriptiontitle   => $subscriptiontitle,
        subscriptionsnumber => $subscriptionscount,
    );
}

$template->param (
    norequests              => $norequests,
    item_loop               => \@item_loop,
    item_header_loop        => \@item_header_loop,
    item_subfield_codes     => \@item_subfield_codes,
    biblionumber            => $biblionumber,
    popup                   => $popup,
    hide_marc               => C4::Context->preference('hide_marc'),
	marcview => 1,
	z3950_search_params		=> C4::Search::z3950_search_args($biblio),
	C4::Search::enabled_staff_search_views,
    searchid            => scalar $query->param('searchid'),
);

my @allorders_using_biblio = GetOrdersByBiblionumber ($biblionumber);
my @deletedorders_using_biblio;
my @orders_using_biblio;
my @baskets_orders;
my @baskets_deletedorders;

foreach my $myorder (@allorders_using_biblio) {
    my $basket = $myorder->{'basketno'};
    if ((defined $myorder->{'datecancellationprinted'}) and  ($myorder->{'datecancellationprinted'} ne '0000-00-00') ){
        push @deletedorders_using_biblio, $myorder;
        unless (grep(/^$basket$/, @baskets_deletedorders)){
            push @baskets_deletedorders,$myorder->{'basketno'};
        }
    }
    else {
        push @orders_using_biblio, $myorder;
        unless (grep(/^$basket$/, @baskets_orders)){
            push @baskets_orders,$myorder->{'basketno'};
            }
    }
}

my $count_orders_using_biblio = scalar @orders_using_biblio ;
$template->param (countorders => $count_orders_using_biblio);

my $count_deletedorders_using_biblio = scalar @deletedorders_using_biblio ;
$template->param (countdeletedorders => $count_deletedorders_using_biblio);

$biblio = Koha::Biblios->find( $biblionumber );
my $holds = $biblio->holds;
$template->param( holdcount => $holds->count );

output_html_with_http_headers $query, $cookie, $template->output;
