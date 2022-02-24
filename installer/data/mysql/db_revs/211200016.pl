use Modern::Perl;

return {
    bug_number => "30060",
    description => "Update user_permissions to add primary key and remove null option from code column",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless(
            primary_key_exists( 'user_permissions', 'borrowernumber') &&
            primary_key_exists( 'user_permissions', 'module_bit' ) &&
            primary_key_exists( 'user_permissions', 'code')
        ){
            $dbh->do(q{
                ALTER TABLE user_permissions DROP INDEX IF EXISTS `PRIMARY`
            });
            say $out "Dropped any previously created primary key";

            $dbh->do(q{ALTER TABLE user_permissions ADD COLUMN temp SERIAL PRIMARY KEY});
            $dbh->do(q{DELETE t1 FROM user_permissions t1 INNER JOIN user_permissions t2 WHERE t1.temp < t2.temp AND t1.borrowernumber = t2.borrowernumber AND t1.module_bit = t2.module_bit AND t1.code = t2.code});
            $dbh->do(q{ALTER TABLE user_permissions DROP COLUMN temp});
            say $out "Removed any duplicate rows";

            $dbh->do(q{
                ALTER TABLE user_permissions ADD CONSTRAINT PK_borrowernumber_module_code PRIMARY KEY (borrowernumber,module_bit,code)
            });
            say $out "Added a primary key on user_permissions on borrowernumber, module_bit, code";
        }
    },
};
