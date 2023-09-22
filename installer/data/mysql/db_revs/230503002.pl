use Modern::Perl;

return {
    bug_number  => "34844",
    description => "Add permission manage_item_editor_templates",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE permissions (module_bit, code, description) VALUES
            ( 9, 'manage_item_editor_templates', 'Update and delete item editor template owned by others')
        }
        );

        say $out "Added new permission 'manage_item_editor_templates'";
    },
    }
