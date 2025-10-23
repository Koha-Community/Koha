use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40364",
    description => "Add permission for viewing patron holds history",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE permissions (module_bit, code, description) VALUES
            (4, 'view_holds_history', 'Viewing holds history')
        }
        );

        say $out "Added new permission 'view_holds_history'";

        my ($IntranetHoldsHistory) = $dbh->selectrow_array(
            q|
            SELECT value FROM systempreferences WHERE variable='IntranetReadingHistoryHolds'
        |
        );

        if ($IntranetHoldsHistory) {

            my $insert_sth = $dbh->prepare(
                "INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code) VALUES (?, ?, ?)");

            my $sth = $dbh->prepare("SELECT borrowernumber FROM user_permissions WHERE code = 'edit_borrowers'");
            $sth->execute();

            my @borrowernumbers;
            while ( my ($borrowernumber) = $sth->fetchrow_array() ) {
                push @borrowernumbers, $borrowernumber;
            }

            my @rows_to_insert = ( map { [ $_, 4, "view_holds_history" ] } @borrowernumbers );
            foreach my $row (@rows_to_insert) { $insert_sth->execute( @{$row} ); }

            say_success( $out, "view_holds_history added to all borrowers with edit_borrowers" );
        }

    },
};
