use Modern::Perl;

return {
    bug_number  => "34748",
    description => "Fix column name in column configuration for basket summary",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{UPDATE columns_settings SET columnname="order_line" WHERE columnname="basket_number" AND module="acqui" AND page="basket" and tablename="orders"}
        );

        say $out "Update column configuration with new columnname order_line";
    },
};
