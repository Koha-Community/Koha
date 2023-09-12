#
# RenewAll: class to manage status of "Renew All" transaction

package C4::SIP::ILS::Transaction::RenewAll;

use strict;
use warnings;

use C4::SIP::Sip qw( siplog );

use C4::SIP::ILS::Item;

use Koha::Patrons;

use parent qw(C4::SIP::ILS::Transaction::Renew);

my %fields = (
    renewed   => [],
    unrenewed => [],
);

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();

    foreach my $element ( keys %fields ) {
        $self->{_permitted}->{$element} = $fields{$element};
    }

    @{$self}{ keys %fields } = values %fields;
    return bless $self, $class;
}

sub do_renew_all {
    my $self     = shift;
    siplog('LOG_DEBUG', "ILS::Transaction::RenewAll performing renewals...");
    my $patron = Koha::Patrons->find( $self->{patron}->{borrowernumber} );
    my $all_ok   = 1;
    $self->{renewed}   = [];
    $self->{unrenewed} = [];
    foreach my $itemx ( @{ $self->{patron}->{items} } ) {
        my $item_id = $itemx->{barcode};
        my $item    = C4::SIP::ILS::Item->new($item_id);
        if ( !defined($item) ) {
            siplog(
                'LOG_WARNING',
                q|renew_all: Invalid item id '%s' associated with patron '%s'|,
                $item_id,
                $patron->id
            );

            # $all_ok = 0; Do net set as still ok
            push @{ $self->unrenewed }, $item_id;
            next;
        }
        $self->{item} = $item;
        $self->do_renew_for($patron);
        if ( $self->renewal_ok ) {
            $item->{due_date} = $self->{due};
            push @{ $self->{renewed} }, $item_id;
        }
        else {
            push @{ $self->{unrenewed} }, $item_id;
        }
        $self->screen_msg(q{});    # clear indiv message
    }
    $self->ok($all_ok);
    return $self;
}

1;
