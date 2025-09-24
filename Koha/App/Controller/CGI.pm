package Koha::App::Controller::CGI;

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

use Mojo::Base 'Mojolicious::Controller';

use CGI::Compile;
use CGI::Emulate::PSGI;
use CGI;

=head1 NAME

Koha::App::Controller::CGI - Mojolicious controller for all CGI scripts

=cut

# CGI::Compile calls CGI::initialize_globals before each request, which resets PARAM_UTF8 to 0
# We need to set it back to the correct value
{
    no warnings 'redefine';
    my $old_new = \&CGI::new;
    *CGI::new = sub {
        $CGI::PARAM_UTF8 = 1;
        return $old_new->(@_);
    };
}

=head1 METHODS

=head2 intranet

Controller action that routes the request to the corresponding intranet CGI script

=cut

sub intranet {
    my ($c) = @_;

    my $script = $c->stash('script');

    # Special case for installer which can take a long time
    $c->inactivity_timeout(300) if $script eq 'installer/install.pl';

    $c->_render_script($script);
}

=head2 opac

Controller action that routes the request to the corresponding OPAC CGI script

=cut

sub opac {
    my ($c) = @_;

    my $script = $c->stash('script');
    $script = "opac/$script";

    $c->_render_script($script);
}

sub _render_script {
    my ( $c, $script ) = @_;

    # Remove trailing slash, if any (e.g. .../svc/config/systempreferences/)
    $script =~ s|/$||;

    unless ( -e $c->app->home->rel_file($script) ) {
        return $c->reply->not_found;
    }

    my $sub      = CGI::Compile->compile($script);
    my $app      = CGI::Emulate::PSGI->handler($sub);
    my $response = $app->( $c->_psgi_env() );

    $c->res->code( $response->[0] );
    $c->res->headers->from_hash( { @{ $response->[1] } } );
    $c->res->body( join( '', @{ $response->[2] } ) );
    $c->rendered;
}

sub _psgi_env {
    my ($c) = @_;

    my $env = $c->req->env;

    my $body = $c->req->build_body;
    open my $input, '<', \$body or die "Can't open in-memory scalar: $!";
    $env = {
        %$env,
        'psgi.input'    => $input,
        'psgi.errors'   => *STDERR,
        REQUEST_METHOD  => $c->req->method,
        QUERY_STRING    => $c->req->url->query->to_string,
        SERVER_NAME     => $c->req->url->to_abs->host,
        SERVER_PORT     => $c->req->url->to_abs->port,
        SERVER_PROTOCOL => 'HTTP/1.1',
        CONTENT_LENGTH  => $c->req->headers->content_length,
        CONTENT_TYPE    => $c->req->headers->content_type,
        REMOTE_ADDR     => $c->tx->remote_address,
        SCRIPT_NAME     => $c->req->url->path->to_string,
    };

    # Starman sets PATH_INFO to the same value of SCRIPT_NAME, which confuses
    # CGI and causes the redirect after OPAC login to fail
    delete $env->{PATH_INFO} if ( $env->{PATH_INFO} && $env->{PATH_INFO} eq $env->{SCRIPT_NAME} );

    for my $name ( @{ $c->req->headers->names } ) {
        my $value = $c->req->headers->header($name);
        $name =~ s/-/_/g;
        $name = 'HTTP_' . uc($name);
        $env->{$name} = $value;
    }

    return $env;
}

1;
