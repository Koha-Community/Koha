use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);
use Array::Utils            qw( array_minus );

return {
    bug_number  => "29509",
    description => "Update users with list_borrowers permission where required",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Users to exclude from update, (superlibrarians or borrowers flags)
        my $sth = $dbh->prepare("SELECT borrowernumber FROM borrowers WHERE flags = 1 OR flags & 16");
        $sth->execute();
        my @exclusions = map { $_->[0] } @{ $sth->fetchall_arrayref };

        # Prepare insert
        my $insert_sth =
            $dbh->prepare("INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code) VALUES (?, ?, ?)");

        # Check for 'borrowers > edit_borrowers' permission
        my $sth2 = $dbh->prepare("SELECT borrowernumber FROM user_permissions WHERE code = 'edit_borrowers'");
        $sth2->execute();
        my @edit_borrowers = map { $_->[0] } @{ $sth2->fetchall_arrayref };
        my @reduced        = array_minus( @edit_borrowers, @exclusions );
        my @rows_to_insert = ( map { [ $_, 4, "list_borrowers" ] } array_minus( @edit_borrowers, @exclusions ) );
        my $count          = 0;
        foreach my $row (@rows_to_insert) { $insert_sth->execute( @{$row} ); $count++; }

        if ($count) {
            say_info( $out, "Added permission 'list_borrowers' to $count users with 'edit_borrowers' permissions" );
        }

        # Check for 'circulate' or 'circulate > manage_bookings' permission
        $count = 0;
        my $sth3 = $dbh->prepare("SELECT borrowernumber FROM user_permissions WHERE code = 'manage_bookings'");
        $sth3->execute();
        my @manage_bookings = map { $_->[0] } @{ $sth3->fetchall_arrayref };
        my $sth3_1          = $dbh->prepare("SELECT borrowernumber FROM borrowers WHERE flags & (1<<1)");
        $sth3_1->execute();
        my @circulate = map { $_->[0] } @{ $sth3_1->fetchall_arrayref };
        my @bookings  = ( @manage_bookings, @circulate );
        @rows_to_insert = ( map { [ $_, 4, "list_borrowers" ] } array_minus( @bookings, @exclusions ) );
        foreach my $row (@rows_to_insert) { $insert_sth->execute( @{$row} ); $count++; }

        if ($count) {
            say_info( $out, "Added permission 'list_borrowers' to $count users with 'manage_bookings' permissions" );
        }

        # Check for 'tools' or 'tools > label_creator' permission
        $count = 0;
        my $sth4 = $dbh->prepare("SELECT borrowernumber FROM user_permissions WHERE code = 'label_creator'");
        $sth4->execute();
        my @label_creator = map { $_->[0] } @{ $sth4->fetchall_arrayref };
        my $sth4_1        = $dbh->prepare("SELECT borrowernumber FROM borrowers WHERE flags & (1<<13)");
        $sth4_1->execute();
        my @tools  = map { $_->[0] } @{ $sth4_1->fetchall_arrayref };
        my @labels = ( @label_creator, @tools );
        @rows_to_insert = ( map { [ $_, 4, "list_borrowers" ] } array_minus( @labels, @exclusions ) );
        foreach my $row (@rows_to_insert) { $insert_sth->execute( @{$row} ); $count++; }

        if ($count) {
            say_info( $out, "Added permission 'list_borrowers' to $count users with 'label_creator' permissions" );
        }

        # Check for 'serials' or 'serials > routing' permission
        $count = 0;
        my $sth5 = $dbh->prepare("SELECT borrowernumber FROM user_permissions WHERE code = 'routing'");
        $sth5->execute();
        my @routing = map { $_->[0] } @{ $sth5->fetchall_arrayref };
        my $sth5_1  = $dbh->prepare("SELECT borrowernumber FROM borrowers WHERE flags & (1<<15)");
        $sth5_1->execute();
        my @serials       = map { $_->[0] } @{ $sth5_1->fetchall_arrayref };
        my @routing_lists = ( @routing, @serials );
        @rows_to_insert = ( map { [ $_, 4, "list_borrowers" ] } array_minus( @routing_lists, @exclusions ) );
        foreach my $row (@rows_to_insert) { $insert_sth->execute( @{$row} ); $count++ }

        if ($count) {
            say_info( $out, "Added permission 'list_borrowers' to $count users with 'routing' permissions" );
        }

        # Check for 'acquisitions' or 'acquisitions > order_manage' permission
        $count = 0;
        my $sth6 = $dbh->prepare("SELECT borrowernumber FROM user_permissions WHERE code = 'order_manage'");
        $sth6->execute();
        my @order_manage = map { $_->[0] } @{ $sth6->fetchall_arrayref };
        my $sth6_1       = $dbh->prepare("SELECT borrowernumber FROM borrowers WHERE flags & (1<<11)");
        $sth6_1->execute();
        my @acquisitions = map { $_->[0] } @{ $sth6_1->fetchall_arrayref };
        my @orders       = ( @order_manage, @acquisitions );
        @rows_to_insert = ( map { [ $_, 4, "list_borrowers" ] } array_minus( @orders, @exclusions ) );
        foreach my $row (@rows_to_insert) { $insert_sth->execute( @{$row} ); $count++ }

        if ($count) {
            say_info( $out, "Added permission 'list_borrowers' to $count users with 'order_manage' permissions" );
        }
    },
};
