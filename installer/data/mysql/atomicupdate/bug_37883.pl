use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "37883",
    description => "Add system preference FilterSearchResultsByLoggedInBranch",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('FilterSearchResultsByLoggedInBranch','0','','Option to filter location column on staff search results by logged in branch','YesNo')
        }
        );

        say $out "Added new system preference 'FilterSearchResultsByLoggedInBranch'";
    },
};
