package Koha::Authority;

# Copyright 2015 Koha Development Team
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

use base qw(Koha::Object);

use Koha::Authority::ControlledIndicators;
use Koha::SearchEngine::Search;

use C4::Heading qw( new_from_field );

=head1 NAME

Koha::Authority - Koha Authority Object class

=head1 API

=head2 Class methods

=head3 get_usage_count

    $count = $self->get_usage_count;

    Returns the number of linked biblio records.

=cut

sub get_usage_count {
    my ($self) = @_;
    return Koha::Authorities->get_usage_count( { authid => $self->authid } );
}

=head3 linked_biblionumbers

    my @biblios = $self->linked_biblionumbers({
        [ max_results => $max ], [ offset => $offset ],
    });

    Returns an array of biblionumbers.

=cut

sub linked_biblionumbers {
    my ( $self, $params ) = @_;
    $params->{authid} = $self->authid;
    return Koha::Authorities->linked_biblionumbers($params);
}

=head3 heading_object

    Routine to return the C4::Heading object for this authority

=cut

sub heading_object {

    my ( $self, $params ) = @_;
    my $record = $params->{record};

    if ( !$self->{_report_tag} ) {
        my $authtype = Koha::Authority::Types->find( $self->authtypecode );
        return {} if !$authtype;    # very exceptional
        $self->{_report_tag} = $authtype->auth_tag_to_report;
    }

    if ( !$record ) {
        $record = $self->record;
    }
    my $field   = $record->field( $self->{_report_tag} );
    my $heading = C4::Heading->new_from_field( $field, undef, 1 );    #new auth heading
    return $heading;

}

=head3 controlled_indicators

    Some authority types control the indicators of some corresponding
    biblio fields (especially in MARC21).
    For example, if you have a PERSO_NAME authority (report tag 100), the
    first indicator of biblio field 600 directly comes from the authority,
    and the second indicator depends on thesaurus settings in the authority
    record. Use this method to obtain such controlled values. In this example
    you should pass 600 in the biblio_tag parameter.

    my $result = $self->controlled_indicators({
        record => $auth_marc, biblio_tag => $bib_tag
    });
    my $ind1 = $result->{ind1};
    my $ind2 = $result->{ind2};
    my $subfield_2 = $result->{sub2}; # Optional subfield 2 when ind==7

    If an indicator is not controlled, the result hash does not contain a key
    for its value. (Same for the sub2 key for an optional subfield $2.)

    Note: The record parameter is a temporary bypass in order to prevent
    needless conversion of $self->marcxml.

=cut

sub controlled_indicators {
    my ( $self, $params ) = @_;
    my $tag    = $params->{biblio_tag} // q{};
    my $record = $params->{record};

    my $flavour =
        C4::Context->preference('marcflavour') eq 'UNIMARC'
        ? 'UNIMARCAUTH'
        : 'MARC21';
    if ( !$record ) {
        $record = $self->record;
    }

    if ( !$self->{_report_tag} ) {
        my $authtype = Koha::Authority::Types->find( $self->authtypecode );
        return {} if !$authtype;    # very exceptional
        $self->{_report_tag} = $authtype->auth_tag_to_report;
    }

    $self->{_ControlledInds} //= Koha::Authority::ControlledIndicators->new;
    return $self->{_ControlledInds}->get(
        {
            auth_record => $record,
            report_tag  => $self->{_report_tag},
            biblio_tag  => $tag,
            flavour     => $flavour,
        }
    );
}

=head3 get_identifiers_and_information

    my $information = $author->get_identifiers_and_information;

Return a list of information of the authors (syspref OPACAuthorIdentifiersAndInformation)

=cut

sub get_identifiers_and_information {
    my ($self) = @_;

    my $record = $self->record;

    # FIXME UNIMARC not supported yet.
    return if C4::Context->preference('marcflavour') eq 'UNIMARC';

    my $information;
    for my $info ( split ',', C4::Context->preference('OPACAuthorIdentifiersAndInformation') ) {
        if ( $info eq 'identifiers' ) {

            # identifiers (024$2$a)
            for my $field ( $record->field('024') ) {
                my $sf_2 = $field->subfield('2');
                my $sf_a = $field->subfield('a');
                next unless $sf_2 && $sf_a;
                push @{ $information->{identifiers} }, { source => $sf_2, number => $sf_a, };
            }
        } elsif ( $info eq 'activity' ) {

            # activity: Activity (372$a$s$t)
            for my $field ( $record->field('372') ) {
                my $sf_a = $field->subfield('a');
                my $sf_s = $field->subfield('s');
                my $sf_t = $field->subfield('t');
                push @{ $information->{activity} },
                    { field_of_activity => $sf_a, start_period => $sf_s, end_period => $sf_t, };
            }
        } elsif ( $info eq 'address' ) {

            # address: Address (371$a$b$d$e)
            for my $field ( $record->field('371') ) {
                my $sf_a = $field->subfield('a');
                my $sf_b = $field->subfield('b');
                my $sf_d = $field->subfield('d');
                my $sf_e = $field->subfield('e');
                push @{ $information->{address} },
                    { address => $sf_a, city => $sf_b, country => $sf_d, postal_code => $sf_e, };
            }
        } elsif ( $info eq 'associated_group' ) {

            # associated_group: Associated group (373$a$s$t$u$v$0)
            for my $field ( $record->field('373') ) {
                my $sf_a = $field->subfield('a');
                my $sf_s = $field->subfield('s');
                my $sf_t = $field->subfield('t');
                my $sf_u = $field->subfield('u');
                my $sf_v = $field->subfield('v');
                my $sf_0 = $field->subfield('0');
                push @{ $information->{associated_group} },
                    {
                    associated_group      => $sf_a, start_period            => $sf_s, end_period => $sf_t, uri => $sf_u,
                    source_of_information => $sf_v, authority_record_number => $sf_0,
                    };
            }
        } elsif ( $info eq 'email_address' ) {

            # email_address: Electronic mail address (371$m)
            for my $field ( $record->field('371') ) {
                my $sf_m = $field->subfield('m');
                push @{ $information->{email_address} }, { email_address => $sf_m, };
            }
        } elsif ( $info eq 'occupation' ) {

            # occupation: Occupation (374$a$s$t$u$v$0)
            for my $field ( $record->field('374') ) {
                my $sf_a = $field->subfield('a');
                my $sf_s = $field->subfield('s');
                my $sf_t = $field->subfield('t');
                my $sf_u = $field->subfield('u');
                my $sf_v = $field->subfield('v');
                my $sf_0 = $field->subfield('0');
                push @{ $information->{occupation} },
                    {
                    occupation            => $sf_a, start_period            => $sf_s, end_period => $sf_t, uri => $sf_u,
                    source_of_information => $sf_v, authority_record_number => $sf_0,
                    };
            }
        } elsif ( $info eq 'place_of_birth' ) {

            # place_of_birth: Place of birth (370$a)
            for my $field ( $record->field('370') ) {
                my $sf_a = $field->subfield('a');
                push @{ $information->{place_of_birth} }, { place_of_birth => $sf_a, };
            }
        } elsif ( $info eq 'place_of_death' ) {

            # place_of_death: Place of death (370$b)
            for my $field ( $record->field('370') ) {
                my $sf_b = $field->subfield('b');
                push @{ $information->{place_of_death} }, { place_of_death => $sf_b, };
            }
        } elsif ( $info eq 'uri' ) {

            # uri: URI (371$u)
            for my $field ( $record->field('371') ) {
                my $sf_u = $field->subfield('u');
                push @{ $information->{uri} }, { uri => $sf_u, };
            }
        }
    }

    return $information;
}

=head3 record

    my $record = $authority->record()

Return the MARC::Record for this authority

=cut

sub record {
    my ($self) = @_;

    my $flavour = $self->record_schema;
    return MARC::Record->new_from_xml( $self->marcxml, 'UTF-8', $flavour );
}

=head3 record_schema

my $schema = $biblio->record_schema();

Returns the record schema (MARC21 or UNIMARCAUTH).

=cut

sub record_schema {
    my ($self) = @_;

    return C4::Context->preference('marcflavour') eq 'UNIMARC'
        ? 'UNIMARCAUTH'
        : 'MARC21';
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Authority object
on the API.

=cut

sub to_api_mapping {
    return {
        authid            => 'authority_id',
        authtrees         => undef,
        authtypecode      => 'framework_id',
        datecreated       => 'created_date',
        linkid            => undef,
        marcxml           => undef,
        modification_time => 'modified_date',
        origincode        => undef,
    };
}

=head3 move_to_deleted

    $authority->move_to_deleted;

    This sub actually copies the authority (to be deleted) into the
    deletedauth_header table. (Just as the other ones.)

=cut

sub move_to_deleted {
    my ($self) = @_;
    my $data = $self->unblessed;
    delete $data->{modification_time};    # trigger new timestamp

    # Set leader 05 (deleted)
    my $format = C4::Context->preference('marcflavour') eq 'UNIMARC' ? 'UNIMARCAUTH' : 'MARC21';
    my $record = $self->record;
    $record->leader( substr( $record->leader, 0, 5 ) . 'd' . substr( $record->leader, 6, 18 ) );
    $data->{marcxml} = $record->as_xml_record($format);

    return Koha::Database->new->schema->resultset('DeletedauthHeader')->create($data);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'AuthHeader';
}

1;
