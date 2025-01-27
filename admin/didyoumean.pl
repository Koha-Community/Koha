#!/usr/bin/perl

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::SuggestionEngine;
use Module::Load::Conditional qw( can_load );
use JSON                      qw( from_json );

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/didyoumean.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_didyoumean' },
    }
);

my $opacplugins = from_json( C4::Context->preference('OPACdidyoumean') || '[]' );

my @pluginlist = Koha::SuggestionEngine::AvailablePlugins();
foreach my $plugin (@pluginlist) {
    next if $plugin eq 'Koha::SuggestionEngine::Plugin::Null';
    next                                          unless ( can_load( modules => { "$plugin" => undef } ) );
    push @$opacplugins, { name => $plugin->NAME } unless grep { $_->{name} eq $plugin->NAME } @$opacplugins;
}
$template->{VARS}->{OPACpluginlist} = $opacplugins;

output_html_with_http_headers $input, $cookie, $template->output;
