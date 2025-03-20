use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38494",
    description => "Add `ConsiderHeadingUse` preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('ConsiderHeadingUse', '0', NULL, 'Consider MARC21 authority heading use (main/added entry, or subject, or series title) in cataloging and linking', 'YesNo')}
        );

        say_success( $out, "Added system preference 'ConsiderHeadingUse'" );
    },
};
