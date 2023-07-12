use Modern::Perl;

return {
    bug_number => "18203",
    description => "Add per borrower category restrictions on ILL placement",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless ( column_exists('categories', 'canplaceillopac') ) {
            $dbh->do(q{
                ALTER TABLE `categories`
                ADD COLUMN `canplaceillopac` TINYINT(1) NOT NULL DEFAULT 1 COMMENT 'can this patron category place interlibrary loan requests'
                AFTER `checkprevcheckout`;
            });
        }
    },
};
