#
# Sip::MsgType.pm
#
# A Class for handing SIP messages
#

package C4::SIP::Sip::MsgType;

use strict;
use warnings;
use Exporter;

use C4::SIP::Sip qw(:all);
use C4::SIP::Sip::Constants qw(:all);
use C4::SIP::Sip::Checksum qw(verify_cksum);

use Data::Dumper;
use CGI qw ( -utf8 );
use C4::Auth qw(&check_api_auth);

use Koha::Patrons;
use Koha::Patron::Attributes;
use Koha::Plugins;
use Koha::Items;
use Koha::DateUtils qw( output_pref );

use UNIVERSAL::can;

use vars qw(@ISA @EXPORT_OK);

use constant INVALID_CARD => 'Invalid cardnumber';
use constant INVALID_PW   => 'Invalid password';

BEGIN {
    @ISA       = qw(Exporter);
    @EXPORT_OK = qw(handle login_core);
}

# Predeclare handler subroutines
use subs qw(handle_patron_status handle_checkout handle_checkin
  handle_block_patron handle_sc_status handle_request_acs_resend
  handle_login handle_patron_info handle_end_patron_session
  handle_fee_paid handle_item_information handle_item_status_update
  handle_patron_enable handle_hold handle_renew handle_renew_all);

#
# For the most part, Version 2.00 of the protocol just adds new
# variable fields, but sometimes it changes the fixed header.
#
# In general, if there's no '2.00' protocol entry for a handler, that's
# because 2.00 didn't extend the 1.00 version of the protocol.  This will
# be handled by the module initialization code following the declaration,
# which goes through the handlers table and creates a '2.00' entry that
# points to the same place as the '1.00' entry.  If there's a 2.00 entry
# but no 1.00 entry, then that means that it's a completely new service
# in 2.00, so 1.00 shouldn't recognize it.

my %handlers = (
    (PATRON_STATUS_REQ) => {
        name     => "Patron Status Request",
        handler  => \&handle_patron_status,
        protocol => {
            1 => {
                template     => "A3A18",
                template_len => 21,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_TERMINAL_PWD), (FID_PATRON_PWD) ],
            }
        }
    },
    (CHECKOUT) => {
        name     => "Checkout",
        handler  => \&handle_checkout,
        protocol => {
            1 => {
                template     => "A1A1A18A18",
                template_len => 38,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_ITEM_ID), (FID_TERMINAL_PWD) ],
            },
            2 => {
                template     => "A1A1A18A18",
                template_len => 38,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_ITEM_ID), (FID_TERMINAL_PWD), (FID_ITEM_PROPS), (FID_PATRON_PWD), (FID_FEE_ACK), (FID_CANCEL) ],
            },
        }
    },
    (CHECKIN) => {
        name     => "Checkin",
        handler  => \&handle_checkin,
        protocol => {
            1 => {
                template     => "A1A18A18",
                template_len => 37,
                fields       => [ (FID_CURRENT_LOCN), (FID_INST_ID), (FID_ITEM_ID), (FID_TERMINAL_PWD) ],
            },
            2 => {
                template     => "A1A18A18",
                template_len => 37,
                fields       => [ (FID_CURRENT_LOCN), (FID_INST_ID), (FID_ITEM_ID), (FID_TERMINAL_PWD), (FID_ITEM_PROPS), (FID_CANCEL) ],
            }
        }
    },
    (BLOCK_PATRON) => {
        name     => "Block Patron",
        handler  => \&handle_block_patron,
        protocol => {
            1 => {
                template     => "A1A18",
                template_len => 19,
                fields       => [ (FID_INST_ID), (FID_BLOCKED_CARD_MSG), (FID_PATRON_ID), (FID_TERMINAL_PWD) ],
            },
        }
    },
    (SC_STATUS) => {
        name     => "SC Status",
        handler  => \&handle_sc_status,
        protocol => {
            1 => {
                template     => "A1A3A4",
                template_len => 8,
                fields       => [],
            }
        }
    },
    (REQUEST_ACS_RESEND) => {
        name     => "Request ACS Resend",
        handler  => \&handle_request_acs_resend,
        protocol => {
            1 => {
                template     => q{},
                template_len => 0,
                fields       => [],
            }
        }
    },
    (LOGIN) => {
        name     => "Login",
        handler  => \&handle_login,
        protocol => {
            2 => {
                template     => "A1A1",
                template_len => 2,
                fields       => [ (FID_LOGIN_UID), (FID_LOGIN_PWD), (FID_LOCATION_CODE) ],
            }
        }
    },
    (PATRON_INFO) => {
        name     => "Patron Info",
        handler  => \&handle_patron_info,
        protocol => {
            2 => {
                template     => "A3A18A10",
                template_len => 31,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_TERMINAL_PWD), (FID_PATRON_PWD), (FID_START_ITEM), (FID_END_ITEM) ],
            }
        }
    },
    (END_PATRON_SESSION) => {
        name     => "End Patron Session",
        handler  => \&handle_end_patron_session,
        protocol => {
            2 => {
                template     => "A18",
                template_len => 18,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_TERMINAL_PWD), (FID_PATRON_PWD) ],
            }
        }
    },
    (FEE_PAID) => {
        name     => "Fee Paid",
        handler  => \&handle_fee_paid,
        protocol => {
            2 => {
                template     => "A18A2A2A3",
                template_len => 25,
                fields       => [ (FID_FEE_AMT), (FID_INST_ID), (FID_PATRON_ID), (FID_TERMINAL_PWD), (FID_PATRON_PWD), (FID_FEE_ID), (FID_TRANSACTION_ID) ],
            }
        }
    },
    (ITEM_INFORMATION) => {
        name     => "Item Information",
        handler  => \&handle_item_information,
        protocol => {
            2 => {
                template     => "A18",
                template_len => 18,
                fields       => [ (FID_INST_ID), (FID_ITEM_ID), (FID_TERMINAL_PWD) ],
            }
        }
    },
    (ITEM_STATUS_UPDATE) => {
        name     => "Item Status Update",
        handler  => \&handle_item_status_update,
        protocol => {
            2 => {
                template     => "A18",
                template_len => 18,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_ITEM_ID), (FID_TERMINAL_PWD), (FID_ITEM_PROPS) ],
            }
        }
    },
    (PATRON_ENABLE) => {
        name     => "Patron Enable",
        handler  => \&handle_patron_enable,
        protocol => {
            2 => {
                template     => "A18",
                template_len => 18,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_TERMINAL_PWD), (FID_PATRON_PWD) ],
            }
        }
    },
    (HOLD) => {
        name     => "Hold",
        handler  => \&handle_hold,
        protocol => {
            2 => {
                template     => "AA18",
                template_len => 19,
                fields       => [
                    (FID_EXPIRATION), (FID_PICKUP_LOCN), (FID_HOLD_TYPE), (FID_INST_ID), (FID_PATRON_ID), (FID_PATRON_PWD),
                    (FID_ITEM_ID), (FID_TITLE_ID), (FID_TERMINAL_PWD), (FID_FEE_ACK)
                ],
            }
        }
    },
    (RENEW) => {
        name     => "Renew",
        handler  => \&handle_renew,
        protocol => {
            2 => {
                template     => "A1A1A18A18",
                template_len => 38,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_PATRON_PWD), (FID_ITEM_ID), (FID_TITLE_ID), (FID_TERMINAL_PWD), (FID_ITEM_PROPS), (FID_FEE_ACK) ],
            }
        }
    },
    (RENEW_ALL) => {
        name     => "Renew All",
        handler  => \&handle_renew_all,
        protocol => {
            2 => {
                template     => "A18",
                template_len => 18,
                fields       => [ (FID_INST_ID), (FID_PATRON_ID), (FID_PATRON_PWD), (FID_TERMINAL_PWD), (FID_FEE_ACK) ],
            }
        }
    }
);

#
# Now, initialize some of the missing bits of %handlers
#
foreach my $i ( keys(%handlers) ) {
    if ( !exists( $handlers{$i}->{protocol}->{2} ) ) {
        $handlers{$i}->{protocol}->{2} = $handlers{$i}->{protocol}->{1};
    }
}

sub new {
    my ( $class, $msg, $seqno ) = @_;
    my $self = {};
    my $msgtag = substr( $msg, 0, 2 );

    if ( $msgtag eq LOGIN ) {

        # If the client is using the 2.00-style "Login" message
        # to authenticate to the server, then we get the Login message
        # _before_ the client has indicated that it supports 2.00, but
        # it's using the 2.00 login process, so it must support 2.00.
        $protocol_version = 2;
    }
    siplog( "LOG_DEBUG", "Sip::MsgType::new('%s', '%s...', '%s'): seq.no '%s', protocol %s", $class, substr( $msg, 0, 10 ), $msgtag, $seqno, $protocol_version );

    # warn "SIP PROTOCOL: $protocol_version";
    if ( !exists( $handlers{$msgtag} ) ) {
        siplog( "LOG_WARNING", "new Sip::MsgType: Skipping message of unknown type '%s' in '%s'", $msgtag, $msg );
        return;
    } elsif ( !exists( $handlers{$msgtag}->{protocol}->{$protocol_version} ) ) {
        siplog( "LOG_WARNING", "new Sip::MsgType: Skipping message '%s' unsupported by protocol rev. '%d'", $msgtag, $protocol_version );
        return;
    }

    bless $self, $class;

    $self->{seqno} = $seqno;
    $self->_initialize( substr( $msg, 2 ), $handlers{$msgtag} );

    return ($self);
}

sub _initialize {
    my ( $self, $msg, $control_block ) = @_;
    my $fn;
    my $proto = $control_block->{protocol}->{$protocol_version};

    $self->{name}    = $control_block->{name};
    $self->{handler} = $control_block->{handler};

    $self->{fields}       = {};
    $self->{fixed_fields} = [];

    chomp($msg);    # These four are probably unnecessary now.
    $msg =~ tr/\cM//d;
    $msg =~ s/\^M$//;
    chomp($msg);

    foreach my $field ( @{ $proto->{fields} } ) {
        $self->{fields}->{$field} = undef;
    }

    siplog( "LOG_DEBUG", "Sip::MsgType::_initialize('%s', '%s', '%s', '%s', ...)", $self->{name}, $msg, $proto->{template}, $proto->{template_len} );

    $self->{fixed_fields} = [ unpack( $proto->{template}, $msg ) ];    # see http://perldoc.perl.org/5.8.8/functions/unpack.html

    # Skip over the fixed fields and the split the rest of
    # the message into fields based on the delimiter and parse them
    foreach my $field ( split( quotemeta($field_delimiter), substr( $msg, $proto->{template_len} ) ) ) {
        $fn = substr( $field, 0, 2 );

        if ( !exists( $self->{fields}->{$fn} ) ) {
            siplog( "LOG_WARNING", "Unsupported field '%s' in %s message '%s'", $fn, $self->{name}, $msg );
        } elsif ( defined( $self->{fields}->{$fn} ) ) {
            siplog( "LOG_WARNING", "Duplicate field '%s' (previous value '%s') in %s message '%s'", $fn, $self->{fields}->{$fn}, $self->{name}, $msg );
        } else {
            $self->{fields}->{$fn} = substr( $field, 2 );
        }
    }

    return ($self);
}

sub handle {
    my ( $msg, $server, $req ) = @_;
    my $config = $server->{config};
    my $self;

    # Set system preference overrides, first global, then account level
    # Clear overrides from previous message handling first
    foreach my $key ( keys %ENV ) {
        delete $ENV{$key} if index($key, 'OVERRIDE_SYSPREF_') > 0;
    }
    foreach my $key ( keys %{ $config->{'syspref_overrides'} } ) {
        $ENV{"OVERRIDE_SYSPREF_$key"} = $config->{'syspref_overrides'}->{$key};
    }
    foreach my $key ( keys %{ $server->{account}->{'syspref_overrides'} } ) {
        $ENV{"OVERRIDE_SYSPREF_$key"} =
          $server->{account}->{'syspref_overrides'}->{$key};
    }

    #
    # What's the field delimiter for variable length fields?
    # This can't be based on the account, since we need to know
    # the field delimiter to parse a SIP login message
    #
    if ( defined( $server->{config}->{delimiter} ) ) {
        $field_delimiter = $server->{config}->{delimiter};
    }

    # error detection is active if this is a REQUEST_ACS_RESEND
    # message with a checksum, or if the message is long enough
    # and the last nine characters begin with a sequence number
    # field
    if ( $msg eq REQUEST_ACS_RESEND_CKSUM ) {

        # Special case
        $error_detection = 1;
        $self = C4::SIP::Sip::MsgType->new( (REQUEST_ACS_RESEND), 0 );
    } elsif ( ( length($msg) > 11 ) && ( substr( $msg, -9, 2 ) eq "AY" ) ) {
        $error_detection = 1;

        if ( !verify_cksum($msg) ) {
            siplog( "LOG_WARNING", "Checksum failed on message '%s'", $msg );

            # REQUEST_SC_RESEND with error detection
            $last_response = REQUEST_SC_RESEND_CKSUM;
            print("$last_response\r");
            return REQUEST_ACS_RESEND;
        } else {

            # Save the sequence number, then strip off the
            # error detection data to process the message
            $self = C4::SIP::Sip::MsgType->new( substr( $msg, 0, -9 ), substr( $msg, -7, 1 ) );
        }
    } elsif ($error_detection) {

        # We received a non-ED message when ED is supposed to be active.
        # Warn about this problem, then process the message anyway.
        siplog( "LOG_WARNING", "Received message without error detection: '%s'", $msg );
        $error_detection = 0;
        $self = C4::SIP::Sip::MsgType->new( $msg, 0 );
    } else {
        $self = C4::SIP::Sip::MsgType->new( $msg, 0 );
    }

    if (   ( substr( $msg, 0, 2 ) ne REQUEST_ACS_RESEND )
        && $req
        && ( substr( $msg, 0, 2 ) ne $req ) ) {
        return substr( $msg, 0, 2 );
    }
    unless ( $self->{handler} ) {
        siplog( "LOG_WARNING", "No handler defined for '%s'", $msg );
        $last_response = REQUEST_SC_RESEND;
        print("$last_response\r");
        return REQUEST_ACS_RESEND;
    }
    return ( $self->{handler}->( $self, $server ) );    # FIXME
                                                        # FIXME: Use of uninitialized value in subroutine entry
                                                        # Can't use string ("") as a subroutine ref while "strict refs" in use
}

##
## Message Handlers
##

#
# Patron status messages are produced in response to both
# "Request Patron Status" and "Block Patron"
#
# Request Patron Status requires a patron password, but
# Block Patron doesn't (since the patron may never have
# provided one before attempting some illegal action).
#
# ASSUMPTION: If the patron password field is present in the
# message, then it must match, otherwise incomplete patron status
# information will be returned to the terminal.
#
sub build_patron_status {
    my ( $patron, $lang, $fields, $server ) = @_;

    my $patron_pwd = $fields->{ (FID_PATRON_PWD) };
    my $resp = (PATRON_STATUS_RESP);
    my $password_rc;

    if ( $patron ) {
        if ($patron_pwd) {
            $password_rc = $patron->check_password($patron_pwd);
        }

        $resp .= patron_status_string( $patron, $server );
        $resp .= $lang . timestamp();
        if ( defined $server->{account}->{ae_field_template} ) {
            $resp .= add_field( FID_PERSONAL_NAME, $patron->format( $server->{account}->{ae_field_template}, $server ) );
        } else {
            $resp .= add_field( FID_PERSONAL_NAME, $patron->name, $server );
        }


        # while the patron ID we got from the SC is valid, let's
        # use the one returned from the ILS, just in case...
        $resp .= add_field( FID_PATRON_ID, $patron->id, $server );

        if ( $protocol_version >= 2 ) {
            $resp .= add_field( FID_VALID_PATRON, 'Y', $server );

            # Patron password is a required field.
            $resp .= add_field( FID_VALID_PATRON_PWD, sipbool($password_rc), $server );
            $resp .= maybe_add( FID_CURRENCY, $patron->currency, $server );
            $resp .= maybe_add( FID_FEE_AMT,  $patron->fee_amount, $server );
        }

        my $msg = $patron->screen_msg;
        $msg .= ' -- '. INVALID_PW if $patron_pwd && !$password_rc;
        $resp .= maybe_add( FID_SCREEN_MSG, $msg, $server );

        $resp .= maybe_add( FID_SCREEN_MSG, $patron->{branchcode}, $server )
          if ( $server->{account}->{send_patron_home_library_in_af} );
        $resp .= maybe_add( FID_PRINT_LINE, $patron->print_line, $server );

        $resp .= $patron->build_custom_field_string( $server );
        $resp .= $patron->build_patron_attributes_string( $server );

    } else {
        # Invalid patron (cardnumber)
        # Report that the user has no privs.

        # no personal name, and is invalid (if we're using 2.00)
        $resp .= 'YYYY' . ( ' ' x 10 ) . $lang . timestamp();
        $resp .= add_field( FID_PERSONAL_NAME, '', $server );

        # the patron ID is invalid, but it's a required field, so
        # just echo it back
        $resp .= add_field( FID_PATRON_ID, $fields->{ (FID_PATRON_ID) }, $server );

        ( $protocol_version >= 2 )
          and $resp .= add_field( FID_VALID_PATRON, 'N', $server );

        $resp .= maybe_add( FID_SCREEN_MSG, INVALID_CARD, $server );
    }

    $resp .= add_field( FID_INST_ID, $fields->{ (FID_INST_ID) }, $server );
    return $resp;
}

sub handle_patron_status {
    my ( $self, $server ) = @_;
    my $ils = $server->{ils};
    my $patron;
    my $resp    = (PATRON_STATUS_RESP);
    my $account = $server->{account};
    my ( $lang, $date ) = @{ $self->{fixed_fields} };
    my $fields = $self->{fields};

    $ils->check_inst_id( $fields->{ (FID_INST_ID) }, "handle_patron_status" );
    $patron = $ils->find_patron( $fields->{ (FID_PATRON_ID) } );
    $resp = build_patron_status( $patron, $lang, $fields, $server );
    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );
    return (PATRON_STATUS_REQ);
}

sub handle_checkout {
    my ( $self, $server ) = @_;
    my $account = $server->{account};
    my $ils     = $server->{ils};
    my $inst    = $ils->institution;
    my ( $sc_renewal_policy, $no_block, $trans_date, $nb_due_date );
    my $fields;
    my ( $patron_id, $item_id, $status );
    my ( $item, $patron );
    my $resp;

    ( $sc_renewal_policy, $no_block, $trans_date, $nb_due_date ) = @{ $self->{fixed_fields} };
    $fields = $self->{fields};

    $patron_id = $fields->{ (FID_PATRON_ID) };
    Koha::Plugins->call('patron_barcode_transform', \$patron_id );
    $item_id   = $fields->{ (FID_ITEM_ID) };
    my $fee_ack = $fields->{ (FID_FEE_ACK) };

    if ( $no_block eq 'Y' ) {

        # Off-line transactions need to be recorded, but there's
        # not a lot we can do about it
        siplog( "LOG_WARNING", "received no-block checkout from terminal '%s'", $account->{id} );

        $status = $ils->checkout( $patron_id, $item_id, $sc_renewal_policy, $fee_ack, $account, $nb_due_date );
    } else {

        # Does the transaction date really matter for items that are
        # checkout out while the terminal is online?  I'm guessing 'no'
        $status = $ils->checkout( $patron_id, $item_id, $sc_renewal_policy, $fee_ack, $account );
    }

    $item   = $status->item;
    $patron = $status->patron;

    if ( $status->ok ) {

        # Item successfully checked out
        # Fixed fields
        $resp = CHECKOUT_RESP . '1';
        $resp .= sipbool( $status->renew_ok );
        if ( $ils->supports('magnetic media') ) {
            $resp .= sipbool( $item->magnetic_media );
        } else {
            $resp .= 'U';
        }

        # We never return the obsolete 'U' value for 'desensitize'
        $resp .= sipbool(
            desensitize(
                {
                    item   => $item,
                    patron => $patron,
                    server => $server,
                    status => $status,
                }
            )
        );
        $resp .= timestamp;

        # Now for the variable fields
        $resp .= add_field( FID_INST_ID,   $inst, $server );
        $resp .= add_field( FID_PATRON_ID, $patron_id, $server );
        $resp .= add_field( FID_ITEM_ID,   $item_id, $server );
        $resp .= add_field( FID_TITLE_ID,  $item->title_id, $server );
        if ( $item->due_date ) {
            my $due_date =
              $account->{format_due_date}
              ? output_pref( { str => $item->due_date, as_due_date => 1 } )
              : timestamp( $item->due_date );
            $resp .= add_field( FID_DUE_DATE, $due_date, $server );
        } else {
            $resp .= add_field( FID_DUE_DATE, q{}, $server );
        }

        $resp .= maybe_add( FID_SCREEN_MSG, $status->screen_msg, $server );
        $resp .= maybe_add( FID_PRINT_LINE, $status->print_line, $server );

        if ( $protocol_version >= 2 ) {
            if ( $ils->supports('security inhibit') ) {
                $resp .= add_field( FID_SECURITY_INHIBIT, $status->security_inhibit, $server );
            }
            $resp .= maybe_add( FID_MEDIA_TYPE, $item->sip_media_type, $server );
            $resp .= maybe_add( FID_ITEM_PROPS, $item->sip_item_properties, $server );

        }
    }

    else {

        # Checkout failed
        # Checkout Response: not ok, no renewal, don't know mag. media,
        # no desensitize
        $resp = sprintf( "120NUN%s", timestamp );
        $resp .= add_field( FID_INST_ID,   $inst, $server );
        $resp .= add_field( FID_PATRON_ID, $patron_id, $server );
        $resp .= add_field( FID_ITEM_ID,   $item_id, $server );

        # If the item is valid, provide the title, otherwise
        # leave it blank
        $resp .= add_field( FID_TITLE_ID, $item ? $item->title_id : '', $server );

        # Due date is required.  Since it didn't get checked out,
        # it's not due, so leave the date blank
        $resp .= add_field( FID_DUE_DATE, '', $server );

        $resp .= maybe_add( FID_SCREEN_MSG, $status->screen_msg, $server );
        $resp .= maybe_add( FID_PRINT_LINE, $status->print_line, $server );

        if ( $protocol_version >= 2 ) {

            # Is the patron ID valid?
            $resp .= add_field( FID_VALID_PATRON, sipbool($patron), $server );

            if ( $patron && exists( $fields->{FID_PATRON_PWD} ) ) {

                # Password provided, so we can tell if it was valid or not
                $resp .= add_field( FID_VALID_PATRON_PWD, sipbool( $patron->check_password( $fields->{ (FID_PATRON_PWD) } ) ), $server );
            }
        }
    }

    $resp .= $item->build_additional_item_fields_string( $server ) if $item;

    if ( $protocol_version >= 2 ) {

        # Financials : return irrespective of ok status
        if ( $status->fee_amount ) {
            $resp .= add_field( FID_FEE_AMT, $status->fee_amount, $server );
            $resp .= maybe_add( FID_CURRENCY,       $status->sip_currency, $server );
            $resp .= maybe_add( FID_FEE_TYPE,       $status->sip_fee_type, $server );
            $resp .= maybe_add( FID_TRANSACTION_ID, $status->transaction_id, $server );
        }
    }

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );
    return (CHECKOUT);
}

sub handle_checkin {
    my ( $self, $server ) = @_;
    my $account   = $server->{account};
    my $ils       = $server->{ils};
    my $my_branch = $ils->institution;
    my ( $current_loc, $inst_id, $item_id, $terminal_pwd, $item_props, $cancel );
    my ( $patron, $item, $status );
    my $resp = CHECKIN_RESP;
    my ( $no_block, $trans_date, $return_date ) = @{ $self->{fixed_fields} };
    my $fields = $self->{fields};

    $current_loc = $fields->{ (FID_CURRENT_LOCN) };
    $inst_id     = $fields->{ (FID_INST_ID) };
    $item_id     = $fields->{ (FID_ITEM_ID) };
    $item_props  = $fields->{ (FID_ITEM_PROPS) };
    $cancel      = $fields->{ (FID_CANCEL) };
    if ($current_loc) {
        $my_branch = $current_loc;    # most scm do not set $current_loc
    }

    $ils->check_inst_id( $inst_id, "handle_checkin" );

    if ( $no_block eq 'Y' ) {

        # Off-line transactions, ick.
        siplog( "LOG_WARNING", "received no-block checkin from terminal '%s' - no-block checkin not supported", $account->{id} );
        #FIXME We need to write the routine called below
        #$status = $ils->checkin_no_block( $item_id, $trans_date, $return_date, $item_props, $cancel );
        #Until we do, lets just checkin the item
        $status = $ils->checkin( $item_id, $trans_date, $return_date, $my_branch, $item_props, $cancel, $account );
    } else {
        $status = $ils->checkin( $item_id, $trans_date, $return_date, $my_branch, $item_props, $cancel, $account );
    }

    $patron = $status->patron;
    $item   = $status->item;

    $resp .= $status->ok          ? '1' : '0';
    $resp .= $status->resensitize ? 'Y' : 'N';
    if ( $item && $ils->supports('magnetic media') ) {
        $resp .= sipbool( $item->magnetic_media );
    } else {

        # item barcode is invalid or system doesn't support 'magnetic media' indicator
        $resp .= 'U';
    }

    $resp .= $status->alert ? 'Y' : 'N';
    $resp .= timestamp;
    $resp .= add_field( FID_INST_ID, $inst_id, $server );
    $resp .= add_field( FID_ITEM_ID, $item_id, $server );

    if ($item) {
        $resp .= add_field( FID_PERM_LOCN, $item->permanent_location, $server );
        $resp .= maybe_add( FID_TITLE_ID, $item->title_id, $server );
        $resp .= $item->build_additional_item_fields_string( $server );
    }

    if ( $protocol_version >= 2 ) {
        $resp .= maybe_add( FID_SORT_BIN, $status->sort_bin, $server );
        if ($patron) {
            $resp .= add_field( FID_PATRON_ID, $patron->id, $server );
        }
        if ($item) {
            $resp .= maybe_add( FID_MEDIA_TYPE,           $item->sip_media_type,      $server );
            $resp .= maybe_add( FID_ITEM_PROPS,           $item->sip_item_properties, $server );
            $resp .= maybe_add( FID_CALL_NUMBER,          $item->call_number,         $server );
            $resp .= maybe_add( FID_HOLD_PATRON_ID,       $item->hold_patron_bcode,   $server );
            $resp .= add_field( FID_DESTINATION_LOCATION, $item->destination_loc,     $server ) if ( $item->destination_loc || $server->{account}->{ct_always_send} );
            $resp .= maybe_add( FID_HOLD_PATRON_NAME,     $item->hold_patron_name( $server->{account}->{da_field_template} ), $server );

            if ( my $CR = $server->{account}->{cr_item_field} ) {
                $resp .= maybe_add( FID_COLLECTION_CODE, $item->{$CR}, $server );
            } else {
                $resp .= maybe_add( FID_COLLECTION_CODE, $item->collection_code, $server );
            }

            if ( $status->hold and $status->hold->{branchcode} ne $item->destination_loc ) {
                warn 'SIP hold mismatch: $status->hold->{branchcode}=' . $status->hold->{branchcode} . '; $item->destination_loc=' . $item->destination_loc;

                # just me being paranoid.
            }
        }
    }

    if ( $status->alert && $status->alert_type ) {
        $resp .= maybe_add( FID_ALERT_TYPE, $status->alert_type, $server );
    } elsif ( $server->{account}->{cv_send_00_on_success} ) {
        $resp .= add_field( FID_ALERT_TYPE, '00', $server );
    }
    $resp .= maybe_add( FID_SCREEN_MSG, $status->screen_msg, $server );
    $resp .= maybe_add( FID_PRINT_LINE, $status->print_line, $server );

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (CHECKIN);
}

sub handle_block_patron {
    my ( $self, $server ) = @_;
    my $account = $server->{account};
    my $ils     = $server->{ils};
    my ( $card_retained, $trans_date );
    my ( $inst_id, $blocked_card_msg, $patron_id, $terminal_pwd );
    my ( $fields, $resp, $patron );

    ( $card_retained, $trans_date ) = @{ $self->{fixed_fields} };
    $fields           = $self->{fields};
    $inst_id          = $fields->{ (FID_INST_ID) };
    $blocked_card_msg = $fields->{ (FID_BLOCKED_CARD_MSG) };
    $patron_id        = $fields->{ (FID_PATRON_ID) };
    $terminal_pwd     = $fields->{ (FID_TERMINAL_PWD) };

    Koha::Plugins->call('patron_barcode_transform', \$patron_id );

    # Terminal passwords are different from account login
    # passwords, but I have no idea what to do with them.  So,
    # I'll just ignore them for now.

    # FIXME ???

    $ils->check_inst_id( $inst_id, "block_patron" );
    $patron = $ils->find_patron($patron_id);

    # The correct response for a "Block Patron" message is a
    # "Patron Status Response", so use that handler to generate
    # the message, but then return the correct code from here.
    #
    # Normally, the language is provided by the "Patron Status"
    # fixed field, but since we're not responding to one of those
    # we'll just say, "Unspecified", as per the spec.  Let the
    # terminal default to something that, one hopes, will be
    # intelligible
    if ($patron) {

        # Valid patron id
        $patron->block( $card_retained, $blocked_card_msg );
    }

    $resp = build_patron_status( $patron, $patron->language, $fields, $server );
    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );
    return (BLOCK_PATRON);
}

sub handle_sc_status {
    my ( $self, $server ) = @_;
    ($server) or warn "handle_sc_status error: no \$server argument received.";
    my ( $status, $print_width, $sc_protocol_version ) = @{ $self->{fixed_fields} };
    my ($new_proto);

    if ( $sc_protocol_version =~ /^1\./ ) {
        $new_proto = 1;
    } elsif ( $sc_protocol_version =~ /^2\./ ) {
        $new_proto = 2;
    } else {
        siplog( "LOG_WARNING", "Unrecognized protocol revision '%s', falling back to '1'", $sc_protocol_version );
        $new_proto = 1;
    }

    if ( $new_proto != $protocol_version ) {
        siplog( "LOG_INFO", "Setting protocol level to $new_proto" );
        $protocol_version = $new_proto;
    }

    if ( $status == SC_STATUS_PAPER ) {
        siplog( "LOG_WARNING", "Self-Check unit '%s@%s' out of paper", $self->{account}->{id}, $self->{account}->{institution} );
    } elsif ( $status == SC_STATUS_SHUTDOWN ) {
        siplog( "LOG_WARNING", "Self-Check unit '%s@%s' shutting down", $self->{account}->{id}, $self->{account}->{institution} );
    }

    $self->{account}->{print_width} = $print_width;
    return ( send_acs_status( $self, $server ) ? SC_STATUS : '' );
}

sub handle_request_acs_resend {
    my ( $self, $server ) = @_;

    if ( !$last_response ) {

        # We haven't sent anything yet, so respond with a
        # REQUEST_SC_RESEND msg (p. 16)
        $self->write_msg( REQUEST_SC_RESEND, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );
    } elsif ( ( length($last_response) < 9 )
        || substr( $last_response, -9, 2 ) ne 'AY' ) {

        # When resending a message, we aren't supposed to include
        # a sequence number, even if the original had one (p. 4).
        # If the last message didn't have a sequence number, then
        # we can just send it.
        print("$last_response\r");    # not write_msg?
    } else {

        # Cut out the sequence number and checksum, since the old
        # checksum is wrong for the resent message.
        my $rebuilt = substr( $last_response, 0, -9 );
        $self->write_msg( $rebuilt, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );
    }

    return REQUEST_ACS_RESEND;
}

sub login_core {
    my $server = shift or return;
    my $uid    = shift;
    my $pwd    = shift;
    my $status = 1;                 # Assume it all works
    if ( !exists( $server->{config}->{accounts}->{$uid} ) ) {
        siplog( "LOG_WARNING", "MsgType::login_core: Unknown login '$uid'" );
        $status = 0;
    } elsif ( $server->{config}->{accounts}->{$uid}->{password} ne $pwd ) {
        siplog( "LOG_WARNING", "MsgType::login_core: Invalid password for login '$uid'" );
        $status = 0;
    } else {

        # Store the active account someplace handy for everybody else to find.
        $server->{account} = $server->{config}->{accounts}->{$uid};
        my $inst = $server->{account}->{institution};
        $server->{institution}  = $server->{config}->{institutions}->{$inst};
        $server->{policy}       = $server->{institution}->{policy};
        $server->{sip_username} = $uid;
        $server->{sip_password} = $pwd;

        my $auth_status = api_auth( $uid, $pwd, $inst );
        if ( !$auth_status or $auth_status !~ /^ok$/i ) {
            siplog( "LOG_WARNING", "api_auth failed for SIP terminal '%s' of '%s': %s", $uid, $inst, ( $auth_status || 'unknown' ) );
            $status = 0;
        } else {
            siplog( "LOG_INFO", "Successful login/auth for '%s' of '%s'", $server->{account}->{id}, $inst );

            #
            # initialize connection to ILS
            #
            my $module = $server->{config}->{institutions}->{$inst}->{implementation};
            siplog( "LOG_DEBUG", 'login_core: ' . Dumper($module) );

            # Suspect this is always ILS but so we don't break any eccentic install (for now)
            if ( $module eq 'ILS' ) {
                $module = 'C4::SIP::ILS';
            }
            $module->use;
            if ($@) {
                siplog( "LOG_ERR", "%s: Loading ILS implementation '%s' for institution '%s' failed", $server->{service}, $module, $inst );
                die("Failed to load ILS implementation '$module' for $inst");
            }

            # like   ILS->new(), I think.
            $server->{ils} = $module->new( $server->{institution}, $server->{account} );
            if ( !$server->{ils} ) {
                siplog( "LOG_ERR", "%s: ILS connection to '%s' failed", $server->{service}, $inst );
                die("Unable to connect to ILS '$inst'");
            }
        }
    }
    return $status;
}

sub handle_login {
    my ( $self, $server ) = @_;
    my ( $uid_algorithm, $pwd_algorithm );
    my ( $uid,           $pwd );
    my $inst;
    my $fields;
    my $status = 1;    # Assume it all works

    $fields = $self->{fields};
    ( $uid_algorithm, $pwd_algorithm ) = @{ $self->{fixed_fields} };

    $uid = $fields->{ (FID_LOGIN_UID) };    # Terminal ID, not patron ID.
    $pwd = $fields->{ (FID_LOGIN_PWD) };    # Terminal PWD, not patron PWD.

    if ( $uid_algorithm || $pwd_algorithm ) {
        siplog( "LOG_ERR", "LOGIN: Unsupported non-zero encryption method(s): uid = $uid_algorithm, pwd = $pwd_algorithm" );
        $status = 0;
    } else {
        $status = login_core( $server, $uid, $pwd );
    }

    $self->write_msg( LOGIN_RESP . $status, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );
    return $status ? LOGIN : '';
}

#
# Build the detailed summary information for the Patron
# Information Response message based on the first 'Y' that appears
# in the 'summary' field of the Patron Information request.  The
# specification says that only one 'Y' can appear in that field,
# and we're going to believe it.
#
sub summary_info {
    my ( $ils, $patron, $summary, $start, $end, $server ) = @_;
    my $resp = '';

    #
    # Map from offsets in the "summary" field of the Patron Information
    # message to the corresponding field and handler
    #
    my @summary_map = (
        { func => $patron->can("hold_items"),    fid => FID_HOLD_ITEMS },
        { func => $patron->can("overdue_items"), fid => FID_OVERDUE_ITEMS },
        { func => $patron->can("charged_items"), fid => FID_CHARGED_ITEMS },
        { func => $patron->can("fine_items"),    fid => FID_FINE_ITEMS },
        { func => $patron->can("recall_items"),  fid => FID_RECALL_ITEMS },
        { func => $patron->can("unavail_holds"), fid => FID_UNAVAILABLE_HOLD_ITEMS },
    );

    my $summary_type = index( $summary, 'Y' );
    return q{} if $summary_type == -1;    # No detailed information required.
    return q{} if $summary_type > 5;      # Positions 6-9 are not defined in the sip spec,
                                          # and we have no extensions to handle them.

    siplog( "LOG_DEBUG", "Summary_info: index == '%d', field '%s'", $summary_type, $summary_map[$summary_type]->{fid} );

    my $func     = $summary_map[$summary_type]->{func};
    my $fid      = $summary_map[$summary_type]->{fid};
    my $itemlist = &$func( $patron, $start, $end, $server );

    siplog( "LOG_DEBUG", "summary_info: list = (%s)", join( ", ", map{ $_->{barcode} } @{$itemlist} ) );
    foreach my $i ( @{$itemlist} ) {
        $resp .= add_field( $fid, $i->{barcode}, $server );
    }

    return $resp;
}

sub handle_patron_info {
    my ( $self, $server ) = @_;
    my $ils = $server->{ils};
    my ( $lang, $trans_date, $summary ) = @{ $self->{fixed_fields} };
    my $fields = $self->{fields};
    my ( $inst_id, $patron_id, $terminal_pwd, $patron_pwd, $start, $end );
    my ( $resp, $patron );

    $inst_id      = $fields->{ (FID_INST_ID) };
    $patron_id    = $fields->{ (FID_PATRON_ID) };
    $terminal_pwd = $fields->{ (FID_TERMINAL_PWD) };
    $patron_pwd   = $fields->{ (FID_PATRON_PWD) };
    $start        = $fields->{ (FID_START_ITEM) };
    $end          = $fields->{ (FID_END_ITEM) };

    Koha::Plugins->call('patron_barcode_transform', \$patron_id );

    $patron = $ils->find_patron($patron_id);

    $resp = (PATRON_INFO_RESP);
    if ($patron) {
        $patron->update_lastseen();
        $resp .= patron_status_string( $patron, $server );
        $resp .= ( defined($lang) and length($lang) == 3 ) ? $lang : $patron->language;
        $resp .= timestamp();

        $resp .= add_count( 'patron_info/hold_items',    scalar @{ $patron->hold_items } );
        $resp .= add_count( 'patron_info/overdue_items', scalar @{ $patron->overdue_items } );
        $resp .= add_count( 'patron_info/charged_items', scalar @{ $patron->charged_items } );
        $resp .= add_count( 'patron_info/fine_items',    scalar @{ $patron->fine_items } );
        $resp .= add_count( 'patron_info/recall_items',  scalar @{ $patron->recall_items } );
        $resp .= add_count( 'patron_info/unavail_holds', scalar @{ $patron->unavail_holds } );

        $resp .= add_field( FID_INST_ID, ( $ils->institution_id || 'SIP2' ), $server );

        # while the patron ID we got from the SC is valid, let's
        # use the one returned from the ILS, just in case...
        $resp .= add_field( FID_PATRON_ID,     $patron->id, $server );
        if ( defined $server->{account}->{ae_field_template} ) {
            $resp .= add_field( FID_PERSONAL_NAME, $patron->format( $server->{account}->{ae_field_template} ), $server );
        } else {
            $resp .= add_field( FID_PERSONAL_NAME, $patron->name, $server );
        }

        # TODO: add code for the fields
        #   hold items limit
        #   overdue items limit
        #   charged items limit

        $resp .= add_field( FID_VALID_PATRON, 'Y', $server );
        my $password_rc;
        if ( defined($patron_pwd) ) {

            # If patron password was provided, report whether it was right or not.
            if ( $patron_pwd eq q{} && $server->{account}->{allow_empty_passwords} ) {
                $password_rc = 1;
            } else {
                $password_rc = $patron->check_password($patron_pwd);
            }
            $resp .= add_field( FID_VALID_PATRON_PWD, sipbool( $password_rc ), $server );
        }

        $resp .= maybe_add( FID_CURRENCY, $patron->currency, $server );
        $resp .= maybe_add( FID_FEE_AMT,  $patron->fee_amount, $server );
        $resp .= add_field( FID_FEE_LMT, $patron->fee_limit, $server );

        # TODO: zero or more item details for 2.0 can go here:
        #          hold_items
        #       overdue_items
        #       charged_items
        #          fine_items
        #        recall_items

        $resp .= summary_info( $ils, $patron, $summary, $start, $end, $server );

        $resp .= maybe_add( FID_HOME_ADDR,  $patron->address, $server );
        $resp .= maybe_add( FID_EMAIL,      $patron->email_addr, $server );
        $resp .= maybe_add( FID_HOME_PHONE, $patron->home_phone, $server );

        # SIP 2.0 extensions used by Envisionware
        # Other terminals will ignore unrecognized fields (unrecognized field identifiers)
        $resp .= maybe_add( FID_PATRON_BIRTHDATE, $patron->birthdate, $server );
        $resp .= maybe_add( FID_PATRON_CLASS,     $patron->ptype, $server );

        # Custom protocol extension to report patron internet privileges
        $resp .= maybe_add( FID_INET_PROFILE, $patron->inet_privileges, $server );

        my $msg = $patron->screen_msg;
        if( defined( $patron_pwd ) && !$password_rc ) {
            $msg .= ' -- ' . INVALID_PW;
        }
        $resp .= maybe_add( FID_SCREEN_MSG, $msg, $server );
        if ( $server->{account}->{send_patron_home_library_in_af} ) {
            $resp .= maybe_add( FID_SCREEN_MSG, $patron->{branchcode}, $server);
        }
        $resp .= maybe_add( FID_PRINT_LINE, $patron->print_line, $server );

        $resp .= $patron->build_custom_field_string( $server );
        $resp .= $patron->build_patron_attributes_string( $server );
    } else {

        # Invalid patron ID:
        # no privileges, no items associated,
        # no personal name, and is invalid (if we're using 2.00)
        $resp .= 'YYYY' . ( ' ' x 10 ) . $lang . timestamp();
        $resp .= '0000' x 6;

        $resp .= add_field( FID_INST_ID, ( $ils->institution_id || 'SIP2' ), $server );

        # patron ID is invalid, but field is required, so just echo it back
        $resp .= add_field( FID_PATRON_ID, $fields->{ (FID_PATRON_ID) }, $server );
        $resp .= add_field( FID_PERSONAL_NAME, '', $server );

        if ( $protocol_version >= 2 ) {
            $resp .= add_field( FID_VALID_PATRON, 'N', $server );
        }
        $resp .= maybe_add( FID_SCREEN_MSG, INVALID_CARD, $server );
    }

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );
    return (PATRON_INFO);
}

sub handle_end_patron_session {
    my ( $self, $server ) = @_;
    my $ils = $server->{ils};
    my $trans_date;
    my $fields = $self->{fields};
    my $resp   = END_SESSION_RESP;
    my ( $status, $screen_msg, $print_line );

    ($trans_date) = @{ $self->{fixed_fields} };

    $ils->check_inst_id( $fields->{ (FID_INST_ID) }, 'handle_end_patron_session' );

    ( $status, $screen_msg, $print_line ) = $ils->end_patron_session( $fields->{ (FID_PATRON_ID) } );

    $resp .= $status ? 'Y' : 'N';
    $resp .= timestamp();

    $resp .= add_field( FID_INST_ID, $server->{ils}->institution, $server );
    $resp .= add_field( FID_PATRON_ID, $fields->{ (FID_PATRON_ID) }, $server );

    $resp .= maybe_add( FID_SCREEN_MSG, $screen_msg, $server );
    $resp .= maybe_add( FID_PRINT_LINE, $print_line, $server );

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (END_PATRON_SESSION);
}

sub handle_fee_paid {
    my ( $self, $server ) = @_;
    my $ils = $server->{ils};
    my ( $trans_date, $fee_type, $pay_type, $currency ) = @{ $self->{fixed_fields} };
    my $fields = $self->{fields};
    my ( $fee_amt, $inst_id, $patron_id, $terminal_pwd, $patron_pwd );
    my ( $fee_id, $trans_id );
    my $status;
    my $resp = FEE_PAID_RESP;

    my $disallow_overpayment  = $server->{account}->{disallow_overpayment};
    my $payment_type_writeoff = $server->{account}->{payment_type_writeoff} || q{};
    my $register_id           = $server->{account}->{register_id};

    my $is_writeoff = $pay_type eq $payment_type_writeoff;

    $fee_amt    = $fields->{ (FID_FEE_AMT) };
    $inst_id    = $fields->{ (FID_INST_ID) };
    $patron_id  = $fields->{ (FID_PATRON_ID) };
    $patron_pwd = $fields->{ (FID_PATRON_PWD) };
    $fee_id     = $fields->{ (FID_FEE_ID) };
    $trans_id   = $fields->{ (FID_TRANSACTION_ID) };

    Koha::Plugins->call('patron_barcode_transform', \$patron_id );

    $ils->check_inst_id( $inst_id, "handle_fee_paid" );

    my $pay_result = $ils->pay_fee( $patron_id, $patron_pwd, $fee_amt, $fee_type, $pay_type, $fee_id, $trans_id, $currency, $is_writeoff, $disallow_overpayment, $register_id );
    $status = $pay_result->{status};
    my $pay_response = $pay_result->{pay_response};

    my $failmap = {
        "no_item" => "No matching item could be found",
        "no_checkout" => "Item is not checked out",
        "too_soon" => "Cannot yet be renewed",
        "too_many" => "Renewed the maximum number of times",
        "auto_too_soon" => "Scheduled for automatic renewal and cannot yet be renewed",
        "auto_too_late" => "Scheduled for automatic renewal and cannot yet be any more",
        "auto_account_expired" => "Scheduled for automatic renewal and cannot be renewed because the patron's account has expired",
        "auto_renew" => "Scheduled for automatic renewal",
        "auto_too_much_oweing" => "Scheduled for automatic renewal",
        "on_reserve" => "On hold for another patron",
        "patron_restricted" => "Patron is currently restricted",
        "item_denied_renewal" => "Item is not allowed renewal",
        "onsite_checkout" => "Item is an onsite checkout"
    };
    my @success = ();
    my @fail = ();
    foreach my $result( @{$pay_response->{renew_result}} ) {
        my $item = Koha::Items->find({ itemnumber => $result->{itemnumber} });
        if ($result->{success}) {
            push @success, '"' . $item->biblio->title . '"';
        } else {
            push @fail, '"' . $item->biblio->title . '" : ' . $failmap->{$result->{error}};
        }
    }

    my $msg = "";
    if (scalar @success > 0) {
        $msg.="The following items were renewed: " . join(", ", @success) . ". ";
    }
    if (scalar @fail > 0) {
        $msg.="The following items were not renewed: " . join(", ", @fail) . ".";
    }
    if (length $msg > 0) {
        $status->screen_msg($status->screen_msg . " $msg");
    }

    $resp .= ( $status->ok ? 'Y' : 'N' ) . timestamp;
    $resp .= add_field( FID_INST_ID,   $inst_id, $server );
    $resp .= add_field( FID_PATRON_ID, $patron_id, $server );
    $resp .= maybe_add( FID_TRANSACTION_ID, $status->transaction_id, $server );
    $resp .= maybe_add( FID_SCREEN_MSG,     $status->screen_msg, $server );
    $resp .= maybe_add( FID_PRINT_LINE,     $status->print_line, $server );

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (FEE_PAID);
}

sub handle_item_information {
    my ( $self, $server ) = @_;
    my $account = $server->{account};
    my $ils     = $server->{ils};
    my $fields  = $self->{fields};
    my $resp    = ITEM_INFO_RESP;
    my $trans_date;
    my $item;
    my $i;

    ($trans_date) = @{ $self->{fixed_fields} };

    $ils->check_inst_id( $fields->{ (FID_INST_ID) }, "handle_item_information" );

    $item = $ils->find_item( $fields->{ (FID_ITEM_ID) } );

    if ( !defined($item) ) {

        # Invalid Item ID
        # "Other" circ stat, "Other" security marker, "Unknown" fee type
        $resp .= "010101";
        $resp .= timestamp;

        # Just echo back the invalid item id
        $resp .= add_field( FID_ITEM_ID, $fields->{ (FID_ITEM_ID) }, $server );

        # title id is required, but we don't have one
        $resp .= add_field( FID_TITLE_ID, '', $server );
    } else {

        # Valid Item ID, send the good stuff
        my $circulation_status = $item->sip_circulation_status;
        $resp .= $circulation_status;
        $resp .= $item->sip_security_marker;
        $resp .= $item->sip_fee_type;
        $resp .= timestamp;

        if ( $circulation_status eq '01' ) {
            $resp .= maybe_add( FID_SCREEN_MSG, "Item is damaged", $server );
        }

        $resp .= add_field( FID_ITEM_ID,  $item->id, $server );
        $resp .= add_field( FID_TITLE_ID, $item->title_id, $server );

        $resp .= maybe_add( FID_MEDIA_TYPE,   $item->sip_media_type, $server );
        $resp .= maybe_add( FID_PERM_LOCN,    $item->permanent_location, $server );
        $resp .= maybe_add( FID_CURRENT_LOCN, $item->current_location, $server );
        $resp .= maybe_add( FID_ITEM_PROPS,   $item->sip_item_properties, $server );


        if ( my $CR = $server->{account}->{cr_item_field} ) {
                $resp .= maybe_add( FID_COLLECTION_CODE, $item->{$CR}, $server );
        } else {
          $resp .= maybe_add( FID_COLLECTION_CODE, $item->collection_code, $server );
        }

        if ( ( $i = $item->fee ) != 0 ) {
            $resp .= add_field( FID_CURRENCY, $item->fee_currency, $server );
            $resp .= add_field( FID_FEE_AMT,  $i, $server );
        }
        $resp .= maybe_add( FID_OWNER, $item->owner, $server );

        if ( ( $i = scalar @{ $item->hold_queue } ) > 0 ) {
            $resp .= add_field( FID_HOLD_QUEUE_LEN, $i, $server );
        }
        if ( $item->due_date ) {
            my $due_date =
              $account->{format_due_date}
              ? output_pref( { str => $item->due_date, as_due_date => 1 } )
              : timestamp( $item->due_date );
            $resp .= add_field( FID_DUE_DATE, $due_date, $server );
        }
        if ( ( $i = $item->recall_date ) != 0 ) {
            $resp .= add_field( FID_RECALL_DATE, timestamp($i), $server );
        }
        if ( ( $i = $item->hold_pickup_date ) != 0 ) {
            $resp .= add_field( FID_HOLD_PICKUP_DATE, timestamp($i), $server );
        }

        $resp .= maybe_add( FID_SCREEN_MSG, $item->screen_msg, $server );
        $resp .= maybe_add( FID_PRINT_LINE, $item->print_line, $server );

        $resp .= $item->build_additional_item_fields_string( $server );
        $resp .= $item->build_custom_field_string( $server );
    }

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (ITEM_INFORMATION);
}

sub handle_item_status_update {
    my ( $self, $server ) = @_;
    my $ils = $server->{ils};
    my ( $trans_date, $item_id, $terminal_pwd, $item_props );
    my $fields = $self->{fields};
    my $status;
    my $item;
    my $resp = ITEM_STATUS_UPDATE_RESP;

    ($trans_date) = @{ $self->{fixed_fields} };

    $ils->check_inst_id( $fields->{ (FID_INST_ID) } );

    $item_id    = $fields->{ (FID_ITEM_ID) };
    $item_props = $fields->{ (FID_ITEM_PROPS) };

    if ( !defined($item_id) ) {
        siplog( "LOG_WARNING", "handle_item_status: received message without Item ID field" );
    } else {
        $item = $ils->find_item($item_id);
    }

    if ( !$item ) {

        # Invalid Item ID
        $resp .= '0';
        $resp .= timestamp;
        $resp .= add_field( FID_ITEM_ID, $item_id, $server );
    } else {

        # Valid Item ID

        $status = $item->status_update($item_props);

        $resp .= $status->ok ? '1' : '0';
        $resp .= timestamp;

        $resp .= add_field( FID_ITEM_ID,  $item->id, $server );
        $resp .= add_field( FID_TITLE_ID, $item->title_id, $server );
        $resp .= maybe_add( FID_ITEM_PROPS, $item->sip_item_properties, $server );
    }

    $resp .= maybe_add( FID_SCREEN_MSG, $status->screen_msg, $server );
    $resp .= maybe_add( FID_PRINT_LINE, $status->print_line, $server );

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (ITEM_STATUS_UPDATE);
}

sub handle_patron_enable {
    my ( $self, $server ) = @_;
    my $ils    = $server->{ils};
    my $fields = $self->{fields};
    my ( $trans_date, $patron_id, $terminal_pwd, $patron_pwd );
    my ( $status, $patron );
    my $resp = PATRON_ENABLE_RESP;

    ($trans_date) = @{ $self->{fixed_fields} };
    $patron_id  = $fields->{ (FID_PATRON_ID) };
    $patron_pwd = $fields->{ (FID_PATRON_PWD) };

    Koha::Plugins->call('patron_barcode_transform', \$patron_id );

    siplog( "LOG_DEBUG", "handle_patron_enable: patron_id: '%s', patron_pwd: '%s'", $patron_id, $patron_pwd );

    $patron = $ils->find_patron($patron_id);

    if ( !defined($patron) ) {

        # Invalid patron ID
        $resp .= 'YYYY' . ( ' ' x 10 ) . '000' . timestamp();
        $resp .= add_field( FID_PATRON_ID,        $patron_id, $server );
        $resp .= add_field( FID_PERSONAL_NAME,    '', $server );
        $resp .= add_field( FID_VALID_PATRON,     'N', $server );
        $resp .= add_field( FID_VALID_PATRON_PWD, 'N', $server );
    } else {

        # valid patron
        if ( !defined($patron_pwd) || $patron->check_password($patron_pwd) ) {

            # Don't enable the patron if there was an invalid password
            $status = $patron->enable;
        }
        $resp .= patron_status_string( $patron, $server );
        $resp .= $patron->language . timestamp();

        $resp .= add_field( FID_PATRON_ID,     $patron->id, $server );
        $resp .= add_field( FID_PERSONAL_NAME, $patron->format( $server->{account}->{ae_field_template} ), $server );
        if ( defined($patron_pwd) ) {
            $resp .= add_field( FID_VALID_PATRON_PWD, sipbool( $patron->check_password($patron_pwd) ), $server );
        }
        $resp .= add_field( FID_VALID_PATRON, 'Y', $server );
        $resp .= maybe_add( FID_SCREEN_MSG, $patron->screen_msg, $server );
        $resp .= maybe_add( FID_PRINT_LINE, $patron->print_line, $server );
    }

    $resp .= add_field( FID_INST_ID, $ils->institution, $server );

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (PATRON_ENABLE);
}

sub handle_hold {
    my ( $self, $server ) = @_;
    my $ils = $server->{ils};
    my ( $hold_mode, $trans_date );
    my ( $expiry_date, $pickup_locn, $hold_type, $patron_id, $patron_pwd );
    my ( $item_id, $title_id, $fee_ack );
    my $fields = $self->{fields};
    my $status;
    my $resp = HOLD_RESP;

    ( $hold_mode, $trans_date ) = @{ $self->{fixed_fields} };

    $ils->check_inst_id( $fields->{ (FID_INST_ID) }, "handle_hold" );

    $patron_id   = $fields->{ (FID_PATRON_ID) };
    $expiry_date = $fields->{ (FID_EXPIRATION) } || '';
    $pickup_locn = $fields->{ (FID_PICKUP_LOCN) } || '';
    $hold_type   = $fields->{ (FID_HOLD_TYPE) } || '2';    # Any copy of title
    $patron_pwd  = $fields->{ (FID_PATRON_PWD) };
    $item_id     = $fields->{ (FID_ITEM_ID) } || '';
    $title_id    = $fields->{ (FID_TITLE_ID) } || '';
    $fee_ack     = $fields->{ (FID_FEE_ACK) } || 'N';

    Koha::Plugins->call('patron_barcode_transform', \$patron_id );

    if ( $hold_mode eq '+' ) {
        $status = $ils->add_hold( $patron_id, $patron_pwd, $item_id, $title_id, $expiry_date, $pickup_locn, $hold_type, $fee_ack );
    } elsif ( $hold_mode eq '-' ) {
        $status = $ils->cancel_hold( $patron_id, $patron_pwd, $item_id, $title_id );
    } elsif ( $hold_mode eq '*' ) {
        $status = $ils->alter_hold( $patron_id, $patron_pwd, $item_id, $title_id, $expiry_date, $pickup_locn, $hold_type, $fee_ack );
    } else {
        siplog( "LOG_WARNING", "handle_hold: Unrecognized hold mode '%s' from terminal '%s'", $hold_mode, $server->{account}->{id} );
        $status = $ils->Transaction::Hold;    # new?
        $status->screen_msg("System error. Please contact library staff.");
    }

    $resp .= $status->ok;
    $resp .= sipbool( $status->item && $status->item->available($patron_id) );
    $resp .= timestamp;

    if ( $status->ok ) {
        $resp .= add_field( FID_PATRON_ID, $status->patron->id, $server );

        ( $status->expiration_date )
          and $resp .= maybe_add( FID_EXPIRATION, timestamp( $status->expiration_date ), $server );
        $resp .= maybe_add( FID_QUEUE_POS,   $status->queue_position, $server );
        $resp .= maybe_add( FID_PICKUP_LOCN, $status->pickup_location, $server );
        $resp .= maybe_add( FID_ITEM_ID,     $status->item->id, $server );
        $resp .= maybe_add( FID_TITLE_ID,    $status->item->title_id, $server );
    } else {

        # Not ok.  still need required fields
        $resp .= add_field( FID_PATRON_ID, $patron_id, $server );
    }

    $resp .= add_field( FID_INST_ID, $ils->institution, $server );
    $resp .= maybe_add( FID_SCREEN_MSG, $status->screen_msg, $server );
    $resp .= maybe_add( FID_PRINT_LINE, $status->print_line, $server );

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (HOLD);
}

sub handle_renew {
    my ( $self, $server ) = @_;
    my $ils = $server->{ils};
    my ( $third_party, $no_block, $trans_date, $nb_due_date );
    my ( $patron_id, $patron_pwd, $item_id, $title_id, $item_props, $fee_ack );
    my $fields = $self->{fields};
    my $status;
    my ( $patron, $item );
    my $resp = RENEW_RESP;

    ( $third_party, $no_block, $trans_date, $nb_due_date ) = @{ $self->{fixed_fields} };

    $ils->check_inst_id( $fields->{ (FID_INST_ID) }, "handle_renew" );

    if ( $no_block eq 'Y' ) {
        siplog( "LOG_WARNING", "handle_renew: received 'no block' renewal from terminal '%s'", $server->{account}->{id} );
    }

    $patron_id  = $fields->{ (FID_PATRON_ID) };
    $patron_pwd = $fields->{ (FID_PATRON_PWD) };
    $item_id    = $fields->{ (FID_ITEM_ID) };
    $title_id   = $fields->{ (FID_TITLE_ID) };
    $item_props = $fields->{ (FID_ITEM_PROPS) };
    $fee_ack    = $fields->{ (FID_FEE_ACK) };

    Koha::Plugins->call('patron_barcode_transform', \$patron_id );

    $status = $ils->renew( $patron_id, $patron_pwd, $item_id, $title_id, $no_block, $nb_due_date, $third_party, $item_props, $fee_ack );

    $patron = $status->patron;
    $item   = $status->item;

    if ( $status->renewal_ok ) {
        $resp .= '1';
        $resp .= $status->renewal_ok ? 'Y' : 'N';
        if ( $ils->supports('magnetic media') ) {
            $resp .= sipbool( $item->magnetic_media );
        } else {
            $resp .= 'U';
        }
        $resp .= sipbool( desensitize( { status => $status, patron => $patron, server => $server } ) );
        $resp .= timestamp;
        $resp .= add_field( FID_PATRON_ID, $patron->id, $server );
        $resp .= add_field( FID_ITEM_ID, $item->id, $server );
        $resp .= add_field( FID_TITLE_ID, $item->title_id, $server );
        if ( $item->due_date ) {
            $resp .= add_field( FID_DUE_DATE, timestamp( $item->due_date ), $server );
        } else {
            $resp .= add_field( FID_DUE_DATE, q{}, $server );
        }
        if ( $ils->supports('security inhibit') ) {
            $resp .= add_field( FID_SECURITY_INHIBIT, $status->security_inhibit, $server );
        }
        $resp .= add_field( FID_MEDIA_TYPE, $item->sip_media_type, $server );
        $resp .= maybe_add( FID_ITEM_PROPS, $item->sip_item_properties, $server );
    } else {

        # renew failed for some reason
        # not OK, renewal not OK, Unknown media type (why bother checking?)
        $resp .= '0NUN';
        $resp .= timestamp;

        # If we found the patron or the item, the return the ILS
        # information, otherwise echo back the information we received
        # from the terminal
        $resp .= add_field( FID_PATRON_ID, $patron ? $patron->id     : $patron_id, $server );
        $resp .= add_field( FID_ITEM_ID,   $item   ? $item->id       : $item_id, $server );
        $resp .= add_field( FID_TITLE_ID,  $item   ? $item->title_id : $title_id, $server );
        $resp .= add_field( FID_DUE_DATE,  '', $server );
    }

    if ( $status->fee_amount ) {
        $resp .= add_field( FID_FEE_AMT, $status->fee_amount, $server );
        $resp .= maybe_add( FID_CURRENCY,       $status->sip_currency, $server );
        $resp .= maybe_add( FID_FEE_TYPE,       $status->sip_fee_type, $server );
        $resp .= maybe_add( FID_TRANSACTION_ID, $status->transaction_id, $server );
    }

    $resp .= add_field( FID_INST_ID, $ils->institution, $server );
    $resp .= maybe_add( FID_SCREEN_MSG, $status->screen_msg, $server );
    $resp .= maybe_add( FID_PRINT_LINE, $status->print_line, $server );

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (RENEW);
}

sub handle_renew_all {

    # my ($third_party, $no_block, $nb_due_date, $fee_ack, $patron);

    my ( $self, $server ) = @_;
    my $ils = $server->{ils};
    my ( $trans_date, $patron_id, $patron_pwd, $terminal_pwd, $fee_ack );
    my $fields = $self->{fields};
    my $resp   = RENEW_ALL_RESP;
    my $status;
    my ( @renewed, @unrenewed );

    $ils->check_inst_id( $fields->{ (FID_INST_ID) }, "handle_renew_all" );

    ($trans_date) = @{ $self->{fixed_fields} };

    $patron_id    = $fields->{ (FID_PATRON_ID) };
    $patron_pwd   = $fields->{ (FID_PATRON_PWD) };
    $terminal_pwd = $fields->{ (FID_TERMINAL_PWD) };
    $fee_ack      = $fields->{ (FID_FEE_ACK) };

    Koha::Plugins->call('patron_barcode_transform', \$patron_id );

    $status = $ils->renew_all( $patron_id, $patron_pwd, $fee_ack );

    $resp .= $status->ok ? '1' : '0';

    if ( !$status->ok ) {
        $resp .= add_count( "renew_all/renewed_count",   0 );
        $resp .= add_count( "renew_all/unrenewed_count", 0 );
        @renewed   = ();
        @unrenewed = ();
    } else {
        @renewed   = ( @{ $status->renewed } );
        @unrenewed = ( @{ $status->unrenewed } );
        $resp .= add_count( "renew_all/renewed_count",   scalar @renewed );
        $resp .= add_count( "renew_all/unrenewed_count", scalar @unrenewed );
    }

    $resp .= timestamp;
    $resp .= add_field( FID_INST_ID, $ils->institution, $server );

    $resp .= join( '', map( add_field( FID_RENEWED_ITEMS,   $_ ), @renewed ), $server );
    $resp .= join( '', map( add_field( FID_UNRENEWED_ITEMS, $_ ), @unrenewed ), $server );

    $resp .= maybe_add( FID_SCREEN_MSG, $status->screen_msg, $server );
    $resp .= maybe_add( FID_PRINT_LINE, $status->print_line, $server );

    $self->write_msg( $resp, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );

    return (RENEW_ALL);
}

#
# send_acs_status($self, $server)
#
# Send an ACS Status message, which is contains lots of little fields
# of information gleaned from all sorts of places.
#

my @message_type_names = (
    "patron status request",
    "checkout",
    "checkin",
    "block patron",
    "acs status",
    "request sc/acs resend",
    "login",
    "patron information",
    "end patron session",
    "fee paid",
    "item information",
    "item status update",
    "patron enable",
    "hold",
    "renew",
    "renew all",
);

sub send_acs_status {
    my ( $self, $server, $screen_msg, $print_line ) = @_;

    my $msg = ACS_STATUS;
    ($server) or die "send_acs_status error: no \$server argument received";
    my $account = $server->{account} or die "send_acs_status error: no 'account' in \$server object:\n" . Dumper($server);
    my $policy  = $server->{policy}  or die "send_acs_status error: no 'policy' in \$server object:\n" . Dumper($server);
    my $ils     = $server->{ils}     or die "send_acs_status error: no 'ils' in \$server object:\n" . Dumper($server);
    my $sip_username = $server->{sip_username} or die "send_acs_status error: no 'sip_username' in \$server object:\n" . Dumper($server);
    my ( $online_status,    $checkin_ok, $checkout_ok, $ACS_renewal_policy );
    my ( $status_update_ok, $offline_ok, $timeout,     $retries );
    my $sip_user = Koha::Patrons->find({ userid => $sip_username });
    die "send_acs_status error: sip_username cannot be found in DB or DB cannot be reached" unless $sip_user;

    $online_status      = 'Y';
    $checkout_ok        = sipbool( $ils->checkout_ok );
    $checkin_ok         = sipbool( $ils->checkin_ok );
    $ACS_renewal_policy = sipbool( $policy->{renewal} );
    $status_update_ok   = sipbool( $ils->status_update_ok );
    $offline_ok         = sipbool( $ils->offline_ok );
    $timeout            = $server->get_timeout({ policy => 1 });
    $retries            = sprintf( "%03d", $policy->{retries} );

    if ( length($retries) != 3 ) {
        siplog( "LOG_ERR", "handle_acs_status: retries field wrong size: '%s'", $retries );
        $retries = '000';
    }

    $msg .= "$online_status$checkin_ok$checkout_ok$ACS_renewal_policy";
    $msg .= "$status_update_ok$offline_ok$timeout$retries";
    $msg .= timestamp();

    if ( $protocol_version == 1 ) {
        $msg .= '1.00';
    } elsif ( $protocol_version == 2 ) {
        $msg .= '2.00';
    } else {
        siplog( "LOG_ERR", 'Bad setting for $protocol_version, "%s" in send_acs_status', $protocol_version );
        $msg .= '1.00';
    }

    # Institution ID
    $msg .= add_field( FID_INST_ID, $account->{institution}, $server );

    if ( $protocol_version >= 2 ) {

        # Supported messages: we do it all
        my $supported_msgs = '';

        foreach my $msg_name (@message_type_names) {
            if ( $msg_name eq 'request sc/acs resend' ) {
                $supported_msgs .= sipbool(1);
            } else {
                $supported_msgs .= sipbool( $ils->supports($msg_name) );
            }
        }
        if ( length($supported_msgs) < 16 ) {
            siplog( "LOG_ERR", 'send_acs_status: supported messages "%s" too short', $supported_msgs );
        }
        $msg .= add_field( FID_SUPPORTED_MSGS, $supported_msgs, $server );
    }

    $msg .= maybe_add( FID_SCREEN_MSG, $screen_msg, $server );

    if (   defined( $account->{print_width} )
        && defined($print_line)
        && $account->{print_width} < length($print_line) ) {
        siplog( "LOG_WARNING", "send_acs_status: print line '%s' too long.  Truncating", $print_line );
        $print_line = substr( $print_line, 0, $account->{print_width} );
    }

    $msg .= maybe_add( FID_PRINT_LINE, $print_line, $server );

    # Do we want to tell the terminal its location?

    $self->write_msg( $msg, undef, $server->{account}->{terminator}, $server->{account}->{encoding} );
    return 1;
}

#
# build_patron_status: create the 14-char patron status
# string for the Patron Status message
#
sub patron_status_string {
    my $patron = shift;
    my $server = shift;

    my $patron_status;

    my $too_many_lost = 0;
    if ( my $lost_block_checkout = $server->{account}->{lost_block_checkout} ) {
        my $lost_block_checkout_value = $server->{account}->{lost_block_checkout_value} // 1;
        my $lost_checkouts = Koha::Checkouts->search({ borrowernumber => $patron->borrowernumber, 'itemlost' => { '>=', $lost_block_checkout_value } }, { join => 'item'} )->count;
        $too_many_lost = $lost_checkouts >= $lost_block_checkout;
    }

    siplog( "LOG_DEBUG", "patron_status_string: %s charge_ok: %s", $patron->id, $patron->charge_ok );
    $patron_status = sprintf(
        '%s%s%s%s%s%s%s%s%s%s%s%s%s%s',
        denied( $patron->charge_ok ),
        denied( $patron->renew_ok ),
        denied( $patron->recall_ok ),
        denied( $patron->hold_ok ),
        boolspace( $patron->card_lost ),
        boolspace( $patron->too_many_charged ),
        $server->{account}->{overdues_block_checkout} ? boolspace( $patron->too_many_overdue ) : q{ },
        boolspace( $patron->too_many_renewal ),
        boolspace( $patron->too_many_claim_return ),
        boolspace( $too_many_lost ),
        boolspace( $patron->excessive_fines ),
        boolspace( $patron->excessive_fees ),
        boolspace( $patron->recall_overdue ),
        boolspace( $patron->too_many_billed )
    );
    return $patron_status;
}

sub api_auth {
    my ( $username, $password, $branch ) = @_;
    $ENV{REMOTE_USER} = $username;
    my $query = CGI->new();
    $query->param( userid   => $username );
    $query->param( password => $password );
    if ($branch) {
        $query->param( branch => $branch );
    }
    my ( $status, $cookie, $sessionID ) = check_api_auth( $query, { circulate => 1 }, 'intranet' );
    return $status;
}

sub desensitize {
    my ($params) = @_;

    my $status      = $params->{status};
    my $desensitize = $status->desensitize();

    # If desenstize is already false, no need to do anything
    return unless $desensitize;

    my $patron = $params->{patron};
    my $item   = $params->{item};
    my $server = $params->{server};

    my $patron_categories = $server->{account}->{inhouse_patron_categories} // q{};
    my $item_types = $server->{account}->{inhouse_item_types} // q{};

    # If no patron categories or item types are set for never desensitize, no need to do anything
    return $desensitize unless $patron_categories || $item_types;

    my $patron_category = $patron->ptype();
    my @patron_categories = split( /,/, $patron_categories );
    my $found_patron_category = grep( /^$patron_category$/, @patron_categories );
    return 0 if $found_patron_category;

    my $item_type = $item->itemtype;
    my @item_types = split( /,/, $item_types );
    my $found_item_type = grep( /^$item_type$/, @item_types );
    return 0 if $found_item_type;

    return 1;
}

1;
__END__

