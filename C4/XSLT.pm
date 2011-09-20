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
# Foundation; either version 2 of the License, or (at your option) any later
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
use Encode;
use XML::LibXML;
use XML::LibXSLT;
use LWP::Simple;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    require Exporter;
    $VERSION = 3.08.01.002;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &XSLTParse4Display
        &GetURI
    );
}

=head1 NAME

C4::XSLT - Functions for displaying XSLT-generated content

=head1 FUNCTIONS

=head2 GetURI

GetURI file and returns the xslt as a string

=cut

sub GetURI {
    my ($uri) = @_;
    my $string;
    $string = get $uri ;
    return $string;
}

=head2 transformMARCXML4XSLT

Replaces codes with authorized values in a MARC::Record object

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

Returns a ref of hash of ref of hash for tag -> letter controled by authorised values

=cut

# Cache for tagfield-tagsubfield to decode per framework.
# Should be preferably be placed in Koha-core...
my %authval_per_framework;

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

my $stylesheet;

sub XSLTParse4Display {
    my ( $biblionumber, $orig_record, $xslsyspref, $fixamps, $hidden_items ) = @_;
    my $xslfilename = C4::Context->preference($xslsyspref);
    if ( $xslfilename =~ /^\s*"?default"?\s*$/i ) {
        if ($xslsyspref eq "XSLTDetailsDisplay") {
            $xslfilename = C4::Context->config('intrahtdocs') .
                        '/' . C4::Context->preference("template") .
                        '/' . C4::Templates::_current_language() .
                        '/xslt/' .
                        C4::Context->preference('marcflavour') .
                        "slim2intranetDetail.xsl";
        } elsif ($xslsyspref eq "XSLTResultsDisplay") {
            $xslfilename = C4::Context->config('intrahtdocs') .
                        '/' . C4::Context->preference("template") .
                        '/' . C4::Templates::_current_language() .
                        '/xslt/' .
                        C4::Context->preference('marcflavour') .
                        "slim2intranetResults.xsl";
        } elsif ($xslsyspref eq "OPACXSLTDetailsDisplay") {
            $xslfilename = C4::Context->config('opachtdocs') .
                        '/' . C4::Context->preference("opacthemes") .
                        '/' . C4::Templates::_current_language() .
                        '/xslt/' .
                        C4::Context->preference('marcflavour') .
                        "slim2OPACDetail.xsl";
        } elsif ($xslsyspref eq "OPACXSLTResultsDisplay") {
            $xslfilename = C4::Context->config('opachtdocs') .
                        '/' . C4::Context->preference("opacthemes") .
                        '/' . C4::Templates::_current_language() .
                        '/xslt/' .
                        C4::Context->preference('marcflavour') .
                        "slim2OPACResults.xsl";
        }
    }

    if ( $xslfilename =~ m/\{langcode\}/ ) {
        my $lang = C4::Templates::_current_language();
        $xslfilename =~ s/\{langcode\}/$lang/;
    }

    # grab the XML, run it through our stylesheet, push it out to the browser
    my $record = transformMARCXML4XSLT($biblionumber, $orig_record);
    #return $record->as_formatted();
    my $itemsxml  = buildKohaItemsNamespace($biblionumber, $hidden_items);
    my $xmlrecord = $record->as_xml(C4::Context->preference('marcflavour'));
    my $sysxml = "<sysprefs>\n";
    foreach my $syspref ( qw/ hidelostitems OPACURLOpenInNewWindow
                              DisplayOPACiconsXSLT URLLinkText viewISBD
                              OPACBaseURL TraceCompleteSubfields UseICU
                              UseAuthoritiesForTracings TraceSubjectSubdivisions
                              Display856uAsImage OPACDisplay856uAsImage 
                              UseControlNumber
                              singleBranchMode
                              AlternateHoldingsField AlternateHoldingsSeparator / )
    {
        my $sp = C4::Context->preference( $syspref );
        next unless defined($sp);
        $sysxml .= "<syspref name=\"$syspref\">$sp</syspref>\n";
    }
    $sysxml .= "</sysprefs>\n";
    $xmlrecord =~ s/\<\/record\>/$itemsxml$sysxml\<\/record\>/;
    if ($fixamps) { # We need to correct the ampersand entities that Zebra outputs
        $xmlrecord =~ s/\&amp;amp;/\&amp;/g;
    }
    $xmlrecord =~ s/\& /\&amp\; /;
    $xmlrecord =~ s/\&amp\;amp\; /\&amp\; /;

    my $parser = XML::LibXML->new();
    # don't die when you find &, >, etc
    $parser->recover_silently(0);
    my $source = $parser->parse_string($xmlrecord);
    unless ( $stylesheet->{$xslfilename} ) {
        my $xslt = XML::LibXSLT->new();
        my $style_doc;
        if ( $xslfilename =~ /^https?:\/\// ) {
            my $xsltstring = GetURI($xslfilename);
            $style_doc = $parser->parse_string($xsltstring);
        } else {
            use Cwd;
            $style_doc = $parser->parse_file($xslfilename);
        }
        $stylesheet->{$xslfilename} = $xslt->parse_stylesheet($style_doc);
    }
    my $results      = $stylesheet->{$xslfilename}->transform($source);
    my $newxmlrecord = $stylesheet->{$xslfilename}->output_string($results);
    return $newxmlrecord;
}

sub buildKohaItemsNamespace {
    my ($biblionumber, $hidden_items) = @_;

    my @items = C4::Items::GetItemsInfo($biblionumber);
    if ($hidden_items && @$hidden_items) {
        my %hi = map {$_ => 1} @$hidden_items;
        @items = grep { !$hi{$_->{itemnumber}} } @items;
    }
    my $branches = GetBranches();
    my $itemtypes = GetItemTypes();
    my $xml = '';
    for my $item (@items) {
        my $status;

        my ( $transfertwhen, $transfertfrom, $transfertto ) = C4::Circulation::GetTransfers($item->{itemnumber});

	my ( $reservestatus, $reserveitem, undef ) = C4::Reserves::CheckReserves($item->{itemnumber});

        if ( $itemtypes->{ $item->{itype} }->{notforloan} || $item->{notforloan} || $item->{onloan} || $item->{wthdrawn} || $item->{itemlost} || $item->{damaged} || 
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
            if ( $item->{wthdrawn}) {
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
	    my $itemcallnumber = xml_escape($item->{itemcallnumber});
        $xml.= "<item><homebranch>$homebranch</homebranch>".
		"<status>$status</status>".
		"<itemcallnumber>".$itemcallnumber."</itemcallnumber>"
        . "</item>";

    }
    $xml = "<items xmlns=\"http://www.koha-community.org/items\">".$xml."</items>";
    return $xml;
}



1;
__END__

=head1 NOTES

=cut

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=cut
