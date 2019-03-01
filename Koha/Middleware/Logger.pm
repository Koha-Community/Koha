package Koha::Middleware::Logger;

# Copyright 2019 The National Library of Finland
# Copyright 2018 Koha-Suomi Oy
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

use Modern::Perl;

use parent qw(Plack::Middleware);
use Plack::Util::Accessor qw(logger);

use Koha::Logger;

=head1 NAME

Koha::Middleware::Logger - Plack Middleware to enable Koha::Logger

=head1 SYNOPSIS

  builder {
      ...
      enable "+Koha::Middleware::Logger";   # Use Koha::Logger at psgix.logger.
      enable "LogWarn";
      enable "LogErrors";
      ...
  }

=cut

our $logger = Koha::Logger->get(); # package logger must be globally available so it can be re-interfaced when the interface changes.

sub call {
    my ($self, $env) = @_;

    die "Cannot determine the used interface from \$env->{PATH_INFO} '".$env->{PATH_INFO}."'" unless ($env->{PATH_INFO} =~ m!^/(\w+)[/\-]!);
    my $interface = ($1 eq 'intranet') ? $1 :
                    ($1 eq 'opac')     ? $1 :
                    ($1 eq 'api')      ? 'rest'
                                       : '';
    $logger->error("Unable to find the correct interface from Plack \$env->{PATH_INFO}='".$env->{PATH_INFO}."'. Using the root logger.") unless $interface;


    C4::Context->interface($interface);
    $self->logger($logger);

    $env->{'psgix.logger'} = sub {
        my $args = shift;
        my $level = $args->{level};
        $self->logger->$level($args->{message});
    };

    $self->app->($env);
}

=head1 AUTHOR

Lari Taskula, E<lt>lari.taskula@joensuu.fiE<gt>

=cut

1;
