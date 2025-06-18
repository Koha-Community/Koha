use utf8;

package Koha::Schema::Loader::mysql;

# Copyright 2020 PTFS Europe
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

use base 'DBIx::Class::Schema::Loader::DBI::mysql';
use mro 'c3';

use Scalar::Util qw( blessed );

# This is being upstreamed, but for now lets make sure whatever version of DBIx::Class::Schema::Loader you are using,
# we will catch MariaDB current_timestamp() and convert it to \"current_timestamp" correctly.
sub _extra_column_info {
    no warnings 'uninitialized';
    my ( $self, $table, $col, $info, $dbi_info ) = @_;
    my %extra_info;

    if ( $dbi_info->{mysql_is_auto_increment} ) {
        $extra_info{is_auto_increment} = 1;
    }
    if ( $dbi_info->{mysql_type_name} =~ /\bunsigned\b/i ) {
        $extra_info{extra}{unsigned} = 1;
    }
    if ( $dbi_info->{mysql_values} ) {
        $extra_info{extra}{list} = $dbi_info->{mysql_values};
    }
    if (
        ( not blessed $dbi_info)    # isa $sth
        && lc( $dbi_info->{COLUMN_DEF} ) =~ m/^current_timestamp/
        && lc( $dbi_info->{mysql_type_name} ) eq 'timestamp'
        )
    {

        my $current_timestamp = 'current_timestamp';
        $extra_info{default_value} = \$current_timestamp;
    }

    return \%extra_info;
}

1;
