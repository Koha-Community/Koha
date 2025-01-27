use Modern::Perl;

return {
    bug_number  => "20310",
    description => "Add new system preference ArticleRequestsOpacHostRedirection",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
                ('ArticleRequestsOpacHostRedirection', '0', NULL, 'Enables redirection from child to host when requesting article on OPAC', 'YesNo')
        }
        );
    },
    }
