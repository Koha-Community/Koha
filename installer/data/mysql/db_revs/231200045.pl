use Modern::Perl;

return {
    bug_number  => "22740",
    description =>
        "Preferences to enable automated setting of lost status when the associated fine is paid or written off",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        # sysprefs
        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('UpdateItemLostStatusWhenPaid', '0', NULL, 'Allows the status of lost items to be automatically changed when item paid for', 'Integer')
            }
        );
        say $out "Added new system preference 'UpdateItemLostStatusWhenPaid'";

        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('UpdateItemLostStatusWhenWriteoff', '0', NULL, 'Allows the status of lost items to be automatically changed when item written off', 'Integer')
            }
        );
        say $out "Added new system preference 'UpdateItemLostStatusWhenWriteoff'";
    },
};
