#
# An object to handle checkin status
#

package ILS::Transaction::Checkin;

use warnings;
use strict;

# use POSIX qw(strftime);

use ILS;
use ILS::Transaction;

use C4::Circulation;
use C4::Reserves qw( ModReserveAffect );
use C4::Items qw( ModItemTransfer );
use C4::Debug;

use parent qw(ILS::Transaction);

my %fields = (
    magnetic => 0,
    sort_bin => undef,
    collection_code  => undef,
    # 3M extensions:
    call_number      => undef,
    destination_loc  => undef,
    alert_type       => undef,  # 00,01,02,03,04 or 99
    hold_patron_id   => undef,
    hold_patron_name => "",
    hold             => undef,
);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();                # start with an ILS::Transaction object

    foreach (keys %fields) {
        $self->{_permitted}->{$_} = $fields{$_};    # overlaying _permitted
    }

    @{$self}{keys %fields} = values %fields;        # copying defaults into object
    return bless $self, $class;
}

sub do_checkin {
    my $self = shift;
    my $branch = shift;
    my $return_date = shift;
    if (!$branch) {
        $branch = 'SIP2';
    }
    my $barcode = $self->{item}->id;

    $return_date =   substr( $return_date, 0, 4 )
                   . '-'
                   . substr( $return_date, 4, 2 )
                   . '-'
                   . substr( $return_date, 6, 2 )
                   . q{ }
                   . substr( $return_date, 12, 2 )
                   . ':'
                   . substr( $return_date, 14, 2 )
                   . ':'
                   . substr( $return_date, 16, 2 );

    $debug and warn "do_checkin() calling AddReturn($barcode, $branch)";
    my ($return, $messages, $iteminformation, $borrower) = AddReturn($barcode, $branch, undef, undef, $return_date);
    $self->alert(!$return);
    # ignoring messages: NotIssued, IsPermanent, WasLost, WasTransfered

    # biblionumber, biblioitemnumber, itemnumber
    # borrowernumber, reservedate, branchcode
    # cancellationdate, found, reservenotes, priority, timestamp

    if ($messages->{BadBarcode}) {
        $self->alert_type('99');
    }
    if ($messages->{withdrawn}) {
        $self->alert_type('99');
    }
    if ($messages->{Wrongbranch}) {
        $self->destination_loc($messages->{Wrongbranch}->{Rightbranch});
        $self->alert_type('04');            # send to other branch
    }
    if ($messages->{WrongTransfer}) {
        $self->destination_loc($messages->{WrongTransfer});
        $self->alert_type('04');            # send to other branch
    }
    if ($messages->{NeedsTransfer}) {
        $self->destination_loc($iteminformation->{homebranch});
        $self->alert_type('04');            # send to other branch
    }
    if ($messages->{WasTransfered}) { # set into transit so tell unit
        $self->destination_loc($iteminformation->{homebranch});
        $self->alert_type('04');            # send to other branch
    }
    if ($messages->{ResFound}) {
        $self->hold($messages->{ResFound});
        if ($branch eq $messages->{ResFound}->{branchcode}) {
            $self->alert_type('01');
            ModReserveAffect( $messages->{ResFound}->{itemnumber},
                $messages->{ResFound}->{borrowernumber}, 0);

        } else {
            $self->alert_type('02');
            ModReserveAffect( $messages->{ResFound}->{itemnumber},
                $messages->{ResFound}->{borrowernumber}, 1);
            ModItemTransfer( $messages->{ResFound}->{itemnumber},
                $branch,
                $messages->{ResFound}->{branchcode}
            );

        }
        $self->{item}->hold_patron_id( $messages->{ResFound}->{borrowernumber} );
        $self->{item}->destination_loc( $messages->{ResFound}->{branchcode} );
    }
    $self->alert(1) if defined $self->alert_type;  # alert_type could be "00", hypothetically
    $self->ok($return);
}

sub resensitize {
	my $self = shift;
	unless ($self->{item}) {
		warn "resensitize(): no item found in object to resensitize";
		return;
	}
	return !$self->{item}->magnetic_media;
}

sub patron_id {
	my $self = shift;
	unless ($self->{patron}) {
		warn "patron_id(): no patron found in object";
		return;
	}
	return $self->{patron}->id;
}

1;
