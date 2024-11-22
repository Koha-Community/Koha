use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "38274",
    description => "Fix typo in arabic language description",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{ UPDATE language_descriptions SET description='العربية' WHERE subtag='ar' AND type='language' AND lang='ar' });
    },
};
