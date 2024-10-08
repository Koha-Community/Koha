use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "23295",
    description => "Automatically debar patrons if SMS or email notice fail",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        try {
            $dbh->do(q{INSERT IGNORE INTO restriction_types (code, display_text, is_system, is_default) VALUES ('NOTICE_FAILURE_SUSPENSION', 'Notice failure suspension', 1, 0)});
            say_success( $out, "Added a new system restriction_types 'NOTICE_FAILURE_SUSPENSION'" );
        }
        catch {
            say_failure( $out, "Database modification failed with errors: $_" );
        };
    },
};
