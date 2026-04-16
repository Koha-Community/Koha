use Modern::Perl;
use Koha::Installer::Output qw(say_success say_info say_warning);

return {
    bug_number  => "39107",
    description => "Remove illrequests_safk FK constraint on illrequests.status_alias as required by MySQL 8.4+",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Check if the foreign key exists before trying to drop it
        my $fk_exists = $dbh->selectrow_array(
            q{
                SELECT COUNT(*)
                FROM information_schema.TABLE_CONSTRAINTS
                WHERE CONSTRAINT_SCHEMA = DATABASE()
                AND TABLE_NAME = 'illrequests'
                AND CONSTRAINT_NAME = 'illrequests_safk'
                AND CONSTRAINT_TYPE = 'FOREIGN KEY'
            }
        );

        if ($fk_exists) {
            $dbh->do(q{ ALTER TABLE illrequests DROP FOREIGN KEY illrequests_safk });
            say_success( $out, "Removed illrequests_safk FK constraint on illrequests.status_alias" );
        } else {
            say_info( $out, "Foreign key illrequests_safk does not exist, skipping..." );
        }
    },
};
