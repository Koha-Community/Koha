use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);
use C4::SIP::Sip::Configuration;
use Koha::Config;

return {
    bug_number  => "37893",
    description => "Move SIPconfig.xml to database",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        my $koha_instance = $ENV{KOHA_CONF} =~ m!^.+/sites/([^/]+)/koha-conf\.xml$! ? $1 : undef;
        unless ($koha_instance) {
            say_warning(
                $out,
                "No Koha instance found. Ensure \$KOHA_CONF is set and contains a valid Koha instance koha-conf.xml"
            );
            return;
        }

        my $SIPconfigFile = "/etc/koha/sites/$koha_instance/SIPconfig.xml";
        say_info( $out, "Reading SIPconfig.xml for $koha_instance located at $SIPconfigFile" );
        my $SIPconfig = C4::SIP::Sip::Configuration->new($SIPconfigFile);

        # Institutions #
        my @institution_keys = keys %{ $SIPconfig->{institutions} };
        foreach my $institution_key (@institution_keys) {
            my $insert_institutions = $dbh->prepare(
                q{INSERT IGNORE INTO sip_institutions (name, implementation, checkin, checkout, offline, renewal, retries, status_update, timeout) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)}
            );

            my $implementation = $SIPconfig->{institutions}->{$institution_key}->{implementation}     // 'ILS';
            my $checkin        = $SIPconfig->{institutions}->{$institution_key}->{policy}->{checkin}  // 'true';
            my $checkout       = $SIPconfig->{institutions}->{$institution_key}->{policy}->{checkout} // 'true';
            my $offline        = $SIPconfig->{institutions}->{$institution_key}->{policy}->{offline};
            my $renewal        = $SIPconfig->{institutions}->{$institution_key}->{policy}->{renewal} // 'false';
            my $retries        = $SIPconfig->{institutions}->{$institution_key}->{policy}->{retries} // 5;
            my $status_update  = $SIPconfig->{institutions}->{$institution_key}->{policy}->{status_update};
            my $timeout        = $SIPconfig->{institutions}->{$institution_key}->{policy}->{timeout} // 100;

            $insert_institutions->execute(
                $institution_key,
                $implementation,
                $checkin eq 'false'  ? 0 : 1,
                $checkout eq 'false' ? 0 : 1,
                defined $offline
                ? ( $offline eq 'false' ? 0 : 1 )
                : undef,
                $renewal eq 'true' ? 1 : 0,
                $retries,
                defined $status_update
                ? ( $status_update eq 'false' ? 0 : 1 )
                : undef,
                $timeout,
            );
        }

        # Accounts #
        my @account_keys = keys %{ $SIPconfig->{accounts} };
        foreach my $account_key (@account_keys) {
            next unless $SIPconfig->{accounts}->{$account_key}->{id};

            my $sip_institution =
                Koha::SIP2::Institutions->find( { name => $SIPconfig->{accounts}->{$account_key}->{institution} } );
            next unless $sip_institution;

            my $insert_accounts = $dbh->prepare(
                q{INSERT IGNORE INTO sip_accounts (sip_institution_id, ae_field_template, allow_additional_materials_checkout, allow_empty_passwords, allow_fields, av_field_template, blocked_item_types, checked_in_ok, convert_nonprinting_characters, cr_item_field, ct_always_send, cv_send_00_on_success, cv_triggers_alert, da_field_template, delimiter, disallow_overpayment, encoding, error_detect, format_due_date, hide_fields, holds_block_checkin, holds_get_captured, inhouse_item_types, inhouse_patron_categories, login_id, login_password, lost_block_checkout, lost_block_checkout_value, lost_status_for_missing, overdues_block_checkout, payment_type_writeoff, prevcheckout_block_checkout, register_id, seen_on_item_information, send_patron_home_library_in_af, show_checkin_message, show_outstanding_amount, terminator) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?, ?,?,?,?,?,?,?, ?,?,?,?,?)}
            );

            my $sip_institution_id = $sip_institution->get_column('sip_institution_id');
            my $ae_field_template  = $SIPconfig->{accounts}->{$account_key}->{ae_field_template};
            my $allow_additional_materials_checkout =
                $SIPconfig->{accounts}->{$account_key}->{allow_additional_materials_checkout};
            my $allow_empty_passwords = $SIPconfig->{accounts}->{$account_key}->{allow_empty_passwords};
            my $allow_fields          = $SIPconfig->{accounts}->{$account_key}->{allow_fields};
            my $av_field_template     = $SIPconfig->{accounts}->{$account_key}->{av_field_template};
            my $blocked_item_types    = $SIPconfig->{accounts}->{$account_key}->{blocked_item_types};
            my $checked_in_ok         = $SIPconfig->{accounts}->{$account_key}->{checked_in_ok};
            my $convert_nonprinting_characters =
                $SIPconfig->{accounts}->{$account_key}->{convert_nonprinting_characters};
            my $cr_item_field         = $SIPconfig->{accounts}->{$account_key}->{cr_item_field};
            my $ct_always_send        = $SIPconfig->{accounts}->{$account_key}->{ct_always_send};
            my $cv_send_00_on_success = $SIPconfig->{accounts}->{$account_key}->{cv_send_00_on_success};
            my $cv_triggers_alert     = $SIPconfig->{accounts}->{$account_key}->{cv_triggers_alert};
            my $da_field_template     = $SIPconfig->{accounts}->{$account_key}->{da_field_template};
            my $delimiter             = $SIPconfig->{accounts}->{$account_key}->{delimiter} || undef;
            my $disallow_overpayment  = $SIPconfig->{accounts}->{$account_key}->{disallow_overpayment};
            my $encoding              = $SIPconfig->{accounts}->{$account_key}->{encoding};

            my $error_detect;
            if ( defined $SIPconfig->{accounts}->{$account_key}->{'error-detect'} ) {
                $error_detect = $SIPconfig->{accounts}->{$account_key}->{'error-detect'} eq 'enabled' ? 1 : 0;
            }

            my $format_due_date             = $SIPconfig->{accounts}->{$account_key}->{format_due_date};
            my $hide_fields                 = $SIPconfig->{accounts}->{$account_key}->{hide_fields};
            my $holds_block_checkin         = $SIPconfig->{accounts}->{$account_key}->{holds_block_checkin};
            my $holds_get_captured          = $SIPconfig->{accounts}->{$account_key}->{holds_get_captured};
            my $inhouse_item_types          = $SIPconfig->{accounts}->{$account_key}->{inhouse_item_types};
            my $inhouse_patron_categories   = $SIPconfig->{accounts}->{$account_key}->{inhouse_patron_categories};
            my $login_id                    = $SIPconfig->{accounts}->{$account_key}->{id};
            my $login_password              = $SIPconfig->{accounts}->{$account_key}->{password};
            my $lost_block_checkout         = $SIPconfig->{accounts}->{$account_key}->{lost_block_checkout};
            my $lost_block_checkout_value   = $SIPconfig->{accounts}->{$account_key}->{lost_block_checkout_value};
            my $lost_status_for_missing     = $SIPconfig->{accounts}->{$account_key}->{lost_status_for_missing};
            my $overdues_block_checkout     = $SIPconfig->{accounts}->{$account_key}->{overdues_block_checkout};
            my $payment_type_writeoff       = $SIPconfig->{accounts}->{$account_key}->{payment_type_writeoff};
            my $prevcheckout_block_checkout = $SIPconfig->{accounts}->{$account_key}->{prevcheckout_block_checkout};
            my $register_id                 = $SIPconfig->{accounts}->{$account_key}->{register_id} || undef;
            my $seen_on_item_information    = $SIPconfig->{accounts}->{$account_key}->{seen_on_item_information};
            my $send_patron_home_library_in_af =
                $SIPconfig->{accounts}->{$account_key}->{send_patron_home_library_in_af};
            my $show_checkin_message    = $SIPconfig->{accounts}->{$account_key}->{show_checkin_message};
            my $show_outstanding_amount = $SIPconfig->{accounts}->{$account_key}->{show_outstanding_amount};
            my $terminator              = $SIPconfig->{accounts}->{$account_key}->{terminator};

            $insert_accounts->execute(
                $sip_institution_id,
                $ae_field_template,
                $allow_additional_materials_checkout,
                $allow_empty_passwords,
                $allow_fields,
                $av_field_template,
                $blocked_item_types,
                $checked_in_ok,
                $convert_nonprinting_characters,
                $cr_item_field,
                $ct_always_send,
                $cv_send_00_on_success,
                $cv_triggers_alert,
                $da_field_template,
                $delimiter,
                $disallow_overpayment,
                $encoding,
                $error_detect,
                $format_due_date,
                $hide_fields,
                $holds_block_checkin,
                $holds_get_captured,
                $inhouse_item_types,
                $inhouse_patron_categories,
                $login_id,
                $login_password,
                $lost_block_checkout,
                $lost_block_checkout_value,
                $lost_status_for_missing,
                $overdues_block_checkout,
                $payment_type_writeoff,
                $prevcheckout_block_checkout,
                $register_id,
                $seen_on_item_information,
                $send_patron_home_library_in_af,
                $show_checkin_message,
                $show_outstanding_amount,
                $terminator
            );

            my $new_account_id = $dbh->last_insert_id( undef, undef, "sip_accounts", "sip_account_id" );

            # Accounts custom patron fields
            my @custom_patron_fields =
                ref $SIPconfig->{accounts}->{$account_key}->{custom_patron_field} eq "ARRAY"
                ? @{ $SIPconfig->{accounts}->{$account_key}->{custom_patron_field} }
                : ( $SIPconfig->{accounts}->{$account_key}->{custom_patron_field} );

            my $insert_custom_patron_fields = $dbh->prepare(
                q{INSERT IGNORE INTO sip_account_custom_patron_fields (sip_account_id, field, template) VALUES (?, ?, ?)}
            );

            foreach my $custom_patron_field (@custom_patron_fields) {
                $insert_custom_patron_fields->execute(
                    $new_account_id,
                    $custom_patron_field->{field},
                    $custom_patron_field->{template}
                ) if $custom_patron_field;
            }

            # Accounts patron attributes
            my @patron_attributes =
                ref $SIPconfig->{accounts}->{$account_key}->{patron_attribute} eq "ARRAY"
                ? @{ $SIPconfig->{accounts}->{$account_key}->{patron_attribute} }
                : ( $SIPconfig->{accounts}->{$account_key}->{patron_attribute} );

            my $insert_patron_attributes = $dbh->prepare(
                q{INSERT IGNORE INTO sip_account_patron_attributes (sip_account_id, field, code) VALUES (?, ?, ?)});

            foreach my $patron_attribute (@patron_attributes) {
                $insert_patron_attributes->execute(
                    $new_account_id,
                    $patron_attribute->{field},
                    $patron_attribute->{code}
                ) if $patron_attribute;
            }

            # Accounts custom item fields
            my @custom_item_fields =
                ref $SIPconfig->{accounts}->{$account_key}->{custom_item_field} eq "ARRAY"
                ? @{ $SIPconfig->{accounts}->{$account_key}->{custom_item_field} }
                : ( $SIPconfig->{accounts}->{$account_key}->{custom_item_field} );

            my $insert_custom_item_fields = $dbh->prepare(
                q{INSERT IGNORE INTO sip_account_custom_item_fields (sip_account_id, field, template) VALUES (?, ?, ?)}
            );

            foreach my $custom_item_field (@custom_item_fields) {
                $insert_custom_item_fields->execute(
                    $new_account_id,
                    $custom_item_field->{field},
                    $custom_item_field->{template}
                ) if $custom_item_field;
            }

            # Accounts item fields
            my @item_fields =
                ref $SIPconfig->{accounts}->{$account_key}->{item_field} eq "ARRAY"
                ? @{ $SIPconfig->{accounts}->{$account_key}->{item_field} }
                : ( $SIPconfig->{accounts}->{$account_key}->{item_field} );

            my $insert_item_fields = $dbh->prepare(
                q{INSERT IGNORE INTO sip_account_item_fields (sip_account_id, field, code) VALUES (?, ?, ?)});

            foreach my $item_field (@item_fields) {
                $insert_item_fields->execute(
                    $new_account_id,
                    $item_field->{field},
                    $item_field->{code}
                ) if $item_field;
            }

            # Accounts system preference overrides
            my @account_system_preference_overrides =
                ref $SIPconfig->{accounts}->{$account_key}->{syspref_overrides} eq "ARRAY"
                ? @{ $SIPconfig->{accounts}->{$account_key}->{syspref_overrides} }
                : ( $SIPconfig->{accounts}->{$account_key}->{syspref_overrides} );

            my $insert_account_system_preference_overrides = $dbh->prepare(
                q{INSERT IGNORE INTO sip_account_system_preference_overrides (sip_account_id, variable, value) VALUES (?, ?, ?)}
            );

            foreach my $account_system_preference_override (@account_system_preference_overrides) {

                if ( ref $account_system_preference_override eq 'HASH' ) {
                    for my $key ( keys %{$account_system_preference_override} ) {
                        my $override_value = $account_system_preference_override->{$key};
                        if ( ref $account_system_preference_override->{$key} eq 'ARRAY' ) {
                            $override_value = $account_system_preference_override->{$key}->[0];
                        }
                        $insert_account_system_preference_overrides->execute(
                            $new_account_id,
                            $key,
                            $override_value
                        );
                    }
                }
            }

        }
    },
};
