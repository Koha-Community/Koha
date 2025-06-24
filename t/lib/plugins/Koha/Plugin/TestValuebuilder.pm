package Koha::Plugin::TestValuebuilder;

## It's good practice to use Modern::Perl
use Modern::Perl;

## Required for all plugins
use base qw(Koha::Plugins::Base);

our $VERSION  = "v1.01";
our $metadata = {
    name             => 'Test Valuebuilder Plugin',
    author           => 'Koha Development Team',
    description      => 'Test plugin for valuebuilder functionality',
    date_authored    => '2025-01-01',
    date_updated     => '2025-01-01',
    minimum_version  => '3.11',
    maximum_version  => undef,
    version          => $VERSION,
    namespace        => 'test_valuebuilder',
    valuebuilder_tag => 'valuebuilder_test',
};

## This is the minimum code required for a plugin's 'new' method
## More can be added, but none should be removed
sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

## This method returns the name of the valuebuilder this plugin provides
sub get_valuebuilder {
    my $self = shift;
    return 'test_plugin_valuebuilder.pl';
}

## This method provides the builder code (JavaScript) for the valuebuilder
sub builder_code {
    my ( $self, $params ) = @_;

    my $id = $params->{id} || 'default_id';

    return qq{
        <script>
        function test_focus_$id() {
            var field = document.getElementById('$id');
            if (field && field.value === '') {
                field.value = 'Plugin Generated Value';
            }
        }

        function test_click_$id() {
            window.open('/cgi-bin/koha/plugins/run.pl?class=Koha::Plugin::TestValuebuilder&method=launcher&id=$id',
                       'valuebuilder',
                       'width=500,height=400,toolbar=false,scrollbars=yes');
        }
        </script>
    };
}

## This method provides the launcher (popup) functionality for the valuebuilder
sub launcher {
    my ( $self, $params ) = @_;

    my $input = $self->{cgi};
    my $id    = $input->param('id') || 'default_id';

    my $template = $self->get_template( { file => 'test_valuebuilder_popup.tt' } );

    $template->param(
        field_id    => $id,
        plugin_name => 'Test Valuebuilder Plugin',
    );

    print $input->header();
    print $template->output();
}

1;
