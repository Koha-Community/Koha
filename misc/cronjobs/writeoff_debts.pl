#!/usr/bin/perl

use Modern::Perl;
use feature 'say';

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use C4::Log qw( cronlogaction );

use Koha::Account::Lines;
use Koha::DateUtils qw( dt_from_string );

use Koha::Script -cron;

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

my ( $help, $verbose, @type, $before, $after, @category_code, $file, $confirm );
GetOptions(
    'h|help'                           => \$help,
    'v|verbose+'                       => \$verbose,
    't|type:s'                         => \@type,
    'ab|added_before|added-before:s'   => \$before,
    'aa|added_after|added-after:s'     => \$after,
    'cc|category_code|category-code:s' => \@category_code,
    'f|file:s'                         => \$file,
    'c|confirm'                        => \$confirm,
) or pod2usage(2);

pod2usage(1) if $help;

if ( !$confirm && !$verbose ) {
    say STDERR "Missing required option: either --verbose or --confirm must be supplied";
    pod2usage(2);
}

@type = split( /,/, join( ',', @type ) );

if ( !$file && !@type && !$before && !$after && !@category_code ) {
    say STDERR "Missing required filter option: at least one filter option should be used";
    pod2usage(2);
}

my $where = { 'amountoutstanding' => { '>' => 0 } };
my $attr  = {};

if ($file) {
    my @accounts_from_file;
    open( my $fh, '<:encoding(UTF-8)', $file )
        or die "Could not open file '$file' $!";
    while ( my $line = <$fh> ) {
        chomp($line);
        push @accounts_from_file, $line;
    }
    close($fh);
    $where->{accountlines_id} = { '-in' => \@accounts_from_file };
}

if (@type) {
    $where->{debit_type_code} = \@type;
}

my $dtf;
if ( $before || $after ) {
    $dtf = Koha::Database->new->schema->storage->datetime_parser;
}

if ($before) {
    my $added_before = dt_from_string( $before, 'iso' );
    $where->{date}->{'<'} = $dtf->format_datetime($added_before);
}

if ($after) {
    my $added_after = dt_from_string( $after, 'iso' );
    $where->{date}->{'>'} = $dtf->format_datetime($added_after);
}

if (@category_code) {
    $where->{'patron.categorycode'}->{'-in'} = \@category_code;
    push @{ $attr->{'join'} }, 'patron';
}

my $lines = Koha::Account::Lines->search( $where, $attr );
if ($verbose) {
    print "Attempting to write off " . $lines->count . " debts";
    print " of type " . join( ',', @type ) if @type;
    print " added before " . $before       if $before;
    print " from the passed list"          if $file;
    print "\n";
}

while ( my $line = $lines->next ) {
    say "Skipping " . $line->accountlines_id . "; Not a debt" and next
        if $line->is_credit && $verbose > 1;
    say "Skipping " . $line->accountlines_id . "; Is a PAYOUT" and next
        if $line->debit_type_code eq 'PAYOUT' && $verbose > 1;

    if ($confirm) {
        $line->_result->result_source->schema->txn_do(
            sub {

                # A 'writeoff' is a 'credit'
                my $writeoff = Koha::Account::Line->new(
                    {
                        date              => \'NOW()',
                        amount            => 0 - $line->amountoutstanding,
                        credit_type_code  => 'WRITEOFF',
                        status            => 'ADDED',
                        amountoutstanding => 0 - $line->amountoutstanding,
                        manager_id        => undef,
                        borrowernumber    => $line->borrowernumber,
                        interface         => 'intranet',
                        branchcode        => undef,
                    }
                )->store();

                my $writeoff_offset = Koha::Account::Offset->new(
                    {
                        credit_id => $writeoff->accountlines_id,
                        type      => 'CREATE',
                        amount    => $line->amountoutstanding
                    }
                )->store();

                # Link writeoff to charge
                $writeoff->apply( { debits => [$line] } );
                $writeoff->status('APPLIED')->store();

                # Update status of original debit
                $line->status('FORGIVEN')->store;
            }
        );
    }

    if ($verbose) {
        if ($confirm) {
            say "Accountline " . $line->accountlines_id . " written off";
        } else {
            say "Accountline " . $line->accountlines_id . " will be written off";
        }
    }
}

cronlogaction( { action => 'End', info => "COMPLETED" } );

exit(0);

__END__

=head1 NAME

writeoff_debts.pl

=head1 SYNOPSIS

  writeoff_debts.pl --confirm [--verbose] <filter options>
  writeoff_debts.pl --verbose <filter options>
  writeoff_debts.pl --help

  <filter options> are:
      [--type <type>] [--file <file>] [--added-before <date>]
      [--added-after <date>] [--category-code <category code>]

This script batch waives debts.

=head1 OPTIONS

The options to select the debt records to writeoff are cumulative. For
example, supplying both --added_before and --type specifies that the
accountline must meet both conditions to be selected for writeoff.

You must pass at least one of the filtering options for the script to run.
This is to prevent an accidental 'writeoff all' operation. Please note that
--category-code must be accompanied by another filter - the script will not
run if this is the only filter provided.

=over

=item B<-h|--help>

Prints this help message

=item B<--added-before>

Writeoff debts added before the date passed.

Dates should be in ISO format, e.g., 2013-07-19, and can be generated
with `date -d '-3 month' --iso-8601`.

=item B<--added-after>

Writeoff debts added after the date passed.

Dates should be in ISO format, e.g., 2013-07-19, and can be generated
with `date -d '-3 month' --iso-8601`.

=item B<--category-code>

Writeoff debts for patrons belonging to the passed categories.

Can be used multiple times for additional category codes.

This option cannot be used alone, it must be combined with another filter.

=item B<--type>

Writeoff debts of the passed type. Accepts a list of debit type codes.

=item B<--file>

Writeoff debts passed as one accountlines_id per line in this file. If other
criteria are defined it will only writeoff those in the file that match those
criteria.

=item B<-v|--verbose>

This flag set the script to output logging for the actions it will perform.

The B<-v> option is mandatory if B<-c> is not supplied.

It can be repeated for increased verbosity.

=item B<-c|--confirm>

This flag must be provided in order for the script to actually
writeoff debts.

If it is not supplied, the B<-v> option is required. The script will then only
report on the accountline records it would have been written off.

=back

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=head1 COPYRIGHT

Copyright 2020 PTFS Europe

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
