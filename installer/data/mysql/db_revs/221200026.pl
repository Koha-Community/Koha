use Modern::Perl;

return {
    bug_number  => "22440",
    description => "Add new /ill_requests endopoint",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        unless ( foreign_key_exists( 'illrequests', 'illrequests_bibfk' ) ) {
            $dbh->do(q{
                ALTER TABLE illrequests
                    ADD KEY `illrequests_bibfk` (`biblio_id`),
                    ADD FOREIGN KEY illrequests_bibfk (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE;
            });

            say $out "Added foreign key constraint 'illrequests.illrequests_bibfk'";
        }
    },
};
