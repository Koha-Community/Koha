package Koha::MongoDB::Users;

use Moose;
use MongoDB;
use utf8;
use Koha::Patron::Categories;
use Koha::Database;
use Koha::Libraries;
use Koha::Patrons;
use Koha::MongoDB::Config;

has 'config' => (
    is      => 'rw',
    isa => 'Koha::MongoDB::Config',
    reader => 'getConfig',
    writer => 'setConfig'
);

sub BUILD {
    my $self = shift;
    $self->setConfig(new Koha::MongoDB::Config);
}


sub getUser{
    my $self = shift;
    my ($borrowernumber) = @_;

    my $patron = Koha::Patrons->find( $borrowernumber );
    if ($patron) {
        $patron = $patron->unblessed;
    } else {
        my $schema  = Koha::Database->new->schema;
        my $del = $schema->resultset('Deletedborrower')->find({
            borrowernumber => $borrowernumber
        });
        if ($del) {
            $patron = { $del->get_columns } if $del;
        } else {
            # Borrowernumber does not exist either in borrowers nor
            # deletedborrowers table. Return a dummy result.

            # Select first branchcode and categorycode
            my $lib = Koha::Libraries->search->next;
            my $cat = Koha::Patron::Categories->search->next;
            $patron = {
                borrowernumber => 0,
                surname => 'Not found',
                address => 'Nowhere',
                city    => 'Nowhere',
                branchcode => $lib->branchcode,
                categorycode => $cat->categorycode,
            };
        }
    }

    return $patron;
}

sub setUser{
	my $self = shift;
	my ($user) = @_;

	my $client = $self->getConfig->mongoClient();
    my $settings = $self->getConfig->getSettings();

    my $users = $client->ns($settings->{database}.'.users');
    my $finduser = $self->checkUser($user->{borrowernumber});
    my $objectId;

    unless ($finduser) {

        my $result = $users->insert_one({ 
            borrowernumber => $user->{borrowernumber},
            firsname => $user->{firstname},
            surname => $user->{surname},
            date => DateTime->today()->ymd(),
            library => $user->{branchcode},
            cardnumber => $user->{cardnumber}
            });
        $objectId = $result->inserted_id;

    } else {
        $objectId = $finduser->{_id};
    }

    return $objectId;
}

sub checkUser {
	my $self = shift;
    my ($borrowernumber) = @_;
    my $client = $self->getConfig->mongoClient();
    my $settings = $self->getConfig->getSettings();

    my $users = $client->ns($settings->{database}.'.users');
    my $finduser = $users->find_one({borrowernumber => $borrowernumber});
    return $finduser;
}

1;
