#!/usr/bin/perl

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
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use Test::NoWarnings;

use File::Spec;
use FindBin  qw( $Bin );
use IPC::Cmd qw( run );

use C4::Context;

my $plugin_class = 'Koha::Plugin::1_CalcFineEmpty';
my $plugins_lib  = File::Spec->rel2abs("$Bin/../../../lib/plugins");
my $plugin_file  = "$plugins_lib/Koha/Plugin/1_CalcFineEmpty.pm";

my $dbh = C4::Context->dbh;
$dbh->do(
    q{REPLACE INTO plugin_data (plugin_class, plugin_key, plugin_value) VALUES (?, '__ENABLED__', '1')},
    {}, $plugin_class
);

my ( $success, undef, $full_buf ) = run(
    command => [ $^X, "-I$plugins_lib", '-c', $plugin_file ],
    timeout => 30,
);

$dbh->do( 'DELETE FROM plugin_data WHERE plugin_class = ?', {}, $plugin_class );

ok(
    $success,
    'perl -c on an enabled plugin file does not trigger a C3 merge error'
) or diag( join( '', @{ $full_buf // [] } ) );
