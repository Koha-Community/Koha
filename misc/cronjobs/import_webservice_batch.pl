#!/usr/bin/perl -w

# Copyright 2012 CatalystIT
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

use strict;
use warnings;
use utf8;

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::Script -cron;
use C4::ImportBatch qw( BatchCommitRecords GetStagedWebserviceBatches );

=head1 NAME

import_webservice_batch.pl - Find batches staged by webservice and import them.

=head1 SYNOPSIS

import_webservice_batch.pl [--framework=<frameworkcode> --overlay_framework=<frameworkcode>]

Options:

   --help                   brief help message
   --framework              specify frameworkcode for new records
   --overlay_framework      specify frameworkcode when overlaying records

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--framework>

Specify frameworkcode for new records. Uses default if not specified.

=item B<--overlay_framework>

Specify frameworkcode when overlaying records.  Current framework is preserved if not specified.

=back

=head1 DESCRIPTION

This script is designed to import batches staged by webservices (e.g. connection).

=head1 USAGE EXAMPLES

C<import_webservice_batch.pl> - Imports the batches using default framework

C<import_webservice_batch.pl> -f=<frameworkcode> Imports the batches adding new records into specified framework, not adjusting framework of matched records

C<import_webservice_batch.pl> -f=<frameworkcode> -o=<frameworkcode> Imports the batches adding new records into specified framework, overlaying matched records to specified framework

=cut

my ( $help, $man, $framework, $overlay_framework );

GetOptions(
    'help|?'                => \$help,
    'man'                   => \$man,
    'f|framework=s'         => \$framework,
    'o|overlay_framework=s' => \$overlay_framework,
);

pod2usage(1) if $help;

pod2usage( -verbose => 2 ) if $man;

my $batch_ids = GetStagedWebserviceBatches() or exit;

$framework ||= '';
BatchCommitRecords(
    {
        batch_id          => $_,
        framework         => $framework,
        overlay_framework => $overlay_framework,
    }
) foreach @$batch_ids;
