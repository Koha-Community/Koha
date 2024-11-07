use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37757",
    description => "More robust handling of EmailFieldPrimary system preference values",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE systempreferences
            SET value=IF(value='OFF','',value),
                options='|email|emailpro|B_email|cardnumber|MULTI'
            WHERE variable='EmailFieldPrimary';
        }
        ) == 1 && say_success( $out, "Updated system preference 'EmailFieldPrimary'" );
    },
};
