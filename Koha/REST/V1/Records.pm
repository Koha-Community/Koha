package Koha::REST::V1::Records;

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

use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';

use MARC::Record;
use Encode;

use Koha::REST::V1;
use Koha::REST::V1::Biblio;
use C4::Matcher;
use C4::Biblio;


sub add_record {
    my $c = shift->openapi->valid_input or return;
    my ($record, $newXmlRecord, $biblionumber, $biblioitemnumber);

    my $args = $c->req->params->to_hash;

    ##Test that encoding is valid utf8
    eval {
        unless (Encode::is_utf8($args->{marcxml})) {
            Encode::decode_utf8($args->{marcxml}, Encode::FB_CROAK);
        }
    };
    if ($@) {
        return $c->render( status => 400, openapi => { error =>
            "Given marcxml is not valid utf8:\n".$args->{marcxml}."\nError: '$@'"
        } );
    }

    ##Can we parse XML to MARC::Record?
    eval {
        $record = MARC::Record->new_from_xml(
            $args->{marcxml}, 'utf8', C4::Context->preference("marcflavour")
        );
    };
    if ($@) {
        return $c->render( status => 400, openapi => { error =>
            "Couldn't parse the given marcxml:\n".$args->{marcxml}."\nError: '$@'"
        } );
    }

    ##Validate that the MARC::Record has 001 and 003. Super important for cross
    ##database record sharing!!
    my @mandatoryFields = ('001', '003');
    my @fieldValues;
    eval {
        if ($record->field($_)->data()) {
            push(@fieldValues, $record->field($_)->data());
        }
    } for @mandatoryFields;
    if ($@ || not (@mandatoryFields == @fieldValues)) {
        return $c->render( status => 400, openapi => {
            error => "One of mandatory fields '@mandatoryFields' missing, field ".
            "values '@fieldValues'. For the given marcxml :\n".$args->{marcxml}
        } );
    }

    ##Make a duplication check
    my @matches = C4::Matcher->fetch(1)->get_matches($record, 2);
    if (@matches) {
        return $c->render( status => 400, openapi => {
            error => "Couldn't add the MARC Record to the database:\nThe given ".
            "record duplicates an existing record \"".$matches[0]->{'record_id'}.
            "\". Using matcher 1.\n\nMARC XML of this record:\n".$args->{marcxml}
        } );
    }

    ##Can we write to DB?
    eval {
        #Add to the default framework code
        ($biblionumber, $biblioitemnumber) = C4::Biblio::AddBiblio($record, '');
    };
    if ($@ || not($biblionumber)) {
        return $c->render( status => 500, openapi => {
            error => "Couldn't add the given marcxml to the database:\n".
            $args->{marcxml}."\nError: '$@'"
        } );
    }

    ##Can we get the Koha's mangled version of input data back?
    eval { $newXmlRecord = C4::Biblio::GetXmlBiblio($biblionumber); };
    if ($@ || not($newXmlRecord)) {
        return $c->render( status => 500, openapi => {
            error => "Couldn't get the given marcxml back from the database??:\n".
            $args->{marcxml}."\nError: '$@'"
        } );
    }

    my $responseBody = {biblionumber => 0+$biblionumber, marcxml => $newXmlRecord};
    ##Attach HATEOAS links to response
    Koha::REST::V1::hateoas($c, $responseBody, 'self.nativeView',
        "/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber");

    ##Phew, we survived.
    return $c->render( status => 200, openapi => $responseBody );
}

sub get_record {
    my $c = shift->openapi->valid_input or return;
    my ($record, $xmlRecord);

    my $biblionumber = $c->validation->param('biblionumber');
    ##Can we get the XML?
    eval { $record = C4::Biblio::GetMarcBiblio($biblionumber); };
    if ($@) {
        return $c->render( status => 500, openapi => {
            error => "Couldn't get the given record from the database??:".
                     "\n$biblionumber\nError: '$@'"
        });
    }
    my $encoding = C4::Context->preference("marcflavour");
    $xmlRecord = $record->as_xml_record($encoding) if (defined $record);
    if (not($xmlRecord)) {
        return $c->render( status => 404, openapi => {
            error => "No such MARC record in our database for ".
                     "biblionumber '$biblionumber'"
        });
    }

    my $componentPartBiblios = C4::Biblio::getComponentRecords( $record );
    my @componentPartRecords;
    if ($componentPartBiblios) {
        for my $cb ( @{$componentPartBiblios} ) {
            my $component->{biblionumber} = C4::Biblio::getComponentBiblionumber($cb)+0;
            $component->{marcxml} = decode('utf8', $cb);
            push @componentPartRecords, $component;
        }
    }

    ##Phew, we survived.
    return $c->render( status => 200, openapi => {
        biblionumber => 0+$biblionumber,
        marcxml => $xmlRecord,
        componentparts => \@componentPartRecords
    } );
}

sub delete_record {
    return Koha::REST::V1::Biblio::delete(@_);
}

1;
