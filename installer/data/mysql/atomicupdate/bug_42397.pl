use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42397",
    description => "Migrate ILL batch action_logs entries to ILL_BATCHES module",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my ($count) = $dbh->selectrow_array(
            q{
            SELECT COUNT(*) FROM action_logs
            WHERE module = 'ILL'
              AND action IN (
                'batch_create',
                'batch_update',
                'batch_delete',
                'batch_status_create',
                'batch_status_update',
                'batch_status_delete'
              )
        }
        );

        if ($count) {
            $dbh->do(
                q{
                UPDATE action_logs
                SET module = 'ILL_BATCHES'
                WHERE module = 'ILL'
                  AND action IN (
                    'batch_create',
                    'batch_update',
                    'batch_delete',
                    'batch_status_create',
                    'batch_status_update',
                    'batch_status_delete'
                  )
            }
            );

            say_success( $out, "Migrated $count action_logs entries from module 'ILL' to 'ILL_BATCHES'" );
        }
    },
};
