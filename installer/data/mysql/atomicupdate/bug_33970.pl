use Modern::Perl;

return {
    bug_number  => "33970",
    description => "Add 'backend' column and to composite primary key in illrequestattributes",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'illrequestattributes', 'backend' ) ) {

            say $out "Adding 'backend' column to 'illrequestattributes' table";
            $dbh->do(
                q{ ALTER TABLE illrequestattributes ADD COLUMN backend varchar(80) NOT NULL COMMENT 'API ILL backend name' AFTER illrequest_id }
            );

            say $out "Dropping illrequestattributes_ifk foreign key in 'illrequestattributes' table ";
            $dbh->do(q{ ALTER TABLE illrequestattributes DROP FOREIGN KEY illrequestattributes_ifk });

            say $out "Dropping primary key in 'illrequestattributes' table ";
            $dbh->do(q{ ALTER TABLE illrequestattributes DROP PRIMARY KEY });

            say $out "Creating new primary key in 'illrequestattributes' table ";
            $dbh->do(q{ ALTER TABLE illrequestattributes ADD PRIMARY KEY( illrequest_id, backend, type (191)) });

            say $out "Creating new foreign key constraint in 'illrequestattributes' table ";
            $dbh->do(
                q{
                    ALTER TABLE illrequestattributes ADD CONSTRAINT illrequestattributes_ifk
                    FOREIGN KEY(illrequest_id)
                    REFERENCES illrequests(illrequest_id)
                    ON DELETE CASCADE ON UPDATE CASCADE;
                }
            );

            say $out "Updating backend value for all pre-existing illrequestattributes";
            $dbh->do(
                q{
                    UPDATE
                    illrequestattributes ira,
                    illrequests ir
                    SET ira.backend = ir.backend
                    WHERE ira . illrequest_id = ir.illrequest_id;
                }
            );
        }
    },
};
