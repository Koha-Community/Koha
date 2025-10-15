use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41029",
    description => "Add 'add_to_basket' source option for MARC overlay rules",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $existing_batchimport_rules_count = (
            $dbh->selectrow_array(
                'SELECT COUNT(*) FROM marc_overlay_rules WHERE module="source" and filter="batchimport"', undef
            )
        )[0];
        my $existing_add_to_basket_rules_count = (
            $dbh->selectrow_array(
                'SELECT COUNT(*) FROM marc_overlay_rules WHERE module="source" and filter="add_to_basket"', undef
            )
        )[0];
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
            say $out "Added existing batchimport overlay rules as add_to_basket rules";
        } else {
            say_info(
                $out,
                "No existing batchimport marc_overlay_rules found or existing add_to_basket rules found, not updating"
            );
        }

    },
};
