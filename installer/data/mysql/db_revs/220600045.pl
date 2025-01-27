use Modern::Perl;

return {
    bug_number  => 29144,
    description => "Copy and remove branches.opac_info",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'branches', 'opac_info' ) ) {
            $dbh->do(
                q{
    INSERT IGNORE INTO additional_contents ( category,code,location,branchcode,title,content,lang,published_on )
    SELECT 'html_customizations', CONCAT('OpacLibraryInfo_', branches.branchcode), 'OpacLibraryInfo', branches.branchcode, branches.branchname, branches.opac_info, 'default', NOW()
    FROM branches
    WHERE branches.opac_info IS NOT NULL
            }
            );

            $dbh->do(
                q{
                ALTER TABLE branches DROP COLUMN opac_info;
            }
            );
        }
    },
};
