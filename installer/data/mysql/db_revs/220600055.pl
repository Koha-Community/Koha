use Modern::Perl;

return {
    bug_number  => "26368",
    description => "Add OCLC Encoding Levels system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES ('UseOCLCEncodingLevels','0',NULL,'If enabled, include OCLC encoding levels in leader value builder dropdown for position 17.','YesNo')
        }
        );
        say $out "Added new system preference 'UseOCLCEncodingLevels'";
    },
};
