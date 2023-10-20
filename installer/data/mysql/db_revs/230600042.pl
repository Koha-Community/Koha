use Modern::Perl;

return {
    bug_number  => "33845",
    description => "Update holds_table column settings entries to holds-table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE columns_settings SET tablename="holds-table"
            WHERE page="circulation" and tablename="holds_table"
        }
        );

        say $out "Update columns settings to use table name holds-table";
    },
};
