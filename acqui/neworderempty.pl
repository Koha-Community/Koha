#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

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

neworderempty.pl

=head1 DESCRIPTION
this script allows to create a new record to order it. This record shouldn't exist
on database.

=head1 CGI PARAMETERS

=over 4

=item booksellerid
the bookseller the librarian has to buy a new book.

=item title
the title of this new record.

=item author
the author of this new record.

=item copyright
the copyright of this new record.

=item ordnum
the number of this order.

=item biblio

=item basketno
the basket number for this new order.

=item suggestionid
if this order comes from a suggestion.

=item breedingid
the item's id in the breeding reservoir

=item close

=back

=cut

use warnings;
use strict;
use CGI;
use C4::Context;
use C4::Input;

use C4::Auth;
use C4::Budgets;
use C4::Input;
#use C4::Bookfund;

use C4::Bookseller;		# GetBookSellerFromId
use C4::Acquisition;
use C4::Suggestions;	# GetSuggestion
use C4::Biblio;			# GetBiblioData
use C4::Output;
use C4::Input;
use C4::Koha;
use C4::Branch;			# GetBranches
use C4::Members;
use C4::Search qw/FindDuplicate BiblioAddAuthorities/;

#needed for z3950 import:
use C4::ImportBatch qw/GetImportRecordMarc/;

my $input        = new CGI;
my $booksellerid = $input->param('booksellerid');	# FIXME: else ERROR!
my $budget_id    = $input->param('budget_id');	# FIXME: else ERROR!
my $title        = $input->param('title');
my $author       = $input->param('author');
my $copyright    = $input->param('copyright');
my $bookseller   = GetBookSellerFromId($booksellerid);	# FIXME: else ERROR!
my $ordnum       = $input->param('ordnum') || '';
my $biblionumber = $input->param('biblionumber');
my $basketno     = $input->param('basketno');
my $purchaseorder= $input->param('purchaseordernumber');
my $suggestionid = $input->param('suggestionid');
# my $donation     = $input->param('donation');
my $close        = $input->param('close');
my $uncertainprice = $input->param('uncertainprice');
my $data;
my $new = 'no';

my $budget_name;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/neworderempty.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
        debug           => 1,
    }
);

#simple parameters reading (all in one :-)
my $params = $input->Vars;
if ( $ordnum eq '' and defined $params->{'breedingid'}){
#we want to import from the breeding reservoir (from a z3950 search)
    my ($marcrecord, $encoding) = MARCfindbreeding($params->{'breedingid'});
    die("Could not find the selected record in the reservoir, bailing") unless $marcrecord;

    my $duplicatetitle;
#look for duplicates
    if (! (($biblionumber,$duplicatetitle) = FindDuplicate($marcrecord))){
        my $itemtypes = GetItemTypes();
        my $marcflavour = C4::Context->preference("marcflavour");
#         warn("$marcflavour----itemtype"."-------------marcflavour".$marcflavour."---------subfield".$marcrecord->subfield('200', 'b'));
#use the itemtype field of the UNIMARC standard.
        if ( $marcflavour eq 'UNIMARC' ) {
            my $itemtype = $marcrecord->subfield('200', 'b');
#Check wether the itemtype is known
            warn(grep { $itemtypes->{$_}->{itemtype} =~ /$itemtype/ } keys %$itemtypes);
            if (scalar(grep { $itemtypes->{$_}->{itemtype} =~ /$itemtype/ } keys %$itemtypes) == 0) {
                my @itemtypes = sort {lc($itemtypes->{$a}->{'description'}) cmp lc($itemtypes->{$b}->{'description'})} keys %$itemtypes;
                $itemtype = $itemtypes[0];
#                warn(YAML->Dump(@itemtypes));
                $marcrecord->field('200')->update('b' => $itemtype);
            }
        }
        if (C4::Context->preference("BiblioAddsAuthorities")){
              my ($countlinked,$countcreated)=BiblioAddAuthorities($marcrecord, $params->{'frameworkcode'});
        }
        my $bibitemnum;
        $params->{'frameworkcode'} or $params->{'frameworkcode'} = "";
        ( $biblionumber, $bibitemnum ) = AddBiblio( $marcrecord, $params->{'frameworkcode'} );
    }
}


my $cur = GetCurrency();

if ( $ordnum eq '' ) {    # create order
    $new = 'yes';

    # 	$ordnum=newordernum;
    if ( $biblionumber && !$suggestionid ) {
        $data = GetBiblioData($biblionumber);
    }

# get suggestion fields if applicable. If it's a subscription renewal, then the biblio already exists
# otherwise, retrieve suggestion information.
    if ($suggestionid) {
		$data = ($biblionumber) ? GetBiblioData($biblionumber) : GetSuggestion($suggestionid);
    }
}
else {    #modify order
    $data   = GetOrder($ordnum);
    $biblionumber = $data->{'biblionumber'};
    $budget_id = $data->{'budget_id'};

    #get basketno and supplierno. too!
    my $data2 = GetBasket( $data->{'basketno'} );
    $basketno     = $data2->{'basketno'};
    $booksellerid = $data2->{'booksellerid'};
}

# get currencies (for change rates calcs if needed)
my @rates = GetCurrencies();
my $count = scalar @rates;

# ## @rates

my @loop_currency = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
    $line{currency} = $rates[$i]->{'currency'};
    $line{rate}     = $rates[$i]->{'rate'};
    push @loop_currency, \%line;
}

    # ##  @loop_currency


# build itemtype list
my $itemtypes = GetItemTypes;

my @itemtypesloop;
foreach my $thisitemtype (sort {$itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'}} keys %$itemtypes) {
    push @itemtypesloop, { itemtype => $itemtypes->{$thisitemtype}->{'itemtype'} , desc =>  $itemtypes->{$thisitemtype}->{'description'} } ;
}

# build branches list
my $onlymine=C4::Context->preference('IndependantBranches') && 
             C4::Context->userenv && 
             C4::Context->userenv->{flags}!=1 && 
             C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my @branchloop;
foreach my $thisbranch ( sort {$branches->{$a}->{'branchname'} cmp $branches->{$b}->{'branchname'}} keys %$branches ) {
     my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
    );
	$row{'selected'} = 1 if( $thisbranch eq $data->{branchcode}) ;
    push @branchloop, \%row;
}
$template->param( branchloop => \@branchloop , itypeloop => \@itemtypesloop );

# build bookfund list
my $borrower= GetMember('borrowernumber' => $loggedinuser);
my ( $flags, $homebranch )= ($borrower->{'flags'},$borrower->{'branchcode'});

my $budget =  GetBudget($budget_id);
# build budget list
my %labels;
my @values;
my $budgets = GetBudgetHierarchy('1','',$borrower->{'borrowernumber'});
foreach my $r (@$budgets) {
    $labels{"$r->{budget_id}"} = $r->{budget_name};
    next if  sprintf ("%00d",  $r->{budget_amount})  ==   0;
    push @values, $r->{budget_id};
}
# if no budget_id is passed then its an add
my $budget_dropbox = CGI::scrolling_list(
    -name    => 'budget_id',
    -id      => 'budget_id',
    -values  => \@values,
    -size    => 1,
    -labels  => \%labels,
    -onChange   => "fetchSortDropbox(this.form)",
);

if ($close) {
    $budget_id      =  $data->{'budget_id'};
    $budget_name    =   $budget->{'budget_name'};      

}


my $CGIsort1;
if ($budget) {    # its a mod ..
    if ( defined $budget->{'sort1_authcat'} ) {    # with custom  Asort* planning values
        $CGIsort1 = GetAuthvalueDropbox( 'sort1', $budget->{'sort1_authcat'}, $data->{'sort1'} );
    }
} else {
    $CGIsort1 = GetAuthvalueDropbox( 'sort1', 'Asort1', '' );
}

# if CGIsort is successfully fetched, the use it
# else - failback to plain input-field
if ($CGIsort1) {
    $template->param( CGIsort1 => $CGIsort1 );
} else {
    $template->param( sort1 => $data->{'sort1'} );
}

my $CGIsort2;
if ($budget) {
    if ( defined $budget->{'sort2_authcat'} ) {
        $CGIsort2 = GetAuthvalueDropbox( 'sort2', $budget->{'sort2_authcat'}, $data->{'sort2'} );
    }
} else {
    $CGIsort2 = GetAuthvalueDropbox( 'sort2', 'Asort2', '' );
}
if ($CGIsort2) {
    $template->param( CGIsort2 => $CGIsort2 );
} else {
    $template->param( sort2 => $data->{'sort2'} );
}



#do a biblioitems lookup on bib
my @bibitems = GetBiblioItemByBiblioNumber($biblionumber);
my $bibitemscount = scalar @bibitems;

if ( $bibitemscount > 0 ) {
    # warn "NEWBIBLIO: bibitems for $biblio exists\n";
    my @bibitemloop;
    for ( my $i = 0 ; $i < $bibitemscount ; $i++ ) {
        my %line;
        $line{biblioitemnumber} = $bibitems[$i]->{'biblioitemnumber'};
        $line{isbn}             = $bibitems[$i]->{'isbn'};
        $line{itemtype}         = $bibitems[$i]->{'itemtype'};
        $line{volumeddesc}      = $bibitems[$i]->{'volumeddesc'};
        push( @bibitemloop, \%line );

        $template->param( bibitemloop => \@bibitemloop );
    }
    $template->param( bibitemexists => "1" );
}

if (C4::Context->preference('AcqCreateItem') eq 'ordering' && !$ordnum) {
    # prepare empty item form
    my $cell = PrepareItemrecordDisplay();
    my @itemloop;
    push @itemloop,$cell;
    
    $template->param(items => \@itemloop);
}

# fill template
$template->param(
    close        => $close,
    budget_id    => $budget_id,
    budget_name  => $budget_name
  )
  if ($close);

    # ## @loop_currency,
$template->param(
    existing         => $biblionumber,
    ordnum           => $ordnum,
    basketno         => $basketno,
    booksellerid     => $booksellerid,
    suggestionid     => $suggestionid,
    biblionumber     => $biblionumber,
    uncertainprice   => $data->{'uncertainprice'},
    authorisedbyname => $borrower->{'firstname'} . " " . $borrower->{'surname'},
	biblioitemnumber => $data->{'biblioitemnumber'},
    itemtype         => $data->{'itemtype'},
    itemtype_desc    => $itemtypes->{$data->{'itemtype'}}->{description},
    discount_2dp     => sprintf( "%.2f",  $bookseller->{'discount'}) ,   # for display
    discount         => $bookseller->{'discount'},
    listincgst       => $bookseller->{'listincgst'},
    invoiceincgst    => $bookseller->{'invoiceincgst'},
    invoicedisc      => $bookseller->{'invoicedisc'},
    nocalc           => $bookseller->{'nocalc'},
    name             => $bookseller->{'name'},
    cur_active_sym   => $cur->{symbol},
    cur_active       => $cur->{currency},
    currency         => $bookseller->{'listprice'}, # eg: 'EUR'
    loop_currencies  => \@loop_currency,
    orderexists      => ( $new eq 'yes' ) ? 0 : 1,
    title            => $data->{'title'},
    author           => $data->{'author'},
    copyrightdate    => $data->{'copyrightdate'},
    budget_dropbox   => $budget_dropbox,
    isbn             => $data->{'isbn'},
    seriestitle      => $data->{'seriestitle'},
    quantity         => $data->{'quantity'},
    quantityrec      => $data->{'quantity'},


    rrp              => $data->{'rrp'},
    list_price       => sprintf("%.2f", $data->{'listprice'}), # watch the '-'
    total            => sprintf("%.2f", $data->{ecost}*$data->{quantity} ),
    invoice          => $data->{'booksellerinvoicenumber'},
    ecost            => $data->{'ecost'},
    purchaseordernumber => $data->{'purchaseordernumber'},
    notes            => $data->{'notes'},
    publishercode    => $data->{'publishercode'},


# CHECKME: gst-stuff needs verifing, mason.
    gstrate          => $bookseller->{gstrate} || C4::Context->preference("gist"),
    gstreg           => $bookseller->{'gstreg'},

#     donation         => $donation
);

output_html_with_http_headers $input, $cookie, $template->output;


=item MARCfindbreeding

    $record = MARCfindbreeding($breedingid);

Look up the import record repository for the record with
record with id $breedingid.  If found, returns the decoded
MARC::Record; otherwise, -1 is returned (FIXME).
Returns as second parameter the character encoding.

=cut

sub MARCfindbreeding {
    my ( $id ) = @_;
    my ($marc, $encoding) = GetImportRecordMarc($id);
    # remove the - in isbn, koha store isbn without any -
    if ($marc) {
        my $record = MARC::Record->new_from_usmarc($marc);
        my ($isbnfield,$isbnsubfield) = GetMarcFromKohaField('biblioitems.isbn','');
        if ( $record->field($isbnfield) ) {
            foreach my $field ( $record->field($isbnfield) ) {
                foreach my $subfield ( $field->subfield($isbnsubfield) ) {
                    my $newisbn = $field->subfield($isbnsubfield);
                    $newisbn =~ s/-//g;
                    $field->update( $isbnsubfield => $newisbn );
                }
            }
        }
        # fix the unimarc 100 coded field (with unicode information)
        if (C4::Context->preference('marcflavour') eq 'UNIMARC' && $record->subfield(100,'a')) {
            my $f100a=$record->subfield(100,'a');
            my $f100 = $record->field(100);
            my $f100temp = $f100->as_string;
            $record->delete_field($f100);
            if ( length($f100temp) > 28 ) {
                substr( $f100temp, 26, 2, "50" );
                $f100->update( 'a' => $f100temp );
                my $f100 = MARC::Field->new( '100', '', '', 'a' => $f100temp );
                $record->insert_fields_ordered($f100);
            }
        }
		
        if ( !defined(ref($record)) ) {
            return -1;
        }
        else {
            # normalize author : probably UNIMARC specific...
            if (    C4::Context->preference("z3950NormalizeAuthor")
                and C4::Context->preference("z3950AuthorAuthFields") )
            {
                my ( $tag, $subfield ) = GetMarcFromKohaField("biblio.author");

 #                 my $summary = C4::Context->preference("z3950authortemplate");
                my $auth_fields =
                  C4::Context->preference("z3950AuthorAuthFields");
                my @auth_fields = split /,/, $auth_fields;
                my $field;

                if ( $record->field($tag) ) {
                    foreach my $tmpfield ( $record->field($tag)->subfields ) {

       #                        foreach my $subfieldcode ($tmpfield->subfields){
                        my $subfieldcode  = shift @$tmpfield;
                        my $subfieldvalue = shift @$tmpfield;
                        if ($field) {
                            $field->add_subfields(
                                "$subfieldcode" => $subfieldvalue )
                              if ( $subfieldcode ne $subfield );
                        }
                        else {
                            $field =
                              MARC::Field->new( $tag, "", "",
                                $subfieldcode => $subfieldvalue )
                              if ( $subfieldcode ne $subfield );
                        }
                    }
                }
                $record->delete_field( $record->field($tag) );
                foreach my $fieldtag (@auth_fields) {
                    next unless ( $record->field($fieldtag) );
                    my $lastname  = $record->field($fieldtag)->subfield('a');
                    my $firstname = $record->field($fieldtag)->subfield('b');
                    my $title     = $record->field($fieldtag)->subfield('c');
                    my $number    = $record->field($fieldtag)->subfield('d');
                    if ($title) {

#                         $field->add_subfields("$subfield"=>"[ ".ucfirst($title).ucfirst($firstname)." ".$number." ]");
                        $field->add_subfields(
                                "$subfield" => ucfirst($title) . " "
                              . ucfirst($firstname) . " "
                              . $number );
                    }
                    else {

#                       $field->add_subfields("$subfield"=>"[ ".ucfirst($firstname).", ".ucfirst($lastname)." ]");
                        $field->add_subfields(
                            "$subfield" => ucfirst($firstname) . ", "
                              . ucfirst($lastname) );
                    }
                }
                $record->insert_fields_ordered($field);
            }
            return $record, $encoding;
        }
    }
    return -1;
}

