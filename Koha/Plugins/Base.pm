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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Cwd        qw( abs_path );
use List::Util qw( max );
use Try::Tiny;

use base qw{Module::Bundled::Files};

use C4::Context;
use C4::Output qw( output_with_http_headers );

use Koha::Exceptions::Plugin;
use Koha::Cache::Memory::Lite;

=head1 NAME

Koha::Plugins::Base - Base Module for plugins

=cut

=head2 new

Missing POD for new.

=cut

sub new {
    my ( $class, $args ) = @_;

    return unless ( C4::Context->config("enable_plugins") || $args->{'enable_plugins'} );

    $args->{'class'}    = $class;
    $args->{'template'} = Template->new( { ABSOLUTE => 1, ENCODING => 'UTF-8' } );

    my $self = bless( $args, $class );

    my $plugin_version   = $self->get_metadata->{version};
    my $database_version = $self->retrieve_data('__INSTALLED_VERSION__') || 0;

    ## Run the installation method if it exists and hasn't been run before
    if ( $self->can('install') && !$self->retrieve_data('__INSTALLED__') ) {
        try {
            if ( $self->install() ) {
                $self->store_data( { '__INSTALLED__' => 1, '__ENABLED__' => 1 } );
                if ( my $version = $plugin_version ) {
                    $self->store_data( { '__INSTALLED_VERSION__' => $version } );
                }
            } else {
                warn "Plugin $class failed during installation!";
            }
        } catch {
            Koha::Exceptions::Plugin::InstallDied->throw( plugin_class => $class, install_error => "$_" );
        };
    } elsif ( $self->can('upgrade') ) {
        if ( _version_compare( $plugin_version, $database_version ) == 1 ) {
            try {
                if ( $self->upgrade() ) {
                    $self->store_data( { '__INSTALLED_VERSION__' => $plugin_version } );
                } else {
                    warn "Plugin $class failed during upgrade!";
                }
            } catch {
                Koha::Exceptions::Plugin::UpgradeDied->throw( plugin_class => $class, upgrade_error => "$_" );
            };
        }
    } elsif ( $plugin_version ne $database_version ) {
        $self->store_data( { '__INSTALLED_VERSION__' => $plugin_version } );
    }

    $self->{_bundle_path} = abs_path( $self->mbf_dir );

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

    if ( exists $data->{__ENABLED__} ) {
        Koha::Cache::Memory::Lite->clear_from_cache( Koha::Plugins->ENABLED_PLUGINS_CACHE_KEY );
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

The returned template contains 3 variables that can be used in the plugin
templates:

=over 8

=item B<CLASS>

The name of the plugin class.

=item B<METHOD>

Then name of the plugin method used. For example 'tool' or 'report'.

=item B<PLUGIN_PATH>

The URL path to the plugin. It can be used in templates in order to localize
resources like images in html tags, or other templates.

=item B<PLUGIN_DIR>

The absolute pathname to the plugin directory. Necessary to include other
templates from a template with the [% INCLUDE %] directive.

=back


=cut

sub get_template {
    my ( $self, $args ) = @_;

    require C4::Auth;

    my $template_name = $args->{'file'} // '';

    # if not absolute, call mbf_path, which dies if file does not exist
    $template_name = $self->mbf_path($template_name)
        if $template_name !~ m/^\//;
    my ( $template, $loggedinuser, $cookie ) = C4::Auth::get_template_and_user(
        {
            template_name   => $template_name,
            query           => $self->{'cgi'},
            type            => "intranet",
            authnotrequired => 1,
        }
    );
    $template->param(
        CLASS       => $self->{'class'},
        METHOD      => scalar $self->{'cgi'}->param('method'),
        PLUGIN_PATH => $self->get_plugin_http_path(),
        PLUGIN_DIR  => $self->bundle_path(),
        LANG        => C4::Languages::getlanguage( $self->{'cgi'} ),
    );

    return $template;
}

=head2 get_metadata

Missing POD for get_metadata.

=cut

sub get_metadata {
    my ( $self, $args ) = @_;

    #FIXME: Why another encoding issue? For metadata containing non latin characters.
    my $metadata = $self->{metadata};
    defined( $metadata->{$_} ) && utf8::decode( $metadata->{$_} ) for keys %$metadata;
    return $metadata;
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

=head2 output_html

    $self->output_html( $data, $status, $extra_options );

Outputs $data setting the right headers for HTML content.

Note: this is a wrapper function for C4::Output::output_with_http_headers

=cut

sub output_html {
    my ( $self, $data, $status, $extra_options, $cookie ) = @_;
    output_with_http_headers( $self->{cgi}, $cookie, $data, 'html', $status, $extra_options );
}

=head2 bundle_path

    my $bundle_path = $self->bundle_path

Returns the directory in which bundled files are.

=cut

sub bundle_path {
    my ($self) = @_;

    return $self->{_bundle_path};
}

=head2 output

   $self->output( $data, $content_type[, $status[, $extra_options]]);

Outputs $data with the appropriate HTTP headers,
the authentication cookie and a Content-Type specified in
$content_type.

$content_type is one of the following: 'html', 'js', 'json', 'xml', 'rss', or 'atom'.

$status is an HTTP status message, like '403 Authentication Required'. It defaults to '200 OK'.

$extra_options is hashref.  If the key 'force_no_caching' is present and has
a true value, the HTTP headers include directives to force there to be no
caching whatsoever.

Note: this is a wrapper function for C4::Output::output_with_http_headers

=cut

sub output {
    my ( $self, $data, $content_type, $status, $extra_options ) = @_;
    output_with_http_headers( $self->{cgi}, undef, $data, $content_type, $status, $extra_options );
}

=head2 _version_compare

Utility method to compare two version numbers.
Returns 1 if the first argument is the higher version
Returns -1 if the first argument is the lower version
Returns 0 if both versions are equal

if ( _version_compare( '2.6.26', '2.6.0' ) == 1 ) {
    print "2.6.26 is greater than 2.6.0\n";
}

=cut

sub _version_compare {
    my @args = @_;

    if ( $args[0]->isa('Koha::Plugins::Base') ) {
        shift @args;
    }

    my $ver1 = shift @args || 0;
    my $ver2 = shift @args || 0;

    my @v1 = split /[.+:~-]/, $ver1;
    my @v2 = split /[.+:~-]/, $ver2;

    for ( my $i = 0 ; $i < max( scalar(@v1), scalar(@v2) ) ; $i++ ) {

        # Add missing version parts if one string is shorter than the other
        # i.e. 0 should be lt 0.2.1 and not equal, so we append .0
        # 0.0.0 <=> 0.2.1 = -1
        push( @v1, 0 ) unless defined( $v1[$i] );
        push( @v2, 0 ) unless defined( $v2[$i] );

        # Strip letters before comparing, suppresses 'Argument "v1" isn't numeric in int' warning
        $v1[$i] =~ s/^v//g;
        $v2[$i] =~ s/^v//g;

        if ( int( $v1[$i] ) > int( $v2[$i] ) ) {
            return 1;
        } elsif ( int( $v1[$i] ) < int( $v2[$i] ) ) {
            return -1;
        }
    }
    return 0;
}

=head2 is_enabled

Method that returns whether the plugin is enabled or not

$plugin->enable

=cut

sub is_enabled {
    my ($self) = @_;

    return $self->retrieve_data('__ENABLED__');
}

=head2 enable

Method for enabling plugin

$plugin->enable

=cut

sub enable {
    my ($self) = @_;

    $self->store_data( { '__ENABLED__' => 1 } );

    return $self;
}

=head2 disable

Method for disabling plugin

$plugin->disable

=cut

sub disable {
    my ($self) = @_;

    $self->store_data( { '__ENABLED__' => 0 } );

    return $self;
}

1;
__END__

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
