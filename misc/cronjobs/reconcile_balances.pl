#!/usr/bin/perl

# Copyright 2018 Theke Solutions
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

reconcile_balances.pl - cron script to reconcile patron's balances

=head1 SYNOPSIS

./reconcile_balances.pl

or, in crontab:
0 1 * * * reconcile_balances.pl

=head1 DESCRIPTION

This script loops through patrons with outstanding credits and proceeds
to reconcile their balances.

=head1 OPTIONS

=over 8

=item B<--help>

Prints a brief help message and exits.

=item B<--verbose>

Makes the process print information about the taken actions.

=back

=cut

use Modern::Perl;

use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );
use Try::Tiny    qw( catch try );

use Koha::Script -cron;
use C4::Log qw( cronlogaction );

use Koha::Account::Lines;
use Koha::Patrons;

my $help    = 0;
my $verbose = 0;

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

GetOptions(
    'help'    => \$help,
    'verbose' => \$verbose
) or pod2usage(2);

pod2usage(1) if $help;

my @patron_ids = Koha::Account::Lines->search(
    {
        amountoutstanding => { '<'  => 0 },
        borrowernumber    => { '!=' => undef }
    },
    {
        columns  => [qw/borrowernumber/],
        distinct => 1,
    }
)->get_column('borrowernumber');

my $patrons = Koha::Patrons->search( { borrowernumber => { -in => \@patron_ids } } );

while ( my $patron = $patrons->next ) {

    my $account                  = $patron->account;
    my $total_outstanding_credit = $account->outstanding_credits->total_outstanding;
    my $total_outstanding_debit  = $account->outstanding_debits->total_outstanding;

    if (    $total_outstanding_credit < 0
        and $total_outstanding_debit > 0 )
    {

        try {

            $account->reconcile_balance;

            print $patron->id
                . ": credit: $total_outstanding_credit "
                . "debit: $total_outstanding_debit "
                . "=> outstanding "
                . "credit: "
                . $account->outstanding_credits->total_outstanding
                . " debit: "
                . $account->outstanding_debits->total_outstanding . "\n"
                if $verbose;
        } catch {
            print "Problem with patron " . $patron->borrowernumber . ": $_";
        };
    }
}

cronlogaction( { action => 'End', info => "COMPLETED" } );

1;

__END__
