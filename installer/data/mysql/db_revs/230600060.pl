use Modern::Perl;

return {
    bug_number  => "18203",
    description => "Add per borrower category restrictions on ILL placement",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'categories', 'can_place_ill_in_opac' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `categories`
                ADD COLUMN `can_place_ill_in_opac` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'can this patron category place interlibrary loan requests'
                AFTER `checkprevcheckout`;
            }
            );

            say $out "Added column 'categories.can_place_ill_in_opac'";
        }
    },
};
