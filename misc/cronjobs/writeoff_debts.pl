#!/usr/bin/perl

use Modern::Perl;
use feature 'say';

use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

use Koha::Account::Lines;
use Koha::DateUtils qw( dt_from_string );

use Koha::Script -cron;

my ( $help, $verbose, @type, $before, $after, $file, $confirm );
GetOptions(
    'h|help'                         => \$help,
    'v|verbose+'                     => \$verbose,
    't|type:s'                       => \@type,
    'ab|added_before|added-before:s' => \$before,
    'aa|added_after|added-after:s'   => \$after,
    'f|file:s'                       => \$file,
    'c|confirm'                      => \$confirm,
);
@type = split( /,/, join( ',', @type ) );

pod2usage(1) if ( $help || !$confirm && !$verbose || !$file && !@type && !$before && !$after );

my $where = { 'amountoutstanding' => { '>' => 0 } };
my $attr = {};

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
if ($before||$after) {
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

my $lines = Koha::Account::Lines->search( $where, $attr );
if ( $verbose ) {
    print "Attempting to write off " . $lines->count . " debts";
    print " of type " . join(',',@type) if @type;
    print " added before " . $before if $before;
    print " from the passed list" if $file;
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
                        type      => 'WRITEOFF',
                        amount    => $line->amountoutstanding
                    }
                )->store();

                # Link writeoff to charge
                $writeoff->apply(
                    {
                        debits => [$line]
                    }
                );
                $writeoff->status('APPLIED')->store();

                # Update status of original debit
                $line->status('FORGIVEN')->store;
            }
        );
    }

    if ($verbose) {
        if ($confirm) {
            say "Accountline " . $line->accountlines_id . " written off";
        }
        else {
            say "Accountline " . $line->accountlines_id . " will be written off";
        }
    }
}

exit(0);

__END__

=head1 NAME

writeoff_debts.pl

=head1 SYNOPSIS

  ./writeoff_debts.pl --added_before DATE --type OVERDUE --file REPORT --confirm

This script batch waives debts.

The options to select the debt records to writeoff are cumulative. For
example, supplying both --added_before and --type specifies that the
accountline must meet both conditions to be selected for writeoff.

You must pass at least one of the filtering options for the script to run.
This is to prevent an accidental 'writeoff all' operation.

=head1 OPTIONS

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

=item B<--type>

Writeoff debts of the passed type. Accepts a list of CREDIT_TYPE_CODEs.

=item B<--file>

Writeoff debts passed as one accountlines_id per line in this file. If other
criteria are defined it will only writeoff those in the file that match those
criteria.

=item B<-v|--verbose>

This flag set the script to output logging for the actions it will perform.

=item B<-c|--confirm>

This flag must be provided in order for the script to actually
writeoff debts.  If it is not supplied, the script will
only report on the accountline records it would have been written off.

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
