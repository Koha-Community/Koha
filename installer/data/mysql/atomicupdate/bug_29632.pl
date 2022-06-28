use Modern::Perl;

return {
    bug_number => "29632    ",
    description => "Add callnumber type to allow sorting",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            ALTER TABLE `search_field` MODIFY COLUMN `type`
            enum('','string','date','number','boolean','sum','isbn','stdno','year','callnumber') NOT NULL
        });
        say $out "Add callnumber to search_field type enum";
    },
};
