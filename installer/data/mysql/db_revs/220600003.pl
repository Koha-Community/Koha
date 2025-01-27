use Modern::Perl;

return {
    bug_number  => 30924,
    description => "Add missing RecallCancellation option to branchtransfers.reason ENUM",
    up          => sub {
        my ($args) = @_;
        my ($dbh)  = @$args{qw(dbh)};

        # Add RecallCancellation ENUM option to branchtransfers.reason
        $dbh->do(
            q{
            ALTER TABLE branchtransfers MODIFY COLUMN reason
            ENUM('Manual','StockrotationAdvance','StockrotationRepatriation','ReturnToHome','ReturnToHolding','RotatingCollection','Reserve','LostReserve','CancelReserve','TransferCancellation','Recall','RecallCancellation') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'what triggered the transfer'
        }
        );
    },
};
