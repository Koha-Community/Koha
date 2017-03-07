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
use base qw(Log::Log4perl::Logger);

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
    my $logger = Log::Log4perl->get_logger($l4pcat);
    bless($logger, $class);
    return $logger;
}

sub _init {
    my $confFile = C4::Context->config("log4perl_conf");
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
    my $method = $Koha::Logger::AUTOLOAD;
    warn "ERROR: Unsupported method $method, params '@_'";
    return undef;
}

1;
