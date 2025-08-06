use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39802",
    description => "Add LostChargesControl system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get the existing value from the CircControl system preference
        my ($circcontrol) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='CircControl';
        |
        );
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('LostChargesControl',?,'PickupLibrary|PatronLibrary|ItemHomeLibrary','Specify the agency that controls the charges for items being marked lost','Choice')
        }, undef, $circcontrol
        );
        say $out "Added new system preference 'LostChargesControl'";
    },
};
