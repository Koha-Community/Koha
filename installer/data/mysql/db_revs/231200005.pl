use Modern::Perl;

return {
    bug_number  => "34979",
    description => "Fix system preference discrepancies",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Fix missing system preferences
        say $out "Fix mistakes in system preferences, if necessary:";
        my @missing;

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type) VALUES ('RecordStaffUserOnCheckout', '0', 'If enabled, when an item is checked out, the user who checked out the item is recorded', '', 'YesNo')}
            ) == 1
            && push @missing, "RecordStaffUserOnCheckout";

        $dbh->do(
            q{INSERT IGNORE INTO  systempreferences (variable, value, options, explanation) VALUES ('HidePersonalPatronDetailOnCirculation', 0, 'YesNo', 'Hide patrons phone number, email address, street address and city in the circulation page')}
            ) == 1
            && push @missing, "HidePersonalPatronDetailOnCirculation";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OverDriveWebsiteID','', 'WebsiteID provided by OverDrive', NULL, 'Free')}
            ) == 1
            && push @missing, "OverDriveWebsiteID";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OverDriveAuthName','','Authentication for OverDrive integration, used as fallback when no OverDrive library authnames are set','','Free')}
            ) == 1
            && push @missing, "OverDriveAuthName";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('OPACDetailQRCode','0','','Enable the display of a QR Code on the OPAC detail page','YesNo')}
            ) == 1
            && push @missing, "OPACDetailQRCode";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACPopupAuthorsSearch','0','Display the list of authors when clicking on one author.','','YesNo')}
            ) == 1
            && push @missing, "OPACPopupAuthorsSearch";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('OPACSuggestionMandatoryFields','title','','Define the mandatory fields for a patron purchase suggestions made via OPAC.','multiple')}
            ) == 1
            && push @missing, "OPACSuggestionMandatoryFields";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type) VALUES ('OPACShibOnly','0','If ON enables shibboleth only authentication for the opac','','YesNo')}
            ) == 1
            && push @missing, "OPACShibOnly";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) SELECT 'IntranetReadingHistoryHolds', value, '', 'If ON, Holds history is enabled for all patrons', 'YesNo' FROM systempreferences WHERE variable = 'intranetreadinghistory'}
            ) == 1
            && push @missing, "IntranetReadingHistoryHolds";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type`) VALUES('AutoApprovePatronProfileSettings', '0', '', 'Automatically approve patron profile changes from the OPAC.', 'YesNo')}
            ) == 1
            && push @missing, "AutoApprovePatronProfileSettings";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type`) VALUES  ('EmailSMSSendDriverFromAddress', '', '', 'Email SMS send driver from address override', 'Free')}
            ) == 1
            && push @missing, "EmailSMSSendDriverFromAddress";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type`) VALUES ('staffShibOnly','0','If ON enables shibboleth only authentication for the staff client','','YesNo')}
            ) == 1
            && push @missing, "staffShibOnly";

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES ('ManaToken','',NULL,'Security token used for authentication on Mana KB service (anti spam)','Textarea')}
            ) == 1
            && push @missing, "ManaToken";

        # Fix mis-spelled system preferences
        my @misspelled;
        my $pref;

        my $good_exists = $dbh->selectrow_array(
            q{SELECT variable FROM systempreferences WHERE variable = 'OAI-PMH:AutoUpdateSetsEmbedItemData'});

        $pref = $dbh->selectrow_array(
            q{SELECT variable FROM systempreferences WHERE variable = 'OAI-PMH:AutoUpdateSetEmbedItemData'});

        if ( $pref eq "OAI-PMH:AutoUpdateSetEmbedItemData" ) {
            if ($good_exists) {

                # Already exists, just delete the bad one
                $dbh->do(q{DELETE FROM systempreferences WHERE variable = "OAI-PMH:AutoUpdateSetEmbedItemData"});
            } else {
                $dbh->do(
                    q{UPDATE systempreferences SET variable = 'OAI-PMH:AutoUpdateSetsEmbedItemData' WHERE variable = "OAI-PMH:AutoUpdateSetEmbedItemData"}
                );
            }

            push @misspelled, "OAI-PMH:AutoUpdateSetsEmbedItemData";
        }

        # Fix capitalization issues breaking unit tests
        $pref = $dbh->selectrow_array(q{SELECT variable FROM systempreferences WHERE variable = 'ReplyToDefault'});
        if ( $pref eq "ReplyToDefault" ) {
            $dbh->do(q{UPDATE systempreferences SET variable = 'ReplytoDefault' WHERE variable = "ReplyToDefault"});
            push @misspelled, "ReplyToDefault";
        }

        $pref = $dbh->selectrow_array(q{SELECT variable FROM systempreferences WHERE variable = 'OpacPrivacy'});
        if ( $pref eq "OpacPrivacy" ) {
            $dbh->do(q{UPDATE systempreferences SET variable = 'OPACPrivacy' WHERE variable = "OpacPrivacy"});
            push @misspelled, "OPACPrivacy";
        }

        $pref =
            $dbh->selectrow_array(q{SELECT variable FROM systempreferences WHERE variable = 'IllCheckAvailability'});
        if ( $pref eq "IllCheckAvailability" ) {
            $dbh->do(
                q{UPDATE systempreferences SET variable = 'ILLCheckAvailability' WHERE variable = "IllCheckAvailability"}
            );
            push @misspelled, "IllCheckAvailability";
        }

        if ( @missing > 0 )    { say $out "Added system preferences: " . join( ", ", @missing ); }
        if ( @misspelled > 0 ) { say $out "Updated system preferences: " . join( ", ", @misspelled ); }
        if ( @missing == 0 && @misspelled == 0 ) { say $out "No updates required."; }

    },
};
