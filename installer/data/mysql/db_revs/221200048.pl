use Modern::Perl;

return {
    bug_number => "29046",
    description => "Allow setting first_valid_email_address field precedence order",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('EmailFieldPrecedence', 'email|emailpro|B_email', NULL, 'Ordered list of patron email fields to use when AutoEmailPrimaryAddress is set to first valid', 'multi')
        });
        say $out "Added new system preference 'EmailFieldPrecedence'";
    },
};
