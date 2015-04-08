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

use vars qw($VERSION);

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
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

  my $preferences = C4::Members::Messaging::GetMessagingPreferences( { categorycode => 'LIBRARY',
                                                                       message_name   => 'DUE' } );

returns: a hashref of messaging preferences for a borrower or patron category for a particlar message_name

Requires either a borrowernumber or a categorycode key, but not both.

=cut

sub GetMessagingPreferences {
    my $params = shift;

    return unless exists $params->{message_name};
    return unless exists $params->{borrowernumber} xor exists $params->{categorycode}; # yes, xor
    my $sql = <<'END_SQL';
SELECT borrower_message_preferences.*,
       borrower_message_transport_preferences.message_transport_type,
       message_attributes.message_name,
       message_attributes.takes_days,
       message_transports.is_digest,
       message_transports.letter_module,
       message_transports.letter_code
FROM   borrower_message_preferences
LEFT JOIN borrower_message_transport_preferences
ON     borrower_message_transport_preferences.borrower_message_preference_id = borrower_message_preferences.borrower_message_preference_id
LEFT JOIN message_attributes
ON     message_attributes.message_attribute_id = borrower_message_preferences.message_attribute_id
LEFT JOIN message_transports
ON     message_transports.message_attribute_id = message_attributes.message_attribute_id
AND    message_transports.message_transport_type = borrower_message_transport_preferences.message_transport_type
WHERE  message_attributes.message_name = ?
END_SQL

    my @bind_params = ( $params->{'message_name'} );
    if ( exists $params->{'borrowernumber'} ) {
        $sql .= " AND borrower_message_preferences.borrowernumber = ? ";
        push @bind_params, $params->{borrowernumber};
    } else {
        $sql .= " AND borrower_message_preferences.categorycode = ? ";
        push @bind_params, $params->{categorycode};
    }

    my $sth = C4::Context->dbh->prepare($sql);
    $sth->execute(@bind_params);
    my $return;
    my %transports; # helps build a list of unique message_transport_types
    ROW: while ( my $row = $sth->fetchrow_hashref() ) {
        next ROW unless $row->{'message_attribute_id'};
        $return->{'days_in_advance'} = $row->{'days_in_advance'} if defined $row->{'days_in_advance'};
        $return->{'wants_digest'}    = $row->{'wants_digest'}    if defined $row->{'wants_digest'};
        $return->{'letter_code'}     = $row->{'letter_code'};
        next unless defined $row->{'message_transport_type'};
        $return->{'transports'}->{ $row->{'message_transport_type'} } = $row->{'letter_code'};
    }
    return $return;
}

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

=head2 GetMessagingOptions

  my $messaging_options = C4::Members::Messaging::GetMessagingOptions()

returns a hashref of messaging options available.

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
        $choices->{ $row->{'message_name'} }->{'transport_' . $row->{'message_transport_type'}} = ' ';
    }

    my @return = values %$choices;
    # warn( Data::Dumper->Dump( [ \@return ], [ 'return' ] ) );
    return \@return;
}

=head2 SetMessagingPreferencesFromDefaults

  C4::Members::Messaging::SetMessagingPreferencesFromDefaults( { borrowernumber => $borrower->{'borrowernumber'}
                                                                categorycode   => 'CPL' } );

Given a borrowernumber and a patron category code (from the C<borrowernumber> and C<categorycode> keys
in the parameter hashref), replace all of the patron's current messaging preferences with
whatever defaults are defined for the patron category.

=cut

sub SetMessagingPreferencesFromDefaults {
    my $params = shift;

    foreach my $required ( qw( borrowernumber categorycode ) ) {
        unless ( exists $params->{ $required } ) {
            die "SetMessagingPreferencesFromDefaults called without required parameter: $required";
        }
    }

    my $messaging_options = GetMessagingOptions();
    OPTION: foreach my $option ( @$messaging_options ) {
        my $default_pref = GetMessagingPreferences( { categorycode => $params->{categorycode},
                                                      message_name => $option->{'message_name'} } );
        # FIXME - except for setting the borrowernumber, it really ought to be possible
        # to have the output of GetMessagingPreferences be able to be the input
        # to SetMessagingPreference
        my @message_transport_types = keys %{ $default_pref->{transports} };
        $default_pref->{message_attribute_id}    = $option->{'message_attribute_id'};
        $default_pref->{message_transport_types} = \@message_transport_types;
        $default_pref->{borrowernumber}          = $params->{borrowernumber};
        SetMessagingPreference( $default_pref );
    }
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
