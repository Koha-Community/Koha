#!/usr/bin/perl

# Copyright 2016 PTFS Europe
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
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

stockrotation.pl

=head1 SYNOPSIS

    --[a]dmin-email    An address to which email reports should also be sent
    --[b]ranchcode     Select branch to report on for 'email' reports (default: all)
    --e[x]ecute        Actually perform stockrotation housekeeping
    --[r]eport         Select either 'full' or 'email'
    --[S]end-all       Send email reports even if the report body is empty
    --[s]end-email     Send reports by email
    --[h]elp           Display this help message

Cron script implementing scheduled stockrotation functionality.

By default this script merely reports on the current status of the
stockrotation subsystem.  In order to actually place items in transit, the
script must be run with the `execute` argument.

`report` allows you to select the type of report that will be emitted. It's
set to 'full' by default.  If the `email` report is selected, you can use the
`branchcode` parameter to specify which branch's report you would like to see.
The default is 'all'.

`admin-email` is an additional email address to which we will send all email
reports in addition to sending them to branch email addresses.

`send-email` will cause the script to send reports by email, and `send-all`
will cause even reports with an empty body to be sent.

=head1 DESCRIPTION

This script is used to move items from one stockrotationstage to the next,
if they are elible for processing.

it should be run from cron like:

   stockrotation.pl --report email --send-email --execute

Prior to that you can run the script from the command line without the
--execute and --send-email parameters to see what reports the script would
generate in 'production' mode.  This is immensely useful for testing, or for
getting to understand how the stockrotation module works: you can set up
different scenarios, and then "query" the system on what it would do.

Normally you would want to run this script once per day, probably around
midnight-ish to move any stockrotationitems along their rotas and to generate
the email reports for branch libraries.

Each library will receive a report with "items of interest" for them for
today's rota checks.  Each item there will be an item that should, according
to Koha, be located on the shelves of that branch, and which should be picked
up and checked in.  The item will either:
- have been placed in transit to their new stage library;
- have been placed in transit to be returned to their current stage library;
- have just been added to a rota and will already be at the correct library;

In the last case the item will be checked in and no message will pop up.  In
the other cases a message will pop up requesting the item be posted to their
new branch.

=head2 What does the --execute flag do?

To understand this, you will need to know a little bit about the design of
this script and the stockrotation modules.

This script operates in 3 phases: first it walks the graph of rotas, stages
and items.  For each active rota, it investigates the items in each stage and
determines whether action is required.  It does not perform any actions, it
just "sieves" all items on active rotas into "actionable" and "non-actionable"
baskets.  We can use these baskets to perform actions against the items, or to
generate reports.

During the second phase this script then loops through the actionable baskets,
and performs the relevant action (initiate, repatriate, advance) on each item.

Finally, during the third phase we revisit the original baskets and we compile
reports (for instance per branch email reports).

When the script is run without the "--execute" flag, we perform phase 1, skip
phase 2 and move straight onto phase 3.

With the "--execute" flag we also perform the database operations.

So with or without the flag, the report will look the same (except for the "No
database updates have been performed.").

=cut

use Modern::Perl;
use Getopt::Long qw/HelpMessage :config gnu_getopt/;
use C4::Context;
use C4::Letters;
use Koha::StockRotationRotas;

my $admin_email = '';
my $branch      = 0;
my $execute     = 0;
my $report      = 'full';
my $send_all    = 0;
my $send_email  = 0;

my $ok = GetOptions(
    'admin-email|a=s' => \$admin_email,
    'branchcode|b=s'  => sub {
        my ( $opt_name, $opt_value ) = @_;
        my $branches = Koha::Libraries->search( {},
            { order_by => { -asc => 'branchname' } } );
        my $brnch = $branches->find($opt_value);
        if ($brnch) {
            $branch = $brnch;
            return $brnch;
        }
        else {
            printf("Option $opt_name should be one of (name -> code):\n");
            while ( my $candidate = $branches->next ) {
                printf( "  %-40s  ->  %s\n",
                    $candidate->branchname, $candidate->branchcode );
            }
            exit 1;
        }
    },
    'execute|x'  => \$execute,
    'report|r=s' => sub {
        my ( $opt_name, $opt_value ) = @_;
        if ( $opt_value eq 'full' || $opt_value eq 'email' ) {
            $report = $opt_value;
        }
        else {
            printf("Option $opt_name should be either 'email' or 'full'.\n");
            exit 1;
        }
    },
    'send-all|S'   => \$send_all,
    'send-email|s' => \$send_email,
    'help|h|?'     => sub { HelpMessage }
);
exit 1 unless ($ok);

$send_email++ if ($send_all);    # if we send all, then we must want emails.

=head2 Helpers

=head3 execute

  undef = execute($report);

Perform the database updates, within a transaction, that are reported as
needing to be performed by $REPORT.

$REPORT should be the return value of an invocation of `investigate`.

This procedure WILL mess with your database.

=cut

sub execute {
    my ($data) = @_;

    # Begin transaction
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    # Carry out db updates
    foreach my $item ( @{ $data->{items} } ) {
        my $reason = $item->{reason};
        if ( $reason eq 'repatriation' ) {
            $item->{object}->repatriate;
        }
        elsif ( grep { $reason eq $_ } qw/in-demand advancement initiation/ ) {
            $item->{object}->advance;
        }
    }

    # End transaction
    $schema->storage->txn_commit;
}

=head3 report_full

  my $full_report = report_full($report);

Return an arrayref containing a string containing a detailed report about the
current state of the stockrotation subsystem.

$REPORT should be the return value of `investigate`.

No data in the database is manipulated by this procedure.

=cut

sub report_full {
    my ($data) = @_;

    my $header = "";
    my $body   = "";

    # Summary
    $header .= sprintf "
STOCKROTATION REPORT
--------------------\n";
    $body .= sprintf "
  Total number of rotas:         %5u
    Inactive rotas:              %5u
    Active rotas:                %5u
  Total number of items:         %5u
    Inactive items:              %5u
    Stationary items:            %5u
    Actionable items:            %5u
  Total items to be initiated:   %5u
  Total items to be repatriated: %5u
  Total items to be advanced:    %5u
  Total items in demand:         %5u\n\n",
      $data->{sum_rotas},  $data->{rotas_inactive}, $data->{rotas_active},
      $data->{sum_items},  $data->{items_inactive}, $data->{stationary},
      $data->{actionable}, $data->{initiable},      $data->{repatriable},
      $data->{advanceable}, $data->{indemand};

    if ( @{ $data->{rotas} } ) {    # Per Rota details
        $body .= sprintf "ROTAS DETAIL\n------------\n\n";
        foreach my $rota ( @{ $data->{rotas} } ) {
            $body .= sprintf "Details for %s [%s]:\n",
              $rota->{name}, $rota->{id};
            $body .= sprintf "\n  Items:";    # Rota item details
            if ( @{ $rota->{items} } ) {
                $body .=
                  join( "", map { _print_item($_) } @{ $rota->{items} } );
            }
            else {
                $body .=
                  sprintf "\n    No items to be processed for this rota.\n";
            }
            $body .= sprintf "\n  Log:";      # Rota log details
            if ( @{ $rota->{log} } ) {
                $body .= join( "", map { _print_item($_) } @{ $rota->{log} } );
            }
            else {
                $body .= sprintf "\n    No items in log for this rota.\n\n";
            }
        }
    }
    return [
        $header,
        {
            letter => {
                title   => 'Stockrotation Report',
                content => $body                     # The body of the report
            },
            status          => 1,    # We have a meaningful report
            no_branch_email => 1,    # We don't expect branch email in report
        }
    ];
}

=head3 report_email

  my $email_report = report_email($report);

Returns an arrayref containing a header string, with basic report information,
and any number of 'per_branch' strings, containing a detailed report about the
current state of the stockrotation subsystem, from the perspective of those
individual branches.

$REPORT should be the return value of `investigate`, and $BRANCH should be
either 0 (to indicate 'all'), or a specific Koha::Library object.

No data in the database is manipulated by this procedure.

=cut

sub report_email {
    my ( $data, $branch ) = @_;

    my $out    = [];
    my $header = "";

    # Summary
    my $branched = $data->{branched};
    my $flag     = 0;

    $header .= sprintf "
BRANCH-BASED STOCKROTATION REPORT
---------------------------------\n";
    push @{$out}, $header;

    if ($branch) {    # Branch limited report
        push @{$out}, _report_per_branch( $branched->{ $branch->branchcode } );
    }
    elsif ( $data->{actionable} ) {    # Full email report
        while ( my ( $branchcode_id, $details ) = each %{$branched} ) {
            push @{$out}, _report_per_branch($details)
              if ( @{ $details->{items} } );
        }
    }
    else {
        push @{$out}, {
            body => sprintf "
No actionable items at any libraries.\n\n",    # The body of the report
            no_branch_email => 1,    # We don't expect branch email in report
        };
    }
    return $out;
}

=head3 _report_per_branch

  my $branch_string = _report_per_branch($branch_details, $branchcode, $branchname);

return a string containing details about the stockrotation items and their
status for the branch identified by $BRANCHCODE.

This helper procedure is only used from within `report_email`.

No data in the database is manipulated by this procedure.

=cut

sub _report_per_branch {
    my ($branch) = @_;

    my $status = 0;
    if ( $branch && @{ $branch->{items} } ) {
        $status = 1;
    }

    if (
        my $letter = C4::Letters::GetPreparedLetter(
            module                 => 'circulation',
            letter_code            => "SR_SLIP",
            message_transport_type => 'email',
            substitute             => $branch
        )
      )
    {
        return {
            letter        => $letter,
            email_address => $branch->{email},
            $status
        };
    }
    return;
}

=head3 _print_item

  my $string = _print_item($item_section);

Return a string containing an overview about $ITEM_SECTION.

This helper procedure is only used from within `report_full`.

No data in the database is manipulated by this procedure.

=cut

sub _print_item {
    my ($item) = @_;
    return sprintf "
    Title:           %s
    Author:          %s
    Callnumber:      %s
    Location:        %s
    Barcode:         %s
    On loan?:        %s
    Status:          %s
    Current Library: %s [%s]\n\n",
      $item->{title}      || "N/A", $item->{author}   || "N/A",
      $item->{callnumber} || "N/A", $item->{location} || "N/A",
      $item->{barcode} || "N/A", $item->{onloan} ? 'Yes' : 'No',
      $item->{reason} || "N/A", $item->{branch}->branchname,
      $item->{branch}->branchcode;
}

=head3 emit

  undef = emit($params);

$PARAMS should be a hashref of the following format:
  admin_email: the address to which a copy of all reports should be sent.
  execute: the flag indicating whether we performed db updates
  send_all: the flag indicating whether we should send even empty reports
  send_email: the flag indicating whether we want to emit to stdout or email
  report: the data structure returned from one of the report procedures

No data in the database is manipulated by this procedure.

The return value is unspecified: we simply emit a message as a side-effect or
die.

=cut

sub emit {
    my ($params) = @_;

# REPORT is an arrayref of at least 2 elements:
#   - The header for the report, which will be repeated for each part
#   - a "part" for each report we want to emit
# PARTS are hashrefs:
#   - part->{status}: a boolean indicating whether the reported part is empty or not
#   - part->{email_address}: the email address to send the report to
#   - part->{no_branch_email}: a boolean indicating that we are missing a branch email
#   - part->{letter}: a GetPreparedLetter hash as returned by the C4::Letters module
    my $report = $params->{report};
    my $header = shift @{$report};
    my $parts  = $report;

    my @emails;
    foreach my $part ( @{$parts} ) {

        if ( $part->{status} || $params->{send_all} ) {

            # We have a report to send, or we want to send even empty
            # reports.

            # Send to branch
            my $addressee;
            if ( $part->{email_address} ) {
                $addressee = $part->{email_address};
            }
            elsif ( !$part->{no_branch_email} ) {

#push @emails, "***We tried to send a branch report, but we have no email address for this branch.***\n\n";
                $addressee = C4::Context->preference('KohaAdminEmailAddress')
                  if ( C4::Context->preference('KohaAdminEmailAddress') );
            }

            if ( $params->{send_email} ) {    # Only email if emails requested
                if ( defined($addressee) ) {
                    C4::Letters::EnqueueLetter(
                        {
                            letter                 => $part->{letter},
                            to_address             => $addressee,
                            message_transport_type => 'email',
                        }
                      )
                      or warn
                      "can't enqueue letter $part->{letter} for $addressee";
                }

                # Copy to admin?
                if ( $params->{admin_email} ) {
                    C4::Letters::EnqueueLetter(
                        {
                            letter                 => $part->{letter},
                            to_address             => $params->{admin_email},
                            message_transport_type => 'email',
                        }
                      )
                      or warn
"can't enqueue letter $part->{letter} for $params->{admin_email}";
                }
            }
            else {
                my $email =
                  "-------- Email message --------" . "\n\n" . "To: "
                  . defined($addressee)               ? $addressee
                  : defined( $params->{admin_email} ) ? $params->{admin_email}
                  : '' . "\n"
                  . "Subject: "
                  . $part->{letter}->{title} . "\n\n"
                  . $part->{letter}->{content};
                push @emails, $email;
            }
        }
    }

    # Emit to stdout instead of email?
    if ( !$params->{send_email} ) {

        # The final message is the header + body of this part.
        my $msg = $header;
        $msg .= "No database updates have been performed.\n\n"
          unless ( $params->{execute} );

        # Append email reports to message
        $msg .= join( "\n\n", @emails );
        printf $msg;
    }
}

#### Main Code

# Compile Stockrotation Report data
my $rotas = Koha::StockRotationRotas->search(undef,{ order_by => { '-asc' => 'title' }});
my $data  = $rotas->investigate;

# Perform db updates if requested
execute($data) if ($execute);

# Emit Reports
my $out_report = {};
$out_report = report_email( $data, $branch ) if $report eq 'email';
$out_report = report_full( $data, $branch ) if $report eq 'full';
emit(
    {
        admin_email => $admin_email,
        execute     => $execute,
        report      => $out_report,
        send_all    => $send_all,
        send_email  => $send_email,
    }
);

=head1 AUTHOR

Alex Sassmannshausen <alex.sassmannshausen@ptfs-europe.com>

=cut
