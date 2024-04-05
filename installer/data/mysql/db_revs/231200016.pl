use Modern::Perl;

return {
    bug_number  => "36409",
    description => "Fix capitalization for SerialsDefaultEMailAddress and AcquisitionsDefaultEMailAddress",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE systempreferences
            SET variable = 'SerialsDefaultEmailAddress'
            WHERE variable = 'SerialsDefaultEMailAddress';
        }
        );

        say $out "Updated system preference 'SerialsDefaultEMailAddress' -> 'SerialsDefaultEmailAddress'";

        $dbh->do(
            q{
            UPDATE systempreferences
            SET variable = 'AcquisitionsDefaultEmailAddress'
            WHERE variable = 'AcquisitionsDefaultEMailAddress';
        }
        );

        say $out "Updated system preference 'AcquisitionsDefaultEMailAddress' -> 'AcquisitionsDefaultEmailAddress'";
    },
};
