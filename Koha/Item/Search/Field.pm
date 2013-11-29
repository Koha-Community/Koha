package Koha::Item::Search::Field;

use Modern::Perl;
use base qw( Exporter );

our @EXPORT_OK = qw(
    AddItemSearchField
    ModItemSearchField
    DelItemSearchField
    GetItemSearchField
    GetItemSearchFields
);

use C4::Context;

sub AddItemSearchField {
    my ($field) = @_;

    my ( $name, $label, $tagfield, $tagsubfield, $av_category ) =
      @$field{qw(name label tagfield tagsubfield authorised_values_category)};

    return unless ($name and $label and $tagfield);

    my $dbh = C4::Context->dbh;
    my $query = q{
        INSERT INTO items_search_fields (name, label, tagfield, tagsubfield, authorised_values_category)
        VALUES (?, ?, ?, ?, ?)
    };
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute($name, $label, $tagfield, $tagsubfield, $av_category);

    return ($rv) ? $field : undef;
}

sub ModItemSearchField {
    my ($field) = @_;

    my ( $name, $label, $tagfield, $tagsubfield, $av_category ) =
      @$field{qw(name label tagfield tagsubfield authorised_values_category)};

    return unless ($name and $label and $tagfield);

    my $dbh = C4::Context->dbh;
    my $query = q{
        UPDATE items_search_fields
        SET label = ?,
            tagfield = ?,
            tagsubfield = ?,
            authorised_values_category = ?
        WHERE name = ?
    };
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute($label, $tagfield, $tagsubfield, $av_category, $name);

    return ($rv) ? $field : undef;
}

sub DelItemSearchField {
    my ($name) = @_;

    my $dbh = C4::Context->dbh;
    my $query = q{
        DELETE FROM items_search_fields
        WHERE name = ?
    };
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute($name);

    my $is_deleted = $rv ? int($rv) : 0;
    if (!$is_deleted) {
        warn "DelItemSearchField: Field '$name' doesn't exist";
    }

    return $is_deleted;
}

sub GetItemSearchField {
    my ($name) = @_;

    my $dbh = C4::Context->dbh;
    my $query = q{
        SELECT * FROM items_search_fields
        WHERE name = ?
    };
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute($name);

    my $field;
    if ($rv) {
        $field = $sth->fetchrow_hashref;
    }

    return $field;
}

sub GetItemSearchFields {
    my $dbh = C4::Context->dbh;
    my $query = q{
        SELECT * FROM items_search_fields
    };
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute();

    my @fields;
    if ($rv) {
        my $fields = $sth->fetchall_arrayref( {} );
        @fields = @$fields;
    }

    return @fields;
}
