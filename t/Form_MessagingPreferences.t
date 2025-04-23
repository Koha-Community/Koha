#!/usr/bin/perl

use Modern::Perl;
use CGI;
use Template;

use Test::More tests => 1;
use Test::MockModule;
#use Test::NoWarnings;

use C4::Form::MessagingPreferences;

subtest 'restore_values' => sub {
    plan tests => 1;
    my $cgi = CGI->new;
    my $template_module = Test::MockModule->new( 'Template' );
    my $vars = {};
    $template_module->mock( 'param', sub { my ( $self, $key, $val ) = @_; $vars->{$key} = $val; } );
    my $template = Template->new( ENCODING => 'UTF-8' );

    C4::Form::MessagingPreferences::restore_form_values( $cgi, $template );
    require Data::Dumper; warn Data::Dumper::Dumper(  $vars ); #FIXME Remove debugging
    # TODO Add some checking on $vars->{messaging_preferences} here

    ok(1); # FIXME Replace
};
