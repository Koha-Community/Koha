package Koha::Plugins::Base;

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

use Module::Pluggable require => 1;
use Cwd qw(abs_path);

use base qw{Module::Bundled::Files};

use C4::Context;

=head1 NAME

C4::Plugins::Base - Base Module for plugins

=cut

sub new {
    my ( $class, $args ) = @_;

    return unless ( C4::Context->config("enable_plugins") || $args->{'enable_plugins'} );

    $args->{'class'} = $class;
    $args->{'template'} = Template->new( { ABSOLUTE => 1 } );

    my $self = bless( $args, $class );

    ## Run the installation method if it exists and hasn't been run before
    if ( $self->can('install') && !$self->retrieve_data('__INSTALLED__') ) {
        if ( $self->install() ) {
            $self->store_data( { '__INSTALLED__' => 1 } );
        } else {
            warn "Plugin $class failed during installation!";
        }
    }

    return $self;
}

=head2 store_data

store_data allows a plugin to store key value pairs in the database for future use.

usage: $self->store_data({ param1 => 'param1val', param2 => 'param2value' })

=cut

sub store_data {
    my ( $self, $data ) = @_;

    my $dbh = C4::Context->dbh;
    my $sql = "REPLACE INTO plugin_data SET plugin_class = ?, plugin_key = ?, plugin_value = ?";
    my $sth = $dbh->prepare($sql);

    foreach my $key ( keys %$data ) {
        $sth->execute( $self->{'class'}, $key, $data->{$key} );
    }
}

=head2 retrieve_data

retrieve_data allows a plugin to read the values that were previously saved with store_data

usage: my $value = $self->retrieve_data( $key );

=cut

sub retrieve_data {
    my ( $self, $key ) = @_;

    my $dbh = C4::Context->dbh;
    my $sql = "SELECT plugin_value FROM plugin_data WHERE plugin_class = ? AND plugin_key = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute( $self->{'class'}, $key );
    my $row = $sth->fetchrow_hashref();

    return $row->{'plugin_value'};
}

=head2 get_template

get_template returns a Template object. Eventually this will probably be calling
C4:Template, but at the moment, it does not.

=cut

sub get_template {
    my ( $self, $args ) = @_;

    require C4::Auth;

    my ( $template, $loggedinuser, $cookie ) = C4::Auth::get_template_and_user(
        {   template_name   => abs_path( $self->mbf_path( $args->{'file'} ) ),
            query           => $self->{'cgi'},
            type            => "intranet",
            authnotrequired => 1,
            is_plugin       => 1,
        }
    );

    $template->param(
        CLASS       => $self->{'class'},
        METHOD      => $self->{'cgi'}->param('method'),
        PLUGIN_PATH => $self->get_plugin_http_path(),
    );

    return $template;
}

sub get_metadata {
    my ( $self, $args ) = @_;

    return $self->{'metadata'};
}

=head2 get_qualified_table_name

To avoid naming conflict, each plugins tables should use a fully qualified namespace.
To avoid hardcoding and make plugins more flexible, this method will return the proper
fully qualified table name.

usage: my $table = $self->get_qualified_table_name( 'myTable' );

=cut

sub get_qualified_table_name {
    my ( $self, $table_name ) = @_;

    return lc( join( '_', split( '::', $self->{'class'} ), $table_name ) );
}

=head2 get_plugin_http_path

To access a plugin's own resources ( images, js files, css files, etc... )
a plugin will need to know what path to use in the template files. This
method returns that path.

usage: my $path = $self->get_plugin_http_path();

=cut

sub get_plugin_http_path {
    my ($self) = @_;

    return "/plugin/" . join( '/', split( '::', $self->{'class'} ) );
}

=head2 go_home

   go_home is a quick redirect to the Koha plugins home page

=cut

sub go_home {
    my ( $self, $params ) = @_;

    print $self->{'cgi'}->redirect("/cgi-bin/koha/plugins/plugins-home.pl");
}

1;
__END__

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
