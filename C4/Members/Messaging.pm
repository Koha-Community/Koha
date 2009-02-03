package C4::Members::Messaging;

# Copyright (C) 2008 LibLime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;
use C4::Context;

use vars qw($VERSION);

BEGIN {
    # set the version for version checking
    $VERSION = 3.00;
}

=head1 NAME

C4::Members::Messaging - manage patron messaging preferences

=head1 SYNOPSIS

  use C4::Members::Messaging

=head1 DESCRIPTION

This module lets you modify a patron's messaging preferences.

=head1 FUNCTIONS

=head2 GetMessagingPreferences

  my $preferences = C4::Members::Messaging::GetMessagingPreferences( { borrowernumber => $borrower->{'borrowernumber'},
                                                                       message_name   => 'DUE' } );

returns: a hashref of messaging preferences for this borrower for a particlar message_name

=cut

sub GetMessagingPreferences {
    my $params = shift;

    foreach my $required ( qw( borrowernumber message_name ) ) {
        if ( ! exists $params->{ $required } ) {
            return;
        }
    }

    my $sql = <<'END_SQL';
SELECT borrower_message_preferences.*,
       borrower_message_transport_preferences.message_transport_type,
       message_attributes.*,
       message_transports.*
  FROM borrower_message_preferences
  LEFT JOIN borrower_message_transport_preferences
    ON borrower_message_transport_preferences.borrower_message_preference_id = borrower_message_preferences.borrower_message_preference_id
  LEFT JOIN message_attributes
    ON message_attributes.message_attribute_id = borrower_message_preferences.message_attribute_id
  LEFT JOIN message_transports
    ON message_transports.message_attribute_id = message_attributes.message_attribute_id
    AND message_transports.message_transport_type = borrower_message_transport_preferences.message_transport_type
  WHERE borrower_message_preferences.borrowernumber = ?
   AND message_attributes.message_name = ?
END_SQL

    my @bind_params = ( $params->{'borrowernumber'}, $params->{'message_name'} );

    my $sth = C4::Context->dbh->prepare($sql);
    $sth->execute(@bind_params);
    my $return;
    my %transports; # helps build a list of unique message_transport_types
    ROW: while ( my $row = $sth->fetchrow_hashref() ) {
        next ROW unless $row->{'message_attribute_id'};
        # warn( Data::Dumper->Dump( [ $row ], [ 'row' ] ) );
        $return->{'days_in_advance'} = $row->{'days_in_advance'} if defined $row->{'days_in_advance'};
        $return->{'wants_digest'}    = $row->{'wants_digest'}    if defined $row->{'wants_digest'};
		$return->{'letter_code'}     = $row->{'letter_code'};
        $transports{$row->{'message_transport_type'}} = 1;
    }
    @{$return->{'transports'}} = keys %transports;
    return $return;
}

=head2 SetMessagingPreference

This method defines how a user wants to get a certain message delivered.  The
list of valid message types can be delivered can be found in the
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

    foreach my $required ( qw( borrowernumber message_attribute_id message_transport_types ) ) {
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
  WHERE borrowernumber = ?
    AND message_attribute_id = ?
END_SQL
    my $sth = $dbh->prepare( $delete_sql );
    my $deleted = $sth->execute( $params->{'borrowernumber'}, $params->{'message_attribute_id'} );

    if ( $params->{'message_transport_types'} ) {
        my $insert_bmp = <<'END_SQL';
INSERT INTO borrower_message_preferences
(borrower_message_preference_id, borrowernumber, message_attribute_id, days_in_advance, wants_digest)
VALUES
(NULL, ?, ?, ?, ?)
END_SQL
        
        $sth = C4::Context->dbh()->prepare($insert_bmp);
        my $success = $sth->execute( $params->{'borrowernumber'},
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

=head2 GetMessagingOptions

  my $messaging_options = C4::Members::Messaging::GetMessagingOptions()

returns a hashref of messaing options available.

=cut

sub GetMessagingOptions {

    my $sql = <<'END_SQL';
select message_attributes.message_attribute_id, takes_days, message_name, message_transport_type, is_digest
  FROM message_attributes
  LEFT JOIN message_transports
    ON message_attributes.message_attribute_id = message_transports.message_attribute_id
END_SQL

    my $sth = C4::Context->dbh->prepare($sql);
    $sth->execute();
    my $choices;
    while ( my $row = $sth->fetchrow_hashref() ) {
        $choices->{ $row->{'message_name'} }->{'message_attribute_id'} = $row->{'message_attribute_id'};
        $choices->{ $row->{'message_name'} }->{'message_name'}         = $row->{'message_name'};
        $choices->{ $row->{'message_name'} }->{'takes_days'}           = $row->{'takes_days'};
        $choices->{ $row->{'message_name'} }->{'has_digest'}           = 1 if $row->{'is_digest'};
        $choices->{ $row->{'message_name'} }->{'transport-' . $row->{'message_transport_type'}} = ' ';
    }

    my @return = values %$choices;
    # warn( Data::Dumper->Dump( [ \@return ], [ 'return' ] ) );
    return \@return;
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

Koha Development Team <info@koha.org>

Andrew Moore <andrew.moore@liblime.com>

=cut

1;
