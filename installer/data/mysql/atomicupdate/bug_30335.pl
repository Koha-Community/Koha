use Modern::Perl;

return {
    bug_number => "30335",
    description => "Add manual_invoice and manual_credit permissions",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            INSERT IGNORE permissions (module_bit, code, description) VALUES
            (10, 'manual_credit', 'Add manual credits to a patron account'),
            (10, 'manual_invoice', 'Add manual invoices to a patron account')
        });
    },
};
