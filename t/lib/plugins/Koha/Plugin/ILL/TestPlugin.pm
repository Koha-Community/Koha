package Koha::Plugin::ILL::TestPlugin;

use Modern::Perl;

use base            qw(Koha::Plugins::Base);
use Koha::DateUtils qw( dt_from_string );

use File::Basename qw( dirname );
use C4::Installer;
use Cwd qw(abs_path);
use CGI;
use JSON qw( encode_json decode_json );

use JSON           qw( to_json from_json );
use File::Basename qw( dirname );

use Koha::Libraries;
use Koha::Patrons;

our $VERSION = "2.0.4";

our $metadata = {
    name            => 'TestPlugin',
    author          => 'PTFS-Europe',
    date_authored   => '2023-10-30',
    date_updated    => '2024-03-28',
    minimum_version => '24.05.00.000',
    maximum_version => undef,
    version         => $VERSION,
    description     => 'This plugin is an ILL backend plugin example'
};

=head1 METHODS

=head2 new

    Constructor

=cut

sub new {
    my ( $class, $args ) = @_;

    $args->{'metadata'} = $metadata;
    $args->{'_logger'}  = $args->{logger};
    $args->{'_config'}  = $args->{config};
    $args->{'_plugin'}  = $class;

    my $self = $class->SUPER::new($args);
    return $self;
}

=head2 capabilities

    Returns a subroutine reference for the given capability name.
    Returns undef if the capability is not implemented.

    $name - The name of the capability to retrieve.

=cut

sub capabilities {
    my ( $self, $name ) = @_;
    my $capabilities = {
        opac_unauthenticated_ill_requests => sub { return 0; }
    };

    return $capabilities->{$name};
}

1;
