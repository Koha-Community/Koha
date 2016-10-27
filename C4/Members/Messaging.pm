package C4::Members::Messaging;

# Copyright (C) 2008 LibLime
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
use C4::Context;

use Koha::Validation;

=head1 NAME

C4::Members::Messaging - manage patron messaging preferences

=head1 SYNOPSIS

  use C4::Members::Messaging

=head1 DESCRIPTION

This module lets you modify a patron's messaging preferences.

=head1 FUNCTIONS

=head2 SetMessagingPreference

This method defines how a user (or a default for a patron category) wants to get a certain 
message delivered.  The list of valid message types can be delivered can be found in the
C<message_attributes> table, and the list of valid message transports can be
found in the C<message_transport_types> table.

  C4::Members::Messaging::SetMessagingPreference( { borrowernumber          => $borrower->{'borrowernumber'}
                                                    message_attribute_id    => $message_attribute_id,
                                                    message_transport_types => [ qw( email sms ) ],
                                                    days_in_advance         => 5
                                                    wants_digest            => 1 } )

returns nothing useful.

=cut

sub SetMessagingPreference {
    my $params = shift;

    unless (exists $params->{borrowernumber} xor exists $params->{categorycode}) { # yes, xor
        warn "SetMessagingPreference called without exactly one of borrowernumber or categorycode";
        return;
    }
    foreach my $required ( qw( message_attribute_id message_transport_types ) ) {
        if ( ! exists $params->{ $required } ) {
            warn "SetMessagingPreference called without required parameter: $required";
            return;
        }
    }
    $params->{'days_in_advance'} = undef unless exists ( $params->{'days_in_advance'} );
    $params->{'wants_digest'}    = 0     unless exists ( $params->{'wants_digest'} );

    my $dbh = C4::Context->dbh();
    
    my $delete_sql = <<'END_SQL';
DELETE FROM borrower_message_preferences
  WHERE message_attribute_id = ?
END_SQL
    my @bind_params = ( $params->{'message_attribute_id'} );
    if ( exists $params->{'borrowernumber'} ) {
        $delete_sql .= " AND borrowernumber = ? ";
        push @bind_params, $params->{borrowernumber};
    } else {
        $delete_sql .= " AND categorycode = ? ";
        push @bind_params, $params->{categorycode};
    }
    my $sth = $dbh->prepare( $delete_sql );
    my $deleted = $sth->execute( @bind_params );

    if ( $params->{'message_transport_types'} ) {
        my $insert_bmp = <<'END_SQL';
INSERT INTO borrower_message_preferences
(borrower_message_preference_id, borrowernumber, categorycode, message_attribute_id, days_in_advance, wants_digest)
VALUES
(NULL, ?, ?, ?, ?, ?)
END_SQL
        
        $sth = C4::Context->dbh()->prepare($insert_bmp);
        # set up so that we can easily construct the insert SQL
        $params->{'borrowernumber'}  = undef unless exists ( $params->{'borrowernumber'} );
        $params->{'categorycode'}    = undef unless exists ( $params->{'categorycode'} );
        my $success = $sth->execute( $params->{'borrowernumber'},
                                     $params->{'categorycode'},
                                     $params->{'message_attribute_id'},
                                     $params->{'days_in_advance'},
                                     $params->{'wants_digest'} );
        # my $borrower_message_preference_id = $dbh->last_insert_id();
        my $borrower_message_preference_id = $dbh->{'mysql_insertid'};
        
        my $insert_bmtp = <<'END_SQL';
INSERT INTO borrower_message_transport_preferences
(borrower_message_preference_id, message_transport_type)
VALUES
(?, ?)
END_SQL
        $sth = C4::Context->dbh()->prepare($insert_bmtp);
        foreach my $transport ( @{$params->{'message_transport_types'}}) {
            my $success = $sth->execute( $borrower_message_preference_id, $transport );
        }
    }
    return;    
}

=head2 DeleteAllMisconfiguredPreferences

  C4::Members::Messaging::DeleteAllMisconfiguredPreferences( [ $borrowernumber ] );

Deletes all misconfigured preferences for ALL borrowers that have invalid contact information for
the transport types. Given a borrowernumber, deletes misconfigured preferences only for this borrower.

return: returns array of arrayrefs to the deleted preferences (borrower_message_preference_id and message_transport_type)

=cut

sub DeleteAllMisconfiguredPreferences {
    my $borrowernumber = shift;

    my @deleted_prefs;

    push(@deleted_prefs, DeleteMisconfiguredPreference("email", "email", "email",
                                                       $borrowernumber));
    push(@deleted_prefs, DeleteMisconfiguredPreference("phone", "phone", "phone",
                                                       $borrowernumber));
    push(@deleted_prefs, DeleteMisconfiguredPreference("sms", "smsalertnumber",
                                                       "phone", $borrowernumber));

    return @deleted_prefs;
}

=head2 DeleteMisconfiguredPreference

  C4::Members::Messaging::DeleteMisconfiguredPreference(
    $type, $contact, $validator [, $borrowernumber ]
  );

Takes a messaging preference type and the primary contact method for it, and
a string to define the Koha::Validation that should be used to determine whether
the preference is misconfigured.

A messaging preference is misconfigured when it is linked with invalid contact
information. E.g. messaging type email expects the user to have a valid e-mail
address in order to work.

Deletes misconfigured preferences for ALL borrowers that have invalid contact
information for that transport type. Given a borrowernumber, deletes misconfigured
preferences only for this borrower.

return: returns array of arrayrefs to the deleted preferences
(borrower_message_preference_id and message_transport_type)

=cut

sub DeleteMisconfiguredPreference {
    my ($type, $contact, $validator, $borrowernumber) = @_;

    if (not defined $type or not defined $contact or not defined $validator) {
        return 0;
    }

    my @misconfigured_prefs;

    # Get all messaging preferences and borrower's contact information
    my $dbh = C4::Context->dbh();
    my $query = "

        SELECT
                    borrower_message_preferences.borrower_message_preference_id,
                    borrower_message_transport_preferences.message_transport_type,
                    borrowers.$contact

        FROM
                    borrower_message_preferences,
                    borrower_message_transport_preferences,
                    borrowers

        WHERE
                    borrower_message_preferences.borrower_message_preference_id
                    =
                    borrower_message_transport_preferences.borrower_message_preference_id

        AND
                    borrowers.borrowernumber = borrower_message_preferences.borrowernumber

        AND
                    borrower_message_transport_preferences.message_transport_type = ?
    ";

    $query .= " AND borrowers.borrowernumber = ?" if defined $borrowernumber;

    my $sth = $dbh->prepare($query);

    if (defined $borrowernumber){
        $sth->execute($type, $borrowernumber);
    } else {
        $sth->execute($type);
    }

    while (my $ref = $sth->fetchrow_arrayref) {
        if ($$ref[1] eq $type) {
            if (not defined $$ref[2] or defined $$ref[2] and $$ref[2] eq "") {
                my $valid_contact = 0; # delete prefs if empty contact
                unless ($valid_contact && $$ref[2]) {
                    # push the misconfigured preferences into an array
                    push(@misconfigured_prefs, $$ref[0]);
                }
            }
            else {
                my ($valid_contact, $err, $err_msg) =
                Koha::Validation->$validator($$ref[2]);
                unless ($valid_contact && $$ref[2]) {
                    # push the misconfigured preferences into an array
                    push(@misconfigured_prefs, $$ref[0]);
                }
            }
        }
    }

    $sth = $dbh->prepare("

    DELETE FROM
                    borrower_message_transport_preferences

    WHERE
                    borrower_message_preference_id = ? AND message_transport_type = ?
    ");

    my @deleted_prefs;
    foreach my $id (@misconfigured_prefs){
        # delete the misconfigured pref
        $sth->execute($id, $type);
        # push it into array that we will return
        push (@deleted_prefs, [$id,$type]);
    }

    return @deleted_prefs;
}

=head1 TABLES

=head2 message_queue

The actual messages which will be sent via a cron job running
F<misc/cronjobs/process_message_queue.pl>.

=head2 message_attributes

What kinds of messages can be sent?

=head2 message_transport_types

What transports can messages be sent vith?  (email, sms, etc.)

=head2 message_transports

How are message_attributes and message_transport_types correlated?

=head2 borrower_message_preferences

What messages do the borrowers want to receive?

=head2 borrower_message_transport_preferences

What transport should a message be sent with?

=head1 CONFIG

=head2 Adding a New Kind of Message to the System

=over 4

=item 1.

Add a new template to the `letter` table.

=item 2.

Insert a row into the `message_attributes` table.

=item 3.

Insert rows into `message_transports` for each message_transport_type.

=back

=head1 SEE ALSO

L<C4::Letters>

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Andrew Moore <andrew.moore@liblime.com>

=cut

1;
