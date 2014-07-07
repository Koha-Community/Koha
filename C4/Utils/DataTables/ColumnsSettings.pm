package C4::Utils::DataTables::ColumnsSettings;

use Modern::Perl;
use List::Util qw( first );
use YAML;
use C4::Context;
use Koha::Database;

sub get_yaml {
    my $yml_path =
      C4::Context->config('intranetdir') . '/admin/columns_settings.yml';
    my $yaml = eval { YAML::LoadFile($yml_path) };
    warn
"ERROR: the yaml file for DT::ColumnsSettings is not correctly formated: $@"
      if $@;
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

    return $list->{modules}{$module}{$page}{$tablename} || [];
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

        my $column = $schema->resultset('ColumnsSetting')->search(
            {
                module     => $c->{module},
                page       => $c->{page},
                tablename  => $c->{tablename},
                columnname => $c->{columnname},
            }
        );
        if ( $column->count ) {
            $column = $column->first;
            $column->update(
                {
                    module            => $c->{module},
                    page              => $c->{page},
                    tablename         => $c->{tablename},
                    columnname        => $c->{columnname},
                    is_hidden         => $c->{is_hidden},
                    cannot_be_toggled => $c->{cannot_be_toggled},
                }
            );
        }
        else {
            $schema->resultset('ColumnsSetting')->create(
                {
                    module            => $c->{module},
                    page              => $c->{page},
                    tablename         => $c->{tablename},
                    columnname        => $c->{columnname},
                    is_hidden         => $c->{is_hidden},
                    cannot_be_toggled => $c->{cannot_be_toggled},
                }
            );
        }
    }
}

1;
