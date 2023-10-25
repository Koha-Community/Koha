use Modern::Perl;

return {
    bug_number  => "33970",
    description => "Bind ILL attributes to specific backends",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'illrequestattributes', 'backend' ) ) {

            $dbh->do(
                q{ ALTER TABLE illrequestattributes ADD COLUMN backend varchar(80) NOT NULL COMMENT 'API ILL backend name' AFTER illrequest_id }
            );
            say $out "Added column 'illrequestattributes.backend'";

            $dbh->do(q{ ALTER TABLE illrequestattributes DROP FOREIGN KEY illrequestattributes_ifk });
            say $out "Removed 'illrequestattributes.illrequestattributes_ifk' foreign key";

            $dbh->do(q{ ALTER TABLE illrequestattributes DROP PRIMARY KEY });
            say $out "Removed 'illrequestattributes' primary key";

            $dbh->do(q{ ALTER TABLE illrequestattributes ADD PRIMARY KEY( illrequest_id, backend, type (191)) });
            say $out "Added new primary key in 'illrequestattributes'";

            $dbh->do(
                q{
                    ALTER TABLE illrequestattributes ADD CONSTRAINT illrequestattributes_ifk
                    FOREIGN KEY(illrequest_id)
                    REFERENCES illrequests(illrequest_id)
                    ON DELETE CASCADE ON UPDATE CASCADE;
                }
            );
            say $out "Added 'illrequestattributes.illrequestattributes_ifk' foreign key";

            $dbh->do(
                q{
                    UPDATE
                    illrequestattributes ira,
                    illrequests ir
                    SET ira.backend = ir.backend
                    WHERE ira . illrequest_id = ir.illrequest_id;
                }
            );
            say $out "Updated 'backend' column for all pre-existing rows in 'illrequestattributes'";
        }
    },
};
