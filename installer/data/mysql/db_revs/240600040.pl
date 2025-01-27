use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "23295",
    description => "Automatically debar patrons if SMS or email notice fail",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES ('RestrictPatronsWithFailedNotices', '0', NULL, 'If enabled then when SMS and email notices fail sending at the Koha level then a debarment will be applied to a patrons account', 'YesNo') }
        );

        say_success( $out, "Added new system preference 'RestrictPatronsWithFailedNotices'" );

        $dbh->do(
            q{INSERT IGNORE INTO restriction_types (code, display_text, is_system, is_default) VALUES ('NOTICE_FAILURE_SUSPENSION', 'Notice failure suspension', 1, 0)}
        );
        say_success( $out, "Added new system restriction type 'NOTICE_FAILURE_SUSPENSION'" );

    },
};
