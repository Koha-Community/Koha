package Koha::Config::SysPref;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Carp;

use Koha::Database;

use C4::Log;

use base qw(Koha::Object);

=head1 NAME

Koha::Config::SysPref - Koha System Preference Object class

=head1 API

=head2 Class Methods

=cut

=head3 get_yaml_pref_hash

Turn a pref defined via YAML as a hash

=cut

sub get_yaml_pref_hash {
    my ( $self ) = @_;
    return if !defined( $self );

    # We want to use C4::Context->preference in any cases
    # It's cached, and mock_preference still works from tests
    my @lines = split /\n/, C4::Context->preference($self->variable) // '';
    my $pref_as_hash;
    foreach my $line (@lines){
        my ($field,$array) = split /:/, $line;
        next if !$array;
        $field =~ s/^\s*|\s*$//g;
        $array =~ s/[ [\]\r]//g;
        my @array = split /,/, $array;
        @array = map { $_ eq '""' || $_ eq "''" ? '' : $_ } @array;
        @array = map { $_ eq 'NULL' ? undef : $_ } @array;
        $pref_as_hash->{$field} = \@array;
    }

    return $pref_as_hash;
}


=head3 store

=cut

sub store {
    my ($self) = @_;

    my $action = $self->in_storage ? 'MODIFY' : 'ADD';

    C4::Log::logaction( 'SYSTEMPREFERENCE', $action, undef, $self->variable . ' | ' . $self->value );

    return $self->SUPER::store($self);
}

=head3 delete

=cut

sub delete {
    my ($self) = @_;

    my $variable = $self->variable;
    my $value    = $self->value;
    my $deleted  = $self->SUPER::delete($self);

    C4::Log::logaction( 'SYSTEMPREFERENCE', 'DELETE', undef, " $variable | $value" );

    return $deleted;
}

=head3 type

=cut

sub _type {
    return 'Systempreference';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
