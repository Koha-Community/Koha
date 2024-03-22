use Modern::Perl;

return {
    bug_number  => "36033",
    description => "Add more indexes to pseudonymized_transactions",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( index_exists( 'pseudonymized_transactions', 'pseudonymized_transactions_items_ibfk_4' ) ) {
            $dbh->do(
                q{ALTER TABLE `pseudonymized_transactions` ADD INDEX `pseudonymized_transactions_items_ibfk_4` (`itemnumber`)}
            );
            say $out "Added new index on pseudonymized_transactions.itemnumber";
        }
        unless ( index_exists( 'pseudonymized_transactions', 'pseudonymized_transactions_ibfk_5' ) ) {
            $dbh->do(
                q{ALTER TABLE `pseudonymized_transactions` ADD INDEX `pseudonymized_transactions_ibfk_5` (`transaction_type`)}
            );
            say $out "Added new index on pseudonymized_transactions.transaction_type";
        }
        unless ( index_exists( 'pseudonymized_transactions', 'pseudonymized_transactions_ibfk_6' ) ) {
            $dbh->do(
                q{ALTER TABLE `pseudonymized_transactions` ADD INDEX `pseudonymized_transactions_ibfk_6` (`datetime`)});
            say $out "Added new index on pseudonymized_transactions.datetime";
        }
    },
};
