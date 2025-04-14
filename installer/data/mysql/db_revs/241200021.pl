use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38729",
    description => "Linker should consider diacritics",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('LinkerConsiderDiacritics', '0', NULL, 'Linker should consider diacritics', 'YesNo')}
        );

        say_success( $out, "Added new system preference 'LinkerConsiderDiacritics'" );
    },
};
