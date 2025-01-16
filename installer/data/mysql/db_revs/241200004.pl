use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35154",
    description => "Move StaffLoginInstructions to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the StaffLoginInstructions system preference
        my ($stafflogininstructions) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='StaffLoginInstructions';
        |
        );
        if ($stafflogininstructions) {

            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'StaffLoginInstructions', 'StaffLoginInstructions', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'StaffLoginInstructions' AND location = 'StaffLoginInstructions' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'StaffLoginInstructions default', ?, 'default' )",
                undef, $insert_id, $stafflogininstructions
            );

            say_success( $out, "Added 'StaffLoginInstructions' HTML customization" );
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='StaffLoginInstructions'");
        say_success( $out, "Removed system preference 'StaffLoginInstructions'" );

    },
};
