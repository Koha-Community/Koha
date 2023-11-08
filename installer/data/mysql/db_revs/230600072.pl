use Modern::Perl;

return {
    bug_number  => "34188",
    description => "Force staff to select a library when logging into the staff interface.",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
                INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
                VALUES ('ForceLibrarySelection', '0', NULL,'Force staff to select a library when logging into the staff interface.', 'YesNo')}
        );

        # sysprefs
        say $out "Added new system preference 'ForceLibrarySelection'";

    },
};
