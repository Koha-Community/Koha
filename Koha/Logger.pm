package Koha::Logger;

# Copyright 2015 ByWater Solutions
# kyle@bywatersolutions.com
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

Koha::Logger

=head1 SYNOPSIS

    use Koha::Logger;

    my $logger = Koha::Logger->get;
    $logger->warn( 'WARNING: Serious error encountered' );
    $logger->debug( 'I thought that this code was not used' );

=head1 FUNCTIONS

=cut

use Modern::Perl;

use Log::Log4perl;

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
    my $l4pcat = ( C4::Context->psgi_env ? 'plack-' : q{} ) . $interface . '.' . $category;

    my $init = _init();
    my $self = {};
    if ($init) {
        $self->{logger} = Log::Log4perl->get_logger($l4pcat);
        $self->{cat}    = $l4pcat;
        $self->{logs}   = $init if ref $init;
    }
    bless $self, $class;
    return $self;
}

=head2 put_mdc

my $foo = $logger->put_mdc('foo', $foo );

put_mdc sets global thread specific data that can be access later when generating log lines
via the "%X{key}" placeholder in Log::Log4perl::Layout::PatternLayouts.

=cut

sub put_mdc {
    my ( $self, $key, $value ) = @_;

    Log::Log4perl::MDC->put( $key, $value );
}

=head2 get_mdc

my $foo = $logger->get_mdc('foo');

Retrieves the stored mdc value from the stored map.

=cut

sub get_mdc {
    my ( $self, $key ) = @_;

    return Log::Log4perl::MDC->get( $key );
}

=head2 clear_mdc

$logger->clear_mdc();

Removes *all* stored key/value pairs from the MDC map.

=cut

sub clear_mdc {
    my ( $self, $key ) = @_;

    return Log::Log4perl::MDC->remove( $key );
}

=head1 INTERNALS

=head2 AUTOLOAD

    In order to prevent a crash when log4perl cannot write to Koha logfile,
    we check first before calling log4perl.
    If log4perl would add such a check, this would no longer be needed.

=cut

sub AUTOLOAD {
    my ( $self, $line ) = @_;
    my $method = $Koha::Logger::AUTOLOAD;
    $method =~ s/^Koha::Logger:://;

    if ( $self->{logger}->can($method) ) {    #use log4perl
        return $self->{logger}->$method($line);
    }
    else {                                       # we should not really get here
        warn "ERROR: Unsupported method $method";
    }
    return;
}

=head2 DESTROY

    Dummy destroy to prevent call to AUTOLOAD

=cut

sub DESTROY { }

=head2 _init

=cut

sub _init {

    my $log4perl_config =
          exists $ENV{"LOG4PERL_CONF"}
              && $ENV{'LOG4PERL_CONF'}
           && -s $ENV{"LOG4PERL_CONF"}
      # Check for web server level configuration first
      # In this case we ASSUME that you correctly arranged logfile
      # permissions. If not, log4perl will crash on you.
      ? $ENV{"LOG4PERL_CONF"}
      : C4::Context->config("log4perl_conf");

    # This will explode with the relevant error message if something is wrong in the config file
    return Log::Log4perl->init_once($log4perl_config);
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

=head2 context

Mojolicous 8.23 added a "context" method, which Mojolicious will die
on if it's missing from the logger.

Note: We are just preventing a crash here not returning a new context logger.

=cut

sub context {
    my ( $self, @context ) = @_;
    $self->{context} = \@context;
    return $self;
}

sub history {
    my ( $self, @history) = @_;
    if ( @history ) {
        $self->{history} = \@history;
    }
    return $self->{history} || [];
}

=head1 AUTHOR

Kyle M Hall, E<lt>kyle@bywatersolutions.comE<gt>
Marcel de Rooy, Rijksmuseum

=cut

1;

__END__
