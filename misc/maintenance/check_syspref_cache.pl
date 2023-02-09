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
use Pod::Usage qw( pod2usage );
use Encode qw( encode_utf8 );

use Koha::Script;
use Koha::Caches;
use Koha::Config::SysPrefs;
use C4::Context;

=head1 NAME

check_syspref_cache.pl

=head1 SYNOPSIS

    perl check_syspref_cache.pl

=head1 DESCRIPTION

Catch data inconsistencies in cached sysprefs vs those in the database

=cut

my ( $help, $man );
GetOptions(
    'help|?' => \$help,
    'man'    => \$man,
);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

my $syspref_cache = Koha::Caches->get_instance('syspref');
my $prefs = Koha::Config::SysPrefs->search();

while  (my $pref = $prefs->next) {
    my $var = lc $pref->variable;
    my $cached_var = $syspref_cache->get_from_cache("syspref_$var");
    next unless defined $cached_var; #If not defined in cache we will fetch from DB so this case is OK
    say encode_utf8( sprintf( "%s: value in cache is '%s' and value in db is '%s'", $var, $cached_var, $pref->value ) )
      unless $cached_var eq $pref->value;
}
