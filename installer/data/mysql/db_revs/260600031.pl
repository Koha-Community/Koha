use Modern::Perl;
use Koha::Installer::Output qw(say_success);

return {
    bug_number  => "21860",
    description => "Add indicator support to MARC modification template actions",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'marc_modification_template_actions', 'use_indicators' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE marc_modification_template_actions
                    ADD COLUMN use_indicators TINYINT(1) NOT NULL DEFAULT 0
                    AFTER field_number
                }
            );
        }

        unless ( column_exists( 'marc_modification_template_actions', 'from_ind1' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE marc_modification_template_actions
                    ADD COLUMN from_ind1 VARCHAR(1) DEFAULT NULL
                    AFTER from_subfield
                }
            );
        }

        unless ( column_exists( 'marc_modification_template_actions', 'from_ind2' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE marc_modification_template_actions
                    ADD COLUMN from_ind2 VARCHAR(1) DEFAULT NULL
                    AFTER from_ind1
                }
            );
        }

        unless ( column_exists( 'marc_modification_template_actions', 'to_ind1' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE marc_modification_template_actions
                    ADD COLUMN to_ind1 VARCHAR(1) DEFAULT NULL
                    AFTER to_subfield
                }
            );
        }

        unless ( column_exists( 'marc_modification_template_actions', 'to_ind2' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE marc_modification_template_actions
                    ADD COLUMN to_ind2 VARCHAR(1) DEFAULT NULL
                    AFTER to_ind1
                }
            );
        }

        unless ( column_exists( 'marc_modification_template_actions', 'conditional_ind1' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE marc_modification_template_actions
                    ADD COLUMN conditional_ind1 VARCHAR(1) DEFAULT NULL
                    AFTER conditional_subfield
                }
            );
        }

        unless ( column_exists( 'marc_modification_template_actions', 'conditional_ind2' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE marc_modification_template_actions
                    ADD COLUMN conditional_ind2 VARCHAR(1) DEFAULT NULL
                    AFTER conditional_ind1
                }
            );
        }

        say_success( $out, "Added indicator columns to MARC modification template actions" );
    },
};
