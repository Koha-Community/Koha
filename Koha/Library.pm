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


use C4::Context;

use Koha::Caches;
use Koha::Database;
use Koha::StockRotationStages;
use Koha::SMTP::Servers;

use base qw(Koha::Object);

my $cache = Koha::Caches->get_instance();

=head1 NAME

Koha::Library - Koha Library Object class

=head1 API

=head2 Class methods

=head3 store

Library specific store to ensure relevant caches are flushed on change

=cut

sub store {
    my ($self) = @_;

    my $flush = 0;

    if ( !$self->in_storage ) {
        $flush = 1;
    }
    else {
        my $self_from_storage = $self->get_from_storage;
        $flush = 1 if ( $self_from_storage->branchname ne $self->branchname );
    }

    $self = $self->SUPER::store;

    if ($flush) {
        $cache->clear_from_cache('libraries:name');
    }

    return $self;
}

=head2 delete

Library specific C<delete> to clear relevant caches on delete.

=cut

sub delete {
    my $self = shift @_;
    $cache->clear_from_cache('libraries:name');
    $self->SUPER::delete(@_);
}

=head3 stockrotationstages

  my $stages = Koha::Library->stockrotationstages;

Returns the stockrotation stages associated with this Library.

=cut

sub stockrotationstages {
    my ( $self ) = @_;
    my $rs = $self->_result->stockrotationstages;
    return Koha::StockRotationStages->_new_from_dbic( $rs );
}

=head3 outgoing_transfers

  my $outgoing_transfers = Koha::Library->outgoing_transfers;

Returns the outgoing item transfers associated with this Library.

=cut

sub outgoing_transfers {
    my ( $self ) = @_;
    my $rs = $self->_result->branchtransfers_frombranches;
    return Koha::Item::Transfers->_new_from_dbic( $rs );
}

=head3 inbound_transfers

  my $inbound_transfers = Koha::Library->inbound_transfers;

Returns the inbound item transfers associated with this Library.

=cut

sub inbound_transfers {
    my ( $self ) = @_;
    my $rs = $self->_result->branchtransfers_tobranches;
    return Koha::Item::Transfers->_new_from_dbic( $rs );
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

=head3 smtp_server

    my $smtp_server = $library->smtp_server;
    $library->smtp_server({ smtp_server => $smtp_server });
    $library->smtp_server({ smtp_server => undef });

Accessor for getting and setting the library's SMTP server.

Returns the effective SMTP server configuration to be used on the library. The returned
value is always a I<Koha::SMTP::Server> object.

Setting it to undef will remove the link to a specific SMTP server and effectively
make the library use the default setting

=cut

sub smtp_server {
    my ( $self, $params ) = @_;

    my $library_smtp_server_rs = $self->_result->library_smtp_server;

    if ( exists $params->{smtp_server} ) {

        $self->_result->result_source->schema->txn_do( sub {
            $library_smtp_server_rs->delete
                if $library_smtp_server_rs;

            if ( defined $params->{smtp_server} ) {
                # Set the new server
                # Remove any already set SMTP server

                my $smtp_server = $params->{smtp_server};
                $smtp_server->_result->add_to_library_smtp_servers({ library_id => $self->id });
            }
        });
    } # else => reset to default
    else {
        # Getter
        if ( $library_smtp_server_rs ) {
            return Koha::SMTP::Servers->find(
                $library_smtp_server_rs->smtp_server_id );
        }

        return Koha::SMTP::Servers->get_default;
    }

    return $self;
}

=head3 from_email_address

  my $from_email = Koha::Library->from_email_address;

Returns the official 'from' email address for the branch.

It may well be a 'noreply' or other inaccessible local domain
address that is being used to satisfy spam protection filters.

=cut

sub from_email_address {
    my ($self) = @_;

    return
         $self->branchemail
      || C4::Context->preference('KohaAdminEmailAddress')
      || undef;
}

=head3 inbound_email_address

  my $to_email = Koha::Library->inbound_email_address;

Returns an effective email address which should be accessible to librarians at the branch.

NOTE: This is the address to use for 'reply_to' or 'to' fields; It should not usually be
used as the 'from' address for emails as it may lead to mail being caught by spam filters.

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

=head3 inbound_ill_address

  my $to_email = Koha::Library->inbound_ill_address;

Returns an effective email address which should be accessible to librarians at the branch
for inter library loans communication.

=cut

sub inbound_ill_address {
    my ($self) = @_;

    return
         $self->branchillemail
      || C4::Context->preference('ILLDefaultStaffEmail')
      || $self->inbound_email_address;
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

    return 1 if $params->{branchcode} eq $self->id;

    my $branchcode = $params->{branchcode};
    return $self->get_hold_libraries->search( { branchcode => $branchcode } )
      ->count > 0;
}

=head3 public_read_list

This method returns the list of publicly readable database fields for both API and UI output purposes

=cut

sub public_read_list {
    return [
        'branchcode',     'branchname',     'branchaddress1',
        'branchaddress2', 'branchaddress3', 'branchzip',
        'branchcity',     'branchstate',    'branchcountry',
        'branchfax',      'branchemail',    'branchurl'
    ];
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
        branchillemail   => 'illemail',
        branchreplyto    => 'reply_to_email',
        branchreturnpath => 'return_path_email',
        branchurl        => 'url',
        issuing          => undef,
        branchip         => 'ip',
        branchnotes      => 'notes',
        marcorgcode      => 'marc_org_code',
    };
}

=head3 opac_info

    $library->opac_info({ lang => $lang });

Returns additional contents block OpacLibraryInfo for $lang or 'default'.

Note: This replaces the former branches.opac_info column.

=cut

sub opac_info {
    my ( $self, $params ) = @_;
    return Koha::AdditionalContents->find_best_match({
        category => 'html_customizations',
        location => 'OpacLibraryInfo',
        lang => $params->{lang},
        library_id => $self->branchcode,
    });
}


=head3 get_float_libraries

Return all libraries belonging to the same float group

=cut

sub get_float_libraries {
    my ($self) = @_;

    my $library_groups = $self->library_groups;
    my @float_libraries;

    while ( my $library_group = $library_groups->next ) {
        my $root = Koha::Library::Groups->get_root_ancestor( { id => $library_group->id } );
        if ( $root->ft_local_float_group ) {
            push @float_libraries, $root->all_libraries;
        }
    }

    my %seen;
    @float_libraries =
        grep { !$seen{ $_->id }++ } @float_libraries;

    return Koha::Libraries->search( { branchcode => { '-in' => [ keys %seen ] } } );
}

=head3 validate_float_sibling

Return if given library is a valid float group member

=cut

sub validate_float_sibling {
    my ( $self, $params ) = @_;

    return 1 if $params->{branchcode} eq $self->id;

    my $branchcode = $params->{branchcode};
    return $self->get_float_libraries->search( { branchcode => $branchcode } )->count > 0;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Branch';
}

1;
