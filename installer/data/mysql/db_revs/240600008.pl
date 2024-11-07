use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35153",
    description => "Move IntranetmainUserblock to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the IntranetmainUserblock system preference
        my ($intranetmainuserblock) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='IntranetmainUserblock';
        |
        );
        if ($intranetmainuserblock) {

            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'IntranetmainUserblock', 'IntranetmainUserblock', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'IntranetmainUserblock' AND location = 'IntranetmainUserblock' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'IntranetmainUserblock default', ?, 'default' )",
                undef, $insert_id, $intranetmainuserblock
            );

            say_success( $out, "Added 'IntranetmainUserblock' HTML customization" );
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='IntranetmainUserblock'");
        say_success( $out, "Removed system preference 'IntranetmainUserblock'" );

    },
};
