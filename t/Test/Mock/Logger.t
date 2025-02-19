use Modern::Perl;
use Test::More tests => 10;
use Test::Warn;

# Module under test
use t::lib::Mocks::Logger;
use Koha::Logger;

# Test instantiation
my $logger;
subtest 'Constructor tests' => sub {
    plan tests => 2;
    $logger = t::lib::Mocks::Logger->new();
    isa_ok( $logger, 't::lib::Mocks::Logger', 'Constructor returns expected object' );
    can_ok(
        $logger, qw(new diag debug_is error_is fatal_is info_is trace_is warn_is
            debug_like error_like fatal_like info_like trace_like warn_like
            count clear)
    );
};

# Get a reference to the mocked logger
my $mocked_logger = Koha::Logger->get();

# Test logging at various log levels and verify that the messages are captured
subtest 'Basic logging tests' => sub {
    plan tests => 1;

    $logger->clear();

    $mocked_logger->debug('Debug message');
    $mocked_logger->info('Info message');
    $mocked_logger->warn('Warning message');
    $mocked_logger->error('Error message');
    $mocked_logger->fatal('Fatal message');
    $mocked_logger->trace('Trace message');

    is( $logger->count, 6, 'All 6 log messages were captured' );
};

# Test exact message matching methods
subtest 'Exact message matching' => sub {
    plan tests => 6;

    $logger->clear();

    $mocked_logger->debug('Debug message');
    $mocked_logger->info('Info message');
    $mocked_logger->warn('Warning message');
    $mocked_logger->error('Error message');
    $mocked_logger->fatal('Fatal message');
    $mocked_logger->trace('Trace message');

    $logger->debug_is( 'Debug message', 'Debug message matched exactly' );
    $logger->info_is( 'Info message', 'Info message matched exactly' );
    $logger->warn_is( 'Warning message', 'Warning message matched exactly' );
    $logger->error_is( 'Error message', 'Error message matched exactly' );
    $logger->fatal_is( 'Fatal message', 'Fatal message matched exactly' );
    $logger->trace_is( 'Trace message', 'Trace message matched exactly' );
};

# Test regex message matching methods
subtest 'Regex message matching' => sub {
    plan tests => 6;

    $logger->clear();

    $mocked_logger->debug('Debug message 123');
    $mocked_logger->info('Info message 456');
    $mocked_logger->warn('Warning message 789');
    $mocked_logger->error('Error message abc');
    $mocked_logger->fatal('Fatal message def');
    $mocked_logger->trace('Trace message ghi');

    $logger->debug_like( qr/Debug.*123/, 'Debug message matched regex' );
    $logger->info_like( qr/Info.*456/, 'Info message matched regex' );
    $logger->warn_like( qr/Warning.*789/, 'Warning message matched regex' );
    $logger->error_like( qr/Error.*abc/, 'Error message matched regex' );
    $logger->fatal_like( qr/Fatal.*def/, 'Fatal message matched regex' );
    $logger->trace_like( qr/Trace.*ghi/, 'Trace message matched regex' );
};

# Test count method
subtest 'Count method tests' => sub {
    plan tests => 7;

    $logger->clear();

    is( $logger->count, 0, 'Count is 0 after clear' );

    $mocked_logger->debug('Debug message');
    is( $logger->count,          1, 'Count is 1 after one message' );
    is( $logger->count('debug'), 1, 'Debug count is 1' );
    is( $logger->count('error'), 0, 'Error count is 0' );

    $mocked_logger->error('Error message');
    is( $logger->count,          2, 'Count is 2 after two messages' );
    is( $logger->count('debug'), 1, 'Debug count is still 1' );
    is( $logger->count('error'), 1, 'Error count is now 1' );
};

# Test clear method
subtest 'Clear method tests' => sub {
    plan tests => 3;

    $logger->clear();
    $mocked_logger->debug('Debug message');
    $mocked_logger->error('Error message');

    is( $logger->count, 2, 'Count is 2 before clear' );

    $logger->clear('debug');
    is( $logger->count('debug'), 0, 'Debug count is 0 after specific clear' );
    is( $logger->count('error'), 1, 'Error count is still 1 after specific clear' );
};

# Test method chaining
subtest 'Method chaining tests' => sub {
    plan tests => 4;

    $logger->clear();

    $mocked_logger->debug('Debug message 1');
    $mocked_logger->debug('Debug message 2');
    $mocked_logger->error('Error message');

    my $result =
        $logger->debug_is( 'Debug message 1', 'First debug message matched' )
        ->debug_is( 'Debug message 2', 'Second debug message matched' )
        ->error_is( 'Error message', 'Error message matched' );

    isa_ok( $result, 't::lib::Mocks::Logger', 'Method chaining returns the logger object' );
};

# Test diag method (output capture is complex, just verify it runs)
subtest 'Diag method test' => sub {
    plan tests => 1;

    $logger->clear();
    $mocked_logger->debug('Debug message');

    # Just make sure it doesn't throw an exception
    eval { $logger->diag(); };
    is( $@, '', 'diag() method executed without errors' );
};

# Test handling of empty log buffers
subtest 'Empty log buffer handling' => sub {
    plan tests => 6;

    $logger->clear();

    $logger->debug_is( '', 'Empty string returned when no debug messages' );
    $logger->info_is( '', 'Empty string returned when no info messages' );
    $logger->warn_is( '', 'Empty string returned when no warn messages' );
    $logger->error_is( '', 'Empty string returned when no error messages' );
    $logger->fatal_is( '', 'Empty string returned when no fatal messages' );
    $logger->trace_is( '', 'Empty string returned when no trace messages' );
};

# Test multiple messages at the same level
subtest 'Multiple messages at same level' => sub {
    plan tests => 5;

    $logger->clear();

    $mocked_logger->debug('Debug message 1');
    $mocked_logger->debug('Debug message 2');
    $mocked_logger->debug('Debug message 3');

    is( $logger->count('debug'), 3, 'Three debug messages recorded' );
    $logger->debug_is( 'Debug message 1', 'First debug message matched' );
    $logger->debug_is( 'Debug message 2', 'Second debug message matched' );
    $logger->debug_is( 'Debug message 3', 'Third debug message matched' );
    is( $logger->count('debug'), 0, 'All debug messages consumed' );
};
