package Koha::ERM::Agreement;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use MIME::Base64 qw( decode_base64 );
use MIME::Types;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;
use Koha::Acquisition::Bookseller;

use base qw(Koha::Object::Mixin::AdditionalFields Koha::Object);

use Koha::ERM::Agreement::Period;
use Koha::ERM::Agreement::Periods;
use Koha::ERM::Agreement::Licenses;
use Koha::ERM::Agreement::Relationships;
use Koha::ERM::UserRoles;
use Koha::ERM::Documents;
use Koha::ERM::EHoldings::Package::Agreements;

=head1 NAME

Koha::ERM::Agreement - Koha ErmAgreement Object class

=head1 API

=head2 Class Methods

=cut

=head3 periods

Returns the periods for this agreement

=cut

sub periods {
    my ( $self, $periods ) = @_;

    if ($periods) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->periods->delete;

                for my $period (@$periods) {
                    my $extended_attributes = delete $period->{extended_attributes} // [];
                    my @extended_attributes =
                        map { { 'id' => $_->{field_id}, 'value' => $_->{value} } } @{$extended_attributes};
                    $period->{agreement_id} = $self->agreement_id;

                    my $stored_period = Koha::ERM::Agreement::Period->new($period)->store;
                    $stored_period->extended_attributes( \@extended_attributes );
                }
            }
        );
    }

    my $periods_rs = $self->_result->erm_agreement_periods;
    return Koha::ERM::Agreement::Periods->_new_from_dbic($periods_rs);
}

=head3 user_roles

Returns the user roles for this agreement

=cut

sub user_roles {
    my ( $self, $user_roles ) = @_;

    if ($user_roles) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->user_roles->delete;

                for my $user_role (@$user_roles) {
                    $self->_result->add_to_erm_user_roles($user_role);
                }
            }
        );
    }
    my $user_roles_rs = $self->_result->erm_user_roles;
    return Koha::ERM::UserRoles->_new_from_dbic($user_roles_rs);
}

=head3 agreement_licenses

Returns the agreement_licenses for this agreement

=cut

sub agreement_licenses {
    my ( $self, $agreement_licenses ) = @_;

    if ($agreement_licenses) {
        my $controlling = grep { $_->{status} eq 'controlling' } @$agreement_licenses;
        if ( $controlling > 1 ) {
            Koha::Exceptions::DuplicateObject->throw("Only one controlling license can exist for a given agreement");
        }

        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->agreement_licenses->delete;

                for my $agreement_license (@$agreement_licenses) {
                    $self->_result->add_to_erm_agreement_licenses($agreement_license);
                }
            }
        );
    }
    my $agreement_licenses_rs = $self->_result->erm_agreement_licenses;
    return Koha::ERM::Agreement::Licenses->_new_from_dbic($agreement_licenses_rs);
}

=head3 agreement_relationships

Returns the agreement relationships of this agreement

=cut

sub agreement_relationships {
    my ( $self, $relationships ) = @_;

    if ($relationships) {
        my $schema = $self->_result->result_source->schema;

        # FIXME naming - is "back link" ok?
        my $back_links = {
            'supersedes'                            => 'is-superseded-by',
            'is-superseded-by'                      => 'supersedes',
            'provides_post-cancellation_access_for' => 'has-post-cancellation-access-in',
            'has-post-cancellation-access-in'       => 'provides_post-cancellation_access_for',
            'tracks_demand-driven_acquisitions_for' => 'has-demand-driven-acquisitions-in',
            'has-demand-driven-acquisitions-in'     => 'tracks_demand-driven_acquisitions_for',
            'has_backfile_in'                       => 'has_frontfile_in',
            'has_frontfile_in'                      => 'has_backfile_in',
            'related_to'                            => 'related_to',
        };
        $schema->txn_do(
            sub {
                $self->agreement_relationships->delete;
                $self->agreement_back_relationships->delete;

                for my $relationship (@$relationships) {
                    $self->_result->add_to_erm_agreement_relationships_agreements($relationship);
                    my $back_link = {
                        agreement_id         => $relationship->{related_agreement_id},
                        related_agreement_id => $self->agreement_id,
                        relationship         => $back_links->{ $relationship->{relationship} },
                        notes                => $relationship->{notes}, # FIXME Is it correct, do we keep the note here?
                    };
                    $self->_result->add_to_erm_agreement_relationships_related_agreements($back_link);
                }
            }
        );
    }
    my $related_agreements_rs = $self->_result->erm_agreement_relationships_agreements;
    return Koha::ERM::Agreement::Relationships->_new_from_dbic($related_agreements_rs);
}

=head3 agreement_back_relationships

# FIXME Naming - how is it called?
Returns the reverse relationship

=cut

sub agreement_back_relationships {
    my ($self) = @_;
    my $rs = $self->_result->erm_agreement_relationships_related_agreements;
    return Koha::ERM::Agreement::Relationships->_new_from_dbic($rs);
}

=head3 documents

Returns the documents for this agreement

=cut

=head3 documents

Returns or updates the documents for this agreement

=cut

sub documents {
    my ( $self, $documents ) = @_;
    if ($documents) {
        $self->documents->replace_with( $documents, $self );
    }
    my $documents_rs = $self->_result->erm_documents;
    return Koha::ERM::Documents->_new_from_dbic($documents_rs);
}

=head3 agreement_packages

Return the local packages for this agreement (and the other ones that have an entry locally)

=cut

sub agreement_packages {
    my ($self) = @_;
    my $packages_agreements_rs = $self->_result->erm_eholdings_packages_agreements;
    return Koha::ERM::EHoldings::Package::Agreements->_new_from_dbic($packages_agreements_rs);
}

=head3 vendor

Return the vendor for this agreement

=cut

sub vendor {
    my ($self) = @_;
    my $vendor_rs = $self->_result->vendor;
    return unless $vendor_rs;
    return Koha::Acquisition::Bookseller->_new_from_dbic($vendor_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmAgreement';
}

1;
