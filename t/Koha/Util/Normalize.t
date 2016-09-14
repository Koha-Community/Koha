#!/usr/bin/perl

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

use Test::More tests => 5;

BEGIN {
    use_ok('Koha::Util::Normalize');
}

subtest 'legacy_default() normalizer' => sub {

    plan tests => 1;

    my $string = '  .; kY[]:,  (l)/E\'"';

    is( Koha::Util::Normalize::legacy_default( $string ), 'KY LE',
        'The \'legacy_default\' normalizer removes: .;:,][)(/\'" and shifts characters upper-case.
         Also removes spaces from the beginning and ending, and replaces multiple spaces with a single one.' );
};

subtest 'remove_spaces() normalizer' => sub {

    plan tests => 1;

    my $string = '  .; kY[]:,  (l)/E\'"';

    is( Koha::Util::Normalize::remove_spaces( $string ), '.;kY[]:,(l)/E\'"',
        'The \'remove_spaces\' normalizer removes all spaces' );
};

subtest 'upper_case() normalizer' => sub {

    plan tests => 1;

    my $string = '  .; kY[]:,  (l)/E\'"';

    is( Koha::Util::Normalize::upper_case( $string ), '  .; KY[]:,  (L)/E\'"',
        'The \'upper_case\' normalizer only makes characters upper-case' );
};

subtest 'lower_case() normalizer' => sub {

    plan tests => 1;

    my $string = '  .; kY[]:,  (l)/E\'"';

    is( Koha::Util::Normalize::lower_case( $string ), '  .; ky[]:,  (l)/e\'"',
        'The \'lower_case\' normalizer only makes characters lower-case' );
};

1;
