package C4::XSLT;

# Copyright (C) 2006 LibLime
# <jmf at liblime dot com>
# Parts Copyright Katrin Fischer 2011
# Parts Copyright ByWater Solutions 2011
# Parts Copyright Biblibre 2012
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

use Modern::Perl;

use C4::Context;
use C4::Koha qw( xml_escape );
use C4::Biblio qw( GetAuthorisedValueDesc GetFrameworkCode GetMarcStructure );
use Koha::AuthorisedValues;
use Koha::ItemTypes;
use Koha::RecordProcessor;
use Koha::XSLT::Base;
use Koha::Libraries;
use Koha::Recalls;

my $engine; #XSLT Handler object

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(
        buildKohaItemsNamespace
        XSLTParse4Display
    );
    $engine=Koha::XSLT::Base->new( { do_not_return_source => 1 } );
}

=head1 NAME

C4::XSLT - Functions for displaying XSLT-generated content

=head1 FUNCTIONS

=head2 XSLTParse4Display

Returns xml for biblionumber and requested XSLT transformation.
Returns undef if the transform fails.

Used in OPAC results and detail, intranet results and detail, list display.
(Depending on the settings of your XSLT preferences.)

The helper function _get_best_default_xslt_filename is used in a unit test.

=cut

sub _get_best_default_xslt_filename {
    my ($htdocs, $theme, $lang, $base_xslfile) = @_;

    my @candidates = (
        "$htdocs/$theme/$lang/xslt/${base_xslfile}", # exact match
        "$htdocs/$theme/en/xslt/${base_xslfile}",    # if not, preferred theme in English
        "$htdocs/prog/$lang/xslt/${base_xslfile}",   # if not, 'prog' theme in preferred language
        "$htdocs/prog/en/xslt/${base_xslfile}",      # otherwise, prog theme in English; should always
                                                     # exist
    );
    my $xslfilename;
    foreach my $filename (@candidates) {
        $xslfilename = $filename;
        if (-f $filename) {
            last; # we have a winner!
        }
    }
    return $xslfilename;
}

sub get_xslt_sysprefs {
    my $sysxml = "<sysprefs>\n";
    foreach my $syspref ( qw/ hidelostitems OPACURLOpenInNewWindow
                              DisplayOPACiconsXSLT URLLinkText viewISBD
                              OPACBaseURL TraceCompleteSubfields UseICUStyleQuotes
                              UseAuthoritiesForTracings TraceSubjectSubdivisions
                              Display856uAsImage OPACDisplay856uAsImage 
                              UseControlNumber IntranetBiblioDefaultView BiblioDefaultView
                              OPACItemLocation DisplayIconsXSLT
                              AlternateHoldingsField AlternateHoldingsSeparator
                              TrackClicks opacthemes IdRef OpacSuppression
                              OPACResultsLibrary OPACShowOpenURL
                              OpenURLResolverURL OpenURLImageLocation
                              OPACResultsMaxItems OPACResultsMaxItemsUnavailable OPACResultsUnavailableGroupingBy
                              OpenURLText OPACShowMusicalInscripts OPACPlayMusicalInscripts ContentWarningField / )
    {
        my $sp = C4::Context->preference( $syspref );
        next unless defined($sp);
        $sysxml .= "<syspref name=\"$syspref\">$sp</syspref>\n";
    }

    # singleBranchMode was a system preference, but no longer is
    # we can retain it here for compatibility
    my $singleBranchMode = Koha::Libraries->search->count == 1 ? 1 : 0;
    $sysxml .= "<syspref name=\"singleBranchMode\">$singleBranchMode</syspref>\n";

    $sysxml .= "</sysprefs>\n";
    return $sysxml;
}

sub get_xsl_filename {
    my ( $xslsyspref ) = @_;

    my $lang   = C4::Languages::getlanguage();

    my $xslfilename = C4::Context->preference($xslsyspref) || "default";

    if ( $xslfilename =~ /^\s*"?default"?\s*$/i ) {

        my ( $htdocs, $theme, $xslfile );

        if ($xslsyspref eq "XSLTDetailsDisplay") {
            $htdocs  = C4::Context->config('intrahtdocs');
            $theme   = C4::Context->preference("template");
            $xslfile = C4::Context->preference('marcflavour') .
                       "slim2intranetDetail.xsl";
        } elsif ($xslsyspref eq "XSLTResultsDisplay") {
            $htdocs  = C4::Context->config('intrahtdocs');
            $theme   = C4::Context->preference("template");
            $xslfile = C4::Context->preference('marcflavour') .
                        "slim2intranetResults.xsl";
        } elsif ($xslsyspref eq "OPACXSLTDetailsDisplay") {
            $htdocs  = C4::Context->config('opachtdocs');
            $theme   = C4::Context->preference("opacthemes");
            $xslfile = C4::Context->preference('marcflavour') .
                       "slim2OPACDetail.xsl";
        } elsif ($xslsyspref eq "OPACXSLTResultsDisplay") {
            $htdocs  = C4::Context->config('opachtdocs');
            $theme   = C4::Context->preference("opacthemes");
            $xslfile = C4::Context->preference('marcflavour') .
                       "slim2OPACResults.xsl";
        } elsif ($xslsyspref eq 'XSLTListsDisplay') {
            # Lists default to *Results.xslt
            $htdocs  = C4::Context->config('intrahtdocs');
            $theme   = C4::Context->preference("template");
            $xslfile = C4::Context->preference('marcflavour') .
                        "slim2intranetResults.xsl";
        } elsif ($xslsyspref eq 'OPACXSLTListsDisplay') {
            # Lists default to *Results.xslt
            $htdocs  = C4::Context->config('opachtdocs');
            $theme   = C4::Context->preference("opacthemes");
            $xslfile = C4::Context->preference('marcflavour') .
                       "slim2OPACResults.xsl";
        }
        $xslfilename = _get_best_default_xslt_filename($htdocs, $theme, $lang, $xslfile);
    }

    if ( $xslfilename =~ m/\{langcode\}/ ) {
        $xslfilename =~ s/\{langcode\}/$lang/;
    }

    return $xslfilename;
}

sub XSLTParse4Display {
    my ( $params ) = @_;

    my $biblionumber = $params->{biblionumber};
    my $record       = $params->{record};
    my $xslsyspref   = $params->{xsl_syspref};
    my $fixamps      = $params->{fix_amps};
    my $hidden_items = $params->{hidden_items} || [];
    my $variables    = $params->{xslt_variables};
    my $items_rs     = $params->{items_rs};
    my $interface    = C4::Context->interface;

    die "Mandatory \$params->{xsl_syspref} was not provided, called with biblionumber $params->{biblionumber}"
        if not defined $params->{xsl_syspref};

    my $xslfilename = get_xsl_filename( $xslsyspref);

    my $frameworkcode = GetFrameworkCode($biblionumber) || '';
    my $record_processor = Koha::RecordProcessor->new(
        {
            filters => [ 'ExpandCodedFields' ],
            options => {
                interface     => $interface,
                frameworkcode => $frameworkcode
            }
        }
    );
    $record_processor->process($record);

    # grab the XML, run it through our stylesheet, push it out to the browser
    my $itemsxml;
    if ( $xslsyspref eq "OPACXSLTDetailsDisplay" || $xslsyspref eq "XSLTDetailsDisplay" || $xslsyspref eq "XSLTResultsDisplay" ) {
        $itemsxml = ""; #We don't use XSLT for items display on these pages
    } else {
        $itemsxml = buildKohaItemsNamespace($biblionumber, $hidden_items, $items_rs);
    }
    my $xmlrecord = $record->as_xml(C4::Context->preference('marcflavour'));

    $variables ||= {};
    my $biblio;
    if ( $interface eq 'opac' && C4::Context->preference('OPACShowOpenURL')) {
        my @biblio_itemtypes;
        $biblio //= Koha::Biblios->find($biblionumber);
        if (C4::Context->preference('item-level_itypes')) {
            @biblio_itemtypes = $biblio->items->get_column("itype");
        } else {
            push @biblio_itemtypes, $biblio->itemtype;
        }
        my @itypes = split( /\s/, C4::Context->preference('OPACOpenURLItemTypes') );
        my %original = ();
        map { $original{$_} = 1 } @biblio_itemtypes;
        if ( grep { $original{$_} } @itypes ) {
            $variables->{OpenURLResolverURL} = $biblio->get_openurl;
        }
    }

    my $varxml = "<variables>\n";
    while (my ($key, $value) = each %$variables) {
        $value //= q{};
        $varxml .= "<variable name=\"$key\">$value</variable>\n";
    }
    $varxml .= "</variables>\n";

    my $sysxml = get_xslt_sysprefs();
    $xmlrecord =~ s/\<\/record\>/$itemsxml$sysxml$varxml\<\/record\>/;
    if ($fixamps) { # We need to correct the ampersand entities that Zebra outputs
        $xmlrecord =~ s/\&amp;amp;/\&amp;/g;
        $xmlrecord =~ s/\&amp\;lt\;/\&lt\;/g;
        $xmlrecord =~ s/\&amp\;gt\;/\&gt\;/g;
    }
    $xmlrecord =~ s/\& /\&amp\; /;
    $xmlrecord =~ s/\&amp\;amp\; /\&amp\; /;

    #If the xslt should fail, we will return undef (old behavior was
    #raw MARC)
    #Note that we did set do_not_return_source at object construction
    return $engine->transform($xmlrecord, $xslfilename ); #file or URL
}

=head2 buildKohaItemsNamespace

    my $items_xml = buildKohaItemsNamespace( $biblionumber, [ $hidden_items, $items ] );

Returns XML for items. It accepts two optional parameters:
- I<$hidden_items>: An arrayref of itemnumber values, for items that should be hidden
- I<$items>: A Koha::Items resultset, for the items to be returned

If both parameters are passed, I<$items> is used as the basis resultset, and I<$hidden_items>
are filtered out of it.

Is only used in this module currently.

=cut

sub buildKohaItemsNamespace {
    my ($biblionumber, $hidden_items, $items_rs) = @_;

    $hidden_items ||= [];

    my $query = {};
    $query = { 'me.itemnumber' => { not_in => $hidden_items } }
      if $hidden_items;

    unless ( $items_rs && ref($items_rs) eq 'Koha::Items' ) {
        $query->{'me.biblionumber'} = $biblionumber;
        $items_rs = Koha::Items->new;
    }

    my $items = $items_rs->search( $query, { prefetch => [ 'branchtransfers', 'reserves' ] } );

    my $shelflocations =
      { map { $_->{authorised_value} => $_->{opac_description} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => "", kohafield => 'items.location' } ) };
    my $ccodes =
      { map { $_->{authorised_value} => $_->{opac_description} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => "", kohafield => 'items.ccode' } ) };

    my %branches = map { $_->branchcode => $_->branchname } Koha::Libraries->search({}, { order_by => 'branchname' })->as_list;

    my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search->unblessed } };
    my $xml = '';
    my %descs = map { $_->{authorised_value} => $_ } Koha::AuthorisedValues->get_descriptions_by_koha_field( { kohafield => 'items.notforloan' } );
    my $ref_status = C4::Context->preference('Reference_NFL_Statuses') || '1|2';

    while ( my $item = $items->next ) {
        my $status;
        my $substatus = '';
        my $recalls_count;

        if ( C4::Context->preference('UseRecalls') ) {
            $recalls_count = Koha::Recalls->search({ item_id => $item->itemnumber, status => 'waiting' })->count;
        }

        if ($recalls_count) {
            # recalls take priority over holds
            $status = 'other';
            $substatus = 'Recall waiting';
        }
        elsif ( $item->has_pending_hold ) {
            $status = 'other';
            $substatus = 'Pending hold';
        }
        elsif ( $item->holds->waiting->count ) {
            $status = 'other';
            $substatus = 'Hold waiting';
        }
        elsif ($item->get_transfer) {
            $status = 'other';
            $substatus = 'In transit';
        }
        elsif ($item->damaged) {
            $status = 'other';
            $substatus = "Damaged";
        }
        elsif ($item->itemlost) {
            $status = 'other';
            $substatus = "Lost";
        }
        elsif ( $item->withdrawn) {
            $status = 'other';
            $substatus = "Withdrawn";
        }
        elsif ($item->onloan) {
            $status = 'other';
            $substatus = "Checked out";
        }
        elsif ( $item->notforloan ) {
            $status = $item->notforloan =~ /^($ref_status)$/
                ? "reference"
                : "reallynotforloan";
            $substatus = exists $descs{$item->notforloan} ? $descs{$item->notforloan}->{opac_description} : "Not for loan";
        }
        elsif ( exists $itemtypes->{ $item->effective_itemtype }
            && $itemtypes->{ $item->effective_itemtype }->{notforloan}
            && $itemtypes->{ $item->effective_itemtype }->{notforloan} == 1 )
        {
            $status = "1" =~ /^($ref_status)$/
                ? "reference"
                : "reallynotforloan";
            $substatus = "Not for loan";
        }
        else {
            $status = "available";
        }
        my $homebranch     = C4::Koha::xml_escape($branches{$item->homebranch});
        my $holdingbranch  = C4::Koha::xml_escape($branches{$item->holdingbranch});
        my $resultbranch   = C4::Context->preference('OPACResultsLibrary') eq 'homebranch' ? $homebranch : $holdingbranch;
        my $location       = C4::Koha::xml_escape($item->location && exists $shelflocations->{$item->location} ? $shelflocations->{$item->location} : $item->location);
        my $ccode          = C4::Koha::xml_escape($item->ccode    && exists $ccodes->{$item->ccode}            ? $ccodes->{$item->ccode}            : $item->ccode);
        my $itemcallnumber = C4::Koha::xml_escape($item->itemcallnumber);
        my $stocknumber    = C4::Koha::xml_escape($item->stocknumber);
        $xml .=
            "<item>"
          . "<homebranch>$homebranch</homebranch>"
          . "<holdingbranch>$holdingbranch</holdingbranch>"
          . "<resultbranch>$resultbranch</resultbranch>"
          . "<location>$location</location>"
          . "<ccode>$ccode</ccode>"
          . "<status>".( $status // q{} )."</status>"
          . "<substatus>$substatus</substatus>"
          . "<itemcallnumber>$itemcallnumber</itemcallnumber>"
          . "<stocknumber>$stocknumber</stocknumber>"
          . "</item>";
    }
    $xml = "<items xmlns=\"http://www.koha-community.org/items\">".$xml."</items>";
    return $xml;
}

=head2 engine

Returns reference to XSLT handler object.

=cut

sub engine {
    return $engine;
}

1;

__END__

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

Koha Development Team <http://koha-community.org/>

=cut
