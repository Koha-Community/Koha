use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "31698",
    description => "Add a new permission for moving holds",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE permissions (module_bit, code, description) VALUES (6, 'alter_hold_targets', 'Move holds between items and records')

        }
        );
        say $out "Added new permission 'alter_hold_targets'";
    },
};
