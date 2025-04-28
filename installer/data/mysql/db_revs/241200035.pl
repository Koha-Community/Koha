use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39325",
    description => "Fix some spelling mistakes",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # avaiable ==> available
        $dbh->do(
            q{
            UPDATE systempreferences
            SET explanation="If enabled, item fields in the MARC record will be made available to XSLT sheets. Otherwise they will be removed."
            WHERE variable="PassItemMarcToXSLT"
        }
        );

        # foriegn ==> foreign
        $dbh->do(
            q{
            ALTER TABLE deletedbiblio
            MODIFY `frameworkcode` varchar(4) NOT NULL DEFAULT '' COMMENT 'foreign key from the biblio_framework table to identify which framework was used in cataloging this record'
        }
        );

        # addres ==> address
        # attemps ==> attempts
        # profesionals ==> professionals
        $dbh->do(
            q{
            ALTER TABLE borrowers
            MODIFY `emailpro` mediumtext DEFAULT NULL COMMENT 'the secondary email address for your patron/borrower''s primary address',
            MODIFY `login_attempts` int(4) NOT NULL DEFAULT 0 COMMENT 'number of failed login attempts',
            MODIFY `contactname` longtext DEFAULT NULL COMMENT 'used for children and professionals to include surname or last name of guarantor or organization name'
        }
        );

        # addres ==> address
        # attemps ==> attempts
        # profesionals ==> professionals
        $dbh->do(
            q{
            ALTER TABLE deletedborrowers
            MODIFY `emailpro` mediumtext DEFAULT NULL COMMENT 'the secondary email address for your patron/borrower''s primary address',
            MODIFY `login_attempts` int(4) NOT NULL DEFAULT 0 COMMENT 'number of failed login attempts',
            MODIFY `contactname` longtext DEFAULT NULL COMMENT 'used for children and professionals to include surname or last name of guarantor or organization name'
        }
        );

        # agains ==> against
        $dbh->do(
            q{
            ALTER TABLE club_holds
            MODIFY `item_id` int(11) DEFAULT NULL COMMENT 'If item-level, the id for the item the hold has been placed against'
        }
        );

        # intented ==> intended
        $dbh->do(
            q{
            ALTER TABLE items
            MODIFY `new_status` varchar(32) DEFAULT NULL COMMENT '''new'' value, you can put whatever free-text information. This field is intended to be managed by the automatic_item_modification_by_age cronjob.'
        }
        );

        # intented ==> intended
        $dbh->do(
            q{
            ALTER TABLE deleteditems
            MODIFY `new_status` varchar(32) DEFAULT NULL COMMENT '''new'' value, you can put whatever free-text information. This field is intended to be managed by the automatic_item_modification_by_age cronjob.'
        }
        );

        # definining ==> defining
        $dbh->do(
            q{
            ALTER TABLE housebound_profile
            MODIFY `frequency` mediumtext NOT NULL COMMENT 'The Authorised_Value defining the pattern for delivery.'
        }
        );

        # goup ==> group
        $dbh->do(
            q{
            ALTER TABLE library_groups
            MODIFY `title` varchar(100) DEFAULT NULL COMMENT 'Short description of the group'
        }
        );

        # shoud ==> should
        $dbh->do(
            q{
            ALTER TABLE stockrotationstages
            MODIFY `duration` int(11) NOT NULL DEFAULT 4 COMMENT 'The number of days items should occupy this stage'
        }
        );

        # thist ==> this
        $dbh->do(
            q{
            ALTER TABLE virtualshelfshares
            MODIFY `invitekey` varchar(10) DEFAULT NULL COMMENT 'temporary string used in accepting the invitation to access this list; not-empty means that the invitation has not been accepted yet'
        }
        );

        say_success( $out, "Fixed spelling mistakes in database documentation" );

    },
};
