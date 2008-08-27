#
# ILS::Item.pm
# 
# A Class for hiding the ILS's concept of the item from the OpenSIP
# system
#

package ILS::Item;

use strict;
use warnings;

use Sys::Syslog qw(syslog);

use ILS::Transaction;

use C4::Debug;
use C4::Context;
use C4::Biblio;
use C4::Items;
use C4::Circulation;
use C4::Members;
use C4::Reserves;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

BEGIN {
	$VERSION = 2.00;
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT_OK = qw();
}

=head2 EXAMPLE

our %item_db = (
		'1565921879' => {
				 title => "Perl 5 desktop reference",
				 id => '1565921879',
				 sip_media_type => '001',
				 magnetic_media => 0,
				 hold_queue => [],
				},
		'0440242746' => {
				 title => "The deep blue alibi",
				 id => '0440242746',
				 sip_media_type => '001',
				 magnetic_media => 0,
				 hold_queue => [],
		},
		'660' => {
				 title => "Harry Potter y el cáliz de fuego",
				 id => '660',
				 sip_media_type => '001',
				 magnetic_media => 0,
				 hold_queue => [],
			 },
		);
=cut

sub priority_sort {
	defined $a->{priority} or return -1;
	defined $b->{priority} or return 1;
	return $a->{priority} <=> $b->{priority};
}

sub new {
	my ($class, $item_id) = @_;
	my $type = ref($class) || $class;
	my $self;
	my $item = GetBiblioFromItemNumber( GetItemnumberFromBarcode($item_id) );
	
	if (! $item) {
		syslog("LOG_DEBUG", "new ILS::Item('%s'): not found", $item_id);
		warn "new ILS::Item($item_id) : No item '$item_id'.";
		return undef;
	}
    $item->{'id'} = $item->{'barcode'};
	# check if its on issue and if so get the borrower
	my $issue = GetItemIssue($item->{'itemnumber'});
	my $borrower = GetMember($issue->{'borrowernumber'},'borrowernumber');
	$item->{patron} = $borrower->{'cardnumber'};
	my @reserves = (@{ GetReservesFromBiblionumber($item->{biblionumber}) });
	$item->{hold_queue} = [ sort priority_sort @reserves ];
	# $item->{joetest} = 111;
	$self = $item;
	bless $self, $type;

    syslog("LOG_DEBUG", "new ILS::Item('%s'): found with title '%s'",
	   $item_id, $self->{title});

    return $self;
}

sub magnetic {
    my $self = shift;
    return $self->{magnetic_media};
}
sub sip_media_type {
    my $self = shift;
    return $self->{sip_media_type};
}
sub sip_item_properties {
    my $self = shift;
    return $self->{sip_item_properties};
}

sub status_update {
    my ($self, $props) = @_;
    my $status = new ILS::Transaction;
    $self->{sip_item_properties} = $props;
    $status->{ok} = 1;
    return $status;
}
    
sub id {
    my $self = shift;
    return $self->{id};
}
sub title_id {
    my $self = shift;
    return $self->{title};
}
sub permanent_location {
    my $self = shift;
    return $self->{permanent_location} || '';
}
sub current_location {
    my $self = shift;
    return $self->{current_location} || '';
}

sub sip_circulation_status {
    my $self = shift;
    if ($self->{patron}) {
		return '04';
    } elsif (scalar @{$self->{hold_queue}}) {
		return '08';
    } else {
		return '03';
    }
}

sub sip_security_marker {
    return '02';
}
sub sip_fee_type {
    return '01';
}

sub fee {
    my $self = shift;
    return $self->{fee} || 0;
}
sub fee_currency {
    my $self = shift;
    return $self->{currency} || 'USD';
}
sub owner {
    my $self = shift;
    return 'CPL';	# FIXME: UWOLS was hardcoded 
}
sub hold_queue {
    my $self = shift;
	(defined $self->{hold_queue}) or return [];
    return $self->{hold_queue};
}

sub hold_queue_position {
	my ($self, $patron_id) = @_;
	($self->{hold_queue}) or return 0;
	my $i = 0;
	foreach (@{$self->{hold_queue}}) {
		$i++;
		$_->{patron_id} or next;
		if ($_->{patron_id} eq $patron_id) {
			return $i;
		}
	}
    return 0;
}

sub due_date {
    my $self = shift;
    return $self->{due_date} || 0;
}
sub recall_date {
    my $self = shift;
    return $self->{recall_date} || 0;
}
sub hold_pickup_date {
    my $self = shift;
    return $self->{hold_pickup_date} || 0;
}
sub screen_msg {
    my $self = shift;
    return $self->{screen_msg} || '';
}
sub print_line {
	my $self = shift;
	return $self->{print_line} || '';
}

# An item is available for a patron if it is:
# 1) checked out to the same patron and there's no hold queue
# OR
# 2) not checked out and (there's no hold queue OR patron
#    is at the front of the queue)
sub available {
	my ($self, $for_patron) = @_;
	my $count = (defined $self->{hold_queue}) ? scalar @{$self->{hold_queue}} : 0;
	$debug and print STDERR "availability check: hold_queue size $count\n";
    if (defined($self->{patron_id})) {
	 	($self->{patron_id} eq $for_patron) or return 0;
		return ($count ? 0 : 1);
	} else {	# not checked out
		($count) or return 1;
		($self->{hold_queue}[0] eq $for_patron) and return 1;
	}
	return 0;
}

1;
__END__

