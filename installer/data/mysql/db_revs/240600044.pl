use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => '28833',
    description => 'Speed up holds queue builder via parallel processing',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @{$args}{qw(dbh out)};

        $dbh->do(
            q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('HoldsQueueParallelLoopsCount', '1', NULL, 'Number of parallel loops to use when running the holds queue builder', 'Integer');
    }
        );

        say_success( $out, "Added new system preference 'HoldsQueueParallelLoopsCount'" );

    },
};
