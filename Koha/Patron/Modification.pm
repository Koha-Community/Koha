package Koha::Patron::Modification;

# Copyright ByWater Solutions 2014
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
use Koha::Exceptions::Patron::Modification;
use Koha::Patron::Attribute;
use Koha::Patron::Attributes;
use Koha::Patron::Modifications;

use JSON;
use List::MoreUtils qw( uniq );
use Try::Tiny;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Modification - Class represents a request to modify or create a patron

=head2 Class Methods

=cut

=head2 store

=cut

sub store {
    my ($self) = @_;

    if ( $self->verification_token ) {
        if (Koha::Patron::Modifications->search(
                { verification_token => $self->verification_token }
            )->count()
            )
        {
            Koha::Exceptions::Patron::Modification::DuplicateVerificationToken->throw(
                "Duplicate verification token " . $self->verification_token );
        }
    }

    if ( $self->extended_attributes ) {
        try {
            my $json_parser = JSON->new;
            $json_parser->decode( $self->extended_attributes );
        }
        catch {
            Koha::Exceptions::Patron::Modification::InvalidData->throw(
                'The passed extended_attributes is not valid JSON');
        };
    }

    return $self->SUPER::store();
}

=head2 approve

$m->approve();

Commits the pending modifications to the borrower record and removes
them from the modifications table.

=cut

sub approve {
    my ($self) = @_;

    my $data = $self->unblessed();
    my $extended_attributes;

    delete $data->{timestamp};
    delete $data->{verification_token};
    delete $data->{extended_attributes};

    foreach my $key ( keys %$data ) {
        delete $data->{$key} unless ( defined( $data->{$key} ) );
    }

    my $patron = Koha::Patrons->find( $self->borrowernumber );

    return unless $patron;

    $patron->set($data);

    # Take care of extended attributes
    if ( $self->extended_attributes ) {
        $extended_attributes = try { from_json( $self->extended_attributes ) }
        catch {
            Koha::Exceptions::Patron::Modification::InvalidData->throw(
                'The passed extended_attributes is not valid JSON');
        };
    }

    $self->_result->result_source->schema->txn_do(
        sub {
            try {
                $patron->store();

                # Deal with attributes
                my @codes
                    = uniq( map { $_->{code} } @{$extended_attributes} );
                foreach my $code (@codes) {
                    map { $_->delete } Koha::Patron::Attributes->search(
                        {   borrowernumber => $patron->borrowernumber,
                            code           => $code
                        }
                    );
                }
                foreach my $attr ( @{$extended_attributes} ) {
                    Koha::Patron::Attribute->new(
                        {   borrowernumber => $patron->borrowernumber,
                            code           => $attr->{code},
                            attribute      => $attr->{value}
                        }
                    )->store
                        if $attr->{value} # there's a value
                           or
                          (    defined $attr->{value} # there's a value that is 0, and not
                            && $attr->{value} ne ""   # the empty string which means delete
                            && $attr->{value} == 0
                          );
                }
            }
            catch {
                if ( $_->isa('DBIx::Class::Exception') ) {
                    Koha::Exceptions::Patron::Modification->throw( $_->{msg} );
                }
                else {
                    Koha::Exceptions::Patron::Modification->throw($_);
                }
            };
        }
    );

    return $self->delete();
}

=head3 type

=cut

sub _type {
    return 'BorrowerModification';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
