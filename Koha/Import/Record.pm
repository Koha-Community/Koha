package Koha::Import::Record;

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

use Carp;
use MARC::Record;

use C4::Context;
use C4::Biblio qw(ModBiblio);
use C4::AuthoritiesMarc qw(GuessAuthTypeCode ModAuthority);
use Koha::Database;
use Koha::Import::Record::Biblios;
use Koha::Import::Record::Auths;
use Koha::Import::Record::Matches;

use base qw(Koha::Object);

=head1 NAME

Koha::Import::Record - Koha Import Record Object class

=head1 API

=head2 Class methods

=head3 get_marc_record

Returns a MARC::Record object

    my $marc_record = $import_record->get_marc_record()

=cut

sub get_marc_record {
    my ($self) = @_;

    my $marcflavour = C4::Context->preference('marcflavour');

    my $format = $marcflavour eq 'UNIMARC' ? 'UNIMARC' : 'USMARC';
    if ($marcflavour eq 'UNIMARC' && $self->record_type eq 'auth') {
        $format = 'UNIMARCAUTH';
    }

    my $record = MARC::Record->new_from_xml($self->marcxml, $self->encoding, $format);

    return $record;
}

=head3 import_biblio

Returns the import biblio object for this import record

    my $import_biblio = $import_record->import_biblio()

=cut

sub import_biblio {
    my ( $self ) = @_;
    my $import_biblio_rs = $self->_result->import_biblio;
    return Koha::Import::Record::Biblio->_new_from_dbic( $import_biblio_rs );
}

=head3 import_auth

Returns the import auth object for this import record

    my $import_auth = $import_record->import_auth()

=cut

sub import_auth {
    my ( $self ) = @_;
    my $import_auth_rs = $self->_result->import_auth;
    return Koha::Import::Record::Auth->_new_from_dbic( $import_auth_rs );
}

=head3 get_import_record_matches

Returns the Import::Record::Matches for the record
optionally specify a 'chosen' param to get only the chosen match

    my $matches = $import_record->get_import_record_matches([{ chosen => 1 }])

=cut

sub get_import_record_matches {
    my ($self, $params) = @_;
    my $chosen = $params->{chosen};

    my $matches = $self->_result->import_record_matches;
    $matches = Koha::Import::Record::Matches->_new_from_dbic( $matches );

    return $matches->filter_by_chosen() if $chosen;

    return $matches->search({},{ order_by => { -desc => ['score','candidate_match_id'] } });
}

=head3 replace

Import the record to replace an existing record which is passed to this sub

    $import_record->replace({ biblio => $biblio_object });

=cut

sub replace {
    my ($self, $params) = @_;
    my $biblio = $params->{biblio};
    my $authority = $params->{authority};

    my $userenv = C4::Context->userenv;
    my $logged_in_patron = Koha::Patrons->find( $userenv->{number} );

    my $marc_record = $self->get_marc_record;
    my $xmlrecord;
    if( $biblio ){
        my $record = $biblio->metadata->record;
        $xmlrecord = $record->as_xml;
        my $context = { source => 'batchimport' };
        if ($logged_in_patron) {
            $context->{categorycode} = $logged_in_patron->categorycode;
            $context->{userid} = $logged_in_patron->userid;
        }
        ModBiblio(
            $marc_record,
            $biblio->id,
            $biblio->frameworkcode,
            {
                overlay_context   => $context,
                skip_record_index => 1
            }
        );
        $self->import_biblio->matched_biblionumber( $biblio->id )->store;
    } elsif( $authority ) {
        $xmlrecord = $authority->marcxml;
        ModAuthority(
            $authority->id,
            $marc_record,
            GuessAuthTypeCode($marc_record)
        );
        $self->import_auth->matched_authid( $authority->id )->store;
    } else {
        # We could also throw an exception
        return;
    }
    $self->marcxml_old( $xmlrecord );
    $self->status('imported');
    $self->overlay_status('match_applied');
    $self->store;

    return 1;
}

=head2 Internal methods

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'ImportRecord';
}

1;
