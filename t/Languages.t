#!/usr/bin/perl

# Copyright 2013 Equinox Software, Inc.
# Copyright 2014 BibLibre
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
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 4;
use Test::MockModule;
use CGI qw ( -utf8 );
use Koha::Cache::Memory::Lite;

BEGIN {
    use_ok('C4::Languages');
}

my @languages = (); # stores the list of active languages
                    # for the syspref mock
my $return_undef = 0;

my $module_context = new Test::MockModule('C4::Context');

$module_context->mock(
    preference => sub {
        my ($self, $pref) = @_;
        if ($return_undef) {
            return undef;
        } elsif ($pref =~ /language/) {
            return join ',', @languages;
        } else {
            return 'XXX';
        }
  },
);

delete $ENV{HTTP_ACCEPT_LANGUAGE};

my $query = CGI->new();
@languages = ('de-DE', 'fr-FR');
is(C4::Languages::getlanguage($query), 'de-DE', 'default to first language specified in syspref (bug 10560)');

Koha::Cache::Memory::Lite->get_instance()->clear_from_cache('getlanguage');
@languages = ();
is(C4::Languages::getlanguage($query), 'en', 'default to English if no language specified in syspref (bug 10560)');

Koha::Cache::Memory::Lite->get_instance()->clear_from_cache('getlanguage');
$return_undef = 1;
is(C4::Languages::getlanguage($query), 'en', 'default to English if no database');
