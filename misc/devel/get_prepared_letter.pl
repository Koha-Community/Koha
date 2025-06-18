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
# with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

get-prepared-letter.pl - preview letter content

=head1 SYNOPSIS

get-prepared-letter.pl --module MODULE --letter-code CODE [options]

=head1 OPTIONS

=over

=item B<--module MODULE>

The letter module (acquisition, catalogue, circulation, ...)

=item B<--letter-code CODE>

The letter code (DUE, PREDUE, ...)

=item B<--branchcode BRANCHCODE>

The letter branchcode

=item B<--message-transport-type TYPE>

The message transport type (email, print, ...)

=item B<--lang LANG>

The letter language (es-ES, fr-FR, ...)

=item B<--repeat REPEAT>

A JSON formatted string that will be used as repeat parameter. See
documentation of GetPreparedLetter for more information.

=item B<--tables TABLES>

A JSON formatted string that will be used as tables parameter. See
documentation of GetPreparedLetter for more information.

=item B<--loops LOOPS>

A JSON formatted string that will be used as loops parameter. See
documentation of GetPreparedLetter for more information.

=back

=cut

use Modern::Perl;

use Getopt::Long qw( GetOptions );
use JSON         qw( decode_json );
use Pod::Usage   qw( pod2usage );

use C4::Letters qw( GetPreparedLetter );

my $help;
my (
    $module, $letter_code, $branchcode, $message_transport_type, $lang,
    $repeat, $tables,      $loops
);

GetOptions(
    'help'                     => \$help,
    'module=s'                 => \$module,
    'letter-code=s'            => \$letter_code,
    'branchcode=s'             => \$branchcode,
    'message-transport-type=s' => \$message_transport_type,
    'lang=s'                   => \$lang,
    'repeat=s'                 => \$repeat,
    'tables=s'                 => \$tables,
    'loops=s'                  => \$loops,
) or pod2usage( -exitval => 2, -verbose => 1 );

if ($help) {
    pod2usage( -exitval => 0, -verbose => 1 );
}

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
