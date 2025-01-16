use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35152",
    description => "Move RoutingListNote to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the RoutingListNote system preference
        my ($routinglistnote) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='RoutingListNote';
        |
        );
        if ($routinglistnote) {

            # Insert any values found from system preference into additional_contents
            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'RoutingListNote', 'RoutingListNote', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'RoutingListNote' AND location = 'RoutingListNote' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'RoutingListNote default', ?, 'default' )",
                undef, $insert_id, $routinglistnote
            );

            say_success( $out, "Added 'RoutingListNote' HTML customization" );
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='RoutingListNote'") == 1
            && say_success( $out, "Removed system preference 'RoutingListNote'" );

    },
};
