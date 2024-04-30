use Modern::Perl;

return {
    bug_number  => "32435",
    description => "Add ticket resolutions to catalog concerns",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_value_categories( category_name, is_system ) VALUES ('TICKET_RESOLUTION', 1);
        }
        );
        say $out "Added TICKET_RESOLUTION authorised value category";
    },
};
