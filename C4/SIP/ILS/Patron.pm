#
# ILS::Patron.pm
#
# A Class for hiding the ILS's concept of the patron from the OpenSIP
# system
#

package C4::SIP::ILS::Patron;

use strict;
use warnings;
use Exporter;
use Carp;

use C4::SIP::Sip qw(siplog);
use Data::Dumper;

use C4::SIP::Sip qw(add_field maybe_add);

use C4::Context;
use C4::Koha;
use C4::Members;
use C4::Reserves;
use C4::Auth qw(checkpw);

use Koha::Items;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Checkouts;
use Koha::TemplateUtils qw( process_tt );
use Koha::Patron::Messages;
use Koha::DateUtils qw(dt_from_string output_pref);
use Date::Calc      qw/Today Date_to_Days/;

our $kp;    # koha patron

=head1 Methods

=cut

=head2 new

Missing POD for new.

=cut

sub new {
    my ( $class, $patron_id ) = @_;
    my $type = ref($class) || $class;
    my $self;

    my $patron;
    if ( ref $patron_id eq "HASH" ) {
        if ( $patron_id->{borrowernumber} ) {
            $patron = Koha::Patrons->find( $patron_id->{borrowernumber} );
        } elsif ( $patron_id->{cardnumber} ) {
            $patron = Koha::Patrons->find( { cardnumber => $patron_id->{cardnumber} } );
        } elsif ( $patron_id->{userid} ) {
            $patron = Koha::Patrons->find( { userid => $patron_id->{userid} } );
        }
    } else {
        $patron = Koha::Patrons->find_by_identifier($patron_id);
    }

    unless ($patron) {
        siplog( "LOG_DEBUG", "new ILS::Patron(%s): no such patron", $patron_id );
        return;
    }
    $kp = $patron->unblessed;
    my $pw       = $kp->{password};
    my $flags    = C4::Members::patronflags($kp);
    my $debarred = $patron->is_debarred;
    siplog( "LOG_DEBUG", "Debarred = %s : ", ( $debarred || 'undef' ) );    # Do we need more debug info here?
    my $expired = 0;
    if ( $kp->{'dateexpiry'} ) {
        my ( $today_year, $today_month, $today_day ) = Today();
        my ( $warning_year, $warning_month, $warning_day ) = split /-/, $kp->{'dateexpiry'};
        my $days_to_expiry = Date_to_Days( $warning_year, $warning_month, $warning_day ) -
            Date_to_Days( $today_year, $today_month, $today_day );
        my $dt                      = dt_from_string( $kp->{'dateexpiry'}, 'iso' );
        my $dateexpiry              = output_pref( { dt => $dt, dateonly => 1 } );
        my $notifyBorrowerDeparture = C4::Context->preference('NotifyBorrowerDeparture') // 0;
        if ( $days_to_expiry < 0 ) {

            #borrower card has expired, warn the borrower
            if ( $kp->{opacnote} ) {
                $kp->{opacnote} .= q{ };
            }
            $kp->{opacnote} .= "Your account has expired as of $dateexpiry";
            $expired = 1;
        } elsif ( $days_to_expiry < $notifyBorrowerDeparture ) {

            # borrower card soon to expire, warn the borrower
            if ( $kp->{opacnote} ) {
                $kp->{opacnote} .= q{ };
            }
            $kp->{opacnote} .= "Your card will expire on $dateexpiry";
        }
    }
    my %ilspatron;
    my $adr = _get_address($kp);
    my $dob = $kp->{dateofbirth};
    $dob and $dob =~ s/-//g;            # YYYYMMDD
    my $dexpiry = $kp->{dateexpiry};
    $dexpiry and $dexpiry =~ s/-//g;    # YYYYMMDD

    # Get fines and add fines for guarantees (depends on preference NoIssuesChargeGuarantees)
    my $patron_charge_limits  = $patron->is_patron_inside_charge_limits();
    my $fines_amount          = $patron_charge_limits->{noissuescharge}->{charge};
    my $personal_fines_amount = $fines_amount;
    my $fee_limit             = $patron_charge_limits->{noissuescharge}->{limit} || 5;
    my $noissueschargeguarantorswithguarantees =
        $patron_charge_limits->{NoIssuesChargeGuarantorsWithGuarantees}->{limit};
    my $noissueschargeguarantees = $patron_charge_limits->{NoIssuesChargeGuarantees}->{limit};

    my $fines_msg    = "";
    my $fine_blocked = 0;
    if ( $patron_charge_limits->{noissuescharge}->{overlimit} ) {
        $fine_blocked = 1;
        $fines_msg .= " -- " . "Patron blocked by fines" if $fine_blocked;
    } elsif ($noissueschargeguarantorswithguarantees) {
        $fines_amount = $patron_charge_limits->{NoIssuesChargeGuarantorsWithGuarantees}->{charge};
        $fine_blocked = $patron_charge_limits->{NoIssuesChargeGuarantorsWithGuarantees}->{overlimit};
        $fines_msg .= " -- " . "Patron blocked by fines ($fines_amount) on related accounts" if $fine_blocked;
    } elsif ($noissueschargeguarantees) {
        if ( $patron->guarantee_relationships->count ) {
            $fines_amount += $patron_charge_limits->{NoIssuesChargeGuarantees}->{charge};
            $fine_blocked = $patron_charge_limits->{NoIssuesChargeGuarantees}->{overlimit};
            $fines_msg .= " -- " . "Patron blocked by fines ($fines_amount) on guaranteed accounts" if $fine_blocked;
        }
    }

    # Get currency 3 chars max
    my $currency = Koha::Acquisition::Currencies->get_active;
    if ($currency) {
        $currency = substr $currency->currency, 0, 3;
    }

    my $circ_blocked =
        ( C4::Context->preference('OverduesBlockCirc') ne "noblock" && defined $flags->{ODUES}->{itemlist} ) ? 1 : 0;
    {
        no warnings;    # any of these $kp->{fields} being concat'd could be undef
        %ilspatron = (
            name            => $kp->{firstname} . " " . $kp->{surname},
            id              => $kp->{cardnumber},                         # to SIP, the id is the BARCODE, not userid
            password        => $pw,
            ptype           => $kp->{categorycode},                       # 'A'dult.  Whatever.
            dateexpiry      => $dexpiry,
            dateexpiry_iso  => $kp->{dateexpiry},
            birthdate       => $dob,
            birthdate_iso   => $kp->{dateofbirth},
            branchcode      => $kp->{branchcode},
            library_name    => "",                                        # only populated if needed, cached here
            borrowernumber  => $kp->{borrowernumber},
            address         => $adr,
            home_phone      => $kp->{phone},
            email_addr      => $kp->{email},
            charge_ok       => ( !$debarred && !$expired && !$fine_blocked && !$circ_blocked ),
            renew_ok        => ( !$debarred && !$expired && !$fine_blocked ),
            recall_ok       => ( !$debarred && !$expired && !$fine_blocked ),
            hold_ok         => ( !$debarred && !$expired && !$fine_blocked ),
            card_lost       => ( $kp->{lost} || $kp->{gonenoaddress} || $flags->{LOST} ),
            claims_returned => 0,
            fines           => $personal_fines_amount,
            fees           => 0,                                                     # currently not distinct from fines
            recall_overdue => 0,
            items_billed   => 0,
            screen_msg     => 'Greetings from Koha. ' . $kp->{opacnote} . $fines_msg,
            print_line     => '',
            items          => [],
            hold_items     => $flags->{WAITING}->{itemlist},
            overdue_items  => $flags->{ODUES}->{itemlist},
            too_many_overdue => $circ_blocked,
            fine_items       => [],
            recall_items     => [],
            unavail_holds    => [],
            inet             => ( !$debarred && !$expired ),
            debarred         => $debarred,
            expired          => $expired,
            fine_blocked     => $fine_blocked,
            fee_limit        => $fee_limit,
            userid           => $kp->{userid},
            currency         => $currency,
        );
    }

    if ( $patron->is_debarred and $patron->debarredcomment ) {
        $ilspatron{screen_msg} .= " -- " . $patron->debarredcomment;
    }

    if ($circ_blocked) {
        $ilspatron{screen_msg} .= " -- " . "Patron has overdues";
    }

    for (qw(EXPIRED CHARGES CREDITS GNA LOST NOTES)) {
        ( $flags->{$_} ) or next;
        if ( $_ ne 'NOTES' and $flags->{$_}->{message} ) {
            $ilspatron{screen_msg} .= " -- " . $flags->{$_}->{message};    # show all but internal NOTES
        }
        if ( $flags->{$_}->{noissues} ) {
            foreach my $toggle (qw(charge_ok renew_ok recall_ok hold_ok inet)) {
                $ilspatron{$toggle} = 0;                                   # if we get noissues, disable everything
            }
        }
    }

    if ( C4::Context->preference('SIP2AddOpacMessagesToScreenMessage') ) {
        my $patron_messages = Koha::Patron::Messages->search(
            {
                borrowernumber => $kp->{borrowernumber},
                message_type   => 'B',
            }
        );
        my @messages_array;
        while ( my $message = $patron_messages->next ) {
            my $messagedt      = dt_from_string( $message->message_date, 'iso' );
            my $formatted_date = output_pref( { dt => $messagedt, dateonly => 1 } );
            push @messages_array, $formatted_date . ": " . $message->message;
        }
        if (@messages_array) {
            $ilspatron{screen_msg} .= " Messages for you: " . join( ' / ', @messages_array );
        }
    }

    # FIXME: populate recall_items
    $ilspatron{unavail_holds} = _get_outstanding_holds( $kp->{borrowernumber} );

    my $pending_checkouts = $patron->pending_checkouts;
    my @barcodes;
    while ( my $c = $pending_checkouts->next ) {
        push @barcodes, { barcode => $c->item->barcode };
    }
    $ilspatron{items} = \@barcodes;

    $self = \%ilspatron;
    siplog( "LOG_DEBUG", "new ILS::Patron(%s): found patron '%s'", $patron_id, $self->{id} );
    bless $self, $type;
    return $self;
}

# 0 means read-only
# 1 means read/write

my %fields = (
    id                    => 0,
    borrowernumber        => 0,
    name                  => 0,
    address               => 0,
    email_addr            => 0,
    home_phone            => 0,
    birthdate             => 0,
    birthdate_iso         => 0,
    dateexpiry            => 0,
    dateexpiry_iso        => 0,
    debarred              => 0,
    fine_blocked          => 0,
    ptype                 => 0,
    charge_ok             => 0,    # for patron_status[0] (inverted)
    renew_ok              => 0,    # for patron_status[1] (inverted)
    recall_ok             => 0,    # for patron_status[2] (inverted)
    hold_ok               => 0,    # for patron_status[3] (inverted)
    card_lost             => 0,    # for patron_status[4]
    recall_overdue        => 0,
    currency              => 1,
    fee_limit             => 0,
    screen_msg            => 1,
    print_line            => 1,
    too_many_charged      => 0,    # for patron_status[5]
    too_many_overdue      => 0,    # for patron_status[6]
    too_many_renewal      => 0,    # for patron_status[7]
    too_many_claim_return => 0,    # for patron_status[8]

    #   excessive_fines         => 0,   # for patron_status[10]
    #   excessive_fees          => 0,   # for patron_status[11]
    recall_overdue  => 0,    # for patron_status[12]
    too_many_billed => 0,    # for patron_status[13]
    inet            => 0,    # EnvisionWare extension
);

our $AUTOLOAD;

sub DESTROY {

    # be cool.  needed for AUTOLOAD(?)
}

sub AUTOLOAD {
    my $self  = shift;
    my $class = ref($self) or croak "$self is not an object";
    my $name  = $AUTOLOAD;

    $name =~ s/.*://;

    unless ( exists $fields{$name} ) {
        croak "Cannot access '$name' field of class '$class'";
    }

    if (@_) {
        $fields{$name} or croak "Field '$name' of class '$class' is READ ONLY.";
        return $self->{$name} = shift;
    } else {
        return $self->{$name};
    }
}

=head2 format

This method uses a template to build a string from a Koha::Patron object
If errors are encountered in processing template we log them and return nothing

=cut

=head2 format

Missing POD for format.

=cut

sub format {
    my ( $self, $template ) = @_;

    if ($template) {
        require Koha::Patrons;

        my $patron = Koha::Patrons->find( $self->{borrowernumber} );
        return process_tt( $template, { patron => $patron } );
    }
}

sub check_password {
    my ( $self, $pwd ) = @_;

    # you gotta give me something (at least ''), or no deal
    return 0 unless defined $pwd;

    # If the record has a NULL password, accept '' as match
    return $pwd eq q{} unless $self->{password};

    my $ret = 0;
    ($ret) = checkpw( $self->{userid}, $pwd, undef, undef, 1 );    # userid, query, type, no_set_userenv
    return $ret;
}

# A few special cases, not in AUTOLOADed %fields

=head2 too_many_lost

This method checks if number of checkouts of lost items exceeds a threshold (defined in server account).

=cut

=head2 too_many_lost

Missing POD for too_many_lost.

=cut

sub too_many_lost {
    my ( $self, $server ) = @_;
    my $too_many_lost = 0;
    if ( $server && $server->{account} && ( my $lost_block_checkout = $server->{account}->{lost_block_checkout} ) ) {
        my $lost_block_checkout_value = $server->{account}->{lost_block_checkout_value} // 1;
        my $lost_checkouts            = Koha::Checkouts->search(
            { borrowernumber => $self->borrowernumber, 'itemlost' => { '>=', $lost_block_checkout_value } },
            { join           => 'item' }
        )->count;
        $too_many_lost = $lost_checkouts >= $lost_block_checkout;
    }
    return $too_many_lost;
}

sub fee_amount {
    my $self = shift;
    if ( $self->{fines} ) {
        return $self->{fines};
    }
    return 0;
}

=head2 fines_amount

Missing POD for fines_amount.

=cut

sub fines_amount {
    my $self = shift;
    return $self->fee_amount;
}

sub language {
    my $self = shift;
    return $self->{language} || '000';    # Unspecified
}

=head2 expired

Missing POD for expired.

=cut

sub expired {
    my $self = shift;
    return $self->{expired};
}

#
# remove the hold on item item_id from my hold queue.
# return true if I was holding the item, false otherwise.
#
sub drop_hold {
    my ( $self, $item_id ) = @_;
    return if !$item_id;
    my $result = 0;
    foreach (qw(hold_items unavail_holds)) {
        $self->{$_} or next;
        for ( my $i = 0 ; $i < scalar @{ $self->{$_} } ; $i++ ) {
            my $held_item = $self->{$_}[$i]->{barcode} or next;
            if ( $held_item eq $item_id ) {
                splice @{ $self->{$_} }, $i, 1;
                $result++;
            }
        }
    }
    return $result;
}

# Accessor method for array_ref values, designed to get the "start" and "end" values
# from the SIP request.  Note those incoming values are 1-indexed, not 0-indexed.
#

=head2 x_items

Missing POD for x_items.

=cut

sub x_items {
    my $self      = shift;
    my $array_var = shift or return;
    my ( $start, $end ) = @_;

    my $item_list = [];
    if ( $self->{$array_var} ) {

        if ( $start && $start > 1 ) {
            --$start;
        } else {
            $start = 0;
        }
        if ( $end && $end < @{ $self->{$array_var} } ) {
            --$end;
        } else {
            $end = @{ $self->{$array_var} };
            --$end;
        }
        @{$item_list} = @{ $self->{$array_var} }[ $start .. $end ];

    }
    return $item_list;
}

#
# List of outstanding holds placed
#

=head2 hold_items

Missing POD for hold_items.

=cut

sub hold_items {
    my $self     = shift;
    my $item_arr = $self->x_items( 'hold_items', @_ );
    foreach my $item ( @{$item_arr} ) {
        my $item_obj = Koha::Items->find( $item->{itemnumber} );
        $item->{barcode} = $item_obj ? $item_obj->barcode : undef;
    }
    return $item_arr;
}

=head2 overdue_items

Missing POD for overdue_items.

=cut

sub overdue_items {
    my $self = shift;
    return $self->x_items( 'overdue_items', @_ );
}

=head2 charged_items

Missing POD for charged_items.

=cut

sub charged_items {
    my $self = shift;
    return $self->x_items( 'items', @_ );
}

=head2 fine_items

Missing POD for fine_items.

=cut

sub fine_items {

    require Koha::Database;
    require Template;

    my $self   = shift;
    my $start  = shift;
    my $end    = shift;
    my $server = shift;

    my @fees = Koha::Database->new()->schema()->resultset('Accountline')->search(
        {
            borrowernumber    => $self->{borrowernumber},
            amountoutstanding => { '>' => '0' },
        }
    );

    $start = $start ? $start - 1 : 0;
    $end   = $end   ? $end - 1   : scalar @fees - 1;

    my $av_field_template = $server ? $server->{account}->{av_field_template} : undef;
    $av_field_template ||= "[% accountline.description %] [% accountline.amountoutstanding | format('%.2f') %]";

    my @return_values;
    for ( my $i = $start ; $i <= $end ; $i++ ) {
        my $fee = $fees[$i];

        next unless $fee;

        my $output = process_tt( $av_field_template, { accountline => $fee } );
        push( @return_values, { barcode => $output } );
    }

    return \@return_values;

}

=head2 recall_items

Missing POD for recall_items.

=cut

sub recall_items {
    my $self = shift;
    return $self->x_items( 'recall_items', @_ );
}

=head2 unavail_holds

Missing POD for unavail_holds.

=cut

sub unavail_holds {
    my $self = shift;
    return $self->x_items( 'unavail_holds', @_ );
}

sub block {
    my ( $self, $card_retained, $blocked_card_msg ) = @_;
    foreach my $field ( 'charge_ok', 'renew_ok', 'recall_ok', 'hold_ok', 'inet' ) {
        $self->{$field} = 0;
    }
    $self->{screen_msg} =
        "Block feature not implemented";    # $blocked_card_msg || "Card Blocked.  Please contact library staff";
                                            # TODO: not really affecting patron record
    return $self;
}

sub enable {
    my $self = shift;
    foreach my $field ( 'charge_ok', 'renew_ok', 'recall_ok', 'hold_ok', 'inet' ) {
        $self->{$field} = 1;
    }
    siplog(
        "LOG_DEBUG",        "Patron(%s)->enable: charge: %s, renew:%s, recall:%s, hold:%s",
        $self->{id},        $self->{charge_ok}, $self->{renew_ok},
        $self->{recall_ok}, $self->{hold_ok}
    );
    $self->{screen_msg} =
        "Enable feature not implemented.";    # "All privileges restored.";   # TODO: not really affecting patron record
    return $self;
}

=head2 inet_privileges

Missing POD for inet_privileges.

=cut

sub inet_privileges {
    my $self = shift;
    return $self->{inet} ? 'Y' : 'N';
}

=head2 excessive_fees

Missing POD for excessive_fees.

=cut

sub excessive_fees {
    my $self = shift;
    return ( $self->fee_amount and $self->fee_amount > $self->fee_limit );
}

=head2 excessive_fines

Missing POD for excessive_fines.

=cut

sub excessive_fines {
    my $self = shift;
    return $self->excessive_fees;    # excessive_fines is the same thing as excessive_fees for Koha
}

=head2 holds_blocked_by_excessive_fees

Missing POD for holds_blocked_by_excessive_fees.

=cut

sub holds_blocked_by_excessive_fees {
    my $self = shift;
    return ( $self->fee_amount && $self->fee_amount > C4::Context->preference("maxoutstanding") );
}

=head2 library_name

Missing POD for library_name.

=cut

sub library_name {
    my $self = shift;
    unless ( $self->{library_name} ) {
        my $library = Koha::Libraries->find( $self->{branchcode} );
        $self->{library_name} = $library ? $library->branchname : '';
    }
    return $self->{library_name};
}
#
# Messages
#

=head2 invalid_patron

Missing POD for invalid_patron.

=cut

sub invalid_patron {
    my $self = shift;
    return "Please contact library staff";
}

=head2 charge_denied

Missing POD for charge_denied.

=cut

sub charge_denied {
    my $self = shift;
    return "Please contact library staff";
}

sub _get_address {
    my $patron = shift;

    my $address = $patron->{streetnumber} || q{};
    for my $field (qw( roaddetails address address2 city state zipcode country)) {
        next unless $patron->{$field};
        if ($address) {
            $address .= q{ };
            $address .= $patron->{$field};
        } else {
            $address .= $patron->{$field};
        }
    }
    return $address;
}

sub _get_outstanding_holds {
    my $borrowernumber = shift;

    my $patron = Koha::Patrons->find($borrowernumber);
    my $holds  = $patron->holds->search( { -or => [ { found => undef }, { found => { '!=' => 'W' } } ] } );
    my @holds;
    while ( my $hold = $holds->next ) {
        my $item;
        if ( $hold->itemnumber ) {
            $item = $hold->item;
        } else {

            # We need to return a barcode for the biblio so the client
            # can request the biblio info
            my $items = $hold->biblio->items;
            $item = $items->count ? $items->next : undef;
        }
        my $unblessed_hold = $hold->unblessed;

        $unblessed_hold->{barcode} = $item ? $item->barcode : undef;

        push @holds, $unblessed_hold;
    }
    return \@holds;
}

=head2 build_patron_attributes_string

This method builds the part of the sip message for extended patron
attributes as defined in the sip config

=cut

=head2 build_patron_attributes_string

Missing POD for build_patron_attributes_string.

=cut

sub build_patron_attributes_string {
    my ( $self, $server ) = @_;

    my $string = q{};
    if ( $server->{account}->{patron_attribute} ) {
        my @attributes_to_send =
            ref $server->{account}->{patron_attribute} eq "ARRAY"
            ? @{ $server->{account}->{patron_attribute} }
            : ( $server->{account}->{patron_attribute} );

        foreach my $a (@attributes_to_send) {
            my @attributes = Koha::Patron::Attributes->search(
                {
                    borrowernumber => $self->{borrowernumber},
                    code           => $a->{code}
                }
            )->as_list;

            foreach my $attribute (@attributes) {
                my $value = $attribute->attribute();
                $string .= add_field( $a->{field}, $value );
            }
        }
    }

    return $string;
}

=head2 build_custom_field_string

This method builds the part of the sip message for custom patron fields as defined in the sip config

=cut

=head2 build_custom_field_string

Missing POD for build_custom_field_string.

=cut

sub build_custom_field_string {
    my ( $self, $server ) = @_;

    my $string = q{};

    if ( $server->{account}->{custom_patron_field} ) {
        my @custom_fields =
            ref $server->{account}->{custom_patron_field} eq "ARRAY"
            ? @{ $server->{account}->{custom_patron_field} }
            : $server->{account}->{custom_patron_field};
        foreach my $custom_field (@custom_fields) {
            $string .= maybe_add( $custom_field->{field}, $self->format( $custom_field->{template} ) )
                if defined $custom_field->{field};
        }
    }
    return $string;
}

1;
__END__

=head1 EXAMPLES

  our %patron_example = (
          djfiander => {
              name => "David J. Fiander",
              id => 'djfiander',
              password => '6789',
              ptype => 'A', # 'A'dult.  Whatever.
              birthdate => '19640925',
              address => '2 Meadowvale Dr. St Thomas, ON',
              home_phone => '(519) 555 1234',
              email_addr => 'djfiander@hotmail.com',
              charge_ok => 1,
              renew_ok => 1,
              recall_ok => 0,
              hold_ok => 1,
              card_lost => 0,
              claims_returned => 0,
              fines => 100,
              fees => 0,
              recall_overdue => 0,
              items_billed => 0,
              screen_msg => '',
              print_line => '',
              items => [],
              hold_items => [],
              overdue_items => [],
              fine_items => ['Computer Time'],
              recall_items => [],
              unavail_holds => [],
              inet => 1,
          },
  );

 From borrowers table:
+---------------------+--------------+------+-----+---------+----------------+
| Field               | Type         | Null | Key | Default | Extra          |
+---------------------+--------------+------+-----+---------+----------------+
| borrowernumber      | int(11)      | NO   | PRI | NULL    | auto_increment |
| cardnumber          | varchar(16)  | YES  | UNI | NULL    |                |
| surname             | mediumtext   | NO   |     | NULL    |                |
| firstname           | text         | YES  |     | NULL    |                |
| title               | mediumtext   | YES  |     | NULL    |                |
| othernames          | mediumtext   | YES  |     | NULL    |                |
| initials            | text         | YES  |     | NULL    |                |
| streetnumber        | varchar(10)  | YES  |     | NULL    |                |
| streettype          | varchar(50)  | YES  |     | NULL    |                |
| address             | mediumtext   | NO   |     | NULL    |                |
| address2            | text         | YES  |     | NULL    |                |
| city                | mediumtext   | NO   |     | NULL    |                |
| state               | mediumtext   | YES  |     | NULL    |                |
| zipcode             | varchar(25)  | YES  |     | NULL    |                |
| country             | text         | YES  |     | NULL    |                |
| email               | mediumtext   | YES  |     | NULL    |                |
| phone               | text         | YES  |     | NULL    |                |
| mobile              | varchar(50)  | YES  |     | NULL    |                |
| fax                 | mediumtext   | YES  |     | NULL    |                |
| emailpro            | text         | YES  |     | NULL    |                |
| phonepro            | text         | YES  |     | NULL    |                |
| B_streetnumber      | varchar(10)  | YES  |     | NULL    |                |
| B_streettype        | varchar(50)  | YES  |     | NULL    |                |
| B_address           | varchar(100) | YES  |     | NULL    |                |
| B_address2          | text         | YES  |     | NULL    |                |
| B_city              | mediumtext   | YES  |     | NULL    |                |
| B_state             | mediumtext   | YES  |     | NULL    |                |
| B_zipcode           | varchar(25)  | YES  |     | NULL    |                |
| B_country           | text         | YES  |     | NULL    |                |
| B_email             | text         | YES  |     | NULL    |                |
| B_phone             | mediumtext   | YES  |     | NULL    |                |
| dateofbirth         | date         | YES  |     | NULL    |                |
| branchcode          | varchar(10)  | NO   | MUL |         |                |
| categorycode        | varchar(10)  | NO   | MUL |         |                |
| dateenrolled        | date         | YES  |     | NULL    |                |
| dateexpiry          | date         | YES  |     | NULL    |                |
| gonenoaddress       | tinyint(1)   | YES  |     | NULL    |                |
| lost                | tinyint(1)   | YES  |     | NULL    |                |
| debarred            | tinyint(1)   | YES  |     | NULL    |                |
| contactname         | mediumtext   | YES  |     | NULL    |                |
| contactfirstname    | text         | YES  |     | NULL    |                |
| contacttitle        | text         | YES  |     | NULL    |                |
| borrowernotes       | mediumtext   | YES  |     | NULL    |                |
| relationship        | varchar(100) | YES  |     | NULL    |                |
| ethnicity           | varchar(50)  | YES  |     | NULL    |                |
| ethnotes            | varchar(255) | YES  |     | NULL    |                |
| sex                 | varchar(1)   | YES  |     | NULL    |                |
| password            | varchar(30)  | YES  |     | NULL    |                |
| flags               | int(11)      | YES  |     | NULL    |                |
| userid              | varchar(30)  | YES  | MUL | NULL    |                |
| opacnote            | mediumtext   | YES  |     | NULL    |                |
| contactnote         | varchar(255) | YES  |     | NULL    |                |
| sort1               | varchar(80)  | YES  |     | NULL    |                |
| sort2               | varchar(80)  | YES  |     | NULL    |                |
| altcontactfirstname | varchar(255) | YES  |     | NULL    |                |
| altcontactsurname   | varchar(255) | YES  |     | NULL    |                |
| altcontactaddress1  | varchar(255) | YES  |     | NULL    |                |
| altcontactaddress2  | varchar(255) | YES  |     | NULL    |                |
| altcontactaddress3  | varchar(255) | YES  |     | NULL    |                |
| altcontactstate     | mediumtext   | YES  |     | NULL    |                |
| altcontactzipcode   | varchar(50)  | YES  |     | NULL    |                |
| altcontactcountry   | text         | YES  |     | NULL    |                |
| altcontactphone     | varchar(50)  | YES  |     | NULL    |                |
| smsalertnumber      | varchar(50)  | YES  |     | NULL    |                |
| privacy             | int(11)      | NO   |     | 1       |                |
+---------------------+--------------+------+-----+---------+----------------+


 From C4::Members

 $flags->{KEY}
 {CHARGES}
    {message}     Message showing patron's credit or debt
    {noissues}    Set if patron owes >$5.00
 {GNA}             Set if patron gone w/o address
    {message}     "Borrower has no valid address"
    {noissues}    Set.
 {LOST}            Set if patron's card reported lost
    {message}     Message to this effect
    {noissues}    Set.
 {DBARRED}         Set if patron is debarred
    {message}     Message to this effect
    {noissues}    Set.
 {NOTES}           Set if patron has notes
    {message}     Notes about patron
 {ODUES}           Set if patron has overdue books
    {message}     "Yes"
    {itemlist}    ref-to-array: list of overdue books
    {itemlisttext}    Text list of overdue items
 {WAITING}         Set if there are items available that the patron reserved
    {message}     Message to this effect
    {itemlist}    ref-to-array: list of available items

=cut


=head1 NAME

ILS::Patron - Portable Patron status object class for SIP

=head1 DESCRIPTION

A C<ILS::Patron> object holds information about a patron that's
used by self service terminals to authenticate and authorize a patron,
and to display information about the patron's borrowing activity.

=head1 SYNOPSIS

    use ILS;
    use ILS::Patron;

    # Look up patron based on patron_id
    my $patron = new ILS::Patron $patron_id

    # Basic object access methods
    $patron_id = $patron->id;
    $str = $patron->name;
    $str = $patron->address;
    $str = $patron->email_addr;
    $str = $patron->home_phone;
    $str = $patron->sip_birthdate;
    $str = $patron->ptype;
    $str = $patron->language;
    $str = $patron->password;
    $str = $patron->check_password($password);
    $str = $patron->currency;
    $str = $patron->screen_msg;
    $str = $patron->print_line;

    # Check patron permissions
    $bool = $patron->charge_ok;
    $bool = $patron->renew_ok;
    $bool = $patron->recall_ok;
    $bool = $patron->hold_ok;
    $bool = $patron->card_lost;
    $bool = $patron->too_many_charged;
    $bool = $patron->too_many_overdue;
    $bool = $patron->too_many_renewal;
    $bool = $patron->too_many_claim_return;
    $bool = $patron->too_many_lost( $server );
    $bool = $patron->excessive_fines;
    $bool = $patron->excessive_fees;
    $bool = $patron->too_many_billed;

    # Patron borrowing activity
    $num = $patron->recall_overdue;
    $num = $patron->fee_amount;
    $bool = $patron->drop_hold($item_id);
    @holds = $patron->hold_items($start, $end);
    @items = $patron->overdue_items($start, $end);
    @items = $patron->charged_items($start, $end);
    @items = $patron->fine_items($start, $end);
    @items = $patron->recall_items($start, $end);
    @items = $patron->unavail_holds($start, $end);

    # Changing a patron's status
    $patron->block($card_retained, $blocked_msg);
    $patron->enable;

=head1 INITIALIZATION

A patron object is created by calling

    $patron = new ILS::Patron $patron_id;

where C<$patron_id> is the patron's barcode as received from the
self service terminal.  If the patron barcode is not registered,
then C<new> should return C<undef>.

=head1 BASIC OBJECT ACCESS METHODS

The following functions return the corresponding information
about the given patron, or C<undef> if the information is
unavailable.

    $patron_id = $patron-E<gt>id;
    $str = $patron-E<gt>name;
    $str = $patron-E<gt>address;
    $str = $patron-E<gt>email_addr;
    $str = $patron-E<gt>home_phone;

    $str = $patron-E<gt>screen_msg;
    $str = $patron-E<gt>print_line;

If there are outstanding display messages associated with the
patron, then these return the screen message and print line,
respectively, as with the C<ILS> methods.

There are a few other object access methods that need a bit more
explication however.

=head2 C<$str = $patron-E<gt>sip_birthdate;>

Returns the patron's birthday formatted according to the SIP
specification:

    YYYYMMDD    HHMMSS

=head2 C<$str = $patron-E<gt>ptype;>

Returns the "patron type" of the patron.  This is not used by the
SIP server code, but is passed through to the self service
terminal (using the non-standard protocol field "PC").  Some self
service terminals use the patron type in determining what level
of service to provide (for example, Envisionware computer
management software can be configured to filter internet access
based on patron type).

=head2 C<$str = $patron-E<gt>language;>

A three-digit string encoding the patron's preferred language.
The full list is defined in the SIP specification, but some of
the important values are:

    000 Unknown (default)
    001 English
    002 French
    008 Spanish
    011 Canadian French
    016 Arabic
    019 Chinese
    021 North American Spanish

=head2 C<$bool = $patron-E<gt>check_password($password);>

Returns C<true> if C<$patron>'s password is C<$password>.

=head2 C<$str = $patron-E<gt>currency;>

Returns the three character ISO 4217 currency code for the
patron's preferred currency.

=head1 CHECKING PATRON PERMISSIONS

Most of the methods associated with Patrons are related to
checking if they're authorized to perform various actions:

    $bool = $patron-E<gt>charge_ok;
    $bool = $patron-E<gt>renew_ok;
    $bool = $patron-E<gt>recall_ok;
    $bool = $patron-E<gt>hold_ok;
    $bool = $patron-E<gt>card_lost;
    $bool = $patron-E<gt>recall_overdue;
    $bool = $patron-E<gt>too_many_charged;
    $bool = $patron-E<gt>too_many_overdue;
    $bool = $patron-E<gt>too_many_renewal;
    $bool = $patron-E<gt>too_many_claim_return;
    $bool = $patron-E<gt>too_many_lost( $server );
    $bool = $patron-E<gt>excessive_fines;
    $bool = $patron-E<gt>excessive_fees;
    $bool = $patron-E<gt>too_many_billed;

=head1 LISTS OF ITEMS ASSOCIATED WITH THE USER

The C<$patron> object provides a set of methods to find out
information about various sets that are associated with the
user.  All these methods take two optional parameters: C<$start>
and C<$end>, which define a subset of the list of items to be
returned (C<1> is the first item in the list).  The following
methods all return a reference to a list of C<$item_id>s:

    $items = $patron-E<gt>hold_items($start, $end);
    $items = $patron-E<gt>overdue_items($start, $end);
    $items = $patron-E<gt>charged_items($start, $end);
    $items = $patron-E<gt>recall_items($start, $end);
    $items = $patron-E<gt>unavail_holds($start, $end);

It is also possible to retrieve an itemized list of the fines
outstanding.  This method returns a reference to an itemized list
of fines:

    $fines = $patron-E<gt>fine_items($start, $end);

=head1 PATRON BORROWING ACTIVITY

=head2 C<$num = $patron-E<gt>fee_amount;>

The total amount of fees and fines owed by the patron.

=head2 C<$bool = $patron-E<gt>drop_hold($item_id);>

Drops the hold that C<$patron> has placed on the item
C<$item_id>.  Returns C<false> if the patron did not have a hold
on the item, C<true> otherwise.



=head1 CHANGING A PATRON'S STATUS

=head2 C<$status = $ils-E<gt>block($card_retained, $blocked_card_msg);>

Block the account of the patron identified by C<$patron_id>.  If
the self check unit captured the patron's card, then
C<$card_retained> will be C<true>.  A message indicating why the
card was retained will be provided by the parameter
C<$blocked_card_msg>.

This function returns an C<ILS::Patron> object that has been
updated to indicate that the patron's privileges have been
blocked, or C<undef> if the patron ID is not valid.

=head2 C<$patron-E<gt>enable;>

Re-enable the patron after she's been blocked.  This is a test
function and will not normally be called by self-service
terminals in production.
