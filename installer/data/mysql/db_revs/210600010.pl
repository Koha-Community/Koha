use Modern::Perl;

return {
    bug_number  => "20472",
    description => "Add new system preference ArticleRequestsSupportedFormats",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('ArticleRequestsSupportedFormats', 'PHOTOCOPY', 'PHOTOCOPY|SCAN', 'List supported formats between vertical bars', 'free')
        }
        );
    },
    }
