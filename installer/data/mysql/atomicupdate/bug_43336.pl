use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);
use JSON                    qw( to_json from_json );

return {
    bug_number  => "43336",
    description => "Clean up sysprefs related to Libris spellcheck",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # LibrisKey
        my $deleted_key = $dbh->do(q{DELETE FROM systempreferences WHERE variable='LibrisKey'});
        if ( $deleted_key && $deleted_key > 0 ) {
            say_success( $out, "Removed system preference 'LibrisKey'" );
        } else {
            say_warning( $out, "'LibrisKey' syspref already removed" );
        }

        # LibrisURL
        my $deleted_url = $dbh->do(q{DELETE FROM systempreferences WHERE variable='LibrisURL'});
        if ( $deleted_url && $deleted_url > 0 ) {
            say_success( $out, "Removed system preference 'LibrisURL'" );
        } else {
            say_warning( $out, "'LibrisURL' syspref already removed" );
        }

        # OPACdidyoumean
        use Data::Dumper;
        my $clean_data;
        my $found_unwanted_setting = 0;

        # Get the current value of OPACdidyoumean
        my ($result) = $dbh->selectrow_array("SELECT value FROM systempreferences WHERE variable = 'OPACdidyoumean'");
        if ($result) {
            my $json_data = from_json($result);

            # Loop over all the elements in the syspref
            foreach my $element ( @{$json_data} ) {
                if ( $element->{'name'} && $element->{'name'} ne 'LibrisSpellcheck' ) {

                    # Save the elements we are not interested in so we can save it back to the DB
                    push @{$clean_data}, $element;
                } else {

                    # Do not save the setting for LibrisSpellcheck
                    $found_unwanted_setting = 1;
                }
            }
            if ( $found_unwanted_setting == 0 ) {

                # We did not find a setting for LibrisSpellcheck, so we can leave the OPACdidyoumean as it was
                say_warning( $out, "'OPACdidyoumean' syspref does not contain a setting for 'LibrisSpellcheck'" );
            } else {

                # Update OPACdidyoumean, but without the setting for LibrisSpellcheck
                my $new_json_data = to_json($clean_data);
                $dbh->do("UPDATE systempreferences SET value = '$new_json_data' WHERE variable='OPACdidyoumean'");
                say_success( $out, "'LibrisSpellcheck' was removed from the OPACdidyoumean syspref" );
            }
        } else {
            say_warning( $out, "'OPACdidyoumean' is not set" );
        }

    },
};
