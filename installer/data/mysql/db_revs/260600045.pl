use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41714",
    description => "Add a way to let the authority linker honor frameworks (MARC21)",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES (
                'LinkerUseFrameworkAuthTypes',
                '0',
                NULL,
                'Use authority types defined in MARC bibliographic frameworks when linking headings to authorities (MARC21 only). When enabled, the authority type configured in the Default framework will be used instead of the hardcoded MARC21 defaults.',
                'YesNo'
            )
        }
        );

        say $out "Added new system preference 'LinkerUseFrameworkAuthTypes'";
    },
};
