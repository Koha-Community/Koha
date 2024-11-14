use Modern::Perl;

use Koha::Patrons;

return {
    bug_number  => "30300",
    description => "Add Patron expiry to messaging preference",
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
            say $out "Message attribute added";
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
            say $out "MEMBERSHIP_EXPIRY added to message_transports";

            my $days_notice = C4::Context->preference('MembershipExpiryDaysNotice');
            if($days_notice) {
                my $patrons = Koha::Patrons->search();
                while ( my $patron = $patrons->next ) {
                    C4::Members::Messaging::SetMessagingPreference(
                        {
                            borrowernumber          => $patron->borrowernumber,
                            message_attribute_id    => $message_attribute_id,
                            message_transport_types => ['email'],
                        }
                    );
                }
            }
        } else {
            say $out "Patron_Expiry message attribute exists, skipping update";
        }
    },
    }
