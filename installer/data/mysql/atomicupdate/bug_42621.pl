use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42621",
    description => "Extend report limitations by library to use library groups",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'library_groups', 'ft_reports' ) ) {
            $dbh->do(
                q{
                ALTER TABLE library_groups
                ADD COLUMN ft_reports TINYINT(1) NOT NULL DEFAULT 0
                AFTER ft_local_float_group
            }
            );
            say $out "Added column 'ft_reports' to library_groups";
        }
    },
};
