#! /usr/bin/perl

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


my $syspref_cache = Koha::Caches->get_instance('syspref');
my $prefs = Koha::Config::SysPrefs->search();

while  (my $pref = $prefs->next) {
    my $var = lc $pref->variable;
    my $cached_var = $syspref_cache->get_from_cache("syspref_$var");
    next unless defined $cached_var; #If not defined in cache we will fetch from DB so this case is OK
    print "$var: value in cache is $cached_var and value in db is ".$pref->value,"\n" unless $cached_var eq $pref->value;
}
