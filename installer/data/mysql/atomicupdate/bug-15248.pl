use Modern::Perl;

return {
    bug_number  => "15248",
    description => "Add biblio_framework_marc_matcher table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('biblio_framework_marc_matcher') ) {
            $dbh->do(
                q{
                CREATE TABLE biblio_framework_marc_matcher (
                    frameworkcode VARCHAR(4) NOT NULL COMMENT 'MARC framework code',
                    marc_matcher_id INT(11) NOT NULL COMMENT 'MARC matcher id',
                    forbid_duplicate_creation TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Do not show an option to create a duplicate record when a duplicate is found',
                    PRIMARY KEY (frameworkcode),
                    CONSTRAINT biblio_framework_marc_matcher_ibfk_1
                      FOREIGN KEY (marc_matcher_id) REFERENCES marc_matchers (matcher_id)
                      ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );
            say $out "Created new table biblio_framework_marc_matcher";
        } else {
            say $out "Table biblio_framework_marc_matcher already exists";
        }
    },
};
