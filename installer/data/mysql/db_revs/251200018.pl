use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "30331",
    description =>
        "Rename RenewalPeriodBase as ManualRenewalPeriodBase AND add new AutomaticRenewalPeriodBase system preference",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        #Get the old value before changing anything
        my $base_period = C4::Context->preference('RenewalPeriodBase');

        $dbh->do(
            q{
            UPDATE systempreferences SET variable = 'ManualRenewalPeriodBase' WHERE variable = 'RenewalPeriodBase'
        }
        );

        say_success( $out, "System preference RenewalPeriodBase updated to ManualRenewalPeriodBase" );

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('AutomaticRenewalPeriodBase', ? ,'date_due|now','Set whether the renewal date should be counted from the date_due or from the moment the Patron asks for renewal, for automatic renewals','Choice')
        }, undef, $base_period
        );

        say_success( $out, "System preference AutomaticRenewalPeriodBase added." );
    },
};
