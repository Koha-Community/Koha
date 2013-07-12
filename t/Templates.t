#!/usr/bin/perl

# Copyright 2013 Equinox Software, Inc.
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
use Test::More tests => 3;
use Test::MockModule;
use CGI;

BEGIN {
    use_ok('C4::Templates');
}

my @languages = (); # stores the list of active languages
                    # for the syspref mock

my $module_context = new Test::MockModule('C4::Context');

$module_context->mock(
    preference => sub {
        my ($self, $pref) = @_;
        if ($pref =~ /language/) {
            return join ',', @languages;
        } else {
            return 'XXX';
        }
  },
);

delete $ENV{TTTP_ACCEPT_LANGUAGE};

my $query = CGI->new();
@languages = ('de-DE', 'fr-FR');
is(C4::Templates::getlanguage($query, 'opac'), 'de-DE', 'default to first language specified in syspref (bug 10560)');

@languages = ();
is(C4::Templates::getlanguage($query, 'opac'), 'en', 'default to English if no language specified in syspref (bug 10560)');
