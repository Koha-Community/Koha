#!/usr/bin/perl

use Modern::Perl;
use CGI;
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Utils::DataTables::TablesSettings qw( get_modules );
my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/columns_settings.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_column_config' },
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

    C4::Utils::DataTables::TablesSettings::update_columns(
        {
            columns => \@columns,
        }
    );

    my @table_ids = $input->multi_param('table_id');
    for my $table_id (@table_ids) {
        next unless $table_id =~ m|^([^#]*)#(.*)$|;
        my $default_display_length = $input->param( $table_id . '_default_display_length' );
        my $default_sort_order     = $input->param( $table_id . '_default_sort_order' );

        undef $default_display_length if defined $default_display_length && $default_display_length eq "";
        undef $default_sort_order if defined $default_sort_order && $default_sort_order eq "";

        if ( defined $default_display_length || defined $default_sort_order )
        {
            C4::Utils::DataTables::TablesSettings::update_table_settings(
                {
                    module                 => $module,
                    page                   => $1,
                    tablename              => $2,
                    default_display_length => $default_display_length,
                    default_sort_order     => $default_sort_order,
                }
            );
        }
    }

    $action = 'list';
}

if ( $action eq 'list' ) {
    my $modules = C4::Utils::DataTables::TablesSettings::get_modules;
    $template->param(
        panel   => defined $input->param('module') ? $input->param('module') : undef,
        page    => defined $input->param('page') ? $input->param('page') : undef,
        table   => defined $input->param('table') ? $input->param('table') : undef,
        modules => $modules,
    );
}

output_html_with_http_headers $input, $cookie, $template->output;
