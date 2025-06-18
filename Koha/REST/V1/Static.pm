package Koha::REST::V1::Static;

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

use Mojo::Base 'Mojolicious::Controller';

use Try::Tiny qw( catch try );

=head1 API

=head2 Class methods

=head3 get

Method that gets file contents

=cut

sub get {
    my $self = shift;
    my $c    = $self->openapi->valid_input or return;

    if ( C4::Context->config("enable_plugins") ) {
        my $path = $c->req->url->path->leading_slash(1);

        return $c->render( status => 400, openapi => { error => 'Endpoint intended for plugin static files' } )
            unless "$path" =~ /^\/api\/v1\/contrib/;

        my $namespace = $path->[3];

        my $checkpath = '/api/v1/contrib/' . $namespace . '/static';

        return $c->render( status => 400, openapi => { error => 'Endpoint intended for plugin static files' } )
            unless "$path" =~ /\Q$checkpath/;

        my @plugins = Koha::Plugins->new()->GetPlugins(
            {
                method => 'api_namespace',
            }
        );

        @plugins = grep { $_->api_namespace eq $namespace } @plugins;

        return $c->render_resource_not_found("File") unless scalar(@plugins) > 0;
        return $c->render( { status => 500, openapi => { error => 'Namespace not unique' } } )
            unless scalar(@plugins) == 1;

        my $plugin = $plugins[0];

        my $basepath = $plugin->bundle_path;

        my $relpath = join( '/', splice( @$path, 5 ) );

        return try {
            my $asset = Mojo::Asset::File->new( path => join( '/', $basepath, $relpath ) );
            return $c->render( { status => 404, openapi => { error => 'File not found' } } ) unless $asset->is_file;
            return $c->reply->asset($asset);
        } catch {
            return $c->render_resource_not_found("File");
        }

    } else {
        $c->render( { status => 500, openapi => { error => 'Plugins are not enabled' } } );
    }

}

1;
