use Modern::Perl;

return {
    bug_number  => "35687",
    description => "Upgrade to 23.06.00.013 may fail, drop FK and recreate after adding the PK to tmp_holdsqueue",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( primary_key_exists( 'tmp_holdsqueue', 'itemnumber' ) ) {
            $dbh->do(q{ALTER TABLE tmp_holdsqueue DROP CONSTRAINT `tmp_holdsqueue_ibfk_1`});
            $dbh->do(q{ALTER TABLE tmp_holdsqueue ADD PRIMARY KEY (itemnumber)});
            $dbh->do(
                q{
                    ALTER TABLE tmp_holdsqueue ADD CONSTRAINT `tmp_holdsqueue_ibfk_1`
                    FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`)
                    ON DELETE CASCADE ON UPDATE CASCADE
                }
            );
        }

        say $out "Set primary key for table 'tmp_holdsqueue' to 'itemnumber'";
    },
};
