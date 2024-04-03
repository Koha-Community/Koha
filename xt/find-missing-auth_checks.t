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

use File::Slurp qw(read_file);

my @excluded_paths =
    qw(C4 debian docs etc installer/data install_misc Koha misc selenium t test tmp xt changelanguage.pl build-resources.PL fix-perl-path.PL koha_perl_deps.pl );
push @excluded_paths, 'opac';    # We cannot test the OPAC scripts, some can be accessed without authentication

my $grep_cmd = q{git grep -l '#!/usr/bin/perl' -- } . join( ' ', map { qq{':!$_'} } @excluded_paths );
my @files    = `$grep_cmd`;

my @missing_auth_check;
FILE: foreach my $file (@files) {
    chomp $file;
    my @lines = read_file($file);
    for my $line (@lines) {
        for my $routine (qw( get_template_and_user check_cookie_auth checkauth check_api_auth C4::Service->init )) {
            next FILE if $line =~ m|^[^#]*$routine|;
        }
    }
    push @missing_auth_check, $file;
}
is( scalar @missing_auth_check, 0 ) or diag "No auth check in the following files:\n" . join "\n", @missing_auth_check;
done_testing;
