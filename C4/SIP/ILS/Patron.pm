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

our $kp;    # koha patron

=head1 Methods

=cut

sub new {
    my ($class, $patron_id) = @_;
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
        $patron = Koha::Patrons->find( { cardnumber => $patron_id } )
            || Koha::Patrons->find( { userid => $patron_id } );
    }

    unless ($patron) {
        siplog("LOG_DEBUG", "new ILS::Patron(%s): no such patron", $patron_id);
        return;
    }
    $kp = $patron->unblessed;
    my $pw        = $kp->{password};
    my $flags     = C4::Members::patronflags( $kp );
    my $debarred  = $patron->is_debarred;
    my ($day, $month, $year) = (localtime)[3,4,5];
    my $today    = sprintf '%04d-%02d-%02d', $year+1900, $month+1, $day;
    my $expired  = ($today gt $kp->{dateexpiry}) ? 1 : 0;
    if ($expired) {
        if ($kp->{opacnote} ) {
            $kp->{opacnote} .= q{ };
        }
        $kp->{opacnote} .= 'PATRON EXPIRED';
    }
    my %ilspatron;
    my $adr     = _get_address($kp);
    my $dob     = $kp->{dateofbirth};
    $dob and $dob =~ s/-//g;    # YYYYMMDD
    my $dexpiry     = $kp->{dateexpiry};
    $dexpiry and $dexpiry =~ s/-//g;    # YYYYMMDD

    # Get fines and add fines for guarantees (depends on preference NoIssuesChargeGuarantees)
    my $fines_amount = ($patron->account->balance > 0) ? $patron->account->non_issues_charges : 0;
    my $personal_fines_amount = $fines_amount;
    my $fee_limit = _fee_limit();
    my $noissueschargeguarantorswithguarantees = C4::Context->preference('NoIssuesChargeGuarantorsWithGuarantees');
    my $fines_msg = "";
    my $fine_blocked = 0;
    my $noissueschargeguarantees = C4::Context->preference('NoIssuesChargeGuarantees');
    if( $fines_amount > $fee_limit ){
        $fine_blocked = 1;
        $fines_msg .= " -- " . "Patron blocked by fines" if $fine_blocked;
    } elsif ( $noissueschargeguarantorswithguarantees ) {
        $fines_amount += $patron->relationships_debt({ include_guarantors => 1, only_this_guarantor => 0, include_this_patron => 0 });
        $fine_blocked ||= $fines_amount > $noissueschargeguarantorswithguarantees;
        $fines_msg .= " -- " . "Patron blocked by fines ($fines_amount) on related accounts" if $fine_blocked;
    } elsif ( $noissueschargeguarantees ) {
        $fines_amount += $patron->relationships_debt({ include_guarantors => 0, only_this_guarantor => 0, include_this_patron => 0 });
        $fine_blocked ||= $fines_amount > $noissueschargeguarantees;
        $fines_msg .= " -- " . "Patron blocked by fines ($fines_amount) on guaranteed accounts" if $fine_blocked;
    }

    my $circ_blocked =( C4::Context->preference('OverduesBlockCirc') ne "noblock" &&  defined $flags->{ODUES}->{itemlist} ) ? 1 : 0;
    {
    no warnings;    # any of these $kp->{fields} being concat'd could be undef
    %ilspatron = (
        name => $kp->{firstname} . " " . $kp->{surname},
        id   => $kp->{cardnumber},    # to SIP, the id is the BARCODE, not userid
        password        => $pw,
        ptype           => $kp->{categorycode},     # 'A'dult.  Whatever.
        dateexpiry      => $dexpiry,
        dateexpiry_iso  => $kp->{dateexpiry},
        birthdate       => $dob,
        birthdate_iso   => $kp->{dateofbirth},
        branchcode      => $kp->{branchcode},
        library_name    => "",                      # only populated if needed, cached here
        borrowernumber  => $kp->{borrowernumber},
        address         => $adr,
        home_phone      => $kp->{phone},
        email_addr      => $kp->{email},
        charge_ok       => ( !$debarred && !$expired && !$fine_blocked && !$circ_blocked),
        renew_ok        => ( !$debarred && !$expired && !$fine_blocked),
        recall_ok       => ( !$debarred && !$expired && !$fine_blocked),
        hold_ok         => ( !$debarred && !$expired && !$fine_blocked),
        card_lost       => ( $kp->{lost} || $kp->{gonenoaddress} || $flags->{LOST} ),
        claims_returned => 0,
        fines           => $personal_fines_amount,
        fees            => 0,             # currently not distinct from fines
        recall_overdue  => 0,
        items_billed    => 0,
        screen_msg      => 'Greetings from Koha. ' . $kp->{opacnote} . $fines_msg,
        print_line      => '',
        items           => [],
        hold_items      => $flags->{WAITING}->{itemlist},
        overdue_items   => $flags->{ODUES}->{itemlist},
        too_many_overdue => $circ_blocked,
        fine_items      => [],
        recall_items    => [],
        unavail_holds   => [],
        inet            => ( !$debarred && !$expired ),
        debarred        => $debarred,
        expired         => $expired,
        fine_blocked    => $fine_blocked,
        fee_limit       => $fee_limit,
        userid          => $kp->{userid},
    );
    }

    if ( $patron->is_debarred and $patron->debarredcomment ) {
        $ilspatron{screen_msg} .= " -- " . $patron->debarredcomment;
    }
    if ( $circ_blocked ) {
        $ilspatron{screen_msg} .= " -- " . "Patron has overdues";
    }
    for (qw(EXPIRED CHARGES CREDITS GNA LOST NOTES)) {
        ($flags->{$_}) or next;
        if ($_ ne 'NOTES' and $flags->{$_}->{message}) {
            $ilspatron{screen_msg} .= " -- " . $flags->{$_}->{message};  # show all but internal NOTES
        }
        if ($flags->{$_}->{noissues}) {
            foreach my $toggle (qw(charge_ok renew_ok recall_ok hold_ok inet)) {
                $ilspatron{$toggle} = 0;    # if we get noissues, disable everything
            }
        }
    }

    # FIXME: populate fine_items recall_items
    $ilspatron{unavail_holds} = _get_outstanding_holds($kp->{borrowernumber});

    my $pending_checkouts = $patron->pending_checkouts;
    my @barcodes;
    while ( my $c = $pending_checkouts->next ) {
        push @barcodes, { barcode => $c->item->barcode };
    }
    $ilspatron{items} = \@barcodes;

    $self = \%ilspatron;
    siplog("LOG_DEBUG", "new ILS::Patron(%s): found patron '%s'", $patron_id,$self->{id});
    bless $self, $type;
    return $self;
}


# 0 means read-only
# 1 means read/write

my %fields = (
    id                      => 0,
    borrowernumber          => 0,
    name                    => 0,
    address                 => 0,
    email_addr              => 0,
    home_phone              => 0,
    birthdate               => 0,
    birthdate_iso           => 0,
    dateexpiry              => 0,
    dateexpiry_iso          => 0,
    debarred                => 0,
    fine_blocked            => 0,
    ptype                   => 0,
    charge_ok               => 0,   # for patron_status[0] (inverted)
    renew_ok                => 0,   # for patron_status[1] (inverted)
    recall_ok               => 0,   # for patron_status[2] (inverted)
    hold_ok                 => 0,   # for patron_status[3] (inverted)
    card_lost               => 0,   # for patron_status[4]
    recall_overdue          => 0,
    currency                => 1,
    fee_limit               => 0,
    screen_msg              => 1,
    print_line              => 1,
    too_many_charged        => 0,   # for patron_status[5]
    too_many_overdue        => 0,   # for patron_status[6]
    too_many_renewal        => 0,   # for patron_status[7]
    too_many_claim_return   => 0,   # for patron_status[8]
    too_many_lost           => 0,   # for patron_status[9]
#   excessive_fines         => 0,   # for patron_status[10]
#   excessive_fees          => 0,   # for patron_status[11]
    recall_overdue          => 0,   # for patron_status[12]
    too_many_billed         => 0,   # for patron_status[13]
    inet                    => 0,   # EnvisionWare extension
);

our $AUTOLOAD;

sub DESTROY {
    # be cool.  needed for AUTOLOAD(?)
}

sub AUTOLOAD {
    my $self = shift;
    my $class = ref($self) or croak "$self is not an object";
    my $name = $AUTOLOAD;

    $name =~ s/.*://;

    unless (exists $fields{$name}) {
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

sub format {
    my ( $self, $template ) = @_;

    if ($template) {
        require Template;
        require Koha::Patrons;

        my $tt = Template->new();

        my $patron = Koha::Patrons->find( $self->{borrowernumber} );

        my $output;
        eval {
            $tt->process( \$template, { patron => $patron }, \$output );
        };
        if ( $@ ){
            siplog("LOG_DEBUG", "Error processing template: $template");
            return "";
        }
        return $output;
    }
}

sub check_password {
    my ( $self, $pwd ) = @_;

    # you gotta give me something (at least ''), or no deal
    return 0 unless defined $pwd;

    # If the record has a NULL password, accept '' as match
    return $pwd eq q{} unless $self->{password};

    my $ret = 0;
    ($ret) = checkpw( $self->{userid}, $pwd, undef, undef, 1 ); # userid, query, type, no_set_userenv
    return $ret;
}

# A few special cases, not in AUTOLOADed %fields
sub fee_amount {
    my $self = shift;
    if ( $self->{fines} ) {
        return $self->{fines};
    }
    return 0;
}

sub fines_amount {
    my $self = shift;
    return $self->fee_amount;
}

sub language {
    my $self = shift;
    return $self->{language} || '000'; # Unspecified
}

sub expired {
    my $self = shift;
    return $self->{expired};
}

#
# remove the hold on item item_id from my hold queue.
# return true if I was holding the item, false otherwise.
# 
sub drop_hold {
    my ($self, $item_id) = @_;
    return if !$item_id;
    my $result = 0;
    foreach (qw(hold_items unavail_holds)) {
        $self->{$_} or next;
        for (my $i = 0; $i < scalar @{$self->{$_}}; $i++) {
            my $held_item = $self->{$_}[$i]->{barcode} or next;
            if ($held_item eq $item_id) {
                splice @{$self->{$_}}, $i, 1;
                $result++;
            }
        }
    }
    return $result;
}

# Accessor method for array_ref values, designed to get the "start" and "end" values
# from the SIP request.  Note those incoming values are 1-indexed, not 0-indexed.
#
sub x_items {
    my $self      = shift;
    my $array_var = shift or return;
    my ($start, $end) = @_;

    my $item_list = [];
    if ($self->{$array_var}) {
        if ($start && $start > 1) {
            --$start;
        }
        else {
            $start = 0;
        }
        if ( $end && $end < @{$self->{$array_var}} ) {
        }
        else {
            $end = @{$self->{$array_var}};
            --$end;
        }
        @{$item_list} = @{$self->{$array_var}}[ $start .. $end ];

    }
    return $item_list;
}

#
# List of outstanding holds placed
#
sub hold_items {
    my $self = shift;
    my $item_arr = $self->x_items('hold_items', @_);
    foreach my $item (@{$item_arr}) {
        my $item_obj = Koha::Items->find($item->{itemnumber});
        $item->{barcode} = $item_obj ? $item_obj->barcode : undef;
    }
    return $item_arr;
}

sub overdue_items {
    my $self = shift;
    return $self->x_items('overdue_items', @_);
}
sub charged_items {
    my $self = shift;
    return $self->x_items('items', @_);
}
sub fine_items {
    require Koha::Database;
    require Template;

    my $self = shift;
    my $start = shift;
    my $end = shift;
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

    my $tt = Template->new();

    my @return_values;
    for ( my $i = $start; $i <= $end; $i++ ) {
        my $fee = $fees[$i];

        next unless $fee;

        my $output;
        $tt->process( \$av_field_template, { accountline => $fee }, \$output );
        push( @return_values, { barcode => $output } );
    }

    return \@return_values;
}
sub recall_items {
    my $self = shift;
    return $self->x_items('recall_items', @_);
}
sub unavail_holds {
    my $self = shift;
    return $self->x_items('unavail_holds', @_);
}

sub block {
    my ($self, $card_retained, $blocked_card_msg) = @_;
    foreach my $field ('charge_ok', 'renew_ok', 'recall_ok', 'hold_ok', 'inet') {
        $self->{$field} = 0;
    }
    $self->{screen_msg} = "Block feature not implemented";  # $blocked_card_msg || "Card Blocked.  Please contact library staff";
    # TODO: not really affecting patron record
    return $self;
}

sub enable {
    my $self = shift;
    foreach my $field ('charge_ok', 'renew_ok', 'recall_ok', 'hold_ok', 'inet') {
        $self->{$field} = 1;
    }
    siplog("LOG_DEBUG", "Patron(%s)->enable: charge: %s, renew:%s, recall:%s, hold:%s",
       $self->{id}, $self->{charge_ok}, $self->{renew_ok},
       $self->{recall_ok}, $self->{hold_ok});
    $self->{screen_msg} = "Enable feature not implemented."; # "All privileges restored.";   # TODO: not really affecting patron record
    return $self;
}

sub inet_privileges {
    my $self = shift;
    return $self->{inet} ? 'Y' : 'N';
}

sub _fee_limit {
    return C4::Context->preference('noissuescharge') || 5;
}

sub excessive_fees {
    my $self = shift;
    return ($self->fee_amount and $self->fee_amount > $self->fee_limit);
}

sub excessive_fines {
    my $self = shift;
    return $self->excessive_fees;   # excessive_fines is the same thing as excessive_fees for Koha
}

sub holds_blocked_by_excessive_fees {
    my $self = shift;
    return ( $self->fee_amount
          && $self->fee_amount > C4::Context->preference("maxoutstanding") );
}
    
sub library_name {
    my $self = shift;
    unless ($self->{library_name}) {
        my $library = Koha::Libraries->find( $self->{branchcode} );
        $self->{library_name} = $library ? $library->branchname : '';
    }
    return $self->{library_name};
}
#
# Messages
#

sub invalid_patron {
    my $self = shift;
    return "Please contact library staff";
}

sub charge_denied {
    my $self = shift;
    return "Please contact library staff";
}

=head2 update_lastseen

    $patron->update_lastseen();

    Patron method to update lastseen field in borrower
    to record that patron has been seen via sip connection

=cut

sub update_lastseen {
    my $self = shift;
    my $kohaobj = Koha::Patrons->find( $self->{borrowernumber} );
    $kohaobj->track_login if $kohaobj; # track_login checks the pref
}

sub _get_address {
    my $patron = shift;

    my $address = $patron->{streetnumber} || q{};
    for my $field (qw( roaddetails address address2 city state zipcode country))
    {
        next unless $patron->{$field};
        if ($address) {
            $address .= q{ };
            $address .= $patron->{$field};
        }
        else {
            $address .= $patron->{$field};
        }
    }
    return $address;
}

sub _get_outstanding_holds {
    my $borrowernumber = shift;

    my $patron = Koha::Patrons->find( $borrowernumber );
    my $holds = $patron->holds->search( { -or => [ { found => undef }, { found => { '!=' => 'W' } } ] } );
    my @holds;
    while ( my $hold = $holds->next ) {
        my $item;
        if ($hold->itemnumber) {
            $item = $hold->item;
        }
        else {
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

sub build_patron_attributes_string {
    my ( $self, $server ) = @_;

    my $string = q{};
    if ( $server->{account}->{patron_attribute} ) {
        my @attributes_to_send =
          ref $server->{account}->{patron_attribute} eq "ARRAY"
          ? @{ $server->{account}->{patron_attribute} }
          : ( $server->{account}->{patron_attribute} );

        foreach my $a ( @attributes_to_send ) {
            my @attributes = Koha::Patron::Attributes->search(
                {
                    borrowernumber => $self->{borrowernumber},
                    code           => $a->{code}
                }
            )->as_list;

            foreach my $attribute ( @attributes ) {
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

sub build_custom_field_string {
    my ( $self, $server ) = @_;

    my $string = q{};

    if ( $server->{account}->{custom_patron_field} ) {
        my @custom_fields =
            ref $server->{account}->{custom_patron_field} eq "ARRAY"
            ? @{ $server->{account}->{custom_patron_field} }
            : $server->{account}->{custom_patron_field};
        foreach my $custom_field ( @custom_fields ) {
            $string .= maybe_add( $custom_field->{field}, $self->format( $custom_field->{template} ) ) if defined $custom_field->{field};
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

