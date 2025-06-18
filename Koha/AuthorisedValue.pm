package Koha::AuthorisedValue;

# Copyright ByWater Solutions 2014
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Caches;
use Koha::Database;
use Koha::Exceptions;
use Koha::Object;
use Koha::Object::Limit::Library;

use base qw(Koha::Object Koha::Object::Limit::Library);

use constant NUM_PATTERN    => q{^(-[1-9][0-9]*|0|[1-9][0-9]*)$};
use constant NUM_PATTERN_JS => q{(-[1-9][0-9]*|0|[1-9][0-9]*)};     # ^ and $ removed

my $cache = Koha::Caches->get_instance();

=head1 NAME

Koha::AuthorisedValue - Koha Authorised value Object class

=head1 API

=head2 Class methods

=cut

=head3 store

AuthorisedValue specific store to ensure relevant caches are flushed on change

=cut

sub store {
    my ($self) = @_;

    my $flush = 0;

    if ( !$self->in_storage ) {
        $flush = 1;
    } else {
        my %updated_columns = $self->_result->get_dirty_columns;

        if (   exists $updated_columns{lib}
            or exists $updated_columns{lib_opac} )
        {
            $flush = 1;
        }
    }

    $self->_check_is_integer_only;

    $self = $self->SUPER::store;

    if ($flush) {
        my $key = "AV_descriptions:" . $self->category;
        $cache->clear_from_cache($key);
    }

    return $self;
}

=head2 delete

AuthorisedValue specific C<delete> to clear relevant caches on delete.

=cut

sub delete {
    my $self = shift @_;
    my $key  = "AV_descriptions:" . $self->category;
    $cache->clear_from_cache($key);
    $self->SUPER::delete(@_);
}

=head3 opac_description

my $description = $av->opac_description();

=cut

sub opac_description {
    my ( $self, $value ) = @_;

    return $self->lib_opac() || $self->lib();
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::AuthorisedValue object
on the API.

=cut

sub to_api_mapping {
    return {
        id               => 'authorised_value_id',
        category         => 'category_name',
        authorised_value => 'value',
        lib              => 'description',
        lib_opac         => 'opac_description',
        imageurl         => 'image_url',
    };
}

=head3 is_integer_only

This helper method tells you if the category for this value allows numbers only.

=cut

sub is_integer_only {
    my $self = shift;
    return $self->_result->category->is_integer_only;
}

=head3 to_api

    my $json = $av->to_api;

Overloaded method that returns a JSON representation of the Koha::AuthorisedValue object,
suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $response  = $self->SUPER::to_api($params);
    my $overrides = {};

    $overrides->{description} = $self->lib // q{};

    return { %$response, %$overrides };
}

=head2 Internal methods

=head3 _check_is_integer_only

    Raise an exception if the category only allows integer values and the value is not.
    Otherwise returns true.

=cut

sub _check_is_integer_only {
    my ($self)  = @_;
    my $pattern = NUM_PATTERN;
    my $value   = $self->authorised_value // q{};
    return 1 if $value =~ qr/${pattern}/;    # no need to check category here yet
    if ( $self->is_integer_only ) {
        Koha::Exceptions::NoInteger->throw("'$value' is no integer value");
    }
    return 1;
}

=head3 _type

=cut

sub _type {
    return 'AuthorisedValue';
}

=head3 _library_limits

=cut

sub _library_limits {
    return {
        class   => 'AuthorisedValuesBranch',
        id      => 'av_id',
        library => 'branchcode'
    };
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
