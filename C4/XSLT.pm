package C4::XSLT;
# Copyright (C) 2006 LibLime
# <jmf at liblime dot com>
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

use strict;
use warnings;

use C4::Context;
use C4::Branch;
use C4::Items;
use C4::Koha;
use C4::Biblio;
use C4::Circulation;
use Encode;
use XML::LibXML;
use XML::LibXSLT;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
    require Exporter;
    $VERSION = 0.03;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &XSLTParse4Display
    );
}

=head1 NAME

C4::XSLT - Functions for displaying XSLT-generated content

=head1 FUNCTIONS

=head1 transformMARCXML4XSLT

=head2 replaces codes with authorized values in a MARC::Record object

=cut

sub transformMARCXML4XSLT {
    my ($biblionumber, $record) = @_;
    my $frameworkcode = GetFrameworkCode($biblionumber);
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

=head1 getAuthorisedValues4MARCSubfields

=head2 returns an ref of hash of ref of hash for tag -> letter controled bu authorised values

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
    my ( $biblionumber, $orig_record, $xsl_suffix ) = @_;
    # grab the XML, run it through our stylesheet, push it out to the browser
    my $record = transformMARCXML4XSLT($biblionumber, $orig_record);
    #return $record->as_formatted();
    my $itemsxml  = buildKohaItemsNamespace($biblionumber);
    my $xmlrecord = $record->as_xml();
    $xmlrecord =~ s/\<\/record\>/$itemsxml\<\/record\>/;
    my $parser = XML::LibXML->new();
    # don't die when you find &, >, etc
    $parser->recover_silently(1);
    my $source = $parser->parse_string($xmlrecord);
    unless ( $stylesheet ) {
        my $xslt = XML::LibXSLT->new();
        my $xslfile = C4::Context->config('opachtdocs') . 
                      "/prog/en/xslt/" .
                      C4::Context->preference('marcflavour') .
                      "slim2OPAC$xsl_suffix.xsl";
        my $style_doc = $parser->parse_file($xslfile);
        $stylesheet = $xslt->parse_stylesheet($style_doc);
    }
    my $results = $stylesheet->transform($source);
    my $newxmlrecord = $stylesheet->output_string($results);
    return $newxmlrecord;
}

sub buildKohaItemsNamespace {
    my ($biblionumber) = @_;
    my @items = C4::Items::GetItemsInfo($biblionumber);
    my $branches = GetBranches();
    my $itemtypes = GetItemTypes();
    my $xml = '';
    for my $item (@items) {
        my $status;

        my ( $transfertwhen, $transfertfrom, $transfertto ) = C4::Circulation::GetTransfers($item->{itemnumber});

        if ( $itemtypes->{ $item->{itype} }->{notforloan} || $item->{notforloan} || $item->{onloan} || $item->{wthdrawn} || $item->{itemlost} || $item->{damaged} ||
             (defined $transfertwhen && $transfertwhen ne '') || $item->{itemnotforloan} ) {
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
        } else {
            $status = "available";
        }
        my $homebranch = $branches->{$item->{homebranch}}->{'branchname'};
        $xml.= "<item><homebranch>$homebranch</homebranch>".
		"<status>$status</status>".
		(defined $item->{'itemcallnumber'} ? "<itemcallnumber>".$item->{'itemcallnumber'}."</itemcallnumber>" 
                                           : "<itemcallnumber />")
        . "</item>";

    }
    $xml = "<items xmlns=\"http://www.koha.org/items\">".$xml."</items>";
    return $xml;
}



1;
__END__

=head1 NOTES

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=cut
