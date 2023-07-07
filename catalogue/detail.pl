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
use C4::Biblio qw( GetBiblioData GetFrameworkCode );
use C4::Items qw( GetAnalyticsCount );
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
use Koha::Biblio::ItemGroup::Items;
use Koha::Biblio::ItemGroups;
use Koha::CoverImages;
use Koha::DateUtils;
use Koha::Illrequests;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Patrons;
use Koha::Virtualshelves;
use Koha::Plugins;
use Koha::Recalls;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;
use Koha::Serial::Items;

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
my $biblio = Koha::Biblios->find( $biblionumber );
$template->param( 'biblio', $biblio );

unless ( $biblio ) {
    # biblionumber invalid -> report and exit
    $template->param( unknownbiblionumber => 1,
                      biblionumber => $biblionumber );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

my $marc_record = eval { $biblio->metadata->record };
my $invalid_marc_record = $@ || !$marc_record;
if ($invalid_marc_record) {
    $template->param( decoding_error => $@ );
    my $marc_xml = C4::Charset::StripNonXmlChars( $biblio->metadata->metadata );

    $marc_record = eval {
        MARC::Record::new_from_xml( $marc_xml, 'UTF-8',
            C4::Context->preference('marcflavour') );
    };
}

my $op = $query->param('op') || q{};
if ( $op eq 'set_item_group' ) {
    my $item_group_id = $query->param('item_group_id');
    my @itemnumbers   = $query->multi_param('itemnumber');

    foreach my $item_id (@itemnumbers) {
        my $item_group_item = Koha::Biblio::ItemGroup::Items->find( { item_id => $item_id } );

        if ($item_group_item) {
            $item_group_item->item_group_id($item_group_id);
        }
        else {
            $item_group_item = Koha::Biblio::ItemGroup::Item->new(
                {
                    item_id        => $item_id,
                    item_group_id  => $item_group_id,
                }
            );
        }

        $item_group_item->store();
    }
}
elsif ( $op eq 'unset_item_group' ) {
    my $item_group_id   = $query->param('item_group_id');
    my @itemnumbers = $query->multi_param('itemnumber');

    foreach my $item_id (@itemnumbers) {
        my $item_group_item = Koha::Biblio::ItemGroup::Items->find( { item_id => $item_id } );
        $item_group_item->delete() if $item_group_item;
    }
}

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

$template->param( ocoins => !$invalid_marc_record ? $biblio->get_coins : undef );

# some useful variables for enhanced content;
# in each case, we're grabbing the first value we find in
# the record and normalizing it
my $upc = GetNormalizedUPC($marc_record,$marcflavour);
my $ean = GetNormalizedEAN($marc_record,$marcflavour);
my $oclc = GetNormalizedOCLCNumber($marc_record,$marcflavour);
my $isbn = GetNormalizedISBN(undef,$marc_record,$marcflavour);
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

my $itemtypes = { map { $_->itemtype => $_ } @{ Koha::ItemTypes->search_with_localization->as_list } };
my $all_items = $biblio->items->search_ordered;
my @items;
my $patron = Koha::Patrons->find( $borrowernumber );
$params->{ itemlost } = 0 if $patron->category->hidelostitems && !$showallitems;
my $items_params = {
    ( $invalid_marc_record ? () : ( host_items => 1 ) ),
};
my $items = $biblio->items($items_params)->search_ordered( $params, { prefetch => ['issue','current_branchtransfers'] } );

# flag indicating existence of at least one item linked via a host record
my $hostrecords = $biblio->host_items->count;

my $dat = &GetBiblioData($biblionumber);
$dat->{'count'} = $biblio->items($items_params)->count;
$dat->{'showncount'} = $items->count;
$dat->{'hiddencount'} = $dat->{'count'} - $dat->{'showncount'};

#is biblio a collection and are bundles enabled
my $leader = $marc_record->leader();
$dat->{bundlesEnabled} = ( ( substr( $leader, 7, 1 ) eq 'c' )
      && C4::Context->preference('BundleNotLoanValue') ) ? 1 : 0;

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
    if ( my $components = !$invalid_marc_record ? $biblio->get_marc_components(C4::Context->preference('MaxComponentRecords')) : undef ) {
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
        my ( $comp_query, $comp_query_str, $comp_sort ) = $biblio->get_components_query;
        my $cpq = $comp_query_str . "&sort_by=" . $comp_sort;
        $template->param( ComponentPartsQuery => $cpq );
    }
} else { # check if we should show analytics anyway
    $show_analytics = 1 if !$invalid_marc_record && @{$biblio->get_marc_components(1)}; # count matters here, results does not
    $template->param( analytics_error => 1 ) if grep { $_->message eq 'component_search' } @{$biblio->object_messages};
}

# XSLT processing of some stuff
my $xslt_variables = { show_analytics_link => $show_analytics };
$template->param(
    XSLTDetailsDisplay => '1',
    XSLTBloc => XSLTParse4Display({
        biblionumber   => $biblionumber,
        record         => $marc_record,
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
    $dat->{imageurl} = getitemtypeimagelocation( 'intranet', $itemtypes->{ $dat->{itemtype} }->imageurl );
}

$dat->{'count'} = $all_items->count + $hostitems->count;
$dat->{'showncount'} = scalar @items + $hostitems->count;
$dat->{'hiddencount'} = $all_items->count + $hostitems->count - scalar @items;

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

while ( my $item = $items->next ) {
    my $itembranchcode = $item->$separatebranch;

    my $item_info = $item->unblessed;
    $item_info->{itemtype} = $itemtypes->{$item->effective_itemtype};

    #get shelf location and collection code description if they are authorised value.
    # same thing for copy number
    my $shelfcode = $item->location;
    $item_info->{'location'} = $shelflocations->{$shelfcode} if ( defined( $shelfcode ) && defined($shelflocations) && exists( $shelflocations->{$shelfcode} ) );
    my $ccode = $item->ccode;
    $item_info->{'ccode'} = $collections->{$ccode} if ( defined( $ccode ) && defined($collections) && exists( $collections->{$ccode} ) );
    my $copynumber = $item->copynumber;
    $item_info->{'copynumber'} = $copynumbers->{$copynumber} if ( defined($copynumber) && defined($copynumbers) && exists( $copynumbers->{$copynumber} ) );
    foreach (qw(ccode enumchron copynumber stocknumber itemnotes itemnotes_nonpublic uri )) {
        $itemfields{$_} = 1 if $item->$_;
    }

    # FIXME The following must be Koha::Item->serial
    my $serial_item = Koha::Serial::Items->find($item->itemnumber);
    if ( $serial_item ) {
        my $serial = Koha::Serials->find($serial_item->serialid);
        $item_info->{serial} = $serial if $serial;
        $itemfields{publisheddate} = 1;
    }

    $item_info->{object} = $item;

    # checking for holds
    my $holds = $item->current_holds;
    if ( my $first_hold = $holds->next ) {
        $item_info->{first_hold} = $first_hold;
    }

    $item_info->{checkout} = $item->checkout;

    # Check the transit status
    my $transfer = $item->get_transfer;
    if ( $transfer ) {
        $item_info->{transfer} = $transfer;
    }

    foreach my $f (qw( itemnotes )) {
        if ($item_info->{$f}) {
            $item_info->{$f} =~ s|\n|<br />|g;
            $itemfields{$f} = 1;
        }
    }

    #item has a host number if its biblio number does not match the current bib

    if ($item->biblionumber ne $biblionumber){
        $item_info->{hostbiblionumber} = $item->biblionumber;
        $item_info->{hosttitle} = $item->biblio->title;
    }


    if ( $analyze ) {
        # count if item is used in analytical bibliorecords
        # The 'countanalytics' flag is only used in the templates if analyze is set
        my $countanalytics = GetAnalyticsCount( $item->itemnumber );
        if ($countanalytics > 0){
            $analytics_flag=1;
            $item_info->{countanalytics} = $countanalytics;
        }
    }

    if (defined($item->materials) && $item->materials =~ /\S/){
        $materials_flag = 1;
        if (defined $materials_map{ $item->materials }) {
            $item_info->{materials} = $materials_map{ $item->materials };
        }
    }

    if ( C4::Context->preference('UseCourseReserves') ) {
        $item_info->{'course_reserves'} = GetItemCourseReservesInfo( itemnumber => $item->itemnumber );
    }

    if ( C4::Context->preference("LocalCoverImages") == 1 ) {
        $item_info->{cover_images} = $item->cover_images;
    }

    if ( C4::Context->preference('UseRecalls') ) {
        $item_info->{recall} = $item->recall;
    }

    if ( C4::Context->preference('IndependentBranches') ) {
        my $userenv = C4::Context->userenv();
        if ( not C4::Context->IsSuperLibrarian()
            and $userenv->{branch} ne $item->homebranch ) {
            $item_info->{cannot_be_edited} = 1;
            $item_info->{not_same_branch} = 1;
        }
    }

    if ( $item->is_bundle ) {
        $item_info->{bundled} =
          $item->bundle_items->search( { itemlost => { '!=' => 0 } } )
          ->count;
        $item_info->{bundled_lost} =
          $item->bundle_items->search( { itemlost => 0 } )->count;
        $item_info->{is_bundle} = 1;
    }

    if ($item->in_bundle) {
        $item_info->{bundle_host} = $item->bundle_host;
    }

    if ($currentbranch and C4::Context->preference('SeparateHoldings')) {
        if ($itembranchcode and $itembranchcode eq $currentbranch) {
            push @itemloop, $item_info;
            $itemloop_has_images++ if $item->cover_images->count;
        } else {
            push @otheritemloop, $item_info;
            $otheritemloop_has_images++ if $item->cover_images->count;
        }
    } else {
        push @itemloop, $item_info;
        $itemloop_has_images++ if $item->cover_images->count;
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
    MARCNOTES               => !$invalid_marc_record ? $biblio->get_marc_notes() : undef,
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

if (C4::Context->preference("AlternateHoldingsField") && $items->count == 0) {
    my $fieldspec = C4::Context->preference("AlternateHoldingsField");
    my $subfields = substr $fieldspec, 3;
    my $holdingsep = C4::Context->preference("AlternateHoldingsSeparator") || ' ';
    my @alternateholdingsinfo = ();
    my @holdingsfields = $marc_record->field(substr $fieldspec, 0, 3);

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
    $template->param(
        localimages => $biblio->cover_images->search(
            {}, { order_by => [ \"COALESCE(itemnumber, 0, 1)", 'timestamp' ] }
        ),
    );
}

# HTML5 Media
if ( (C4::Context->preference("HTML5MediaEnabled") eq 'both') or (C4::Context->preference("HTML5MediaEnabled") eq 'staff') ) {
    $template->param( C4::HTML5Media->gethtml5media($marc_record));
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
