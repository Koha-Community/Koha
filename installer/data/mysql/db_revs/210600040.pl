use Modern::Perl;

return {
    bug_number  => "28263",
    description => "Update AUTO_RENEWAL too_many message",
    up          => sub {
        my ($args) = @_;
        my ($dbh)  = @$args{qw(dbh)};
        $dbh->do(
            q{
            UPDATE letter SET
            content = REPLACE(content, "You have reached the maximum number of checkouts possible." , "You have reached the maximum number of renewals possible.")
            WHERE ( code = 'AUTO_RENEWALS' OR code = 'AUTO_RENEWALS_DGST' );
        }
        );
    },
    }
