package Koha::Util::SystemPreferences;

# Copyright 2018 Koha Development Team
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

use parent qw( Exporter );

our @EXPORT = qw(
  get_yaml_pref_hash
);

=head1 NAME

Koha::Util::SystemPreferences - utility class with System Preference routines

=head1 METHODS

=head2 get_yaml_pref_hash

Turn a pref defined via YAML as a hash

=cut

sub get_yaml_pref_hash {
    my ( $pref ) = @_;
    return if !defined( $pref );

    my @lines = split /\n/, C4::Context->preference($pref)//'';
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

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Nick Clemens <nick@bywatersolutions.com>

=cut
