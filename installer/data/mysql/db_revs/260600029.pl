use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41253",
    description => "Add items_modification_by_age permission",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $inserted = $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description)
            VALUES (13, 'items_modification_by_age', 'Define rules for automatic item aging')
        }
        );
        if ( $inserted == 1 ) {
            say $out "Added new permission 'items_modification_by_age'";

            my $sth = $dbh->prepare(
                q{
            SELECT borrowernumber
            FROM user_permissions
            WHERE code = 'items_batchmod'
        }
            );

            $sth->execute();

            my @borrowernumbers;
            while ( my ($borrowernumber) = $sth->fetchrow_array ) {
                push @borrowernumbers, $borrowernumber;
            }

            if (@borrowernumbers) {

                my $insert_sth = $dbh->prepare(
                    q{
                INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
                VALUES (?, 13, 'items_modification_by_age')
            }
                );

                foreach my $borrowernumber (@borrowernumbers) {
                    $insert_sth->execute($borrowernumber);
                }

                say_success( $out, "Granted items_modification_by_age to users with items_batchmod" );
            }
        }
    },
};
