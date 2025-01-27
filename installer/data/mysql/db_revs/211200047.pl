use Modern::Perl;

return {
    bug_number  => "28138",
    description => "Add system preference RequirePaymentType",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('RequirePaymentType','0','','Require staff to select a payment type when a payment is made','YesNo')
        }
        );
    },
};
