use Modern::Perl;
use Koha::Installer::Output qw(say_success say_info);

return {
    bug_number  => "41029",
    description => "Add 'add_to_basket' source option for MARC overlay rules",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO record_sources (`name`, `can_be_edited`, `is_system`)
            VALUES ('add_to_basket', 1, 1)
        }
        );
        say_success( $out, "Added 'add_to_basket' record source" );

        my $existing_batchimport_rules_count = scalar $dbh->selectrow_array(
            'SELECT COUNT(*) FROM marc_overlay_rules WHERE module="source" AND filter="batchimport"');
        my $existing_add_to_basket_rules_count = scalar $dbh->selectrow_array(
            'SELECT COUNT(*) FROM marc_overlay_rules WHERE module="source" AND filter="add_to_basket"');
        if ( $existing_batchimport_rules_count > 0 && $existing_add_to_basket_rules_count == 0 ) {
            say_info( $out, "Existing batchimport marc_overlay_rules found and no add_to_basket rules found" );
            $dbh->do(
                q{
                INSERT INTO marc_overlay_rules (`tag`, `module`, `filter`, `add`, `append`, `remove`, `delete`)
                SELECT `tag`, `module`, "add_to_basket", `add`, `append`, `remove`, `delete`
                FROM marc_overlay_rules
                WHERE module = 'source' AND filter = 'batchimport'
        }
            );
            say_success( $out, "Added existing batchimport overlay rules as add_to_basket rules" );
        } else {
            say_info(
                $out,
                "No existing batchimport marc_overlay_rules found or existing add_to_basket rules found, not updating"
            );
        }

    },
};
