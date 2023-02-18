use Modern::Perl;

return {
    bug_number => "33004",
    description => "Add VENDOR_TYPE authorised value category",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{INSERT IGNORE INTO authorised_value_categories (category_name, is_system) VALUES ('VENDOR_TYPE', 1)});
        say $out "Added new authorised value category 'VENDOR_TYPE'";
    },
};
