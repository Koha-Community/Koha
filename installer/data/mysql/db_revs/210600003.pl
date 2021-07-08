use Modern::Perl;

{
    bug_number => "24434",
    description => "Add 'WrongTransfer' to branchtransfers.cancellation_reason enum",
    up => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        # add 'wrongtransfer' to branchtransfers cancellation_reason enum
        $dbh->do(
            q{
                alter table
                    `branchtransfers`
                modify column
                    `cancellation_reason` enum(
                        'manual',
                        'stockrotationadvance',
                        'stockrotationrepatriation',
                        'returntohome',
                        'returntoholding',
                        'rotatingcollection',
                        'reserve',
                        'lostreserve',
                        'cancelreserve',
                        'itemlost',
                        'wrongtransfer'
                    )
                after `comments`
              }
        );
    },
}
