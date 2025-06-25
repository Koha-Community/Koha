use Modern::Perl;

return {
    bug_number  => "34563",
    description => "Move StaffReportsHomeHTML to HTML customizations",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the IntranetReportsHomeHTML system preference
        my ($staffreportshome) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='IntranetReportsHomeHTML';
        |
        );
        if ($staffreportshome) {

            $dbh->do(
                "INSERT INTO additional_contents ( category, code, location, branchcode, published_on ) VALUES ('html_customizations', 'StaffReportsHome', 'StaffReportsHome', NULL, CAST(NOW() AS date) )"
            );

            my ($insert_id) = $dbh->selectrow_array(
                "SELECT id FROM additional_contents WHERE category = 'html_customizations' AND code = 'StaffReportsHome' AND location = 'StaffReportsHome' LIMIT 1",
                {}
            );

            $dbh->do(
                "INSERT INTO additional_contents_localizations ( additional_content_id, title, content, lang ) VALUES ( ?, 'StaffReportsHome default', ?, 'default' )",
                undef, $insert_id, $staffreportshome
            );

            say $out "Added 'StaffReportsHome' HTML customization";
        }

        # Remove old system preference
        $dbh->do("DELETE FROM systempreferences WHERE variable='IntranetReportsHomeHTML'");
        say $out "Removed system preference 'IntranetReportsHomeHTML'";

    },
};
