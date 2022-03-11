use Modern::Perl;

return {
    bug_number => "19532",
    description => "Make recalls.status an enum",
    up => sub {
        my ($args) = @_;
        my ($dbh) = @$args{qw(dbh)};

        $dbh->do(q{
            ALTER TABLE recalls
            MODIFY COLUMN
                status ENUM('requested','overdue','waiting','in_transit','cancelled','expired','fulfilled') DEFAULT 'requested' COMMENT "Request status"
        });
    },
};
