use Modern::Perl;

return {
    bug_number  => "12532",
    description => "Add new system preference RedirectGuaranteeEmail and cc_address field",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
            VALUES ('RedirectGuaranteeEmail', '0', 'Enable the ability to redirect guarantee email messages to guarantor.', NULL, 'YesNo')
        }
        );
        say $out "Added system preference 'RedirectGuaranteeEmail'";

        unless ( column_exists( 'message_queue', 'cc_address' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `message_queue`
                ADD COLUMN `cc_address` longtext DEFAULT NULL
                AFTER `to_address`
            }
            );
            say $out "Added column 'cc_address'";
        }
    },
};
