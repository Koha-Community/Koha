package Koha::Authority;

# Copyright 2015 Koha Development Team
#
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

use Carp;

use Koha::Database;
use C4::Context;
use MARC::Record;

use base qw(Koha::Object);

=head1 NAME

Koha::Authority - Koha Authority Object class

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'AuthHeader';
}

=head2 get_all_authorities_iterator

    my $it = Koha::Authority->get_all_authorities_iterator();

This will provide an iterator object that will, one by one, provide the
Koha::Authority of each authority.

The iterator is a Koha::MetadataIterator object.

=cut

sub get_all_authorities_iterator {
    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $rs =
      $schema->resultset('AuthHeader')->search( { marcxml => { '!=', undef } },
        { columns => [qw/ authid authtypecode marcxml /] } );
    my $next_func = sub {
        my $row = $rs->next();
        return if !$row;
        my $authid       = $row->authid;
        my $authtypecode = $row->authtypecode;
        my $marcxml      = $row->marcxml;

        my $record = eval {
            MARC::Record->new_from_xml(
                StripNonXmlChars($marcxml),
                'UTF-8',
                (
                    C4::Context->preference("marcflavour") eq "UNIMARC"
                    ? "UNIMARCAUTH"
                    : C4::Context->preference("marcflavour")
                )
            );
        };
        confess $@ if ($@);
        $record->encoding('UTF-8');

        # I'm not sure why we don't use the authtypecode from the database,
        # but this is how the original code does it.
        require C4::AuthoritiesMarc;
        $authtypecode = C4::AuthoritiesMarc::GuessAuthTypeCode($record);

        my $auth = __PACKAGE__->new( $record, $authid, $authtypecode );

        return $auth;
      };
      return Koha::MetadataIterator->new($next_func);
}

1;
