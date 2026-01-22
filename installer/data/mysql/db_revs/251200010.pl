use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38061",
    description =>
        "Add a column to determine whether a subscription's issues should be preselected in the collections table",
    up => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'subscription', 'preselect_issues_in_collections_table' ) ) {
            $dbh->do(
                q{ ALTER TABLE subscription ADD COLUMN `preselect_issues_in_collections_table` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'yes / no if the subscription should preselect issues in the collections table' AFTER published_on_template}
            );
            say_success( $out, "Added column 'subscription.preselect_issues_in_collections_table'" );
        } else {
            say_info( $out, "Column 'subscription.preselect_issues_in_collections_table' already exists!" );
        }
    },
};
