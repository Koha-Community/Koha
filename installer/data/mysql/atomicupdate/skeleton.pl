use Modern::Perl;
use Term::ANSIColor;

return {
    bug_number  => "BUG_NUMBER",
    description => "A single line description",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(q{});

        # Print useful stuff here
        # tables
        say $out "Added new table 'XXX'";
        say $out "Added column 'XXX.YYY'";

        # sysprefs
        say $out "Added new system preference 'XXX'";
        say $out "Updated system preference 'XXX'";
        say $out "Removed system preference 'XXX'";

        # permissions
        say $out "Added new permission 'XXX'";

        # letters
        say $out "Added new letter 'XXX' (TRANSPORT)";

        # HTML customizations
        say $out "Added 'XXX' HTML customization";

        # Other information
        say $out colored("Use red for danger/failure", 'red');
        say $out colored("Use green for success", 'green');
        say $out colored("Use yellow for warning/a call to action", 'yellow');
        say $out colored("Use blue for further information", 'blue');
    },
};
