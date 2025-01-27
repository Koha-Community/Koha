use Modern::Perl;

return {
    bug_number  => "28374",
    description => "Update point of sale print receipt",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE letter
                SET content = CONCAT('[% USE KohaDates %][% USE Branches %][% USE Price %]', content),
                    is_html = 1
            WHERE   code = 'RECEIPT'
                AND content NOT LIKE '%[\% USE KohaDates \%][\% USE Branches \%][\% USE Price \%]%';
        }
        );
        say $out "Added KohaDates, Branches and Price plugins";

        $dbh->do(
            q{
            UPDATE letter SET content = REPLACE(content, 'payment.', 'credit.') WHERE code = 'RECEIPT';
        }
        );
        say $out "Replaced 'payment' with 'credit' param in RECEIPT template";

        $dbh->do(
            q{
            UPDATE letter SET content = REPLACE(content, 'offsets', 'credit.debits') WHERE code = 'RECEIPT';
        }
        );
        say $out "Replaced 'offsets' with 'credit.debits' param in RECEIPT template";

        $dbh->do(
            q{
            UPDATE letter SET content = REPLACE(content, 'offset', 'debit') WHERE code = 'RECEIPT';
        }
        );
        say $out "Replaced 'offset' with 'debit' param in RECEIPT template";

        $dbh->do(
            q{
            UPDATE letter SET content = REPLACE(content, 'debit.debit', 'debit') WHERE code = 'RECEIPT';
        }
        );
        say $out "Replaced 'debit.debit' with 'debit' param in RECEIPT template";
    },
    }
