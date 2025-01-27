use Modern::Perl;

return {
    bug_number  => "17018",
    description => "Split AdvancedSearchTypes for staff and OPAC",
    up          => sub {
        my ($args) = @_;
        my $dbh = $args->{dbh};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) SELECT 'OpacAdvancedSearchTypes', `value`, `options`, 'Select which set of fields are available as limits on the OPAC advanced search page', `type` FROM systempreferences WHERE variable = 'AdvancedSearchTypes'
        }
        );
    },
};
