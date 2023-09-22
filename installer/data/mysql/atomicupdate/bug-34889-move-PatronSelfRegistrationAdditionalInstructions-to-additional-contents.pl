use Modern::Perl;

return {
    bug_number  => "34889",
    description => "Move PatronSelfRegistrationAdditionalInstructions to additional contents",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get any existing value from the PatronSelfRegistrationAdditionalInstructions system preference
        my ($patronselfregistrationadditionalinstructions) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='PatronSelfRegistrationAdditionalInstructions';
        |
        );
        if ($patronselfregistrationadditionalinstructions) {

            # Insert any values found from system preference into additional_contents
            foreach my $lang ('default') {
                $dbh->do(
                    "INSERT INTO additional_contents ( category, code, location, branchcode, title, content, lang, published_on ) VALUES ('html_customizations', 'PatronSelfRegistrationAdditionalInstructions', 'PatronSelfRegistrationAdditionalInstructions', NULL, ?, ?, ?, CAST(NOW() AS date) )",
                    undef,                                         "PatronSelfRegistrationAdditionalInstructions $lang",
                    $patronselfregistrationadditionalinstructions, $lang
                );
            }

            # Remove old system preference
            $dbh->do("DELETE FROM systempreferences WHERE variable='PatronSelfRegistrationAdditionalInstructions'");
            say $out "Bug 34889 update done";
        }
    }
    }
