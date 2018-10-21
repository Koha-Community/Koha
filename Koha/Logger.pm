package Koha::Logger;

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

=head1 NAME

Koha::Logger

=head1 SYNOPSIS

    use Koha::Logger;

    my $logger = Koha::Logger->get;
    $logger->warn( 'WARNING: Serious error encountered' );
    $logger->debug( 'I thought that this code was not used' );

    #Hot-reload log4perl configuration changes
    kill -HUP <koha process id>

=cut

use C4::Context;

BEGIN {
    Log::Log4perl->wrapper_register(__PACKAGE__);
}

my $defaultConfig = q(
    log4perl.rootLogger=WARN, ROOT
    log4perl.appender.ROOT=Log::Log4perl::Appender::Screen
    log4perl.appender.ROOT.layout=PatternLayout
    log4perl.appender.ROOT.utf8=1
);

=head2 new

    my $logger = Koha::Logger->new($params);

See get() for available $params.
Prepares the logger for lazyLoading if uncertain whether or not the environment is set.
This is meant to be used to instantiate package-level loggers.

=cut

sub new {
    my ($class, $params) = @_;
    my $self = {lazyLoad => $params}; #Mark self as lazy loadable
    bless $self, $class;
    return $self;
}

=head2 get

    Returns a logger object (based on log4perl).
    Category and interface hash parameter are optional.
    Normally, the category should follow the current package and the interface
    should be set correctly via C4::Context.

=cut

sub get {
    my ( $class, $params ) = @_;
    my $interface = $params ? ( $params->{interface} || C4::Context->interface ) : C4::Context->interface;
    my $category = $params ? ( $params->{category} || caller ) : caller;
    my $l4pcat = $interface . '.' . $category;
    _init();
    my $self = {
        logger => Log::Log4perl->get_logger($l4pcat),
    };
    bless($self, $class);

    $self->_checkLoggerOverloads();

    return $self;
}

=head2 sql

    $logger->sql('debug', $sql, $params) if $logger->is_debug();

Log SQL-statements using a unified interface.
@param {String} Log level
@param {String} SQL-command
@param {ArrayRef} SQL prepared statement parameters
@returns whatever Log::Log4perl returns

=cut

sub sql {
    my ($self, $level, $sql, $params) = @_;
    return $self->$level("$sql -- @$params");
}

sub _init {
    my $confFile = C4::Context->config("log4perl_conf");
    if ($confFile) {
        _initFromConfFile($confFile);
    }
    else {
        _initDefault();
    }
}
sub _initDefault {
    eval {
        Log::Log4perl->init( \$defaultConfig )
            unless(Log::Log4perl->initialized());
    };
    if ($@) {
        die __PACKAGE__."::initDefault():> $@";
    }
}
sub _initFromConfFile {
    my ($confFile) = @_;
    eval {
        Log::Log4perl->init_and_watch( $confFile, 'HUP' ) #Starman uses HUP as well!
            unless(Log::Log4perl->initialized());
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
        die $msg;
    }
}

=head2 setConsoleVerbosity

    Koha::Logger->setConsoleVerbosity($verbosity);

Sets all Koha::Loggers to use also the console for logging and adjusts their
verbosity by the given verbosity.

=USAGE

Do deploy verbose mode in a commandline script, add the following code:

    use C4::Context;
    use Koha::Logger;
    C4::Context->setCommandlineEnvironment();
    Koha::Logger->setConsoleVerbosity( 1 || -3 || 'WARN' || ... );

=PARAMS

@param {String or Signed Integer} $verbosity,
                if $verbosity is 0, no adjustment is made,
                If $verbosity is > 1, log level is decremented by that many steps
                    towards TRACE
                If $verbosity is < 0, log level is incremented by that many steps
                    towards FATAL
                If $verbosity is one of log levels, log level is set to that level
                If $verbosity is undef, clear all overrides

=cut

sub setConsoleVerbosity {
    if ($_[0] eq __PACKAGE__ || blessed($_[0]) && $_[0]->isa('Koha::Logger') ) {
        shift(@_); #Compensate for erratic calling styles.
    }
    my ($verbosity) = @_;

    if (defined($verbosity)) {
        #Tell all Koha::Loggers to use a console logger as well
        unless ($verbosity =~ /^-?\d+$/ ||
                $verbosity =~ /^(?:FATAL|ERROR|WARN|INFO|DEBUG|TRACE)$/) {
            my @cc = caller(0);
            die $cc[3]."($verbosity):> \$verbosity must be a positive or negative"
                        ." digit, or a valid Log::Log4perl log level, eg. FATAL,"
                        ." ERROR, WARN, ...";
        }
        $ENV{LOG4PERL_TO_CONSOLE} = 1;

        $ENV{LOG4PERL_VERBOSITY_CHANGE} = $verbosity if defined($verbosity);
    }
    else {
        delete $ENV{LOG4PERL_TO_CONSOLE};
        delete $ENV{LOG4PERL_VERBOSITY_CHANGE};
    }
}

=head2 _checkLoggerOverloads

Checks if there are Environment variables that should overload configured behavior

=cut

# Define a stdout appender. I wonder how can I load a PatternedLayout from
# log4perl.conf here?
my $commandlineScreen =  Log::Log4perl::Appender->new(
                             "Log::Log4perl::Appender::Screen",
                             name      => "commandlineScreen",
                             stderr    => 0);
#I want this to be defined in log4perl.conf instead :(
my $commandlineLayout = Log::Log4perl::Layout::PatternLayout->new(
                   "%d %M{2}> %m %n");
$commandlineScreen->layout($commandlineLayout);

sub _checkLoggerOverloads {
    my ($self) = @_;
    return unless blessed($self->{logger})
        && $self->{logger}->isa('Log::Log4perl::Logger');

    if ($ENV{LOG4PERL_TO_CONSOLE}) {
        $self->{logger}->add_appender($commandlineScreen);
    }
    if ($ENV{LOG4PERL_VERBOSITY_CHANGE}) {
        if ($ENV{LOG4PERL_VERBOSITY_CHANGE} =~ /^-?(\d)$/) {
            if ($ENV{LOG4PERL_VERBOSITY_CHANGE} > 0) {
                $self->{logger}->dec_level( $1 );
            }
            elsif ($ENV{LOG4PERL_VERBOSITY_CHANGE} < 0) {
                $self->{logger}->inc_level( $1 );
            }
        }
       else {
            $self->{logger}->level( $ENV{LOG4PERL_VERBOSITY_CHANGE} );
        }
    }
}

=head2 AUTOLOAD

    Prevent a crash when log4perl is invoked improperly.

=cut

sub AUTOLOAD {
    my $self = shift;
    my $method = $Koha::Logger::AUTOLOAD =~ s/Koha::Logger:://r;

    if ($self->{lazyLoad} && $method ne 'DESTROY') { #We have created this logger to be lazy loadable
        $self = ref($self)->get( $self->{lazyLoad} ); #Lazy load me!
    }

    if (!exists $self->{logger}) {
        # do not use log4perl; no print to stderr
        return undef;
    }
    elsif ($self->{logger}->can($method)) {
        return $self->{logger}->$method(@_);
    }
    warn "ERROR: Unsupported method $Koha::Logger::AUTOLOAD, params '@_'";
    return undef;
}

1;
