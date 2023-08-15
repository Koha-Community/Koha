use Modern::Perl;

return {
    bug_number  => "34494",
    description => "Fix tmp_holdsqueue for MySQL compatibility",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{
            ALTER TABLE tmp_holdsqueue CHANGE COLUMN itemnumber `itemnumber` int(11) NOT NULL
        });
    },
};
