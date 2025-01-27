use Modern::Perl;

return {
    bug_number  => "29586",
    description => "Add Hold Reminder messaging preference if missing",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO `message_attributes`
                (message_attribute_id, message_name, `takes_days`)
            VALUES (10, 'Hold_Reminder', 0)
        }
        );
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
    },
    }
