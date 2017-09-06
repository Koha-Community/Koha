package C4::BatchOverlay::BatchOverlayRule;

use Modern::Perl;

use C4::Context;

sub new {
    my ($class, $name, $matcher_id, $component_matcher_id, $source, $usagerule) = @_;

    my $self = {name => $name,
                matcher_id => $matcher_id,
                component_matcher_id => $component_matcher_id,
                source => $source,
                usagerule => $usagerule};
    bless $self, $class;

    return $self;
}

sub getBatchOverlayRule {
    my ($class, $id, $name) = @_;

    my $dbh = C4::Context->dbh();

    my $sql;
    $sql = 'SELECT * FROM batch_overlay_rules WHERE id = ?' if $id;
    $sql = 'SELECT * FROM batch_overlay_rules WHERE name = ?' if not($id) && $name;

    my $sth = $dbh->prepare( $sql );

    $sth->execute( $id ) if $id;
    $sth->execute( $name ) if not($id) && $name;

    my $self = $sth->fetchrow_hashref();
    bless $self, $class;
    return $self;
}
sub modBatchOverlayRule {
    my $self = shift;

    my $dbh = C4::Context->dbh();

    my $sth = $dbh->prepare(
            'UPDATE batch_overlay_rules SET
                name = ?,
                matcher_id = ?,
                component_matcher_id = ?,
                source = ?,
                usagerule = ?
                WHERE
                id = ?' );

    $sth->execute(
            #UPDATE
                $self->{name},
                $self->{matcher_id},
                $self->{component_matcher_id},
                $self->{source},
                $self->{usagerule},
                #WHERE
                $self->{id} );
}
sub addBatchOverlayRule {
    my $self = shift;

    my $dbh = C4::Context->dbh();

    my $sth = $dbh->prepare(
            'INSERT INTO batch_overlay_rules SET
                name = ?,
                matcher_id = ?,
                component_matcher_id = ?,
                source = ?,
                usagerule = ?' );

    $sth->execute(
            #INSERT
                $self->{name},
                $self->{matcher_id},
                $self->{component_matcher_id},
                $self->{source},
                $self->{usagerule});

    my $newSelf = getBatchOverlayRule(undef, $self->{name});
    $self->{id} = $newSelf->{id};
}
#Returns the source name and id.
# ex.  my $id = $overlayRule->getSource();
# ex.  my ($source, $id) = $overlayRule->getSource();
sub getSource {
    my $self = shift;
    if ($self->{source} =~ /^([^,]+),([^,]+)$/) {
        return ($1, $2);
    }
}

1;
