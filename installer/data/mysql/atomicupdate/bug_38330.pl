use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38330",
    description => "Make bib-level suppression a biblio table field instead of part of a marc tag",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'biblio', 'opac_suppressed' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `biblio`
                    ADD COLUMN `opac_suppressed` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'whether the record should be suppressed in the OPAC' AFTER `abstract`;
                }
            );
            say $out "Added column 'biblio.opac_suppressed'";
        }

        if ( !column_exists( 'deletedbiblio', 'opac_suppressed' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `deletedbiblio`
                    ADD COLUMN `opac_suppressed` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'whether the record should be suppressed in the OPAC' AFTER `abstract`;
                }
            );
            say $out "Added column 'deletedbiblio.opac_suppressed'";
        }

        $dbh->do(
            q{
                UPDATE marc_subfield_structure SET kohafield='biblio.opac_suppressed' WHERE tagfield=942 AND tagsubfield='n';
            }
        );
        say $out "Set the 942\$n => biblio.opac_suppressed mapping for all MARC frameworks";
        say_warning( $out, "You need to run the `maintenance/touch_all_biblios.pl` script" );
    },
};
