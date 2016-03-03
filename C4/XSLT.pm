package C4::XSLT;

# Copyright (C) 2006 LibLime
# <jmf at liblime dot com>
# Parts Copyright Katrin Fischer 2011
# Parts Copyright ByWater Solutions 2011
# Parts Copyright Biblibre 2012
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use C4::Context;
use C4::Branch;
use C4::Items;
use C4::Koha;
use C4::Biblio;
use C4::Circulation;
use C4::Reserves;
use Koha::XSLT_Handler;
use Koha::Libraries;

use Encode;

use vars qw(@ISA @EXPORT);

my $engine; #XSLT Handler object
my %authval_per_framework;
    # Cache for tagfield-tagsubfield to decode per framework.
    # Should be preferably be placed in Koha-core...

BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &XSLTParse4Display
    );
    $engine=Koha::XSLT_Handler->new( { do_not_return_source => 1 } );
}

=head1 NAME

C4::XSLT - Functions for displaying XSLT-generated content

=head1 FUNCTIONS

=head2 transformMARCXML4XSLT

Replaces codes with authorized values in a MARC::Record object
Is only used in this module currently.

=cut

sub transformMARCXML4XSLT {
    my ($biblionumber, $record) = @_;
    my $frameworkcode = GetFrameworkCode($biblionumber) || '';
    my $tagslib = &GetMarcStructure(1,$frameworkcode);
    my @fields;
    # FIXME: wish there was a better way to handle exceptions
    eval {
        @fields = $record->fields();
    };
    if ($@) { warn "PROBLEM WITH RECORD"; next; }
    my $av = getAuthorisedValues4MARCSubfields($frameworkcode);
    foreach my $tag ( keys %$av ) {
        foreach my $field ( $record->field( $tag ) ) {
            if ( $av->{ $tag } ) {
                my @new_subfields = ();
                for my $subfield ( $field->subfields() ) {
                    my ( $letter, $value ) = @$subfield;
                    $value = GetAuthorisedValueDesc( $tag, $letter, $value, '', $tagslib )
                        if $av->{ $tag }->{ $letter };
                    push( @new_subfields, $letter, $value );
                } 
                $field ->replace_with( MARC::Field->new(
                    $tag,
                    $field->indicator(1),
                    $field->indicator(2),
                    @new_subfields
                ) );
            }
        }
    }
    return $record;
}

=head2 getAuthorisedValues4MARCSubfields

Returns a ref of hash of ref of hash for tag -> letter controlled by authorised values
Is only used in this module currently.

=cut

sub getAuthorisedValues4MARCSubfields {
    my ($frameworkcode) = @_;
    unless ( $authval_per_framework{ $frameworkcode } ) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("SELECT DISTINCT tagfield, tagsubfield
                                 FROM marc_subfield_structure
                                 WHERE authorised_value IS NOT NULL
                                   AND authorised_value!=''
                                   AND frameworkcode=?");
        $sth->execute( $frameworkcode );
        my $av = { };
        while ( my ( $tag, $letter ) = $sth->fetchrow() ) {
            $av->{ $tag }->{ $letter } = 1;
        }
        $authval_per_framework{ $frameworkcode } = $av;
    }
    return $authval_per_framework{ $frameworkcode };
}

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

sub XSLTParse4Display {
    my ( $biblionumber, $orig_record, $xslsyspref, $fixamps, $hidden_items ) = @_;
    my $xslfilename = C4::Context->preference($xslsyspref);
    if ( $xslfilename =~ /^\s*"?default"?\s*$/i ) {
        my $htdocs;
        my $theme;
        my $lang = C4::Languages::getlanguage();
        my $xslfile;
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
        }
        $xslfilename = _get_best_default_xslt_filename($htdocs, $theme, $lang, $xslfile);
    }

    if ( $xslfilename =~ m/\{langcode\}/ ) {
        my $lang = C4::Languages::getlanguage();
        $xslfilename =~ s/\{langcode\}/$lang/;
    }

    # grab the XML, run it through our stylesheet, push it out to the browser
    my $record = transformMARCXML4XSLT($biblionumber, $orig_record);
    my $itemsxml  = buildKohaItemsNamespace($biblionumber, $hidden_items);
    my $xmlrecord = $record->as_xml(C4::Context->preference('marcflavour'));
    my $sysxml = "<sysprefs>\n";
    foreach my $syspref ( qw/ hidelostitems OPACURLOpenInNewWindow
                              DisplayOPACiconsXSLT URLLinkText viewISBD
                              OPACBaseURL TraceCompleteSubfields UseICU
                              UseAuthoritiesForTracings TraceSubjectSubdivisions
                              Display856uAsImage OPACDisplay856uAsImage 
                              UseControlNumber IntranetBiblioDefaultView BiblioDefaultView
                              OPACItemLocation DisplayIconsXSLT
                              AlternateHoldingsField AlternateHoldingsSeparator
                              TrackClicks opacthemes IdRef / )
    {
        my $sp = C4::Context->preference( $syspref );
        next unless defined($sp);
        $sysxml .= "<syspref name=\"$syspref\">$sp</syspref>\n";
    }

    # singleBranchMode was a system preference, but no longer is
    # we can retain it here for compatibility
    my $singleBranchMode = Koha::Libraries->search->count == 1;
    $sysxml .= "<syspref name=\"singleBranchMode\">$singleBranchMode</syspref>\n";

    $sysxml .= "</sysprefs>\n";
    $xmlrecord =~ s/\<\/record\>/$itemsxml$sysxml\<\/record\>/;
    if ($fixamps) { # We need to correct the HTML entities that Zebra outputs
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

Returns XML for items.
Is only used in this module currently.

=cut

sub buildKohaItemsNamespace {
    my ($biblionumber, $hidden_items) = @_;

    my @items = C4::Items::GetItemsInfo($biblionumber);
    if ($hidden_items && @$hidden_items) {
        my %hi = map {$_ => 1} @$hidden_items;
        @items = grep { !$hi{$_->{itemnumber}} } @items;
    }

    my $shelflocations = GetKohaAuthorisedValues('items.location',GetFrameworkCode($biblionumber), 'opac');
    my $ccodes         = GetKohaAuthorisedValues('items.ccode',GetFrameworkCode($biblionumber), 'opac');

    my $branches = GetBranches();
    my $itemtypes = GetItemTypes();
    my $location = "";
    my $ccode = "";
    my $xml = '';
    for my $item (@items) {
        my $status;

        my ( $transfertwhen, $transfertfrom, $transfertto ) = C4::Circulation::GetTransfers($item->{itemnumber});

        my $reservestatus = C4::Reserves::GetReserveStatus( $item->{itemnumber} );

        if ( $itemtypes->{ $item->{itype} }->{notforloan} || $item->{notforloan} || $item->{onloan} || $item->{withdrawn} || $item->{itemlost} || $item->{damaged} ||
             (defined $transfertwhen && $transfertwhen ne '') || $item->{itemnotforloan} || (defined $reservestatus && $reservestatus eq "Waiting") ){ 
            if ( $item->{notforloan} < 0) {
                $status = "On order";
            } 
            if ( $item->{itemnotforloan} > 0 || $item->{notforloan} > 0 || $itemtypes->{ $item->{itype} }->{notforloan} == 1 ) {
                $status = "reference";
            }
            if ($item->{onloan}) {
                $status = "Checked out";
            }
            if ( $item->{withdrawn}) {
                $status = "Withdrawn";
            }
            if ($item->{itemlost}) {
                $status = "Lost";
            }
            if ($item->{damaged}) {
                $status = "Damaged"; 
            }
            if (defined $transfertwhen && $transfertwhen ne '') {
                $status = 'In transit';
            }
            if (defined $reservestatus && $reservestatus eq "Waiting") {
                $status = 'Waiting';
            }
        } else {
            $status = "available";
        }
        my $homebranch = $item->{homebranch}? xml_escape($branches->{$item->{homebranch}}->{'branchname'}):'';
        my $holdingbranch = $item->{holdingbranch}? xml_escape($branches->{$item->{holdingbranch}}->{'branchname'}):'';
        $location = $item->{location}? xml_escape($shelflocations->{$item->{location}}||$item->{location}):'';
        $ccode = $item->{ccode}? xml_escape($ccodes->{$item->{ccode}}||$item->{ccode}):'';
        my $itemcallnumber = xml_escape($item->{itemcallnumber});
        $xml.= "<item><homebranch>$homebranch</homebranch>".
                "<holdingbranch>$holdingbranch</holdingbranch>".
                "<location>$location</location>".
                "<ccode>$ccode</ccode>".
                "<status>$status</status>".
                "<itemcallnumber>".$itemcallnumber."</itemcallnumber>".
                "</item>";
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
