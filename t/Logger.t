use Modern::Perl;

use C4::Context;
use Koha::Logger;

use File::Temp qw/tempfile/;
use Test::MockModule;
use Test::More tests => 1;

subtest 'Test01 -- Simple tests for Koha::Logger' => sub {
    plan tests => 6;
    test01();
};

sub test01 {
    my $mContext = new Test::MockModule('C4::Context');
    $mContext->mock( 'config', sub { return; } );

    my $logger= Koha::Logger->get;
    is( exists $logger->{logger}, '', 'No log4perl config');
    my $d= $logger->debug('Message 1');
    is( $d, undef, 'No return value for debug call');

    my $log = mytempfile();
    my $conf = mytempfile( <<"HERE"
log4perl.logger.intranet = WARN, INTRANET
log4perl.appender.INTRANET=Log::Log4perl::Appender::File
log4perl.appender.INTRANET.filename=$log
log4perl.appender.INTRANET.mode=append
log4perl.appender.INTRANET.layout=PatternLayout
log4perl.appender.INTRANET.layout.ConversionPattern=[%d] [%p] %m %l %n
HERE
    );
    $mContext->mock( 'config', sub { return $conf; } );
    $logger= Koha::Logger->get({ interface => 'intranet' });
    is( exists $logger->{logger}, 1, 'Log4perl config found');
    is( $logger->warn('Message 2'), 1, 'Message 2 returned a value' );
    is( $logger->catastrophe, undef, 'catastrophe undefined');
    system("chmod 400 $log");
    is( $logger->warn('Message 3'), undef, 'Message 3 returned undef' );
}

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.logger.test', UNLINK => 1 );
    print $fh $_[0]//'';
    close $fh;
    return $fn;
}
