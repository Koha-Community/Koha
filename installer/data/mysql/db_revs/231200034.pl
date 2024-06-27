use Modern::Perl;

return {
    bug_number  => '12802',
    description => 'Change type of system preference EmailFieldPrimary to multiple',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            "UPDATE systempreferences SET options='email|emailpro|B_email|cardnumber|OFF|MULTI' WHERE variable='EmailFieldPrimary'"
        );
        say $out "Updated system preference 'EmailFieldPrimary' to include 'selected addresses' option";

        $dbh->do(
            "INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('EmailFieldSelection','','email|emailpro|B_email','Selection list of patron email fields to use whern AutoEmailPrimaryAddress is set to selected addresses','multiple')"
        );

        say $out "Added new system preference 'EmailFieldSelection'";
    },
};
