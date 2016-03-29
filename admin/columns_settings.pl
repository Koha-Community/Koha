#!/usr/bin/perl

use Modern::Perl;
use CGI;
use YAML qw( LoadFile );
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Utils::DataTables::ColumnsSettings qw( get_modules );
my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/columns_settings.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

my $action = $input->param('action') // 'list';

if ( $action eq 'save' ) {
    my $module = $input->param('module');
    my @columnids = $input->multi_param("columnid");
    my @columns;
    for my $columnid (@columnids) {
        next unless $columnid =~ m|^([^#]*)#([^#]*)#(.*)$|;
        my $is_hidden = $input->param( $columnid . '_hidden' ) // 0;
        my $cannot_be_toggled =
          $input->param( $columnid . '_cannot_be_toggled' ) // 0;
        push @columns,
          {
            module            => $module,
            page              => $1,
            tablename         => $2,
            columnname        => $3,
            is_hidden         => $is_hidden,
            cannot_be_toggled => $cannot_be_toggled,
          };
    }

    C4::Utils::DataTables::ColumnsSettings::update_columns(
        {
            columns => \@columns,
        }
    );

    $action = 'list';
}

if ( $action eq 'list' ) {
    my $modules = C4::Utils::DataTables::ColumnsSettings::get_modules;
    $template->param(
        panel   => ( $input->param('panel') || 0 ),
        modules => $modules,
    );
}

output_html_with_http_headers $input, $cookie, $template->output;
