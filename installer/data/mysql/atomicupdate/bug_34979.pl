use Modern::Perl;

return {
    bug_number  => "34979",
    description => "Fix system preference discrepancies",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Fix missing system preferences
        say $out "Add missing system preferences, if necessary:";
        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('RecordStaffUserOnCheckout', '0', 'If enabled, when an item is checked out, the user who checked out the item is recorded', '', 'YesNo')}
        );
        say $out "Added system preference 'RecordStaffUserOnCheckout'";

        $dbh->do(
            q{INSERT IGNORE INTO  systempreferences (variable, value, options, explanation) VALUES ('HidePersonalPatronDetailOnCirculation', 0, 'YesNo', 'Hide patrons phone number, email address, street address and city in the circulation page')}
        );
        say $out "Added system preference 'HidePersonalPatronDetailOnCirculation'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OverDriveWebsiteID','', 'WebsiteID provided by OverDrive', NULL, 'Free')}
        );
        say $out "Added system preference 'OverDriveWebsiteID'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OverDriveAuthName','','Authentication for OverDrive integration, used as fallback when no OverDrive library authnames are set','','Free')}
        );
        say $out "Added system preference 'OverDriveAuthName'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('OPACDetailQRCode','0','','Enable the display of a QR Code on the OPAC detail page','YesNo')}
        );
        say $out "Added system preference 'OPACDetailQRCode'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACPopupAuthorsSearch','0','Display the list of authors when clicking on one author.','','YesNo')}
        );
        say $out "Added system preference 'OPACPopupAuthorsSearch'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('OPACSuggestionMandatoryFields','title','','Define the mandatory fields for a patron purchase suggestions made via OPAC.','multiple')}
        );
        say $out "Added system preference 'OPACSuggestionMandatoryFields'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACShibOnly','0','If ON enables shibboleth only authentication for the opac','','YesNo')}
        );
        say $out "Added system preference 'OPACShibOnly'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) SELECT 'IntranetReadingHistoryHolds', value, '', 'If ON, Holds history is enabled for all patrons', 'YesNo' FROM systempreferences WHERE variable = 'intranetreadinghistory'}
        );
        say $out "Added system preference 'IntranetReadingHistoryHolds'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type`) VALUES('AutoApprovePatronProfileSettings', '0', '', 'Automatically approve patron profile changes from the OPAC.', 'YesNo')}
        );
        say $out "Added system preference 'AutoApprovePatronProfileSettings'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type`) VALUES  ('EmailSMSSendDriverFromAddress', '', '', 'Email SMS send driver from address override', 'Free')}
        );
        say $out "Added system preference 'EmailSMSSendDriverFromAddress'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type`) VALUES ('staffShibOnly','0','If ON enables shibboleth only authentication for the staff client','','YesNo')}
        );
        say $out "Added system preference 'staffShibOnly'";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('ManaToken','',NULL,'Security token used for authentication on Mana KB service (anti spam)','Textarea')}
        );
        say $out "Added system preference 'ManaToken'";

        say $out "Fix mis-spelled system preferences";

        # Fix Mis-spelled system preference
        $dbh->do(
            q{UPDATE systempreferences SET variable = 'OAI-PMH:AutoUpdateSetsEmbedItemData' WHERE variable = "OAI-PMH:AutoUpdateSetEmbedItemData"}
        );
        say $out "Updated system preference 'AutoUpdateSetsEmbedItemData'";

        # Fix capitalization issues breaking unit tests
        $dbh->do(q{UPDATE systempreferences SET variable = 'ReplytoDefault' WHERE variable = "ReplyToDefault"});
        say $out "Updated system preference 'ReplytoDefault'";

        $dbh->do(q{UPDATE systempreferences SET variable = 'OPACPrivacy' WHERE variable = "OpacPrivacy"});
        say $out "Updated system preference 'OPACPrivacy'";

        $dbh->do(
            q{UPDATE systempreferences SET variable = 'ILLCheckAvailability' WHERE variable = "IllCheckAvailability"});
        say $out "Updated system preference 'ILLCheckAvailability'";
    },
};
