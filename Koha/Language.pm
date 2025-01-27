package Koha::Language;

# Copyright 2025 Koha development team
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

=head1 NAME

Koha::Language

=head1 SYNOPSIS

    use Koha::Language;

    Koha::Language->set_requested_language('xx-XX');
    my $language = Koha::Language->get_requested_language();

=head1 DESCRIPTION

This module is essentially a communication tool between the REST API and
C4::Languages::getlanguage so that getlanguage can be aware of the value of
KohaOpacLanguage cookie when not in CGI context.

It can also be used in other contexts, like command line scripts for instance.

=cut

use Modern::Perl;

use Koha::Cache::Memory::Lite;

use constant REQUESTED_LANGUAGE_CACHE_KEY => 'requested_language';

=head1 METHODS

=head2 set_requested_language

    Caches requested language

=cut

sub set_requested_language {
    my ( $class, $language ) = @_;

    my $cache = Koha::Cache::Memory::Lite->get_instance;

    $cache->set_in_cache( REQUESTED_LANGUAGE_CACHE_KEY, $language );
}

=head2 get_requested_language

    Gets requested language from cache

=cut

sub get_requested_language {
    my ($class) = @_;

    my $cache = Koha::Cache::Memory::Lite->get_instance;

    return $cache->get_from_cache(REQUESTED_LANGUAGE_CACHE_KEY);
}

1;
