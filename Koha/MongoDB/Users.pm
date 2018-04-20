package Koha::MongoDB::Users;

use Moose;
use MongoDB;
use utf8;
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
    return Koha::Patrons->find( $borrowernumber )->unblessed;
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