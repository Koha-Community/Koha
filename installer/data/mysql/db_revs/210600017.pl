use Modern::Perl;

return {
    bug_number  => "28872",
    description => "Update syspref values from on and off to 1 and 0",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{update systempreferences set value=1 where variable in ('AcquisitionLog', 'NewsLog', 'NoticesLog') and value='on'}
        );
        $dbh->do(
            q{update systempreferences set value=0 where variable in ('AcquisitionLog', 'NewsLog', 'NoticesLog') and value='off'}
        );
    },
    }
