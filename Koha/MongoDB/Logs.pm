package Koha::MongoDB::Logs;

use Moose;
use MongoDB;
use Koha::MongoDB::Config;

has 'schema' => (
    is      => 'rw',
    isa => 'DBIx::Class::Schema',
    reader => 'getSchema',
    writer => 'setSchema'
);

has 'config' => (
    is      => 'rw',
    isa => 'Koha::MongoDB::Config',
    reader => 'getConfig',
    writer => 'setConfig'
);

sub BUILD {
    my $self = shift;
    my $schema = Koha::Database->new()->schema();
    $self->setSchema($schema);
    $self->setConfig(new Koha::MongoDB::Config);
}

sub getActionLogs{
	my $self = shift;
    my ($startdate, $enddate) = @_;
    my @modules = ('MEMBERS', 'CIRCULATION', 'FINES', 'NOTICES', 'SS');
    my $dbh = C4::Context->dbh;
    my $query = "
    SELECT action, object, timestamp, user, info from action_logs 
    where module IN (" . join( ",", map { "?" } @modules ) . ") 
    and DATE_FORMAT(timestamp, '%Y-%m-%d %H:%i') >= ? 
    and DATE_FORMAT(timestamp, '%Y-%m-%d %H:%i') <= ?;";
    my $stmnt = $dbh->prepare($query);
    $stmnt->execute(@modules, $startdate, $enddate);

    my @logs;
    while ( my $row = $stmnt->fetchrow_hashref ) {
        push @logs, $row;
    }
    return \@logs;
}

sub setUserLogs{
	my $self = shift;
	my ($actionlog, $sourceuserId, $objectuserId, $cardnumber, $borrowernumber) = @_;

	my $client = $self->getConfig->mongoClient();
    my $settings = $self->getConfig->getSettings();

    my $logs = $client->ns($settings->{database}.'.user_logs');
    my $result = $logs->insert_one({
        sourceuser       => $sourceuserId,
        objectuser       => $objectuserId,
        objectcardnumber => $cardnumber,
        objectborrowernumber => $borrowernumber,
        action           => $actionlog->{action},
        info             => $actionlog->{info},
        timestamp        => $actionlog->{timestamp}

        });   

    return $actionlog;
}

sub checkLog {
	my $self = shift;
	my ($actionlog, $sourceuserId, $objectuserId) = @_;

	my $client = $self->getConfig->mongoClient();
    my $settings = $self->getConfig->getSettings();

    my $logs = $client->ns($settings->{database}.'.user_logs');
    my $findlog = $logs->find_one({
        sourceuser => $sourceuserId->{_id}, 
        objectuser => $objectuserId->{_id}, 
        action => $actionlog->{action}, 
        timestamp => $actionlog->{timestamp}});

    return $findlog;
}

1;