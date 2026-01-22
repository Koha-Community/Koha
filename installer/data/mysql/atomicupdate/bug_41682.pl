use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41682",
    description => "Fix syspref discrepancies between new and upgraded installs",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Use BINARY to force a case-sensitive comparison
        # => the "Renamed" does not always appear in the output
        $dbh->do(
            q{
                UPDATE systempreferences
                SET variable="OPACItemLocation"
                WHERE BINARY variable="OpacItemLocation"
            }
        );

        # DELETE StaffLoginBranchBasedOnIP if exists. It is now StaffLoginLibraryBasedOnIP
        $dbh->do(
            q{
                DELETE FROM systempreferences
                WHERE variable="StaffLoginBranchBasedOnIP"
            }
        );

        my $new_explanations = {
            AcquisitionsDefaultEmailAddress => q{Default email address that acquisition notices are sent from},
            AdvancedSearchLanguages         =>
                q{ISO 639-2 codes of languages you wish to see appear as an Advanced search option. Example: eng|fre|ita},
            AllowMultipleIssuesOnABiblio => q{Allow/Don't allow patrons to check out multiple items from one biblio},
            Babeltheque => q{Turn ON Babeltheque content - See babeltheque.com to subscribe to this service},
            BlockExpiredPatronOpacActions =>
                q{Specific actions expired patrons of this category are blocked from performing. OPAC actions blocked based on the patron category take priority over this preference.},
            ChildNeedsGuarantor       => q{If ON, a child patron must have a guarantor when adding the patron.},
            DefaultPatronSearchMethod =>
                q{Choose which search method to use by default when searching with PatronAutoComplete},
            displayFacetCount          => q{If enabled, display the number of facet counts},
            EnableBooking              => q{If enabled, activate every functionalities related with Bookings module},
            HoldCancellationRequestSIP => q{Option to set holds cancelled via SIP as cancelation requests},
            HoldRatioDefault           => q{Default value for the hold ratio report},
            ILLModule                  => q{If ON, enables the interlibrary loans module.},
            OPACLoginLabelTextContent  => q{Control the text displayed on the login form},
            OpacHiddenItems            =>
                q{This syspref allows to define custom rules for hiding specific items at the OPAC. See https://wiki.koha-community.org/wiki/OpacHiddenItems for more information.},
            OPACShowLibraries =>
                q{If enabled, a "Libraries" link appears in the OPAC pointing to a page with library information},
            OpacSuppressionRedirect =>
                q{Redirect the opac detail page for suppressed records to an explanatory page (otherwise redirect to 404 error page)},
            OPACVirtualCard        => q{If ON, the patron virtual library card tab in the OPAC will be enabled},
            OPACVirtualCardBarcode =>
                q{Specify the type of barcode to be used in the patron virtual library card tab in the OPAC},
            PatronSelfRegistrationEmailMustBeUnique =>
                q{If set, the field borrowers.email will be considered as a unique field on self-registering},
            PatronSelfRegistrationPrefillForm =>
                q{Display password and prefill login form after a patron has self-registered},
            PreventWithdrawingItemsStatus => q{Prevent the withdrawing of items based on certain statuses},
            RoundFinesAtPayment           =>
                q{If enabled any fines with fractions of a cent will be rounded to the nearest cent when payments are collected. e.g. 1.004 will be paid off by a 1.00 payment},
            SessionRestrictionByIP =>
                q{Check for change in remote IP address for session security. Disable only when remote IP address changes frequently.},
            SeparateHoldingsByGroup =>
                q{Separate current branch holdings and holdings from libraries in the same library groups},
            ShowHeadingUse =>
                q{Show whether MARC21 authority record contains an established heading that conforms to descriptive cataloguing rules, and can therefore be used as a main/added entry, or subject, or series title},
            SuggestionsLog               => q{If ON, log purchase suggestion changes},
            SuspendHoldsIntranet         => q{Allow holds to be suspended from the intranet.},
            SuspendHoldsOpac             => q{Allow holds to be suspended from the OPAC.},
            UpdateItemLostStatusWhenPaid =>
                q{Allows the status of lost items to be automatically changed to lost and paid for when paid for},
            UpdateItemLostStatusWhenWriteoff =>
                q{Allows the status of lost items to be automatically changed to lost and paid for when written off},
            UpdateNotForLoanStatusOnCheckout =>
                qq{This is a list of value pairs. When an item is checked out, if its not for loan value matches the value on the left, then the items not for loan value will be updated to the value on the right. \nE.g. '-1: 0' will cause an item that was set to 'Ordered' to now be available for loan. Each pair of values should be on a separate line.},
        };
        for my $variable ( sort { lc($a) cmp lc($b) } keys %$new_explanations ) {
            my $explanation = $new_explanations->{$variable};
            $dbh->do(
                q{
                    UPDATE systempreferences
                    SET explanation=?
                    WHERE variable=?
                }, undef, $explanation, $variable
            );
        }

        # AlwaysLoadCheckoutsTable and CircConfirmItemParts has "Yes/No" instead of "YesNo"
        $dbh->do(
            q{
                UPDATE systempreferences
                SET type="YesNo"
                WHERE type="Yes/No"
            }
        );

        $dbh->do(
            q{
                UPDATE systempreferences
                SET value="0"
                WHERE type="YesNo" AND value=""
            }
        );
        $dbh->do(
            q{
                UPDATE systempreferences
                SET options=NULL
                WHERE type="YesNo";
            }
        );

        $dbh->do(
            q{
                UPDATE systempreferences
                SET options=NULL
                WHERE options='' OR options='NULL';
            }
        );

        $dbh->do(
            q{
                UPDATE systempreferences
                SET options='starts_with|contains'
                WHERE variable="DefaultPatronSearchMethod";
            }
        );

        $dbh->do(
            q{
                UPDATE systempreferences
                SET type='Free'
                WHERE variable="OpacKohaUrl";
            }
        );

        $dbh->do(
            q{
                UPDATE systempreferences
                SET type='Free'
                WHERE variable="OPACLoginLabelTextContent";
            }
        );
    },
};
