package Koha::Logger;

# Copyright 2019 The National Library of Finland
# Copyright 2017 Koha-Suomi
# Copyright 2015 ByWater Solutions
# kyle@bywatersolutions.com
# Marcel de Rooy, Rijksmuseum
#
# This file is part of Koha.
#

use Modern::Perl;
use Carp;
use Scalar::Util qw(blessed);

use Log::Log4perl;
Log::Log4perl->wrapper_register(__PACKAGE__);
Log::Log4perl->wrapper_register('Koha::Middleware::Logger');
Log::Log4perl->wrapper_register('Plack::Middleware::LogErrors::LogHandle');
Log::Log4perl->wrapper_register('Plack::Middleware::LogWarn');
Log::Log4perl->wrapper_register('Koha::Logger::Mojo');
Log::Log4perl->wrapper_register('MojoX::Log::Log4perl');

use Koha::Exception::BadParameter;

# Collect all Packages/Classes that have package-level Koha::Logger-instances used in the current process, so we can update them when the global interface changes.
# This happens atleast with plack, when initially Koha::Loggers are needed before the running process chooses if it services intranet, opac, commandline or rest.
# Also as a single worker can service multiple interfaces, interface-specific loggers need to be changed to match the scope of the current request.
#
# This is rather hacky, but seems to be the only way to accomplish class/package-level loggers, without refactoring the whole plack-setup -phase to interface-specific processes.
my %knownPackageLoggers;

=head1 NAME

Koha::Logger

=head1 SYNOPSIS

=head2 OPAC/INTRA USAGE

When plack-server starts, the Koha::Logger-subsystem is automatically loaded and the proper interface is set for each request.

=head2 COMMANDLINE

Due to the numerous paths and emulations and magic tricks Koha uses, it is difficult to autodetect the running environment with certainty.
Hence commandline scripts using the logger subsystem must announce the interface as such:

    #!/usr/bin/env perl
    BEGIN { $ENV{KOHA_INTERFACE} = 'commandline'; };

=head2 REST API

Mojolicious has it's own logging subsystem, to which Koha::Logger::Mojo binds to. This is needed so we can configure Mojolicious' internals
log levels.

The usage pattern for that is

    $c->app->log->warn( 'WARNING: Serious error encountered' );

A more performant way is to use the default package/class -level usage pattern.
They can be used interchangedly.

=head2 USAGE

Usage pattern in all scripts and packages and classes in Koha:

    use Koha::Logger;

    our $logger = Koha::Logger->get(); # $logger is a global/package variable so we can reorient it when the interface changes between plack-requests
    $logger->warn('WARNING: Serious error encountered');
    $logger->debug('I thought that this code was not used');

    $logger->trace('This is not printed if TRACE is not enabled');
    Koha::Logger->setVerbosity('TRACE'); #Sets the global log level for all loggers.
    $logger->trace('This is now printed!');

=head2 HOT RELOAD

Hot-reload log4perl configuration changes, if the config was read from a file, as it typically should be.

    kill -HUP <koha process id>

Be aware that the HUP-signal also causes starman (the plack production server) to reload the applicaton code from disk.

=head1 WARN OVERLOAD

warn() is overloaded to use Log::Log4perl, but silently fall back to default warn()-behaviour if Log::Log4perl is unavailable.

=head1 EXAMPLES

See the test file

    t/Koha/Logger.t

For use cases.

=cut

# use C4::Context; #This module MUST be loaded first via the C4::Context

my $defaultConfig = q(
    log4perl.rootLogger=INFO, ROOT
    log4perl.appender.ROOT=Log::Log4perl::Appender::Screen
    log4perl.appender.ROOT.layout=PatternLayout
    log4perl.appender.ROOT.utf8=1
);

our $logger; # we cannot initialize this yet, due to system load race conditions, but this needed for the re-interfacing mechanism to work without warnings.


## Turn existing warn()-commands to use the package-level loggers or a generic logger.
my $oldWarn = $SIG{__WARN__}; #Preserve any existing warn-handlers so we don't accidentally overload those.
$SIG{__WARN__} = sub {
    no strict 'refs'; no warnings 'once';
    my $loggerFromWhereWarnComesFrom = ${caller."::logger"};
    use strict 'refs'; use warnings 'once';

    if ($loggerFromWhereWarnComesFrom) {
        $loggerFromWhereWarnComesFrom->warn(@_) if $loggerFromWhereWarnComesFrom->is_warn();
    }
    elsif ($logger) {
        $logger->warn(@_) if $logger->is_warn();
    }
    else {
        warn(@_); # This doesn't cause an endless loop as the warn subsystem is smart enough to know that we call the __WARN__-handler from within a __WARN__-handler.
    }
    &$oldWarn(@_) if $oldWarn; #Trigger possible existing warn-handlers
};

=head2 get

    my $logger = Koha::Logger->get();

 @param {HASHRef} interface => overload the default interface from C4::Context->interface()
                  category  => overload the default calling package's package name
 @returns {Log::Log4perl::Logger}    Returns a logger object (based on log4perl).

=cut

sub get {
    my ( $class, $params ) = @_;
    my $interface = $params ? ( $params->{interface} || C4::Context->interface ) : C4::Context->interface;
    my $category = $params ? ( $params->{category} || caller ) : caller;
    my $l4pcat = $interface . '.' . $category;

    return _get($l4pcat);
}

sub _get {
    my ($l4pcat) = @_;
    my $logger = Log::Log4perl->get_logger($l4pcat);
    $logger->{_original_level} = $logger->level(); #Persist the original log level so we can check that we adjust to the correct level. This is used to prevent adjustment multiplication when descending the logger hierarchy.
    return $knownPackageLoggers{$l4pcat} = _checkLoggerOverloads($logger);
}

=head2 sql

    Koha::Logger->sql($logger, 'debug', $sql, $params) if $logger->is_debug();

Log SQL-statements using a unified interface.
@param {String} Log level
@param {String} SQL-command
@param {ArrayRef} SQL prepared statement parameters
@returns whatever Log::Log4perl returns

=cut

sub sql {
    my ($class, $logger, $level, $sql, $params) = @_;
    return $logger->$level("$sql -- @$params");
}

=head2 init

Initializes the Log4perl logging subsystem.
Configuration can be hot-reloaded by passing the HUP-signal to the running process.

Initialization is done from various config sources in the following order:

1. $ENV{LOG4PERL_CONF}

- If this is a path to a file, loads it as a normal log4perl config file.
- If not a file, tries to load it as stringified log configuration.

2. C4::Context->config("log4perl_conf")

- This can only be a filepath to the config file

3. Default root logger configuration


It is considered an anomaly if initialization failed from a configuration file.
The log4perl config file must always be present.

=cut

sub init {
    my ($class, $confFile) = @_;
    return undef if (Log::Log4perl->initialized()); #Do not clobber existing initializations. Some tests can init their own logging subsystem.

    if ($ENV{LOG4PERL_CONF}) {
        if (_initFromEnv()) {
            return 1;
        }
        else {
            warn "Unable to init Log::Log4perl from \$ENV{LOG4PERL_CONF}='$ENV{LOG4PERL_CONF}'.";
        }
    }

    unless (_initFromConfFile($confFile)) {
        warn "Unable to load Log::Log4perl from \$confFile='$confFile'. Using a default screen appender.";
        _initFromConfString($defaultConfig);
    }
    return 1;
}
sub _initFromConfString {
    my ($confString) = @_;
    eval {
        Log::Log4perl->init( \$confString );
    };
    if ($@) {
        die "Unable to load Log::Log4perl at all: $@\nUsing configuration '$confString'";
    }
    return 1;
}
sub _initFromConfFile {
    my ($confFile) = @_;
    eval {
        Log::Log4perl->init_and_watch( $confFile, 'HUP' ); #Starman uses HUP as well!
    };
    if ($@) {
        my @err;
        if (not($confFile)) {
            push(@err, 'Not defined');
        } elsif (not(-e $confFile)) {
            push(@err, 'Not exists');
        } elsif (not(-r $confFile)) {
            push(@err, 'Not readable');
        } elsif (not(-f $confFile)) {
            push(@err, 'Not plain file');
        }
        my $msg = "Couldn't init Koha::Logger from configuration file '$confFile'\n";
        $msg .= "Configuration file has these problems: @err\n" if (scalar(@err));
        $msg .= "Log::Log4Perl exception: $@\n";
        warn $msg;
        return undef;
    }
    return 1;
}
sub _initFromEnv {
    $DB::single=1;
    if (-e $ENV{LOG4PERL_CONF}) {
        if (_initFromConfFile($ENV{LOG4PERL_CONF})) {
            return 1;
        }
        else {
            warn "Unable to init Log::Log4perl from \$ENV{LOG4PERL_CONF}='$ENV{LOG4PERL_CONF}'. It looks like a file that exists but failed to load it?";
        }
    }
    if (_initFromConfString($ENV{LOG4PERL_CONF})) {
        return 1;
    }
    else {
        warn "Unable to init Log::Log4perl from \$ENV{LOG4PERL_CONF}='$ENV{LOG4PERL_CONF}'. Guessed it is a string of log4perl configuration?";
    }
    return undef;
}

=head2 setVerbosity

@STATIC

    Koha::Logger->setVerbosity($verbosity);

Adjusts all current and future Koha::Loggers' verbosity.

=USAGE

To deploy verbose mode in a commandline script, add the following code:

    Getopt::Long->( ... );
    Koha::Logger->setVerbosity($verbosity);

=PARAMS

 @param {String or Signed Integer} $verbosity,
                if $verbosity is 0, no adjustment is made,
                If $verbosity is > 1, log level is decremented by that many steps
                    towards TRACE
                If $verbosity is < 0, log level is incremented by that many steps
                    towards FATAL
                If $verbosity is one of log levels, FATAL|ERROR|WARN|INFO|DEBUG|TRACE
                    log level is set to that level

=cut

sub setVerbosity {
    my ($class, $verbosity) = @_;

    if (defined($verbosity)) {
        #Tell all Koha::Loggers to use a console logger as well
        unless ($verbosity =~ /^-?\d+$/ ||
                $verbosity =~ /^(?:OFF|FATAL|ERROR|WARN|INFO|DEBUG|TRACE|ALL)$/) {
            my @cc = caller(0);
            die $cc[3]."($verbosity):> \$verbosity must be a positive or negative"
                        ." digit, or a valid Log::Log4perl log level, eg. FATAL,"
                        ." ERROR, WARN, ...";
        }
        $ENV{LOG4PERL_VERBOSITY_CHANGE} = $verbosity if defined($verbosity);
    }

    #Find existing Loggers from our namespaces and tune their log levels.
    if ($verbosity) {
        foreach my $l4pcategory (sort keys %$Log::Log4perl::Logger::LOGGERS_BY_NAME) { #Thanks Log4perl for making this available!
            my $logger = $Log::Log4perl::Logger::LOGGERS_BY_NAME->{$l4pcategory};
            $logger->{_original_level} = $logger->level() unless exists $logger->{_original_level}; # Log4perl automatically creates some mid-hierarchy loggers for us, make sure they also have the initial level set.
            _checkLoggerOverloads($logger);
        }
    }

    return $verbosity;
}

=head2 getVerbosity

 @returns {String or signed integer} The Log4perl global logger verbosity level, if a string, or the adjustment to the configured default, in levels, if a signed integer.

=cut

sub getVerbosity {
    return $ENV{LOG4PERL_VERBOSITY_CHANGE};
}

=head2 _checkLoggerOverloads

Checks if there are Environment variables that should overload configured behavior

=cut

sub _checkLoggerOverloads {
    my ($logger) = @_;
    Koha::Exception::BadParameter->throw(error => "Given parameter '\$logger'='$logger' is not a 'Log::Log4perl::Logger'")
        unless blessed($logger) && $logger->isa('Log::Log4perl::Logger');

    if ($ENV{LOG4PERL_VERBOSITY_CHANGE}) {
        if ($ENV{LOG4PERL_VERBOSITY_CHANGE} =~ /^-?(\d)$/) {
            if ($ENV{LOG4PERL_VERBOSITY_CHANGE} > 0) {
                my $newLevel = Log::Log4perl::Level::get_lower_level( $logger->{_original_level}, $ENV{LOG4PERL_VERBOSITY_CHANGE} );
                $logger->level($newLevel) if ($newLevel ne $logger->level()); # Prevent needlessly adjusting the logger level. Even if the level is the same, Logger will rebuild level accessors, which is rather costly.
            }
            elsif ($ENV{LOG4PERL_VERBOSITY_CHANGE} < 0) {
                my $newLevel = Log::Log4perl::Level::get_higher_level( $logger->{_original_level}, -$ENV{LOG4PERL_VERBOSITY_CHANGE} );
                $logger->level($newLevel) if ($newLevel ne $logger->level()); # Prevent needlessly adjusting the logger level. Even if the level is the same, Logger will rebuild level accessors, which is rather costly.
            }
        }
        else {
            $logger->level( $ENV{LOG4PERL_VERBOSITY_CHANGE} );
        }
    }

    return $logger;
}

=head2 debug_to_screen

Adds a new appender for the given logger that will log all DEBUG-and-higher messages to stderr.
Useful for daemons.

=cut

sub debug_to_screen {
    my $self = shift;

    return unless ( $self->{logger} );

    my $appender = Log::Log4perl::Appender->new(
        'Log::Log4perl::Appender::Screen',
        stderr => 1,
        utf8 => 1,
        name => 'debug_to_screen' # We need a specific name to prevent duplicates
    );

    $appender->threshold( $Log::Log4perl::DEBUG );
    $self->{logger}->add_appender( $appender );
    $self->{logger}->level( $Log::Log4perl::DEBUG );
}

=head2 reinterfaceLoggers

Reinterfaces all known Koha::Loggers to match the new system state.
Reinterfaces, as creates new loggers for the new interface and replaces the reference in the package-scope with the correct interface logger.
If the interface changes back, the existing loggers are present in the Log::Log4perl's cache.

The internal context, the running process services, can be changed mid-flight.
This is because a single Plack-server services multiple Koha interfaces (opac, intranet, rest), but initally doesn't know which one.
The interface also changes based on the incoming request.

=cut

sub reinterfaceLoggers {
    my ($oldInterface) = @_;
    $logger = __PACKAGE__->get() unless $logger;
    $logger->debug("Recreating Koha::Loggers due to interface change from '".C4::Context->interface()."' to '$oldInterface'");

    for my $l4pcategory (keys(%knownPackageLoggers)) {
        die "Unknown \$l4pcategory '$l4pcategory', couldn't split interface from the category name." unless ($l4pcategory =~ m!^(.*)\.(.+)$!);

        next unless ($oldInterface eq $1); # Preserve interface overloads for special Koha::Loggers. Only change the global interface loggers.

        no strict 'refs';
        $logger->error("Trying to re-interface Package-level logger '\$$2::logger', but there seems to be no such logger?") if (not(${"$2::logger"}) && $2 !~ /^CGI/);
        ${"$2::logger"} = _get(C4::Context->interface().'.'.$2); #Replace-in-place the existing Koha::Logger.
    }
}

1;
