# This file is part of Koha.
#
# Copyright (C) 2013 Tamil s.a.r.l.
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

package Koha::Indexer::RecordReader;

use Moose;

with 'MooseX::RW::Reader';


use Modern::Perl;
use utf8;
use Moose::Util::TypeConstraints;
use MARC::Record;
use MARC::File::XML;
use C4::Context;
use C4::Biblio;
use C4::Items;


subtype 'Koha::RecordType'
    => as 'Str',
    => where { /biblio|authority/i },
    => message { "$_ is not a valid Koha::RecordType (biblio or authority" };

subtype 'Koha::RecordSelect'
    => as 'Str',
    => where { /all|queue|queue_update|queue_delete/ },
    => message {
        "$_ is not a valide Koha::RecordSelect " .
        "(all or queue or queue_update or queue_delete)"
    };


has source => (
    is       => 'rw',
    isa      => 'Koha::RecordType',
    required => 1,
    default  => 'biblio',
);

has select => (
    is       => 'rw',
    isa      => 'Koha::RecordSelect',
    required => 1,
    default  => 'all',
);

has xml => ( is => 'rw', isa => 'Bool', default => '0' );

has sth => ( is => 'rw' );

# Last returned record biblionumber;
has id => ( is => 'rw' );

# Biblio records normalizer, if necessary
has normalizer => ( is => 'rw' );

# Read all records? (or queued records)
has allrecords => ( is => 'rw', isa => 'Bool', default => 1 );

# Mark as done an entry is Zebra queue
has sth_queue_done => ( is => 'rw' );

# Items tag
has itemtag => ( is => 'rw' );

# Las returned record frameworkcode
# FIXME: a KohaRecord class should contain this information
has frameworkcode => ( is => 'rw', isa => 'Str' );


sub BUILD {
    my $self = shift;
    my $dbh  = C4::Context->dbh();

    # Tag containing items
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField("items.itemnumber",'');
    $self->itemtag($itemtag);

    if ( $self->source =~ /biblio/i &&
         C4::Context->preference('IncludeSeeFromInSearches') )
    {
        require Koha::RecordProcessor;
        my $normalizer = Koha::RecordProcessor->new( { filters => 'EmbedSeeFromHeadings' } );
        $self->normalizer($normalizer);
        # Necessary for as_xml method
        MARC::File::XML->default_record_format( C4::Context->preference('marcflavour') );
    }

    my $operation = $self->select =~ /update/i
                    ? 'specialUpdate'
                    : 'recordDelete';
    $self->allrecords( $self->select =~ /all/i ? 1 : 0 );
    my $sql =
        $self->source =~ /biblio/i
            ? $self->allrecords
                ? "SELECT NULL, biblionumber FROM biblio"
                : "SELECT id, biblio_auth_number FROM zebraqueue
                   WHERE server = 'biblioserver'
                     AND operation = '$operation' AND done = 0"
            : $self->allrecords
                ? "SELECT NULL, authid FROM auth_header"
                : "SELECT id, biblio_auth_number FROM zebraqueue
                   WHERE server = 'authorityserver'
                     AND operation = '$operation' AND done = 0";
    my $sth = $dbh->prepare( $sql );
    $sth->execute();
    $self->sth( $sth );

    unless ( $self->allrecords ) {
        $self->sth_queue_done( $dbh->prepare(
            "UPDATE zebraqueue SET done=1 WHERE id=?" ) );
    }

    __PACKAGE__->meta->add_method( 'get' =>
        $self->source =~ /biblio/i
            ? $self->xml && !$self->normalizer
              ? \&get_biblio_xml
              : \&get_biblio_marc
            : $self->xml
              ? \&get_auth_xml
              : \&get_auth_marc
    );
}



sub read {
    my $self = shift;
    while ( my ($queue_id, $id) = $self->sth->fetchrow ) {
        # Suppress entry in zebraqueue table
        $self->sth_queue_done->execute($queue_id) if $queue_id;
        if ( my $record = $self->get( $id ) ) {
            $record = $self->normalizer->process($record) if $self->normalizer;
            $self->count($self->count+1);
            $self->id( $id );
            return $record;
        }
    }
    return 0;
}



sub get_biblio_xml {
    my ( $self, $id ) = @_;
    my$dbh = C4::Context->dbh();
    my $sth = $dbh->prepare(
        "SELECT marcxml FROM biblioitems WHERE biblionumber=? ");
    $sth->execute( $id );
    my ($marcxml) = $sth->fetchrow;

    # If biblio isn't found in biblioitems, it is searched in
    # deletedbilioitems. Usefull for delete Zebra requests
    unless ( $marcxml ) {
        $sth = $dbh->prepare(
            "SELECT marcxml FROM deletedbiblioitems WHERE biblionumber=? ");
        $sth->execute( $id );
        ($marcxml) = $sth->fetchrow;
    }

    # Items extraction
    # FIXME: It slows down drastically biblio records export
    {
        my @items = @{ $dbh->selectall_arrayref(
            "SELECT * FROM items WHERE biblionumber=$id",
            {Slice => {} } ) };
        if (@items){
            my $record = MARC::Record->new;
            $record->encoding('UTF-8');
            my @itemsrecord;
            foreach my $item (@items) {
                my $record = Item2Marc($item, $id);
                push @itemsrecord, $record->field($self->itemtag);
            }
            $record->insert_fields_ordered(@itemsrecord);
            my $itemsxml = $record->as_xml_record();
            $marcxml =
                substr($marcxml, 0, length($marcxml)-10) .
                substr($itemsxml, index($itemsxml, "</leader>\n", 0) + 10);
        }
    }
    return $marcxml;
}


# Get biblio record, if the record doesn't exist in biblioitems, it is searched
# in deletedbiblioitems.
sub get_biblio_marc {
    my ( $self, $id ) = @_;

    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare(
        "SELECT marcxml FROM biblioitems WHERE biblionumber=? ");
    $sth->execute( $id );
    my ($marcxml) = $sth->fetchrow;

    unless ( $marcxml ) {
        $sth = $dbh->prepare(
            "SELECT marcxml FROM deletedbiblioitems WHERE biblionumber=? ");
        $sth->execute( $id );
        ($marcxml) = $sth->fetchrow;
    }

    $marcxml =~ s/[^\x09\x0A\x0D\x{0020}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//g;
    my $record = MARC::Record->new();
    if ($marcxml) {
        $record = eval {
            MARC::Record::new_from_xml( $marcxml, "utf8" ) };
        if ($@) { warn " problem with: $id : $@ \n$marcxml"; }

        # Items extraction if Koha v3.4 and above
        # FIXME: It slows down drastically biblio records export
        if ( $self->itemsextraction ) {
            my @items = @{ $dbh->selectall_arrayref(
                "SELECT * FROM items WHERE biblionumber=$id",
                {Slice => {} } ) };
            if (@items){
                my @itemsrecord;
                foreach my $item (@items) {
                    my $record = Item2Marc($item, $id);
                    push @itemsrecord, $record->field($self->itemtag);
                }
                $record->insert_fields_ordered(@itemsrecord);
            }
        }
        return $record;
    }
    return;
}


sub get_auth_xml {
    my ( $self, $id ) = @_;

    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare(
        "select marcxml from auth_header where authid=? "  );
    $sth->execute( $id );
    my ($xml) = $sth->fetchrow;

    # If authority isn't found we build a mimimalist record
    # Usefull for delete Zebra requests
    unless ( $xml ) {
        return
            "<record
               xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
               xsi:schemaLocation=\"http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd\"
               xmlns=\"http://www.loc.gov/MARC21/slim\">
             <leader>                        </leader>
             <controlfield tag=\"001\">$id</controlfield>
             </record>\n";
    }

    my $new_xml = '';
    foreach ( split /\n/, $xml ) {
        next if /^<collection|^<\/collection/;
        $new_xml .= "$_\n";
    }
    return $new_xml;
}


no Moose;
1;
