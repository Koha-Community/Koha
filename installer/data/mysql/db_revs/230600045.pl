use Modern::Perl;

return {
    bug_number  => "28166",
    description => "Add system preference for additional columns for Z39.50 authority search results",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
('AdditionalFieldsInZ3950ResultAuthSearch', '', NULL, 'Determines which MARC field/subfields are displayed in -Additional field- column in the result of an authority Z39.50 search', 'Free')
}
        );

        # Print useful stuff here
        # sysprefs
        say $out "Added new system preference 'AdditionalFieldsInZ3950ResultAuthSearch'";
    },
};
