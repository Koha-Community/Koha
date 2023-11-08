use Modern::Perl;

return {
    bug_number  => "20755",
    description => "Add sysprefs for email addresses in acquisitions and serials",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('AcquisitionsDefaultEMailAddress', '', NULL, "Default email address  that acquisition notices are sent from.", 'Free');
            }
        );
        say $out "Added new system preference 'AcquisitionsDefaultEMailAddress'";

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('AcquisitionsDefaultReplyTo', '', NULL, "Default email address used as reply-to for notices sent by the acquisitions module.", 'Free');
            }
        );
        say $out "Added new system preference 'AcquisitionsDefaultReplyTo'";

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('SerialsDefaultEMailAddress', '', NULL, "Default email address that serials notices are sent from.", 'Free');
            }
        );
        say $out "Added new system preference 'SerialsDefaultEMailAddress'";

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('SerialsDefaultReplyTo', '', NULL, "Default email address used as reply-to for notices sent by the serials module.", 'Free');
            }
        );
        say $out "Added new system preference 'SerialsDefaultReplyTo'";
    },
};
