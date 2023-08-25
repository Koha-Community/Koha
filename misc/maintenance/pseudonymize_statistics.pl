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
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::DateUtils qw( dt_from_string format_sqldatetime );
use Koha::Script;
use Koha::Statistics;

use C4::Context;

my ( $help, $verbose, $before );
my $result = GetOptions(
    'h|help'     => \$help,
    'v|verbose'  => \$verbose,
    'b|before:s' => \$before,
) || pod2usage(1);

if ($help) {
    pod2usage(0);
}

unless ( C4::Context->preference('Pseudonymization') ) {
    die "The system preference for Pseudonymization is not enabled, no action will be taken";
}

$before //= format_sqldatetime( dt_from_string(), 'sql', undef, 1 );

my $statistics = Koha::Statistics->search( { datetime => { '<=' => $before } } );

while ( my $statistic = $statistics->next ) {
    $statistic->pseudonymize();
}

=head1 NAME

pseudonymize_statistics - This script pseudonymizes statistics before a given date, or now if no date passed.

NOTE: If patrons or items have been deleted their fields cannot be saved, additionally the fields will use current
values as the ones from when the transaction occurred are not available.

=head1 SYNOPSIS

pseudonymize_statistics.pl [-h|--help] [-v|--verbose] [-b|--before=DATE]

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<-v|--verbose>

Verbose mode.

=item B<-b|--before=DATE>

This option allows for specifying a date to pseudonmyize before. Useful if you have enabled pseudonymization and want to pseudonymize transactions before that date. If not passed all statistics before current time will be pseudonymized.

=back

=head1 AUTHOR

Nick Clemens <nick@bywatersolutions.com>

=head1 COPYRIGHT

Copyright 2023 ByWater Solutions

=head1 LICENSE

This file is part of Koha.

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

=cut
