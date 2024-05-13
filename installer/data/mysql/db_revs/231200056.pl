use Modern::Perl;

return {
    bug_number  => "35149",
    description => "Add 'do nothing' option to CircAutoPrintQuickSlip syspref explanation",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{UPDATE `systempreferences` SET `explanation` = 'Choose what should happen when an empty barcode field is submitted in circulation: Display a print quick slip window, Display a print slip window, Do nothing, or Clear the screen.' WHERE `variable` = 'CircAutoPrintQuickSlip'}
        );

        say $out "Updated system preference 'CircAutoPrintQuickSlip'";
    },
};
