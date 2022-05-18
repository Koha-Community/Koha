#!/usr/bin/perl

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


use Modern::Perl;

use CGI qw ( -utf8 );
use HTML::Entities;
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Koha qw(
    GetAuthorisedValues
    getitemtypeimagelocation
    GetNormalizedEAN
    GetNormalizedISBN
    GetNormalizedOCLCNumber
    GetNormalizedUPC
);
use C4::Serials qw( CountSubscriptionFromBiblionumber SearchSubscriptions GetLatestSerials );
use C4::Output qw( output_html_with_http_headers );
use C4::Biblio qw( GetBiblioData GetFrameworkCode GetMarcBiblio );
use C4::Items qw( GetAnalyticsCount GetHostItemsInfo GetItemsInfo );
use C4::Circulation qw( GetTransfers );
use C4::Reserves;
use C4::Serials qw( CountSubscriptionFromBiblionumber SearchSubscriptions GetLatestSerials );
use C4::XISBN qw( get_xisbns );
use C4::External::Amazon qw( get_amazon_tld );
use C4::Search qw( z3950_search_args enabled_staff_search_views new_record_from_zebra );
use C4::Tags qw( get_tags );
use C4::XSLT qw( XSLTParse4Display );
use Koha::DateUtils qw( format_sqldatetime );
use C4::HTML5Media;
use C4::CourseReserves qw( GetItemCourseReservesInfo );
use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::CoverImages;
use Koha::Illrequests;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Patrons;
use Koha::Virtualshelves;
use Koha::Plugins;
use Koha::Recalls;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;

my $query = CGI->new();

my $analyze = $query->param('analyze');

my ( $template, $borrowernumber, $cookie, $flags ) = get_template_and_user(
    {
    template_name   =>  'catalogue/detail.tt',
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

# Determine if we should be offering any enhancement plugin buttons
if ( C4::Context->config('enable_plugins') ) {
    # Only pass plugins that can offer a toolbar button
    my @plugins = Koha::Plugins->new()->GetPlugins({
        method => 'intranet_catalog_biblio_enhancements_toolbar_button'
    });
    $template->param(
        plugins => \@plugins,
    );
}

my $biblionumber = $query->param('biblionumber');
$biblionumber = HTML::Entities::encode($biblionumber);
my $record       = GetMarcBiblio({ biblionumber => $biblionumber });
my $biblio = Koha::Biblios->find( $biblionumber );
$template->param( 'biblio', $biblio );

if ( not defined $record ) {
    # biblionumber invalid -> report and exit
    $template->param( unknownbiblionumber => 1,
                      biblionumber => $biblionumber );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

my $marc_record = eval { $biblio->metadata->record };
$template->param( decoding_error => $@ );

if($query->cookie("holdfor")){
    my $holdfor_patron = Koha::Patrons->find( $query->cookie("holdfor") );
    if ( $holdfor_patron ) {
        $template->param(
            holdfor        => $query->cookie("holdfor"),
            holdfor_patron => $holdfor_patron,
        );
    }
}

if($query->cookie("searchToOrder")){
    my ( $basketno, $vendorid ) = split( /\//, $query->cookie("searchToOrder") );
    $template->param(
        searchtoorder_basketno => $basketno,
        searchtoorder_vendorid => $vendorid
    );
}

my $fw           = GetFrameworkCode($biblionumber);
my $showallitems = $query->param('showallitems');
my $marcflavour  = C4::Context->preference("marcflavour");

$template->param( 'SpineLabelShowPrintOnBibDetails' => C4::Context->preference("SpineLabelShowPrintOnBibDetails") );

# Catch the exception as Koha::Biblio::Metadata->record can explode if the MARCXML is invalid
# Do not propagate it as we already deal with it previously in this script
my $coins = eval { $biblio->get_coins };
$template->param( ocoins => $coins );

# some useful variables for enhanced content;
# in each case, we're grabbing the first value we find in
# the record and normalizing it
my $upc = GetNormalizedUPC($record,$marcflavour);
my $ean = GetNormalizedEAN($record,$marcflavour);
my $oclc = GetNormalizedOCLCNumber($record,$marcflavour);
my $isbn = GetNormalizedISBN(undef,$record,$marcflavour);
my $content_identifier_exists;
if ( $isbn or $ean or $oclc or $upc ) {
    $content_identifier_exists = 1;
}

$template->param(
    normalized_upc => $upc,
    normalized_ean => $ean,
    normalized_oclc => $oclc,
    normalized_isbn => $isbn,
    content_identifier_exists =>  $content_identifier_exists,
);

my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search->unblessed } };

my $dbh = C4::Context->dbh;

my @all_items = GetItemsInfo( $biblionumber );
my @items;
my $patron = Koha::Patrons->find( $borrowernumber );
for my $itm (@all_items) {
    push @items, $itm unless ( $itm->{itemlost} && $patron->category->hidelostitems && !$showallitems);
}

# flag indicating existence of at least one item linked via a host record
my $hostrecords;
# adding items linked via host biblios
my @hostitems = GetHostItemsInfo($record);
if (@hostitems){
    $hostrecords =1;
    push (@items,@hostitems);
}

my $dat = &GetBiblioData($biblionumber);

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       = SearchSubscriptions({ biblionumber => $biblionumber, orderby => 'title' });
my @subs;

foreach my $subscription (@subscriptions) {
    my %cell;
    my $serials_to_display;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{internalnotes};
    $cell{missinglist}       = $subscription->{missinglist};
    $cell{librariannote}     = $subscription->{librariannote};
    $cell{branchcode}        = $subscription->{branchcode};
    $cell{hasalert}          = $subscription->{hasalert};
    $cell{callnumber}        = $subscription->{callnumber};
    $cell{location}          = $subscription->{location};
    $cell{closed}            = $subscription->{closed};
    #get the three latest serials.
    $serials_to_display = $subscription->{staffdisplaycount};
    $serials_to_display = C4::Context->preference('StaffSerialIssueDisplayCount') unless $serials_to_display;
    $cell{staffdisplaycount} = $serials_to_display;
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, $serials_to_display );
    push @subs, \%cell;
}

# Get component parts details
my $showcomp = C4::Context->preference('ShowComponentRecords');
my $show_analytics;
if ( $showcomp eq 'both' || $showcomp eq 'staff' ) {
    if ( my $components = $marc_record ? $biblio->get_marc_components(C4::Context->preference('MaxComponentRecords')) : undef ) {
        $show_analytics = 1 if @{$components}; # just show link when having results
        $template->param( analytics_error => 1 ) if grep { $_->message eq 'component_search' } @{$biblio->object_messages};
        my $parts;
        for my $part ( @{$components} ) {
            $part = C4::Search::new_record_from_zebra( 'biblioserver', $part );
            my $id = Koha::SearchEngine::Search::extract_biblionumber( $part );

            push @{$parts},
              XSLTParse4Display(
                {
                    biblionumber => $id,
                    record       => $part,
                    xsl_syspref  => "XSLTResultsDisplay",
                    fix_amps     => 1,
                }
              );
        }
        $template->param( ComponentParts => $parts );
        $template->param( ComponentPartsQuery => $biblio->get_components_query );
    }
} else { # check if we should show analytics anyway
    $show_analytics = 1 if $marc_record && @{$biblio->get_marc_components(1)}; # count matters here, results does not
    $template->param( analytics_error => 1 ) if grep { $_->message eq 'component_search' } @{$biblio->object_messages};
}

# XSLT processing of some stuff
my $xslt_variables = { show_analytics_link => $show_analytics };
$template->param(
    XSLTDetailsDisplay => '1',
    XSLTBloc => XSLTParse4Display({
        biblionumber   => $biblionumber,
        record         => $record,
        xsl_syspref    => "XSLTDetailsDisplay",
        fix_amps       => 1,
        xslt_variables => $xslt_variables,
    }),
);

# Get acquisition details
if ( C4::Context->preference('AcquisitionDetails') ) {
    my $orders = Koha::Acquisition::Orders->search(
        { biblionumber => $biblionumber },
        {
            join => 'basketno',
            order_by => 'basketno.booksellerid'
        }
    );    # GetHistory sorted by aqbooksellerid, but does it make sense?

    $template->param(
        orders => $orders,
    );
}

if ( C4::Context->preference('suggestion') ) {
    my $suggestions = Koha::Suggestions->search(
        {
            biblionumber => $biblionumber,
            archived     => 0,
        },
        {
            order_by => { -desc => 'suggesteddate' }
        }
    );
    my $nb_archived_suggestions = Koha::Suggestions->search({ biblionumber => $biblionumber, archived => 1 })->count;
    $template->param( suggestions => $suggestions, nb_archived_suggestions => $nb_archived_suggestions );
}

if ( defined $dat->{'itemtype'} ) {
    $dat->{imageurl} = getitemtypeimagelocation( 'intranet', $itemtypes->{ $dat->{itemtype} }{imageurl} );
}

$dat->{'count'} = scalar @all_items + @hostitems;
$dat->{'showncount'} = scalar @items + @hostitems;
$dat->{'hiddencount'} = scalar @all_items + @hostitems - scalar @items;

my $shelflocations =
  { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => $fw, kohafield => 'items.location' } ) };
my $collections =
  { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => $fw, kohafield => 'items.ccode' } ) };
my $copynumbers =
  { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => $fw, kohafield => 'items.copynumber' } ) };
my (@itemloop, @otheritemloop, %itemfields);

my $mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $fw, kohafield => 'items.itemlost', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
if ( $mss->count ) {
    $template->param( itemlostloop => GetAuthorisedValues( $mss->next->authorised_value ) );
}
$mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $fw, kohafield => 'items.damaged', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
if ( $mss->count ) {
    $template->param( itemdamagedloop => GetAuthorisedValues( $mss->next->authorised_value ) );
}
$mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $fw, kohafield => 'items.withdrawn', authorised_value => { not => undef } });
if ( $mss->count ) {
    $template->param( itemwithdrawnloop => GetAuthorisedValues( $mss->next->authorised_value) );
}

$mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $fw, kohafield => 'items.materials', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
my %materials_map;
if ($mss->count) {
    my $materials_authvals = GetAuthorisedValues($mss->next->authorised_value);
    if ($materials_authvals) {
        foreach my $value (@$materials_authvals) {
            $materials_map{$value->{authorised_value}} = $value->{lib};
        }
    }
}

my $analytics_flag;
my $materials_flag; # set this if the items have anything in the materials field
my $currentbranch = C4::Context->userenv ? C4::Context->userenv->{branch} : undef;
if ($currentbranch and C4::Context->preference('SeparateHoldings')) {
    $template->param(SeparateHoldings => 1);
}
my $separatebranch = C4::Context->preference('SeparateHoldingsBranch') || 'homebranch';
my ( $itemloop_has_images, $otheritemloop_has_images );
foreach my $item (@items) {
    my $itembranchcode = $item->{$separatebranch};

    $item->{imageurl} = defined $item->{itype} ? getitemtypeimagelocation('intranet', $itemtypes->{ $item->{itype} }{imageurl})
                                               : '';

    $item->{datedue} = format_sqldatetime($item->{datedue});

    #get shelf location and collection code description if they are authorised value.
    # same thing for copy number
    my $shelfcode = $item->{'location'};
    $item->{'location'} = $shelflocations->{$shelfcode} if ( defined( $shelfcode ) && defined($shelflocations) && exists( $shelflocations->{$shelfcode} ) );
    my $ccode = $item->{'ccode'};
    $item->{'ccode'} = $collections->{$ccode} if ( defined( $ccode ) && defined($collections) && exists( $collections->{$ccode} ) );
    my $copynumber = $item->{'copynumber'};
    $item->{'copynumber'} = $copynumbers->{$copynumber} if ( defined($copynumber) && defined($copynumbers) && exists( $copynumbers->{$copynumber} ) );
    foreach (qw(ccode enumchron copynumber stocknumber itemnotes itemnotes_nonpublic uri publisheddate)) { # Warning when removing GetItemsInfo - publisheddate (at least) is not part of the items table
        $itemfields{$_} = 1 if ( $item->{$_} );
    }

    # checking for holds
    my $item_object = Koha::Items->find( $item->{itemnumber} );
    my $holds = $item_object->current_holds;
    if ( my $first_hold = $holds->next ) {
        $item->{first_hold} = $first_hold;
    }

    if ( my $checkout = $item_object->checkout ) {
        $item->{CheckedOutFor} = $checkout->patron;
    }

    # Check the transit status
    my ( $transfertwhen, $transfertfrom, $transfertto ) = GetTransfers($item->{itemnumber});
    if ( defined( $transfertwhen ) && ( $transfertwhen ne '' ) ) {
        $item->{transfertwhen} = $transfertwhen;
        $item->{transfertfrom} = $transfertfrom;
        $item->{transfertto}   = $transfertto;
        $item->{nocancel} = 1;
    }

    foreach my $f (qw( itemnotes )) {
        if ($item->{$f}) {
            $item->{$f} =~ s|\n|<br />|g;
            $itemfields{$f} = 1;
        }
    }

    #item has a host number if its biblio number does not match the current bib

    if ($item->{biblionumber} ne $biblionumber){
        $item->{hostbiblionumber} = $item->{biblionumber};
        $item->{hosttitle} = GetBiblioData($item->{biblionumber})->{title};
    }
	

    if ( $analyze ) {
        # count if item is used in analytical bibliorecords
        # The 'countanalytics' flag is only used in the templates if analyze is set
        my $countanalytics = C4::Context->preference('EasyAnalyticalRecords') ? GetAnalyticsCount($item->{itemnumber}) : 0;
        if ($countanalytics > 0){
            $analytics_flag=1;
            $item->{countanalytics} = $countanalytics;
        }
    }

    if (defined($item->{'materials'}) && $item->{'materials'} =~ /\S/){
        $materials_flag = 1;
        if (defined $materials_map{ $item->{materials} }) {
            $item->{materials} = $materials_map{ $item->{materials} };
        }
    }

    if ( C4::Context->preference('UseCourseReserves') ) {
        $item->{'course_reserves'} = GetItemCourseReservesInfo( itemnumber => $item->{'itemnumber'} );
    }

    if ( C4::Context->preference('IndependentBranches') ) {
        my $userenv = C4::Context->userenv();
        if ( not C4::Context->IsSuperLibrarian()
            and $userenv->{branch} ne $item->{homebranch} ) {
            $item->{cannot_be_edited} = 1;
        }
    }

    if ( C4::Context->preference("LocalCoverImages") == 1 ) {
        $item->{cover_images} = $item_object->cover_images;
    }

    if ( C4::Context->preference('UseRecalls') ) {
        my $recall = Koha::Recalls->find({ item_id => $item->{itemnumber}, completed => 0 });
        if ( defined $recall ) {
            $item->{recalled} = 1;
            $item->{recall} = $recall;
        }
    }

    if ($currentbranch and C4::Context->preference('SeparateHoldings')) {
        if ($itembranchcode and $itembranchcode eq $currentbranch) {
            push @itemloop, $item;
            $itemloop_has_images++ if $item_object->cover_images->count;
        } else {
            push @otheritemloop, $item;
            $otheritemloop_has_images++ if $item_object->cover_images->count;
        }
    } else {
        push @itemloop, $item;
        $itemloop_has_images++ if $item_object->cover_images->count;
    }
}

$template->param(
    itemloop_has_images      => $itemloop_has_images,
    otheritemloop_has_images => $otheritemloop_has_images,
);

# Display only one tab if one items list is empty
if (scalar(@itemloop) == 0 || scalar(@otheritemloop) == 0) {
    $template->param(SeparateHoldings => 0);
    if (scalar(@itemloop) == 0) {
        @itemloop = @otheritemloop;
    }
}

my $some_private_shelves = Koha::Virtualshelves->get_some_shelves(
    {
        borrowernumber => $borrowernumber,
        add_allowed    => 1,
        public         => 0,
    }
);
my $some_public_shelves = Koha::Virtualshelves->get_some_shelves(
    {
        borrowernumber => $borrowernumber,
        add_allowed    => 1,
        public         => 1,
    }
);


$template->param(
    add_to_some_private_shelves => $some_private_shelves,
    add_to_some_public_shelves  => $some_public_shelves,
);

$template->param(
    MARCNOTES               => $marc_record ? $biblio->get_marc_notes() : undef,
    itemdata_ccode          => $itemfields{ccode},
    itemdata_enumchron      => $itemfields{enumchron},
    itemdata_uri            => $itemfields{uri},
    itemdata_copynumber     => $itemfields{copynumber},
    itemdata_stocknumber    => $itemfields{stocknumber},
    itemdata_publisheddate  => $itemfields{publisheddate},
    volinfo                 => $itemfields{enumchron},
    itemdata_itemnotes      => $itemfields{itemnotes},
    itemdata_nonpublicnotes => $itemfields{itemnotes_nonpublic},
    z3950_search_params     => C4::Search::z3950_search_args($dat),
    hostrecords             => $hostrecords,
    analytics_flag          => $analytics_flag,
    C4::Search::enabled_staff_search_views,
    materials => $materials_flag,
);

if (C4::Context->preference("AlternateHoldingsField") && scalar @items == 0) {
    my $fieldspec = C4::Context->preference("AlternateHoldingsField");
    my $subfields = substr $fieldspec, 3;
    my $holdingsep = C4::Context->preference("AlternateHoldingsSeparator") || ' ';
    my @alternateholdingsinfo = ();
    my @holdingsfields = $record->field(substr $fieldspec, 0, 3);

    for my $field (@holdingsfields) {
        my %holding = ( holding => '' );
        my $havesubfield = 0;
        for my $subfield ($field->subfields()) {
            if ((index $subfields, $$subfield[0]) >= 0) {
                $holding{'holding'} .= $holdingsep if (length $holding{'holding'} > 0);
                $holding{'holding'} .= $$subfield[1];
                $havesubfield++;
            }
        }
        if ($havesubfield) {
            push(@alternateholdingsinfo, \%holding);
        }
    }

    $template->param(
        ALTERNATEHOLDINGS   => \@alternateholdingsinfo,
        );
}

my @results = ( $dat, );
foreach ( keys %{$dat} ) {
    $template->param( "$_" => defined $dat->{$_} ? $dat->{$_} : '' );
}

# does not work: my %views_enabled = map { $_ => 1 } $template->query(loop => 'EnableViews');
# method query not found?!?!
$template->param( AmazonTld => get_amazon_tld() ) if ( C4::Context->preference("AmazonCoverImages"));
$template->param(
    itemloop        => \@itemloop,
    otheritemloop   => \@otheritemloop,
    biblionumber        => $biblionumber,
    ($analyze? 'analyze':'detailview') =>1,
    subscriptions       => \@subs,
    subscriptionsnumber => $subscriptionsnumber,
    subscriptiontitle   => $dat->{title},
    searchid            => scalar $query->param('searchid'),
);

# Lists

if (C4::Context->preference("virtualshelves") ) {
    my $shelves = Koha::Virtualshelves->search(
        {
            biblionumber => $biblionumber,
            public => 1,
        },
        {
            join => 'virtualshelfcontents',
        }
    );
    $template->param( 'shelves' => $shelves );
}

# XISBN Stuff
if (C4::Context->preference("FRBRizeEditions")==1) {
    eval {
        $template->param(
            XISBNS => scalar get_xisbns($isbn, $biblionumber)
        );
    };
    if ($@) { warn "XISBN Failed $@"; }
}

if ( C4::Context->preference("LocalCoverImages") == 1 ) {
    my $images = $biblio->cover_images;
    $template->param( localimages => $biblio->cover_images );
}

# HTML5 Media
if ( (C4::Context->preference("HTML5MediaEnabled") eq 'both') or (C4::Context->preference("HTML5MediaEnabled") eq 'staff') ) {
    $template->param( C4::HTML5Media->gethtml5media($record));
}

# Displaying tags
my $tag_quantity;
if (C4::Context->preference('TagsEnabled') and $tag_quantity = C4::Context->preference('TagsShowOnDetail')) {
    $template->param(
        TagsEnabled => 1,
        TagsShowOnDetail => $tag_quantity
    );
    $template->param(TagLoop => get_tags({biblionumber=>$biblionumber, approved=>1,
                                'sort'=>'-weight', limit=>$tag_quantity}));
}

#we only need to pass the number of holds to the template
my $holds = $biblio->holds;
$template->param( holdcount => $holds->count );

# Check if there are any ILL requests connected to the biblio
my $illrequests =
    C4::Context->preference('ILLModule')
  ? Koha::Illrequests->search( { biblio_id => $biblionumber } )
  : [];
$template->param( illrequests => $illrequests );

my $StaffDetailItemSelection = C4::Context->preference('StaffDetailItemSelection');
if ($StaffDetailItemSelection) {
    # Only enable item selection if user can execute at least one action
    if (
        $flags->{superlibrarian}
        || (
            ref $flags->{tools} eq 'HASH' && (
                $flags->{tools}->{items_batchmod}       # Modify selected items
                || $flags->{tools}->{items_batchdel}    # Delete selected items
            )
        )
        || ( ref $flags->{tools} eq '' && $flags->{tools} )
      )
    {
        $template->param(
            StaffDetailItemSelection => $StaffDetailItemSelection );
    }
}

# get biblionumbers stored in the cart
my @cart_list;

if($query->cookie("intranet_bib_list")){
    my $cart_list = $query->cookie("intranet_bib_list");
    @cart_list = split(/\//, $cart_list);
    if ( grep {$_ eq $biblionumber} @cart_list) {
        $template->param( incart => 1 );
    }
}

if ( C4::Context->preference('UseCourseReserves') ) {
    my $course_reserves = GetItemCourseReservesInfo( biblionumber => $biblionumber );
    $template->param( course_reserves => $course_reserves );
}

$template->param(found1 => scalar $query->param('found1') );

$template->param(biblio => $biblio);

output_html_with_http_headers $query, $cookie, $template->output;
