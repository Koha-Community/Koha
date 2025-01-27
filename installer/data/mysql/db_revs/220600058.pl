use Modern::Perl;

return {
    bug_number  => "30944",
    description => "Replace branchtransfers.cancellation_reason CancelRecall with RecallCancellation",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            ALTER TABLE branchtransfers MODIFY COLUMN cancellation_reason ENUM('Manual','StockrotationAdvance','StockrotationRepatriation','ReturnToHome','ReturnToHolding','RotatingCollection','Reserve','LostReserve','CancelReserve','ItemLost','WrongTransfer','RecallCancellation') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'what triggered the transfer cancellation'
        }
        );
    },
};
