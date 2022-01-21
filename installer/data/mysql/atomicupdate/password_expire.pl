use Modern::Perl;

return {
    bug_number => "BUG_NUMBER",
    description => "Add password expiration",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless( column_exists('categories', 'password_expiry_days') ){
            $dbh->do(q{
                ALTER TABLE categories ADD password_expiry_days SMALLINT(5) NULL DEFAULT NULL AFTER enrolmentperioddate
            });
            say $out "Added password_expiry_days to categories";
        }
        unless( column_exists('borrowers', 'password_expiration_date') ){
            $dbh->do(q{
                ALTER TABLE borrowers ADD password_expiration_date DATE NULL DEFAULT NULL AFTER dateexpiry
            });
            # Print useful stuff here
            say $out "Added password_expiration_date field to borrowers";
        }
        unless( column_exists('deletedborrowers', 'password_expiration_date') ){
            $dbh->do(q{
                ALTER TABLE deletedborrowers ADD password_expiration_date DATE NULL DEFAULT NULL AFTER dateexpiry
            });
            # Print useful stuff here
            say $out "Added password_expiration_date field to borrowers";
        }
    },
};
