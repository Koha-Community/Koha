use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "43872",
    description => "Fix auto_renew_error spelling in issues and old_issues",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                UPDATE issues
                SET auto_renew_error = 'auto_too_much_owing'
                WHERE auto_renew_error = 'auto_too_much_oweing'
            }
        );

        $dbh->do(
            q{
                UPDATE old_issues
                SET auto_renew_error = 'auto_too_much_owing'
                WHERE auto_renew_error = 'auto_too_much_oweing'
            }
        );
        say_success( $out, "Updates auto_renew_error in both issues and old_issues table" );
    },
};
