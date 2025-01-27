use Modern::Perl;

return {
    bug_number  => "15788",
    description => "Split edit_borrowers permission",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        $dbh->do(
            q{
            INSERT IGNORE permissions (module_bit, code, description)
            VALUES
            (4, 'delete_borrowers', 'Delete borrowers')
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
            SELECT borrowernumber, 4, 'delete_borrowers' FROM user_permissions WHERE code = 'edit_borrowers'
        }
        );
    },
    }
