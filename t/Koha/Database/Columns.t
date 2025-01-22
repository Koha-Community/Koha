#!/usr/bin/perl

# This file is part of Koha
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
use Test::NoWarnings;
use Test::More tests => 2;
use Test::MockModule;
use FindBin qw($Bin);
use Encode;

use Koha::Database::Columns;

my $koha_i18n = Test::MockModule->new('Koha::I18N');
$koha_i18n->mock( '_base_directory', sub { "$Bin/../I18N/po" } );

my $c4_languages = Test::MockModule->new('C4::Languages');
$c4_languages->mock( 'getlanguage', sub { 'xx-XX' } );

my $columns = Koha::Database::Columns->columns;

is( $columns->{borrowers}->{opacnote}, decode_utf8('OPAC note ✔ ❤ ★') );
