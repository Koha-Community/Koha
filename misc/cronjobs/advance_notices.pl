#!/usr/bin/perl

# Copyright 2008 LibLime
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

advance_notices.pl - prepare messages to be sent to patrons for nearly due, or due, items

=head1 SYNOPSIS

       advance_notices.pl
         [ -n ][ -m <number of days> ][ --itemscontent <comma separated field list> ][ -c ]

=head1 DESCRIPTION

This script prepares pre-due and item due reminders to be sent to
patrons. It queues them in the message queue, which is processed by
the process_message_queue.pl cronjob. The type and timing of the
messages can be configured by the patrons in their "My Alerts" tab in
the OPAC.

=cut

use strict;
use warnings;
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );
use Koha::Script -cron;
use C4::Context;
use C4::Letters;
use C4::Members;
use C4::Members::Messaging;
use C4::Log qw( cronlogaction );
use Koha::Items;
use Koha::Libraries;
use Koha::Patrons;

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<-v>

Verbose. Without this flag set, only fatal errors are reported.

=item B<-n>

Do not send any email. Advanced or due notices that would have been sent to
the patrons are printed to standard out.

=item B<-m>

Defines the maximum number of days in advance to send advance notices.

=item B<-c>

Confirm flag: Add this option. The script will only print a usage
statement otherwise.

=item B<--itemscontent>

comma separated list of fields that get substituted into templates in
places of the E<lt>E<lt>items.contentE<gt>E<gt> placeholder. This
defaults to date_due,title,author,barcode

Other possible values come from fields in the biblios, items and
issues tables.

=item B<--digest-per-branch>

Flag to indicate that generation of message digests should be
performed separately for each branch.

A patron could potentially have loans at several different branches
There is no natural branch to set as the sender on the aggregated
message in this situation so the default behavior is to use the
borrowers home branch.  This could surprise to the borrower when
message sender is a library where they have not borrowed anything.

Enabling this flag ensures that the issuing library is the sender of
the digested message.  It has no effect unless the borrower has
chosen 'Digests only' on the advance messages.

=item B<--library>

select notices for one specific library. Use the value in the
branches.branchcode table. This option can be repeated in order
to select notices for a group of libraries.

=item B<--frombranch>

Set the from address for the notice to one of 'item-homebranch' or 'item-issuebranch'.

Defaults to 'item-issuebranch'

=back

=head2 Configuration

This script pays attention to the advanced notice configuration
performed by borrowers in the OPAC, or by staff in the patron detail page of the intranet. The content of the messages is configured in Tools -> Notices and slips. Advanced notices use the PREDUE template, due notices use DUE. More information about the use of this
section of Koha is available in the Koha manual.

=head2 Outgoing emails

Typically, messages are prepared for each patron with due
items, and who have selected (or the library has elected for them) Advance or Due notices.

These emails are staged in the outgoing message queue, as are messages
produced by other features of Koha. This message queue must be
processed regularly by the
F<misc/cronjobs/process_message_queue.pl> program.

In the event that the C<-n> flag is passed to this program, no emails
are sent. Instead, messages are sent on standard output from this
program. They may be redirected to a file if desired.

=head2 Templates

Templates can contain variables enclosed in double angle brackets like
E<lt>E<lt>thisE<gt>E<gt>. Those variables will be replaced with values
specific to the overdue items or relevant patron. Available variables
are:

=over

=item E<lt>E<lt>items.contentE<gt>E<gt>

one line for each item, each line containing a tab separated list of
date due, title, author, barcode

=item E<lt>E<lt>borrowers.*E<gt>E<gt>

any field from the borrowers table

=item E<lt>E<lt>branches.*E<gt>E<gt>

any field from the branches table

=back

=head1 SEE ALSO

The F<misc/cronjobs/overdue_notices.pl> program allows you to send
messages to patrons when their messages are overdue.

=cut

binmode( STDOUT, ':encoding(UTF-8)' );

# These are defaults for command line options.
my $confirm;                                                        # -c: Confirm that the user has read and configured this script.
my $nomail;                                                         # -n: No mail. Will not send any emails.
my $mindays     = 0;                                                # -m: Maximum number of days in advance to send notices
my $maxdays     = 30;                                               # -e: the End of the time period
my $verbose     = 0;                                                # -v: verbose
my $digest_per_branch = 0;                                          # -digest-per-branch: Prepare and send digests per branch
my @branchcodes; # Branch(es) passed as parameter
my $frombranch   = 'item-issuebranch';
my $itemscontent = join(',',qw( date_due title author barcode ));

my $help    = 0;
my $man     = 0;

my $command_line_options = join(" ",@ARGV);

GetOptions(
            'help|?'         => \$help,
            'man'            => \$man,
            'library=s'      => \@branchcodes,
            'frombranch=s'   => \$frombranch,
            'c'              => \$confirm,
            'n'              => \$nomail,
            'm:i'            => \$maxdays,
            'v'              => \$verbose,
            'digest-per-branch' => \$digest_per_branch,
            'itemscontent=s' => \$itemscontent,
       )or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

# Since advance notice options are not visible in the web-interface
# unless EnhancedMessagingPreferences is on, let the user know that
# this script probably isn't going to do much
if ( ! C4::Context->preference('EnhancedMessagingPreferences') && $verbose ) {
    warn <<'END_WARN';

The "EnhancedMessagingPreferences" syspref is off.
Therefore, it is unlikely that this script will actually produce any messages to be sent.
To change this, edit the "EnhancedMessagingPreferences" syspref.

END_WARN
}
unless ($confirm) {
     pod2usage(1);
}
cronlogaction({ info => $command_line_options });

my %branches = ();
if (@branchcodes) {
    %branches = map { $_ => 1 } @branchcodes;
}

die "--frombranch takes item-homebranch or item-issuebranch only"
  unless ( $frombranch eq 'item-issuebranch'
    || $frombranch eq 'item-homebranch' );
my $owning_library = ( $frombranch eq 'item-homebranch' ) ? 1 : 0;

# The fields that will be substituted into <<items.content>>
my @item_content_fields = split(/,/,$itemscontent);

warn 'getting upcoming due issues' if $verbose;
my $upcoming_dues = C4::Circulation::GetUpcomingDueIssues( {
    days_in_advance => $maxdays,
    owning_library => $owning_library
 } );
warn 'found ' . scalar( @$upcoming_dues ) . ' issues' if $verbose;

# hash of borrowernumber to number of items upcoming
# for patrons wishing digests only.
my $upcoming_digest = {};
my $due_digest = {};

my $dbh = C4::Context->dbh();
my $sth = $dbh->prepare(<<'END_SQL');
SELECT biblio.*, items.*, issues.*
  FROM issues,items,biblio
  WHERE items.itemnumber=issues.itemnumber
    AND biblio.biblionumber=items.biblionumber
    AND issues.borrowernumber = ?
    AND issues.itemnumber = ?
    AND (TO_DAYS(date_due)-TO_DAYS(NOW()) = ?)
END_SQL

my $admin_adress = C4::Context->preference('KohaAdminEmailAddress');

my @letters;
UPCOMINGITEM: foreach my $upcoming ( @$upcoming_dues ) {
    @letters = ();
    warn 'examining ' . $upcoming->{'itemnumber'} . ' upcoming due items' if $verbose;

    my $from_address = $upcoming->{branchemail} || $admin_adress;

    my $borrower_preferences;
    if ( 0 == $upcoming->{'days_until_due'} ) {
        # This item is due today. Send an 'item due' message.
        $borrower_preferences = C4::Members::Messaging::GetMessagingPreferences( { borrowernumber => $upcoming->{'borrowernumber'},
                                                                                   message_name   => 'item_due' } );
        next unless $borrower_preferences;
        
        if ( $borrower_preferences->{'wants_digest'} ) {
            # cache this one to process after we've run through all of the items.
            if ($digest_per_branch) {
                $due_digest->{ $upcoming->{branchcode} }->{ $upcoming->{borrowernumber} }->{email} = $from_address;
                $due_digest->{ $upcoming->{branchcode} }->{ $upcoming->{borrowernumber} }->{count}++;
            } else {
                $due_digest->{ $upcoming->{borrowernumber} }->{email} = $from_address;
                $due_digest->{ $upcoming->{borrowernumber} }->{count}++;
            }
        } else {
            my $branchcode;
            if($owning_library) {
                $branchcode = $upcoming->{'homebranch'};
            } else {
                $branchcode = $upcoming->{'branchcode'};
            }
            # Skip this DUE if we specify list of libraries and this one is not part of it
            next if (@branchcodes && !$branches{$branchcode});

            my $item = Koha::Items->find( $upcoming->{itemnumber} );
            my $letter_type = 'DUE';
            $sth->execute($upcoming->{'borrowernumber'},$upcoming->{'itemnumber'},'0');
            my $item_info = $sth->fetchrow_hashref();
            my $title = C4::Letters::get_item_content( { item => $item_info, item_content_fields => \@item_content_fields } );

            ## Get branch info for borrowers home library.
            foreach my $transport ( keys %{$borrower_preferences->{'transports'}} ) {
                next if $transport eq 'itiva';
                my $letter = parse_letter( { letter_code    => $letter_type,
                                      borrowernumber => $upcoming->{'borrowernumber'},
                                      branchcode     => $branchcode,
                                      biblionumber   => $item->biblionumber,
                                      itemnumber     => $upcoming->{'itemnumber'},
                                      substitute     => {
                                          'items.content' => $title,
                                          checkout        => $item_info,
                                      },
                                      message_transport_type => $transport,
                                    } )
                    or warn "no letter of type '$letter_type' found for borrowernumber ".$upcoming->{'borrowernumber'}.". Please see sample_notices.sql";
                push @letters, $letter if $letter;
            }
        }
    } else {
        $borrower_preferences = C4::Members::Messaging::GetMessagingPreferences( { borrowernumber => $upcoming->{'borrowernumber'},
                                                                                   message_name   => 'advance_notice' } );
        next UPCOMINGITEM unless $borrower_preferences && exists $borrower_preferences->{'days_in_advance'};
        next UPCOMINGITEM unless $borrower_preferences->{'days_in_advance'} == $upcoming->{'days_until_due'};

        if ( $borrower_preferences->{'wants_digest'} ) {
            # cache this one to process after we've run through all of the items.
            if ($digest_per_branch) {
                $upcoming_digest->{ $upcoming->{branchcode} }->{ $upcoming->{borrowernumber} }->{email} = $from_address;
                $upcoming_digest->{ $upcoming->{branchcode} }->{ $upcoming->{borrowernumber} }->{count}++;
            } else {
                $upcoming_digest->{ $upcoming->{borrowernumber} }->{email} = $from_address;
                $upcoming_digest->{ $upcoming->{borrowernumber} }->{count}++;
            }
        } else {
            my $branchcode;
            if($owning_library) {
            $branchcode = $upcoming->{'homebranch'};
            } else {
            $branchcode = $upcoming->{'branchcode'};
            }
            # Skip this PREDUE if we specify list of libraries and this one is not part of it
            next if (@branchcodes && !$branches{$branchcode});

            my $item = Koha::Items->find( $upcoming->{itemnumber} );
            my $letter_type = 'PREDUE';
            $sth->execute($upcoming->{'borrowernumber'},$upcoming->{'itemnumber'},$borrower_preferences->{'days_in_advance'});
            my $item_info = $sth->fetchrow_hashref();
            my $title = C4::Letters::get_item_content( { item => $item_info, item_content_fields => \@item_content_fields } );

            ## Get branch info for borrowers home library.
            foreach my $transport ( keys %{$borrower_preferences->{'transports'}} ) {
                next if $transport eq 'itiva';
                my $letter = parse_letter( { letter_code    => $letter_type,
                                      borrowernumber => $upcoming->{'borrowernumber'},
                                      branchcode     => $branchcode,
                                      biblionumber   => $item->biblionumber,
                                      itemnumber     => $upcoming->{'itemnumber'},
                                      substitute     => {
                                          'items.content' => $title,
                                          checkout        => $item_info,
                                      },
                                      message_transport_type => $transport,
                                    } )
                    or warn "no letter of type '$letter_type' found for borrowernumber ".$upcoming->{'borrowernumber'}.". Please see sample_notices.sql";
                push @letters, $letter if $letter;
            }
        }
    }

    # If we have prepared a letter, send it.
    if ( @letters ) {
      if ($nomail) {
        for my $letter ( @letters ) {
            local $, = "\f";
            print $letter->{'content'}."\n";
        }
      }
      else {
        for my $letter ( @letters ) {
            C4::Letters::EnqueueLetter( { letter                 => $letter,
                                          borrowernumber         => $upcoming->{'borrowernumber'},
                                          from_address           => $from_address,
                                          message_transport_type => $letter->{message_transport_type} } );
        }
      }
    }
}



# Now, run through all the people that want digests and send them

my $digest_query = 'SELECT biblio.*, items.*, issues.*
  FROM issues,items,biblio
  WHERE items.itemnumber=issues.itemnumber
    AND biblio.biblionumber=items.biblionumber
    AND issues.borrowernumber = ?
    AND (TO_DAYS(date_due)-TO_DAYS(NOW()) = ?)';

my $sth_digest = $dbh->prepare($digest_query);

if ($digest_per_branch) {
    while (my ($branchcode, $digests) = each %$upcoming_digest) {
        send_digests({
            sth => $dbh->prepare( $digest_query . " AND issues.branchcode = '" . $branchcode . "'"),
            digests => $digests,
            letter_code => 'PREDUEDGST',
            message_name => 'advance_notice',
            branchcode => $branchcode,
            get_item_info => sub {
                my $params = shift;
                $params->{sth}->execute($params->{borrowernumber},
                                        $params->{borrower_preferences}->{'days_in_advance'});
                return sub {
                    $params->{sth}->fetchrow_hashref;
                };
            }
        });
    }

    while (my ($branchcode, $digests) = each %$due_digest) {
        send_digests({
            sth => $dbh->prepare( $digest_query . " AND issues.branchcode = '" . $branchcode . "'" ),
            digests => $digests,
            letter_code => 'DUEDGST',
            branchcode => $branchcode,
            message_name => 'item_due',
            get_item_info => sub {
                my $params = shift;
                $params->{sth}->execute($params->{borrowernumber}, 0);
                return sub {
                    $params->{sth}->fetchrow_hashref;
                };
            }
        });
    }
} else {
    send_digests({
        sth => $sth_digest,
        digests => $upcoming_digest,
        letter_code => 'PREDUEDGST',
        message_name => 'advance_notice',
        get_item_info => sub {
            my $params = shift;
            $params->{sth}->execute($params->{borrowernumber},
                                    $params->{borrower_preferences}->{'days_in_advance'});
            return sub {
                $params->{sth}->fetchrow_hashref;
            };
        }
    });

    send_digests({
        sth => $sth_digest,
        digests => $due_digest,
        letter_code => 'DUEDGST',
        message_name => 'item_due',
        get_item_info => sub {
            my $params = shift;
            $params->{sth}->execute($params->{borrowernumber}, 0);
            return sub {
                $params->{sth}->fetchrow_hashref;
            };
        }
    });
}

=head1 METHODS

=head2 parse_letter

=cut

sub parse_letter {
    my $params = shift;

    foreach my $required ( qw( letter_code borrowernumber ) ) {
        return unless exists $params->{$required};
    }
    my $patron = Koha::Patrons->find( $params->{borrowernumber} );

    my %table_params = ( 'borrowers' => $params->{'borrowernumber'} );

    if ( my $p = $params->{'branchcode'} ) {
        $table_params{'branches'} = $p;
    }
    if ( my $p = $params->{'itemnumber'} ) {
        $table_params{'issues'} = $p;
        $table_params{'items'} = $p;
    }
    if ( my $p = $params->{'biblionumber'} ) {
        $table_params{'biblio'} = $p;
        $table_params{'biblioitems'} = $p;
    }

    return C4::Letters::GetPreparedLetter (
        module => 'circulation',
        letter_code => $params->{'letter_code'},
        branchcode => $table_params{'branches'},
        lang => $patron->lang,
        substitute => $params->{'substitute'},
        tables     => \%table_params,
        ( $params->{itemnumbers} ? ( loops => { items => $params->{itemnumbers} } ) : () ),
        message_transport_type => $params->{message_transport_type},
    );
}

=head2 get_branch_info

=cut

sub get_branch_info {
    my ( $borrowernumber ) = @_;

    ## Get branch info for borrowers home library.
    my $patron = Koha::Patrons->find( $borrowernumber );
    my $branch = $patron->library->unblessed;
    my %branch_info;
    foreach my $key( keys %$branch ) {
        $branch_info{"branches.$key"} = $branch->{$key};
    }

    return %branch_info;
}

=head2 send_digests

    send_digests({
        digests => ...,
        sth => ...,
        letter_code => ...,
        get_item_info => ...,
    })

Enqueue digested letters (or print them if -n was passed at command line).

Parameters:

=over 4

=item C<$digests>

Reference to the array of digested messages.

=item C<$sth>

Prepared statement handle for fetching overdue issues.

=item C<$letter_code>

String that denote the letter code.

=item C<$get_item_info>

Subroutine for executing prepared statement.  Takes parameters $sth,
$borrowernumber and $borrower_parameters and return a generator
function that produce the matching rows.

=back

=cut

sub send_digests {
    my $params = shift;

    PATRON: while ( my ( $borrowernumber, $digest ) = each %{$params->{digests}} ) {
        @letters = ();
        my $count = $digest->{count};
        my $from_address = $digest->{email};

        my %branch_info;
        my $branchcode;

        if (defined($params->{branchcode})) {
            %branch_info = ();
            $branchcode = $params->{branchcode};
        } else {
            ## Get branch info for borrowers home library.
            %branch_info = get_branch_info( $borrowernumber );
            $branchcode = $branch_info{'branches.branchcode'};
        }

        my $borrower_preferences =
            C4::Members::Messaging::GetMessagingPreferences(
                {
                    borrowernumber => $borrowernumber,
                    message_name   => $params->{message_name}
                }
            );

        next PATRON unless $borrower_preferences; # how could this happen?

        my $next_item_info = $params->{get_item_info}->({
            sth => $params->{sth},
            borrowernumber => $borrowernumber,
            borrower_preferences => $borrower_preferences
        });
        my $titles = "";
        my @itemnumbers;
        my @checkouts;
        while ( my $item_info = $next_item_info->()) {
            push @itemnumbers, $item_info->{itemnumber};
            push( @checkouts, $item_info );
            $titles .= C4::Letters::get_item_content( { item => $item_info, item_content_fields => \@item_content_fields } );
        }

        foreach my $transport ( keys %{ $borrower_preferences->{'transports'} } ) {
            next if $transport eq 'itiva';
            my $letter = parse_letter(
                {
                    letter_code    => $params->{letter_code},
                    borrowernumber => $borrowernumber,
                    checkouts      => \@checkouts,
                    substitute     => {
                        count           => $count,
                        'items.content' => $titles,
                        checkouts       => \@checkouts,
                        %branch_info
                    },
                    itemnumbers    => \@itemnumbers,
                    branchcode     => $branchcode,
                    message_transport_type => $transport
                }
            );
            unless ( $letter ){
                warn "no letter of type '$params->{letter_type}' found for borrowernumber $borrowernumber. Please see sample_notices.sql";
                next;
            }
            push @letters, $letter if $letter;
        }

        if ( @letters ) {
            if ($nomail) {
                for my $letter ( @letters ) {
                    local $, = "\f";
                    print $letter->{'content'};
                }
            }
            else {
                for my $letter ( @letters ) {
                    C4::Letters::EnqueueLetter( { letter                 => $letter,
                                                  borrowernumber         => $borrowernumber,
                                                  from_address           => $from_address,
                                                  message_transport_type => $letter->{message_transport_type} } );
                }
            }
        }
    }
}

cronlogaction({ action => 'End', info => "COMPLETED" });

1;

__END__
