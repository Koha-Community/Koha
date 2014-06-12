package Koha::Plugins::Handler;

# Copyright 2012 Kyle Hall
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

use File::Path qw(remove_tree);

use Module::Load::Conditional qw(can_load);

use C4::Context;

BEGIN {
    push @INC, C4::Context->config("pluginsdir");
}

=head1 NAME

C4::Plugins::Handler - Handler Module for running plugins

=head1 SYNOPSIS

  Koha::Plugins::Handler->run({ class => $class, method => $method, cgi => $cgi });
  $p->run();

=over 2

=cut

=item run

Runs a plugin

=cut

sub run {
    my ( $class, $args ) = @_;

    return unless ( C4::Context->config("enable_plugins") || $args->{'enable_plugins'} );

    my $plugin_class  = $args->{'class'};
    my $plugin_method = $args->{'method'};
    my $cgi           = $args->{'cgi'};
    my $params        = $args->{'params'};

    if ( can_load( modules => { $plugin_class => undef } ) ) {
        my $plugin = $plugin_class->new( { cgi => $cgi, enable_plugins => $args->{'enable_plugins'} } );
        if ( $plugin->can($plugin_method) ) {
            return $plugin->$plugin_method( $params );
        } else {
            warn "Plugin does not have method $plugin_method";
        }
    } else {
        warn "Plugin $plugin_class cannot be loaded";
    }
}

=item delete

Deletes a plugin

=cut

sub delete {
    my ( $class, $args ) = @_;
    my $plugin_class = $args->{'class'};
    my $plugin_dir   = C4::Context->config("pluginsdir");
    my $plugin_path  = "$plugin_dir/" . join( '/', split( '::', $args->{'class'} ) );

    Koha::Plugins::Handler->run( { class => $plugin_class, method => 'uninstall' } );

    C4::Context->dbh->do( "DELETE FROM plugin_data WHERE plugin_class = ?", undef, ($plugin_class) );

    unlink("$plugin_path.pm");
    remove_tree($plugin_path);
}

1;
__END__

=back

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
