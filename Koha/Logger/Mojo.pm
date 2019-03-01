package Koha::Logger::Mojo;

# Copyright 2017 Koha-Suomi Oy
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::Logger::Mojo

=head1 SYNOPSIS

    use Koha::Logger::Mojo;

    $c->app->log(Koha::Logger::Mojo->get);
    $c->app->log->warn( 'WARNING: Serious error encountered' );

    EXAMPLE CONFIGS:
    log4perl.logger.rest = ERROR, REST
    log4perl.appender.REST=Log::Log4perl::Appender::File
    log4perl.appender.REST.filename=__LOG_DIR__/rest.log
    log4perl.appender.REST.create_at_logtime=true
    log4perl.appender.REST.syswrite=true
    log4perl.appender.REST.recreate=true
    log4perl.appender.REST.mode=append
    log4perl.appender.REST.layout=PatternLayout
    log4perl.appender.REST.layout.ConversionPattern=[%d] [%p] %m %l %n

    log4perl.logger.rest.Mojolicious.Plugin.OpenAPI = WARN, REST
    log4perl.appender.REST=Log::Log4perl::Appender::File
    log4perl.appender.REST.filename=__LOG_DIR__/rest.log
    log4perl.appender.REST.create_at_logtime=true
    log4perl.appender.REST.syswrite=true
    log4perl.appender.REST.recreate=true
    log4perl.appender.REST.mode=append
    log4perl.appender.REST.layout=PatternLayout
    log4perl.appender.REST.layout.ConversionPattern=[%d] [%p] %m %l %n

=head1 DESCRIPTION

    Use Log4perl on Mojolicious with the help of MojoX::Log::Log4perl.
=cut

use Modern::Perl;

use base 'MojoX::Log::Log4perl';

sub get {
    my ($class, $params) = @_;

    my $self;
    if ($ENV{'LOG4PERL_CONF'} and -s $ENV{"LOG4PERL_CONF"}) {
        $self = MojoX::Log::Log4perl->new($ENV{"LOG4PERL_CONF"});
    } elsif (C4::Context->config("log4perl_conf")) {
        $self = MojoX::Log::Log4perl->new(C4::Context->config("log4perl_conf"));
    } else {
        $self = MojoX::Log::Log4perl->new;
    }
    my $interface = $params ? $params->{interface}
                            ? $params->{interface} : C4::Context->interface
                            : C4::Context->interface;
    $self->{interface} = $interface;
    $self->{category} = $params->{category};

    bless $self, $class;
    return $self;
}

=head3 _get_logger

Overloads MojoX::Log::Log4perl::_get_logger by optionally including interface
and category.

For REST API, 'rest' should be the interface by default (defined in startup)

=cut

sub _get_logger {
    my ($self, $depth) = @_;

    my $category = $self->{category} ? $self->{category}
                                     : scalar caller( $depth || 1 );
    my $l4pcat  = $self->{interface} ? $self->{interface}.'.' : '';
       $l4pcat .= $category if $category;

    return Log::Log4perl->get_logger($l4pcat);
}

1;
