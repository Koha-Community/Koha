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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

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
use C4::Output  qw( output_html_with_http_headers );
use C4::Biblio  qw( GetBiblioData GetFrameworkCode );
use C4::Items   qw( GetAnalyticsCount );
use C4::Reserves;
use C4::Serials          qw( CountSubscriptionFromBiblionumber SearchSubscriptions GetLatestSerials );
use C4::XISBN            qw( get_xisbns );
use C4::External::Amazon qw( get_amazon_tld );
use C4::Search           qw( z3950_search_args enabled_staff_search_views new_record_from_zebra );
use C4::Tags             qw( get_tags );
use C4::XSLT             qw( XSLTParse4Display );
use Koha::DateUtils      qw( format_sqldatetime );
use C4::HTML5Media;
use C4::CourseReserves qw( GetItemCourseReservesInfo );
use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::Biblio::ItemGroup::Items;
use Koha::Biblio::ItemGroups;
use Koha::CoverImages;
use Koha::DateUtils;
use Koha::ILL::Requests;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Patrons;
use Koha::Virtualshelves;
use Koha::Plugins;
use Koha::Recalls;
use Koha::Reviews;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;
use Koha::Serial::Items;
use Koha::Library::Group;
use Koha::Library::Groups;

my $query = CGI->new();

my $analyze = $query->param('analyze');

my ( $template, $borrowernumber, $cookie, $flags ) = get_template_and_user(
    {
        template_name => 'catalogue/detail.tt',
        query         => $query,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

# Determine if we should be offering any enhancement plugin buttons
if ( C4::Context->config('enable_plugins') ) {

    # Only pass plugins that can offer a toolbar button
    my @plugins =
        Koha::Plugins->new()->GetPlugins( { method => 'intranet_catalog_biblio_enhancements_toolbar_button' } );
    $template->param(
        plugins => \@plugins,
    );
}

my $activetab    = $query->param('activetab');
my $biblionumber = $query->param('biblionumber');
$biblionumber = HTML::Entities::encode($biblionumber);
my $biblio = Koha::Biblios->find($biblionumber);

$template->param(
    biblio    => $biblio,
    activetab => $activetab,
);

unless ($biblio) {

    # biblionumber invalid -> report and exit
    $template->param(
        blocking_error => 'unknown_biblionumber',
        biblionumber   => $biblionumber
    );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

my $marc_record         = eval { $biblio->metadata->record };
my $invalid_marc_record = $@ || !$marc_record;
if ($invalid_marc_record) {
    $template->param( decoding_error => $@ );
    my $marc_xml = C4::Charset::StripNonXmlChars( $biblio->metadata->metadata );

    $marc_record = eval {
        MARC::Record::new_from_xml(
            $marc_xml, 'UTF-8',
            C4::Context->preference('marcflavour')
        );
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
        } else {
            $item_group_item = Koha::Biblio::ItemGroup::Item->new(
                {
                    item_id       => $item_id,
                    item_group_id => $item_group_id,
                }
            );
        }

        $item_group_item->store();
    }
} elsif ( $op eq 'unset_item_group' ) {
    my $item_group_id = $query->param('item_group_id');
    my @itemnumbers   = $query->multi_param('itemnumber');

    foreach my $item_id (@itemnumbers) {
        my $item_group_item = Koha::Biblio::ItemGroup::Items->find( { item_id => $item_id } );
        $item_group_item->delete() if $item_group_item;
    }
}

if ( $query->cookie("holdfor") ) {
    my $holdfor_patron = Koha::Patrons->find( $query->cookie("holdfor") );
    if ($holdfor_patron) {
        $template->param(
            holdfor        => $query->cookie("holdfor"),
            holdfor_patron => $holdfor_patron,
        );
    }
}

if ( $query->cookie("searchToOrder") ) {
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
my $upc  = GetNormalizedUPC( $marc_record, $marcflavour );
my $ean  = GetNormalizedEAN( $marc_record, $marcflavour );
my $oclc = GetNormalizedOCLCNumber( $marc_record, $marcflavour );
my $isbn = GetNormalizedISBN( undef, $marc_record, $marcflavour );
my $content_identifier_exists;
if ( $isbn or $ean or $oclc or $upc ) {
    $content_identifier_exists = 1;
}

$template->param(
    normalized_upc            => $upc,
    normalized_ean            => $ean,
    normalized_oclc           => $oclc,
    normalized_isbn           => $isbn,
    content_identifier_exists => $content_identifier_exists,
);

my $itemtypes          = { map { $_->itemtype => $_ } @{ Koha::ItemTypes->search_with_localization->as_list } };
my $patron             = Koha::Patrons->find($borrowernumber);
my $include_lost_items = !$patron->category->hidelostitems || $showallitems;
my $items_params       = {
    ( $invalid_marc_record ? () : ( host_items => 1 ) ),
};
my $all_items        = $biblio->items($items_params);
my $items_to_display = $all_items->search( { $include_lost_items ? () : ( itemlost => 0 ) } );

my $dat = &GetBiblioData($biblionumber);

#is biblio a collection and are bundles enabled
my $leader = $marc_record->leader();
$dat->{bundlesEnabled} =
    ( ( substr( $leader, 7, 1 ) eq 'c' ) && C4::Context->preference('BundleNotLoanValue') ) ? 1 : 0;

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       = SearchSubscriptions( { biblionumber => $biblionumber, orderby => 'title' } );
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
    $serials_to_display      = $subscription->{staffdisplaycount};
    $serials_to_display      = C4::Context->preference('StaffSerialIssueDisplayCount') unless $serials_to_display;
    $cell{staffdisplaycount} = $serials_to_display;
    $cell{latestserials} =
        GetLatestSerials( $subscription->{subscriptionid}, $serials_to_display );
    push @subs, \%cell;
}

# Get component parts details
my $showcomp = C4::Context->preference('ShowComponentRecords');
my $show_analytics;
if ( $showcomp eq 'both' || $showcomp eq 'staff' ) {
    if ( my $components =
        !$invalid_marc_record ? $biblio->get_marc_components( C4::Context->preference('MaxComponentRecords') ) : undef )
    {
        $show_analytics = 1 if @{$components};    # just show link when having results
        $template->param( analytics_error => 1 )
            if grep { $_->message eq 'component_search' } @{ $biblio->object_messages };
        my $parts;
        for my $part ( @{$components} ) {
            $part = C4::Search::new_record_from_zebra( 'biblioserver', $part );
            my $id = Koha::SearchEngine::Search::extract_biblionumber($part);

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
} else {    # check if we should show analytics anyway
    $show_analytics = 1
        if !$invalid_marc_record && @{ $biblio->get_marc_components(1) };    # count matters here, results does not
    $template->param( analytics_error => 1 )
        if grep { $_->message eq 'component_search' } @{ $biblio->object_messages };
}

# Display volumes link
my $show_volumes = ( !$invalid_marc_record && @{ $biblio->get_marc_volumes(1) } ) ? 1 : 0;

# XSLT processing of some stuff
my $xslt_variables = {
    show_analytics_link => $show_analytics,
    show_volumes_link   => $show_volumes
};
$template->param(
    XSLTDetailsDisplay => '1',
    XSLTBloc           => XSLTParse4Display(
        {
            biblionumber   => $biblionumber,
            record         => $marc_record,
            xsl_syspref    => "XSLTDetailsDisplay",
            fix_amps       => 1,
            xslt_variables => $xslt_variables,
        }
    ),
);

# Get acquisition details
if ( C4::Context->preference('AcquisitionDetails') ) {
    my $orders = Koha::Acquisition::Orders->search(
        { biblionumber => $biblionumber },
        {
            join     => 'basketno',
            order_by => 'basketno.booksellerid'
        }
    );    # GetHistory sorted by aqbooksellerid, but does it make sense?

    $template->param(
        orders     => $orders,
        acq_status => $biblio->acq_status,
    );
}

if ( C4::Context->preference('suggestion') ) {
    my $suggestions = Koha::Suggestions->search(
        {
            biblionumber => $biblionumber,
            archived     => 0,
        },
        { order_by => { -desc => 'suggesteddate' } }
    );
    my $nb_archived_suggestions = Koha::Suggestions->search( { biblionumber => $biblionumber, archived => 1 } )->count;
    $template->param( suggestions => $suggestions, nb_archived_suggestions => $nb_archived_suggestions );
}

if ( defined $dat->{'itemtype'} ) {
    $dat->{imageurl} = getitemtypeimagelocation( 'intranet', $itemtypes->{ $dat->{itemtype} }->imageurl );
}

my $total_group_holdings_count = 0;
my $other_holdings_count       = 0;
my $branch_holdings_count      = 0;
if ( C4::Context->preference('SeparateHoldings') ) {
    my $SeparateHoldingsBranch = C4::Context->preference('SeparateHoldingsBranch') || 'homebranch';
    $branch_holdings_count =
        $items_to_display->search( { $SeparateHoldingsBranch => { '=' => C4::Context->userenv->{branch} } } )->count;
    $other_holdings_count = $items_to_display->count - $branch_holdings_count;
}
$template->param(
    count                  => $all_items->count,         # FIXME 'count' is used in catalog-strings.inc
    other_holdings_count   => $other_holdings_count,     # But it's not a meaningful variable, we should rename it there
    all_items_count        => $all_items->count,
    items_to_display_count => $items_to_display->count,
    branch_holdings_count  => $branch_holdings_count,
);
if ( C4::Context->preference('SeparateHoldingsByGroup') ) {
    my $branchcode        = C4::Context->userenv->{branch};
    my @all_search_groups = Koha::Library::Groups->get_search_groups( { interface => 'staff' } );
    my @lib_groups;
    my %branchcode_hash;
    my %holdings_count;

    foreach my $search_group (@all_search_groups) {
        while ( my $group = $search_group->next ) {
            my @all_libs = $group->all_libraries;

            # Check if library is in group
            if ( grep { $_->branchcode eq $branchcode } @all_libs ) {

                # Get other libraries in group
                my @other_libs = grep { $_->branchcode ne $branchcode } @all_libs;

                my @libs_branchcodes;
                push @libs_branchcodes, $branchcode;

                foreach my $lib (@other_libs) {
                    push @libs_branchcodes, $lib->branchcode;
                }

                # Build group branchcode hash
                $branchcode_hash{ $group->id } = \@libs_branchcodes;

                my $SeparateHoldingsBranch = C4::Context->preference('SeparateHoldingsBranch') || 'homebranch';
                my $group_holdings_count =
                    $items_to_display->search( { $SeparateHoldingsBranch => { '-in' => \@libs_branchcodes } } )->count;
                $holdings_count{ $group->id } = $group_holdings_count;
                $total_group_holdings_count += $group_holdings_count;

                push @lib_groups, $group;
                $other_holdings_count = ( $items_to_display->count ) - $total_group_holdings_count;
            }
        }
    }

    $template->param(
        lib_groups                 => \@lib_groups,
        branchcodes                => \%branchcode_hash,
        holdings_count_hash        => \%holdings_count,
        total_group_holdings_count => $total_group_holdings_count,
        other_holdings_count       => $other_holdings_count,
    );
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
    MARCNOTES           => !$invalid_marc_record ? $biblio->get_marc_notes() : undef,
    z3950_search_params => C4::Search::z3950_search_args($dat),
    C4::Search::enabled_staff_search_views,
);

if ( C4::Context->preference("AlternateHoldingsField") && $items_to_display->count == 0 ) {
    my $fieldspec             = C4::Context->preference("AlternateHoldingsField");
    my $subfields             = substr $fieldspec, 3;
    my $holdingsep            = C4::Context->preference("AlternateHoldingsSeparator") || ' ';
    my @alternateholdingsinfo = ();
    my @holdingsfields        = $marc_record->field( substr $fieldspec, 0, 3 );

    for my $field (@holdingsfields) {
        my %holding      = ( holding => '' );
        my $havesubfield = 0;
        for my $subfield ( $field->subfields() ) {
            if ( ( index $subfields, $$subfield[0] ) >= 0 ) {
                $holding{'holding'} .= $holdingsep if ( length $holding{'holding'} > 0 );
                $holding{'holding'} .= $$subfield[1];
                $havesubfield++;
            }
        }
        if ($havesubfield) {
            push( @alternateholdingsinfo, \%holding );
        }
    }

    $template->param(
        ALTERNATEHOLDINGS => \@alternateholdingsinfo,
    );
}

if ( C4::Context->preference('OPACComments') ) {
    my $reviews = Koha::Reviews->search(
        { biblionumber => $biblionumber },
        { order_by     => { -desc => 'datereviewed' } }
    )->unblessed;
    my $libravatar_enabled = 0;
    if ( C4::Context->preference('ShowReviewer') and C4::Context->preference('ShowReviewerPhoto') ) {
        eval {
            require Libravatar::URL;
            Libravatar::URL->import();
        };
        if ( !$@ ) {
            $libravatar_enabled = 1;
        }
    }
    for my $review (@$reviews) {
        my $review_patron =
            Koha::Patrons->find( $review->{borrowernumber} );    # FIXME Should be Koha::Review->reviewer or similar

        # setting some borrower info into this hash
        if ($review_patron) {
            $review->{patron} = $review_patron;
            if ( $libravatar_enabled and $review_patron->email ) {
                $review->{avatarurl} = libravatar_url( email => $review_patron->email, https => $ENV{HTTPS} );
            }
        }
    }
    $template->param( 'reviews' => $reviews );

}

my @results = ( $dat, );
foreach ( keys %{$dat} ) {
    $template->param( "$_" => defined $dat->{$_} ? $dat->{$_} : '' );
}

# does not work: my %views_enabled = map { $_ => 1 } $template->query(loop => 'EnableViews');
# method query not found?!?!
$template->param( AmazonTld => get_amazon_tld() ) if ( C4::Context->preference("AmazonCoverImages") );
$template->param(
    biblionumber                            => $biblionumber,
    ( $analyze ? 'analyze' : 'detailview' ) => 1,
    subscriptions                           => \@subs,
    subscriptionsnumber                     => $subscriptionsnumber,
    subscriptiontitle                       => $dat->{title},
    searchid                                => scalar $query->param('searchid'),
);

# Lists

if ( C4::Context->preference("virtualshelves") ) {
    my $shelves = Koha::Virtualshelves->search(
        {
            biblionumber => $biblionumber,
            '-or'        => {
                public => 1,
                owner  => $patron->borrowernumber
            }
        },
        {
            join => 'virtualshelfcontents',
        }
    );
    $template->param( 'shelves' => $shelves );
}

# XISBN Stuff
if ( C4::Context->preference("FRBRizeEditions") == 1 ) {
    eval { $template->param( XISBNS => scalar get_xisbns( $isbn, $biblionumber ) ); };
    if ($@) { warn "XISBN Failed $@"; }
}

if ( C4::Context->preference("LocalCoverImages") == 1 ) {
    my $images = $biblio->cover_images;
    $template->param(
        localimages =>
            $biblio->cover_images->search( {}, { order_by => [ \"COALESCE(itemnumber, 0, 1)", 'timestamp' ] } ),
    );
}

# HTML5 Media
if (   ( C4::Context->preference("HTML5MediaEnabled") eq 'both' )
    or ( C4::Context->preference("HTML5MediaEnabled") eq 'staff' ) )
{
    $template->param( C4::HTML5Media->gethtml5media($marc_record) );
}

# Displaying tags
my $tag_quantity;
if ( C4::Context->preference('TagsEnabled') and $tag_quantity = C4::Context->preference('TagsShowOnDetail') ) {
    $template->param(
        TagsEnabled      => 1,
        TagsShowOnDetail => $tag_quantity
    );
    $template->param(
        TagLoop => get_tags(
            {
                biblionumber => $biblionumber, approved => 1,
                'sort'       => '-weight',     limit    => $tag_quantity
            }
        )
    );
}

#we only need to pass the number of holds to the template
my $holds = $biblio->holds;
$template->param( holdcount => $holds->count );

# Check if there are any ILL requests connected to the biblio
my $illrequests =
      C4::Context->preference('ILLModule')
    ? Koha::ILL::Requests->search( { biblio_id => $biblionumber } )
    : [];
$template->param( illrequests => $illrequests );

# get biblionumbers stored in the cart
my @cart_list;

if ( $query->cookie("intranet_bib_list") ) {
    my $cart_list = $query->cookie("intranet_bib_list");
    @cart_list = split( /\//, $cart_list );
    if ( grep { $_ eq $biblionumber } @cart_list ) {
        $template->param( incart => 1 );
    }
}

if ( C4::Context->preference('UseCourseReserves') ) {
    my $course_reserves = GetItemCourseReservesInfo( biblionumber => $biblionumber );
    $template->param( course_reserves => $course_reserves );
}

my @libraries = $patron->libraries_where_can_edit_items;
$template->param( can_edit_items_from => \@libraries );

my @itemtypes                 = Koha::ItemTypes->search->as_list;
my %item_type_image_locations = map { $_->itemtype => $_->image_location('intranet') } @itemtypes;
$template->param( item_type_image_locations => \%item_type_image_locations );

$template->param( found1 => scalar $query->param('found1') );

$template->param( biblio => $biblio );

output_html_with_http_headers $query, $cookie, $template->output;
