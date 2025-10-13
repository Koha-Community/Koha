use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40425",
    description => "Add a system preference ShowPatronFirstnameIfDifferentThanPreferredname",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
           INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
           ('ShowPatronFirstnameIfDifferentThanPreferredname','0',NULL,'If ON, a patrons firstname will also show in search results if different than their preferred name','YesNo')
        }
        );

        say $out "Added new system preference 'ShowPatronFirstnameIfDifferentThanPreferredname'";
    },
};
