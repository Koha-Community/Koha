package Koha::MetadataRecord::Authority;

# Copyright 2012 C & P Bibliography Services
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

=head1 NAME

Koha::MetadataRecord::Authority - class to encapsulate authority records in Koha

=head1 SYNOPSIS

Object-oriented class that encapsulates authority records in Koha.

=head1 DESCRIPTION

Authority data.

=cut

use strict;
use warnings;
use C4::Context;
use MARC::Record;
use MARC::File::XML;
use C4::Charset qw( StripNonXmlChars );
use Koha::Util::MARC;

use base qw(Koha::MetadataRecord);

__PACKAGE__->mk_accessors(qw( authid authtypecode ));

=head2 new

    my $auth = Koha::MetadataRecord::Authority->new($record);

Create a new Koha::MetadataRecord::Authority object based on the provided record.

=cut

sub new {
    my ( $class, $record, $params ) = @_;

    $params //= {};
    my $self = $class->SUPER::new(
        {
            'record' => $record,
            'schema' => lc C4::Context->preference("marcflavour"),
            %$params,
        }
    );

    bless $self, $class;
    return $self;
}

=head2 get_from_authid

    my $auth = Koha::MetadataRecord::Authority->get_from_authid($authid);

Create the Koha::MetadataRecord::Authority object associated with the provided authid.
Note that this routine currently retrieves a MARC record because
authorities in Koha are MARC records by definition. This is an
unfortunate but unavoidable fact.

=cut

sub get_from_authid {
    my $class       = shift;
    my $authid      = shift;
    my $marcflavour = lc C4::Context->preference("marcflavour");

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select authtypecode, marcxml from auth_header where authid=?");
    $sth->execute($authid);
    my ( $authtypecode, $marcxml ) = $sth->fetchrow;
    my $record = eval {
        MARC::Record->new_from_xml(
            StripNonXmlChars($marcxml), 'UTF-8',
            (
                C4::Context->preference("marcflavour") eq "UNIMARC"
                ? "UNIMARCAUTH"
                : C4::Context->preference("marcflavour")
            )
        );
    };
    return if ($@);
    $record->encoding('UTF-8');

    my $self = $class->SUPER::new(
        {
            authid       => $authid,
            authtypecode => $authtypecode,
            schema       => $marcflavour,
            record       => $record
        }
    );

    bless $self, $class;
    return $self;
}

=head2 get_from_breeding

    my $auth = Koha::MetadataRecord::Authority->get_from_authid($authid);

Create the Koha::MetadataRecord::Authority object associated with the provided authid.

=cut

sub get_from_breeding {
    my $class            = shift;
    my $import_record_id = shift;
    my $marcflavour      = lc C4::Context->preference("marcflavour");

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select marcxml from import_records where import_record_id=? and record_type='auth';");
    $sth->execute($import_record_id);
    my $marcxml = $sth->fetchrow;
    my $record  = eval {
        MARC::Record->new_from_xml(
            StripNonXmlChars($marcxml), 'UTF-8',
            (
                C4::Context->preference("marcflavour") eq "UNIMARC"
                ? "UNIMARCAUTH"
                : C4::Context->preference("marcflavour")
            )
        );
    };
    return if ($@);
    $record->encoding('UTF-8');

    # NOTE: GuessAuthTypeCode has no business in Koha::MetadataRecord::Authority, which is an
    #       object-oriented class. Eventually perhaps there will be utility
    #       classes in the Koha:: namespace, but there are not at the moment,
    #       so this shim seems like the best option all-around.
    require C4::AuthoritiesMarc;
    my $authtypecode = C4::AuthoritiesMarc::GuessAuthTypeCode($record);

    my $self = $class->SUPER::new(
        {
            schema       => $marcflavour,
            authtypecode => $authtypecode,
            record       => $record
        }
    );

    bless $self, $class;
    return $self;
}

=head2 authorized_heading

Missing POD for authorized_heading.

=cut

sub authorized_heading {
    my ($self) = @_;
    if ( $self->schema =~ m/marc/ ) {
        return Koha::Util::MARC::getAuthorityAuthorizedHeading( $self->record, $self->schema );
    }
    return;
}

=head2 get_all_authorities_iterator

    my $it = Koha::MetadataRecord::Authority->get_all_authorities_iterator(%options);

This will provide an iterator object that will, one by one, provide the
Koha::MetadataRecord::Authority of each authority.

The iterator is a Koha::MetadataIterator object.

Possible options are:

=over 4

=item C<slice>

slice may be defined as a hash of two values: index and count. index
is the slice number to process and count is total number of slices.
With this information the iterator returns just the given slice of
records instead of all.

=back

=cut

sub get_all_authorities_iterator {
    my ( $self, %options ) = @_;

    my $search_terms = { marcxml => { '!=', undef } };
    my ( $slice_modulo, $slice_count );
    if ( $options{slice} ) {
        $slice_count  = $options{slice}->{count};
        $slice_modulo = $options{slice}->{index};
        $search_terms = {
            '-and' => [
                %{$search_terms},
                \[ 'mod(authid, ?) = ?', $slice_count, $slice_modulo ]
            ]
        };
    }

    my $search_options->{columns} = [qw/ authid /];
    if ( $options{desc} ) {
        $search_options->{order_by} = { -desc => 'authid' };
    }

    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $rs       = $schema->resultset('AuthHeader')->search(
        $search_terms,
        $search_options
    );

    if ( my $sql = $options{where} ) {
        $rs = $rs->search( \[$sql] );
    }

    my $next_func = sub {

        # Warn and skip bad records, otherwise we break the loop
        while (1) {
            my $row = $rs->next();
            return if !$row;

            my $auth = __PACKAGE__->get_from_authid( $row->authid );
            if ( !$auth ) {
                warn "Something went wrong reading record for authority " . $row->authid . ": $@\n";
                next;
            }
            return $auth;
        }
    };
    return Koha::MetadataIterator->new($next_func);
}

1;
