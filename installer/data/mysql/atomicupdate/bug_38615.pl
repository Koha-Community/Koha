use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38615",
    description => "A single line description",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('HoldCancellationRequestSIP',0,'','Option to set holds cancelled via SIP as cancellation requests','YesNo')
        }
        );

        # sysprefs
        say $out "Added new system preference '38615'";
    },
};
