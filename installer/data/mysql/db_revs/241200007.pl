use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "30300",
    description => "Add 'patron expiry' to messaging preferences",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my $attribute = $dbh->do(
            q{
                SELECT message_attribute_id
                FROM message_attributes
                WHERE message_name = "Patron_Expiry"
        }
        );
        unless ( $attribute == 1 ) {
            $dbh->do(
                q{
                INSERT IGNORE INTO `message_attributes`
                    (message_name, `takes_days`)
                VALUES ('Patron_Expiry', 0)
            }
            );
            say_success( $out, "Message attribute 'Patron_Expiry' added" );
            my $query = q{
                SELECT message_attribute_id
                FROM message_attributes
                WHERE message_name = "Patron_Expiry"
        };
            my $sth = $dbh->prepare($query);
            $sth->execute();
            my $results              = $sth->fetchrow_hashref;
            my $message_attribute_id = $results->{message_attribute_id};

            $dbh->do(
                q{
                INSERT IGNORE INTO `message_transports`
                    (`message_attribute_id`, `message_transport_type`, `is_digest`, `letter_module`, `letter_code`)
                VALUES  (?, 'email', 0, 'circulation', 'MEMBERSHIP_EXPIRY'),
                        (?, 'sms', 0, 'circulation', 'MEMBERSHIP_EXPIRY'),
                        (?, 'phone', 0, 'circulation', 'MEMBERSHIP_EXPIRY'),
                        ( ?, 'itiva', 0, 'circulation', 'MEMBERSHIP_EXPIRY' )
            }, {}, $message_attribute_id, $message_attribute_id, $message_attribute_id, $message_attribute_id

            );
            say_success( $out, "MEMBERSHIP_EXPIRY added to message_transports" );

            my $days_notice = C4::Context->preference('MembershipExpiryDaysNotice');
            if ($days_notice) {

                $dbh->do(
                    q{
                    INSERT IGNORE INTO borrower_message_preferences
                        (`borrower_message_preference_id`, `borrowernumber`, `categorycode`, `message_attribute_id`, `days_in_advance`, `wants_digest`)
                    SELECT
                        NULL, borrowernumber, NULL, ?, NULL, NULL
                    FROM
                        borrowers
                }, {}, $message_attribute_id
                );

                $dbh->do(
                    q{
                    INSERT IGNORE INTO borrower_message_transport_preferences
                        (`borrower_message_preference_id`, `message_transport_type`)
                    SELECT
                        borrower_message_preference_id, 'email'
                    FROM
                        borrower_message_preferences
                    WHERE
                        message_attribute_id = ?
                }, {}, $message_attribute_id
                );
                say_success( $out, "'Patron expiry' notification activated in patron accounts" );
            }
        } else {
            say_success( $out, "'Patron_Expiry' message attribute already exists, skipping update" );
        }
    },
};
