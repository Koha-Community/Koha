#!/usr/bin/perl

use Modern::Perl;
use CGI;
use Template;

use Test::More tests => 1;
use Test::MockModule;

#use Test::NoWarnings;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Form::MessagingPreferences;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'restore_form_values' => sub {

    plan tests => 2;

    my $cgi             = CGI->new;
    my $template_module = Test::MockModule->new('Template');
    my $vars            = {};
    $template_module->mock( 'param', sub { my ( $self, $key, $val ) = @_; $vars->{$key} = $val; } );
    my $template = Template->new( ENCODING => 'UTF-8' );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_preference( 'EnhancedMessagingPreferences', 1 );

    C4::Form::MessagingPreferences::set_form_values( { borrowernumber => $patron->id }, $template );
    my $set_form_values_vars = {%$vars};
    $vars = {};

    C4::Form::MessagingPreferences::restore_form_values( $cgi, $template );
    my $restore_form_values_vars = {%$vars};

    is_deeply(
        $set_form_values_vars, $restore_form_values_vars,
        "Default messaging preferences don't change when handled with restore_form_values."
    );

    C4::Members::Messaging::SetMessagingPreference(
        {
            borrowernumber          => $patron->id,
            message_transport_types => ['email'],
            message_attribute_id    => 2,
            days_in_advance         => 10,
            wants_digest            => 1
        }
    );

    C4::Form::MessagingPreferences::set_form_values( { borrowernumber => $patron->id }, $template );
    $set_form_values_vars = {%$vars};
    $vars                 = {};

    $cgi->param( -name => '2',      -value => 'email' );
    $cgi->param( -name => '2-DAYS', -value => '10' );
    $cgi->param( -name => 'digest', -value => '2' );

    C4::Form::MessagingPreferences::restore_form_values( $cgi, $template );
    $restore_form_values_vars = {%$vars};

    is_deeply(
        $set_form_values_vars, $restore_form_values_vars,
        "Patrons messaging preferences don't change when handled with restore_form_values."
    );

    $schema->storage->txn_rollback;
};
