package Koha::Library;

# Copyright 2015 Koha Development team
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

use Carp;

use C4::Context;

use Koha::Database;
use Koha::StockRotationStages;

use base qw(Koha::Object);

=head1 NAME

Koha::Library - Koha Library Object class

=head1 API

=head2 Class methods

=head3 stockrotationstages

  my $stages = Koha::Library->stockrotationstages;

Returns the stockrotation stages associated with this Library.

=cut

sub stockrotationstages {
    my ( $self ) = @_;
    my $rs = $self->_result->stockrotationstages;
    return Koha::StockRotationStages->_new_from_dbic( $rs );
}

=head3 get_effective_marcorgcode

    my $marcorgcode = Koha::Libraries->find( $library_id )->get_effective_marcorgcode();

Returns the effective MARC organization code of the library. It falls back to the value
from the I<MARCOrgCode> syspref if undefined for the library.

=cut

sub get_effective_marcorgcode {
    my ( $self )  = @_;

    return $self->marcorgcode || C4::Context->preference("MARCOrgCode");
}

=head3 inbound_email_address

  my $to_email = Koha::Library->inbound_email_address;

Returns an effective email address which should be accessible to librarians at the branch.

=cut

sub inbound_email_address {
    my ($self) = @_;

    return
         $self->branchreplyto
      || $self->branchemail
      || C4::Context->preference('ReplytoDefault')
      || C4::Context->preference('KohaAdminEmailAddress')
      || undef;
}

=head3 library_groups

Return the Library groups of this library

=cut

sub library_groups {
    my ( $self ) = @_;
    my $rs = $self->_result->library_groups;
    return Koha::Library::Groups->_new_from_dbic( $rs );
}

=head3 cash_registers

Return Cash::Registers associated with this Library

=cut

sub cash_registers {
    my ( $self ) = @_;
    my $rs = $self->_result->cash_registers;
    return Koha::Cash::Registers->_new_from_dbic( $rs );
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Library object
on the API.

=cut

sub to_api_mapping {
    return {
        branchcode       => 'library_id',
        branchname       => 'name',
        branchaddress1   => 'address1',
        branchaddress2   => 'address2',
        branchaddress3   => 'address3',
        branchzip        => 'postal_code',
        branchcity       => 'city',
        branchstate      => 'state',
        branchcountry    => 'country',
        branchphone      => 'phone',
        branchfax        => 'fax',
        branchemail      => 'email',
        branchreplyto    => 'reply_to_email',
        branchreturnpath => 'return_path_email',
        branchurl        => 'url',
        issuing          => undef,
        branchip         => 'ip',
        branchnotes      => 'notes',
        marcorgcode      => 'marc_org_code',
    };
}

=head3 get_hold_libraries

Return all libraries (including self) that belong to the same hold groups

=cut

sub get_hold_libraries {
    my ( $self ) = @_;
    my $library_groups = $self->library_groups;
    my @hold_libraries;
    while ( my $library_group = $library_groups->next ) {
        my $root = Koha::Library::Groups->get_root_ancestor({id => $library_group->id});
        if($root->ft_local_hold_group) {
            push @hold_libraries, $root->all_libraries;
        }
    }

    my %seen;
    @hold_libraries =
      grep { !$seen{ $_->id }++ } @hold_libraries;

    return Koha::Libraries->search({ branchcode => { '-in' => [ keys %seen ] } });
}

=head3 validate_hold_sibling

Return if given library is a valid hold group member

=cut

sub validate_hold_sibling {
    my ( $self, $params ) = @_;
    my @hold_libraries = $self->get_hold_libraries;

    foreach (@hold_libraries) {
        my $hold_library = $_;
        my $is_valid = 1;
        foreach my $key (keys %$params) {
            unless($hold_library->$key eq $params->{$key}) {
                $is_valid=0;
                last;
            }
        }
        if($is_valid) {
            #Found one library that meets all search parameters
            return 1;
        }
    }
    return 0;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Branch';
}

1;
