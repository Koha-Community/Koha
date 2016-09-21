package t::db_dependent::KohaSuomi::SelfService_context;

use Modern::Perl '2014';

use Test::More;

sub testLogs {
    my ($logs, $i, $borrowernumber, $action, $ymd, $resolution, $SSAPIAuthorizerUser) = @_;

    ok($logs->[$i]->{timestamp} =~ /^$ymd/, "Log entry $i, timestamp kinda ok");
    is($logs->[$i]->{user}, $SSAPIAuthorizerUser->{number}, "Log entry $i, correct user");
    is($logs->[$i]->{module}, 'SS', "Log entry $i, correct module");
    is($logs->[$i]->{action}, $action, "Log entry $i, correct action");
    is($logs->[$i]->{object}, $borrowernumber, "Log entry $i, correct branch");
    is($logs->[$i]->{info}, $resolution, "Log entry $i, resolution ok");
}

1;
