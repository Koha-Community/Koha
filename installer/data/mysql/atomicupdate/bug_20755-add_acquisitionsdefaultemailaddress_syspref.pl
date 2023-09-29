use Modern::Perl;

return {
    bug_number  => "20755",
    description => "Add sysprefs for email addresses in acquisitions and serials",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('AcquisitionsDefaultEMailAddress', '', NULL, NULL, NULL);
            }
        );
        say $out "Added new system preference 'AcquisitionsDefaultEMailAddress'";

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('AcquisitionsDefaultReplyTo', '', NULL, NULL, NULL);
            }
        );
        say $out "Added new system preference 'AcquisitionsDefaultReplyTo'";

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('SerialsDefaultEMailAddress', '', NULL, NULL, NULL);
            }
        );
        say $out "Added new system preference 'SerialsDefaultEMailAddress'";

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('SerialsDefaultReplyTo', '', NULL, NULL, NULL);
            }
        );
        say $out "Added new system preference 'SerialsDefaultReplyTo'";
    },
};
