use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "33268",
    description => "Add rules to preserve current MARC record overlay rules behavior",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Insert filter wildcard rules equivalent to the default
        # fallback rule (overwrite) if wildcard rules exists for a module
        # and other tag wildcard rule not already defined for said module

        my $query = q{
            SELECT DISTINCT `module`, `filter` FROM `marc_overlay_rules`
            WHERE
                `filter` <> "*" AND
                `module` IN (SELECT `module` FROM `marc_overlay_rules` WHERE `filter` = "*") AND
                `filter` NOT IN (SELECT `filter` FROM `marc_overlay_rules` WHERE `tag` = "*")
        };
        my @results = $dbh->selectall_array($query);
        for my $result (@results) {
            my ( $module, $filter ) = @{$result};
            $query = q{
                INSERT INTO `marc_overlay_rules`(`tag`, `module`, `filter`, `add`, `append`, `remove`, `delete`)
                VALUES(?, ?, ?, ?, ?, ?, ?)
            };
            $dbh->do( $query, undef, '*', $module, $filter, 1, 1, 1, 1 );
        }
        say_success( $out, "Added record overlay rules to preserve current behavior" );
    },
};
