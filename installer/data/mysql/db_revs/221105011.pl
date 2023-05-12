use Modern::Perl;

return {
    bug_number => "32357",
    description => "Set borrower_message_preferences.days_in_advance default to NULL",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE borrower_message_preferences ALTER days_in_advance SET DEFAULT NULL;
        });
        say $out "Updated column 'borrower_message_preferences.days_in_advance default' to NULL";
    },
};
