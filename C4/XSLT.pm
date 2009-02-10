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

use C4::Context;
use C4::Branch;
use C4::Items;
use C4::Koha;
use C4::Biblio;
use C4::Circulation;
use XML::LibXML;
use XML::LibXSLT;

use strict;

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
    my ($biblionumber, $orig_record) = @_;
    my $record = $orig_record->clone(); # not updating original record; this may be unnecessarily paranoid
    my $biblio = GetBiblioData($biblionumber);
    my $frameworkcode = GetFrameworkCode($biblionumber);
    my $tagslib = &GetMarcStructure(1,$frameworkcode);
    my @fields;
    # FIXME: wish there was a better way to handle exceptions
    eval {
        @fields = $record->fields();
    };
    if ($@) { warn "PROBLEM WITH RECORD"; next; }
    my $list_of_authvalues = getAuthorisedValues4MARCSubfields($frameworkcode);
    for my $authvalue (@$list_of_authvalues) {
        for my $field ( $record->field($authvalue->{tagfield}) ) {
            my @newSubfields = ();
            for my $subfield ( $field->subfields() ) {
                my ($code,$data) = @$subfield;
                unless ($code eq $authvalue->{tagsubfield}) {
                    push ( @newSubfields, $code, $data );
                } else {
                    my $newvalue = GetAuthorisedValueDesc( $authvalue->{tagfield}, $code, $data, '', $tagslib );
                    push ( @newSubfields, $code, $newvalue );
                }
            }
            my $newField = MARC::Field->new(
                $authvalue->{tagfield},
                $field->indicator(1),
                $field->indicator(2),
                $authvalue->{tagsubfield} => @newSubfields
            );
            $field->replace_with($newField);
        }
    }
    return $record;
}

=head1 getAuthorisedValues4MARCSubfields

=head2 returns an array of hash refs for authorised value tag/subfield combos for a given framework

=cut

sub getAuthorisedValues4MARCSubfields {
    my ($frameworkcode) = @_;
    my @results;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT DISTINCT tagfield,tagsubfield FROM marc_subfield_structure WHERE authorised_value IS NOT NULL AND authorised_value!='' AND frameworkcode=?");
    $sth->execute($frameworkcode);
    while (my $result = $sth->fetchrow_hashref()) {
        push @results, $result;
    }
    return \@results;
}

my $stylesheet;

sub XSLTParse4Display {
    my ($biblionumber, $orig_record, $xslfile) = @_;
    # grab the XML, run it through our stylesheet, push it out to the browser
    my $record = transformMARCXML4XSLT($biblionumber, $orig_record);
    my $itemsxml  = buildKohaItemsNamespace($biblionumber);
    my $xmlrecord = $record->as_xml();
    $xmlrecord =~ s/\<\/record\>/$itemsxml\<\/record\>/;
    my $parser = XML::LibXML->new();
    # don't die when you find &, >, etc
    $parser->recover_silently(1);
    my $source = $parser->parse_string($xmlrecord);
    unless ( $stylesheet ) {
        my $xslt = XML::LibXSLT->new();
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

    my $xml;
    for my $item (@items) {
        my $status;

        my ( $transfertwhen, $transfertfrom, $transfertto ) = C4::Circulation::GetTransfers($item->{itemnumber});

        if ( $itemtypes->{ $item->{itype} }->{notforloan} == 1 || $item->{notforloan} || $item->{onloan} || $item->{wthdrawn} || $item->{itemlost} || $item->{damaged} ||
             ($transfertwhen ne '') || $item->{itemnotforloan} ) {
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
            if ($transfertwhen ne '') {
                $status = 'In transit';
            }
        } else {
            $status = "available";
        }
        $xml.="<item><homebranch>".$branches->{$item->{homebranch}}->{'branchname'}."</homebranch>".
		"<status>$status</status>".
		"<itemcallnumber>".$item->{'itemcallnumber'}."</itemcallnumber></item>";

    }
    return "<items xmlns='http://www.koha.org/items'>".$xml."</items>";
}



1;
__END__

=head1 NOTES

=head1 AUTHOR

Joshua Ferraro <jmf@liblime.com>

=cut
