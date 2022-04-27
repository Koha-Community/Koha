package C4::Utils::DataTables::TablesSettings;

use Modern::Perl;
use List::Util qw( first );
use YAML::XS;
use C4::Context;
use Koha::Database;
use Koha::Caches;

=head1 NAME

C4::Utils::DataTables::TablesSettings - Koha DataTables Settings

=head1 API

=head2 Methods

=cut

sub get_yaml {
    my $yml_path = C4::Context->config('intranetdir') . '/admin/columns_settings.yml';
    my $cache = Koha::Caches->get_instance();
    my $yaml  = $cache->get_from_cache('TablesSettingsYaml');

    unless ($yaml) {
        $yaml = eval { YAML::XS::LoadFile($yml_path) };
        warn "ERROR: the yaml file for DT::TablesSettings is not correctly formatted: $@"
          if $@;
        $cache->set_in_cache( 'TablesSettingsYaml', $yaml, { expiry => 3600 } );
    }

    return $yaml;
}

sub get_columns {
    my ( $module, $page, $tablename ) = @_;

    my $list = get_yaml;

    my $schema = Koha::Database->new->schema;

    my $rs = $schema->resultset('ColumnsSetting')->search(
        {
            module    => $module,
            page      => $page,
            tablename => $tablename,
        }
    );

    while ( my $c = $rs->next ) {
        my $column = first { $c->columnname eq $_->{columnname} }
        @{ $list->{modules}{ $c->module }{ $c->page }{ $c->tablename }{ columns } };
        $column->{is_hidden}         = $c->is_hidden;
        $column->{cannot_be_toggled} = $c->cannot_be_toggled;
    }

    my $columns = $list->{modules}{$module}{$page}{$tablename}{columns} || [];

    # Assign default value if does not exist
    $columns = [ map {
        {
            cannot_be_toggled => exists $_->{cannot_be_toggled} ? $_->{cannot_be_toggled} : 0,
            cannot_be_modified => exists $_->{cannot_be_modified} ? $_->{cannot_be_modified} : 0,
            is_hidden => exists $_->{is_hidden} ? $_->{is_hidden} : 0,
            columnname => $_->{columnname},
        }
    } @$columns ];

    return $columns;
}

=head3 get_table_settings

  my $settings = C4::Utils::DataTables::TablesSettings::get_table_settings(
    {
        module                 => $module,
        pag                    => $page,
        tablename              => $tablename,
    }
  );

Returns the settings for a given table.

The settings are default_display_length and default_sort_order.

=cut

sub get_table_settings {
    my ( $module, $page, $tablename ) = @_;
    my $list = get_yaml;

    my $schema = Koha::Database->new->schema;

    my $rs = $schema->resultset('TablesSetting')->search(
        {
            module    => $module,
            page      => $page,
            tablename => $tablename,
        }
    )->next;

    return {
        default_display_length => $rs ? $rs->default_display_length
        : $list->{modules}{$module}{$page}{$tablename}{default_display_length},
        default_sort_order => $rs ? $rs->default_sort_order
        : $list->{modules}{$module}{$page}{$tablename}{default_sort_order}
    };
}

sub get_modules {
    my $list = get_yaml;

    my $schema = Koha::Database->new->schema;
    my $rs     = $schema->resultset('ColumnsSetting')->search;

    while ( my $c = $rs->next ) {
        my $column = first { $c->columnname eq $_->{columnname} }
        @{ $list->{modules}{ $c->module }{ $c->page }{ $c->tablename }{columns} };
        $column->{is_hidden}         = $c->is_hidden;
        $column->{cannot_be_toggled} = $c->cannot_be_toggled;
        $column->{cannot_be_modified} = 0
            unless exists $column->{cannot_be_modified};
    }

    return $list->{modules};
}

sub update_columns {
    my ($params) = @_;
    my $columns = $params->{columns};

    my $schema = Koha::Database->new->schema;

    for my $c (@$columns) {
        $c->{is_hidden}         //= 0;
        $c->{cannot_be_toggled} //= 0;

        $schema->resultset('ColumnsSetting')->update_or_create(
            {
                module     => $c->{module},
                page       => $c->{page},
                tablename  => $c->{tablename},
                columnname => $c->{columnname},
                is_hidden         => $c->{is_hidden},
                cannot_be_toggled => $c->{cannot_be_toggled},
            }
        );
    }
}

=head3 update_table_settings

  C4::Utils::DataTables::TablesSettings::update_table_settings(
    {
        module                 => $module,
        pag                    => $page,
        tablename              => $tablename,
        default_display_length => $default_display_length,
        default_sort_order     => $default_sort_order
    }
  );

Will update the default_display_length and default_sort_order for the given table.

=cut

sub update_table_settings {
    my ($params)               = @_;
    my $module                 = $params->{module};
    my $page                   = $params->{page};
    my $tablename              = $params->{tablename};
    my $default_display_length = $params->{default_display_length};
    my $default_sort_order     = $params->{default_sort_order};

    my $schema = Koha::Database->new->schema;

    $schema->resultset('TablesSetting')->update_or_create(
        {
            module                 => $module,
            page                   => $page,
            tablename              => $tablename,
            default_display_length => $default_display_length,
            default_sort_order     => $default_sort_order,
        }
    );
}

1;
