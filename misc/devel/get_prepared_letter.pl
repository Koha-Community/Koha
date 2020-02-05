#!/usr/bin/perl

# Copyright 2020 BibLibre
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

use Getopt::Long;
use JSON;

use C4::Letters;

my ( $module, $letter_code, $branchcode, $message_transport_type, $lang,
    $repeat, $tables, $loops );

GetOptions(
    'module=s'                 => \$module,
    'letter-code=s'            => \$letter_code,
    'branchcode=s'             => \$branchcode,
    'message-transport-type=s' => \$message_transport_type,
    'lang=s'                   => \$lang,
    'repeat=s'                 => \$repeat,
    'tables=s'                 => \$tables,
    'loops=s'                  => \$loops,
) or die "Error in command line arguments\n";

$repeat = $repeat ? decode_json($repeat) : {};
$tables = $tables ? decode_json($tables) : {};
$loops  = $loops  ? decode_json($loops)  : {};

my $letter = C4::Letters::GetPreparedLetter(
    module                 => $module,
    letter_code            => $letter_code,
    branchcode             => $branchcode,
    message_transport_type => $message_transport_type,
    lang                   => $lang,
    repeat                 => $repeat,
    tables                 => $tables,
    loops                  => $loops,
);

print "Subject: " . $letter->{title} . "\n\n";
print $letter->{content} . "\n";
