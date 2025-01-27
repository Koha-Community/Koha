use Modern::Perl;

return {
    bug_number  => "20398",
    description => "Add system preference StaffHighlightedWords",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('StaffHighlightedWords','1','','Activate or not highlighting of search terms for staff interface','YesNo')
	}
        );
    },
};
