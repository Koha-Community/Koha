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
    return $self;
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

=head2 AUTOLOAD

    Prevent a crash when log4perl is invoked improperly.

=cut

sub AUTOLOAD {
    my $self = shift;
    my $method = $Koha::Logger::AUTOLOAD =~ s/Koha::Logger:://r;

    if ($self->{lazyLoad}) { #We have created this logger to be lazy loadable
        $self = ref($self)->get( $self->{lazyLoad} ); #Lazy load me!
    }

    if ($self->{logger}->can($method)) {
        return $self->{logger}->$method(@_);
    }
    warn "ERROR: Unsupported method $Koha::Logger::AUTOLOAD, params '@_'";
    return undef;
}

1;
