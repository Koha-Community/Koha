    use Modern::Perl;

    return {
        bug_number  => "33473",
        description => "Allow to send email receipts for payments/writeoff manually instead of automatically",
        up          => sub {
            my ($args) = @_;
            my ( $dbh, $out ) = @$args{qw(dbh out)};

            $dbh->do(
                q{
                UPDATE systempreferences SET variable = 'AutomaticEmailReceipts' WHERE variable = 'UseEmailReceipts';
            }
            );
            say $out "Renamed system preference 'UseEmailReceipts' to 'AutomaticEmailReceipts'";
        },
        }
