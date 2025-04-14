use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35604",
    description => "Add new AutoILLBackendPriority system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{ INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('AutoILLBackendPriority','',NULL,'Set the automatic backend selection priority','ill-backends'); }
        );
        say_success( $out, "Added new system preference 'AutoILLBackendPriority'" );
    },
};
