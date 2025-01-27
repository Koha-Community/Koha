use Modern::Perl;

return {
    bug_number  => "28153",
    description => "Add Hold Reminder messaging preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my $attribute = $dbh->do(
            q{
                SELECT message_attribute_id
                FROM message_attributes
                WHERE message_name = "Hold_Reminder"
        }
        );
        unless ( $attribute == 1 ) {
            $dbh->do(
                q{
                INSERT IGNORE INTO `message_attributes`
                    (message_attribute_id, message_name, `takes_days`)
                VALUES (10, 'Hold_Reminder', 0)
            }
            );
            say $out "Message attribute added";
            $dbh->do(
                q{
                INSERT IGNORE INTO `message_transports`
                    (`message_attribute_id`, `message_transport_type`, `is_digest`, `letter_module`, `letter_code`)
                VALUES  (10, 'email', 0, 'circulation', 'HOLD_REMINDER'),
                        (10, 'sms', 0, 'circulation', 'HOLD_REMINDER'),
                        (10, 'phone', 0, 'circulation', 'HOLD_REMINDER'),
                        (10, 'itiva', 0, 'circulation', 'HOLD_REMINDER')
            }
            );
            say $out "HOLD_REMINDER added to message_transports";
            $dbh->do(
                q{
                    INSERT IGNORE INTO borrower_message_preferences
                    ( borrowernumber, categorycode, message_attribute_id, days_in_advance, wants_digest )
                    SELECT borrowernumber, categorycode, 10, days_in_advance, wants_digest
                    FROM borrower_message_preferences WHERE message_attribute_id = 4
            }
            );
            say $out "Hold_Filled message preference copied to Hold_Reminder";
            $dbh->do(
                q{
                    INSERT IGNORE INTO borrower_message_transport_preferences
                    ( borrower_message_preference_id, message_transport_type )
                    SELECT b1.borrower_message_preference_id, message_transport_type
                    FROM borrower_message_preferences b1
                    JOIN borrower_message_preferences b2 ON
                      b1.message_attribute_id = 10 AND b2.message_attribute_id = 4 AND
                      b1.borrowernumber=b2.borrowernumber
                    JOIN borrower_message_transport_preferences bt ON
                      b2.borrower_message_preference_id = bt.borrower_message_preference_id
            }
            );
            say $out "Hold_Filled message transport preferences copied to Hold_Reminder";
        } else {
            say $out "Hold_Reminder message attribute exists, skipping update";
        }
    },
    }
