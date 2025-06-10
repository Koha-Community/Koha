use Modern::Perl;

return {
    bug_number  => "34563",
    description => "Move StaffReportsHomeHTML to HTML customizations",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the IntranetReportsHomeHTML system preference
        my ($staffreportshomehtml) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='IntranetReportsHomeHTML';
        |
        );
        if ($staffreportshomehtml) {

            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'StaffReportsHomeHTML', 'StaffReportsHomeHTML', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'StaffReportsHomeHTML' AND location = 'StaffReportsHomeHTML' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'StaffReportsHomeHTML default', ?, 'default' )",
                undef, $insert_id, $staffreportshomehtml
            );

            say $out "Added 'StaffReportsHomeHTML' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='IntranetReportsHomeHTML'");
        say $out "Removed system preference 'IntranetReportsHomeHTML'";

    },
};
