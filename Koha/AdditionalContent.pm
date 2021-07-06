package Koha::AdditionalContent;

# Copyright ByWater Solutions 2015
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


use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Libraries;
use Koha::Patrons;

use base qw(Koha::Object);

=head1 NAME

Koha::AdditionalContent - Koha Additional content object class

=head1 API

=head2 Class Methods

=cut

=head3 author

    $additional_content->author;

Return the Koha::Patron object for the patron who authored this additional content

=cut

sub author {
    my ($self) = @_;
    my $author_rs = $self->_result->borrowernumber;
    return unless $author_rs;
    return Koha::Patron->_new_from_dbic($author_rs);
}

=head3 is_expired

my $is_expired = $additional_content->is_expired;

Returns 1 if the additional content is expired or 0;

=cut

sub is_expired {
    my ( $self ) = @_;

    return 0 unless $self->expirationdate;
    return 1 if dt_from_string( $self->expirationdate ) < dt_from_string->truncate( to => 'day' );
    return 0;
}

=head3 library

my $library = $additional_content->library;

Returns Koha::Library object or undef

=cut

sub library {
    my ( $self ) = @_;

    my $library_rs = $self->_result->branchcode;
    return unless $library_rs;
    return Koha::Library->_new_from_dbic( $library_rs );
}


=head3 _type

=cut

sub _type {
    return 'AdditionalContent';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
