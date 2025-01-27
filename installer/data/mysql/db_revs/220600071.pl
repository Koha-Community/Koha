use Modern::Perl;

return {
    bug_number  => "23012",
    description => "Add PROCESSING_FOUND to account_credit_types",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO account_credit_types ( code, description, can_be_added_manually, is_system ) VALUES ('PROCESSING_FOUND', 'Lost item processing fee refund', 0, 1) }
        );
    },
};
