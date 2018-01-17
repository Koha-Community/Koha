#!/usr/bin/perl

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth;
use C4::Output;
use Koha::SuggestionEngine;
use Module::Load::Conditional qw(can_load);
use JSON;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/didyoumean.tt",
            query => $input,
            type => "intranet",
            authnotrequired => 0,
            flagsrequired => {parameters => 'parameters_remaining_permissions'},
            debug => 1,
            });

my $opacplugins = from_json(C4::Context->preference('OPACdidyoumean') || '[]');

my $intraplugins = from_json(C4::Context->preference('INTRAdidyoumean') || '[]');

my @pluginlist = Koha::SuggestionEngine::AvailablePlugins();
foreach my $plugin (@pluginlist) {
    next if $plugin eq 'Koha::SuggestionEngine::Plugin::Null';
    next unless (can_load( modules => { "$plugin" => undef } ));
    push @$opacplugins, { name => $plugin->NAME } unless grep { $_->{name} eq $plugin->NAME } @$opacplugins;
    push @$intraplugins, { name => $plugin->NAME } unless grep { $_->{name} eq $plugin->NAME } @$intraplugins;
}
$template->{VARS}->{OPACpluginlist} = $opacplugins;
$template->{VARS}->{INTRApluginlist} = $intraplugins;
output_html_with_http_headers $input, $cookie, $template->output;
