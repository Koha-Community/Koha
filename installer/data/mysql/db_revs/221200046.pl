use Modern::Perl;

return {
    bug_number => "30358",
    description => "Add new system preference StripWhitespaceChars",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('StripWhitespaceChars', '0', NULL, 'Strip leading and trailing whitespace characters and inner newlines from input fields when cataloguing bibliographic and authority records.', 'YesNo') });
    },
};
