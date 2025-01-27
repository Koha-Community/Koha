use Modern::Perl;

return {
    bug_number  => "30128",
    description => "Change language_subtag_registry.description to varchar(255)",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            ALTER TABLE `language_subtag_registry` MODIFY COLUMN `description` VARCHAR(255) DEFAULT NULL
        }
        );
    },
};
