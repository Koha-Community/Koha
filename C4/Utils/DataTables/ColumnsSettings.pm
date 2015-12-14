package C4::Utils::DataTables::ColumnsSettings;

use Modern::Perl;
use List::Util qw( first );
use YAML;
use C4::Context;
use Koha::Database;
use Koha::Cache;

sub get_yaml {
    my $yml_path = C4::Context->config('intranetdir') . '/admin/columns_settings.yml';
    my $cache = Koha::Cache->get_instance();
    my $yaml  = $cache->get_from_cache('ColumnsSettingsYaml');

    unless ($yaml) {
        $yaml = eval { YAML::LoadFile($yml_path) };
        warn "ERROR: the yaml file for DT::ColumnsSettings is not correctly formated: $@"
          if $@;
        $cache->set_in_cache( 'ColumnsSettingsYaml', $yaml, { expiry => 3600 } );
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
        @{ $list->{modules}{ $c->module }{ $c->page }{ $c->tablename } };
        $column->{is_hidden}         = $c->is_hidden;
        $column->{cannot_be_toggled} = $c->cannot_be_toggled;
    }

    my $columns = $list->{modules}{$module}{$page}{$tablename} || [];

    # Assign default value if does not exist
    $columns = [ map {
        {
            cannot_be_toggled => exists $_->{cannot_be_toggled} ? $_->{cannot_be_toggled} : 0,
            is_hidden => exists $_->{is_hidden} ? $_->{is_hidden} : 0,
            columnname => $_->{columnname},
        }
    } @$columns ];

    return $columns;
}

sub get_modules {
    my $list = get_yaml;

    my $schema = Koha::Database->new->schema;
    my $rs     = $schema->resultset('ColumnsSetting')->search;

    while ( my $c = $rs->next ) {
        my $column = first { $c->columnname eq $_->{columnname} }
        @{ $list->{modules}{ $c->module }{ $c->page }{ $c->tablename } };
        $column->{is_hidden}         = $c->is_hidden;
        $column->{cannot_be_toggled} = $c->cannot_be_toggled;
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

1;
