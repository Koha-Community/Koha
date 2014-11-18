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

use Test::More;
use File::Spec;
use File::Find;

use t::lib::Mocks;

=head1 DESCRIPTION

00-load.t: This script is called by the pre-commit git hook to test modules compile

=cut

my $context_module = t::lib::Mocks::mock_dbh;

# Loop through the C4:: modules
my $lib = File::Spec->rel2abs('C4');
find({
    bydepth => 1,
    no_chdir => 1,
    wanted => sub {
        my $m = $_;
        return unless $m =~ s/[.]pm$//;
        $m =~ s{^.*/C4/}{C4/};
        $m =~ s{/}{::}g;
        return if $m =~ /Auth_with_ldap/; # Dont test this, it will fail on use
        return if $m =~ /SIP/; # SIP modules will not load clean
        use_ok($m) || BAIL_OUT("***** PROBLEMS LOADING FILE '$m'");
    },
}, $lib);

# Loop through the Koha:: modules
$lib = File::Spec->rel2abs('Koha');
find(
    {
        bydepth  => 1,
        no_chdir => 1,
        wanted   => sub {
            my $m = $_;
            return unless $m =~ s/[.]pm$//;
            $m =~ s{^.*/Koha/}{Koha/};
            $m =~ s{/}{::}g;
            return if $m =~ /Koha::NorwegianPatronDB/; # uses non-mandatory modules
            use_ok($m) || BAIL_OUT("***** PROBLEMS LOADING FILE '$m'");
        },
    },
    $lib
);


done_testing();

1;
