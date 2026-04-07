use Modern::Perl;

return {
    bug_number  => "42273",
    description => "Fix 'idenfity' typo in categories table comment",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                ALTER TABLE `categories`
                MODIFY COLUMN `categorycode` varchar(10) NOT NULL DEFAULT ''
                COMMENT 'unique primary key used to identify the patron category'
            }
        );

        say $out "Fixed typo in categories.categorycode column comment";
    },
};
