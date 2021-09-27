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
            $dbh->do(q{
                ALTER TABLE user_permissions ADD CONSTRAINT PK_borrowernumber_module_code PRIMARY KEY (borrowernumber,module_bit,code)
            });
            say $out "Added a primary key on user_permissions on borrowernumber, module_bit, code";
        }
    },
}
