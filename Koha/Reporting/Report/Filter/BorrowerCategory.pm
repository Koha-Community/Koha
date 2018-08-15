#!/usr/bin/perl
package Koha::Reporting::Report::Filter::BorrowerCategory;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('categorycode');
    $self->setDescription('Borrower Category');
    $self->setType('multiselect');
    $self->setDimension('borrower');
    $self->setField('categorycode');
    $self->setRule('in');
    $self->setAddNotSetOption(0);

}

sub loadOptions{
    my $self = shift;
    my $dbh = C4::Context->dbh;
    my $options = [];
    my $query = 'select distinct reporting_borrower_dim.categorycode, categories.description from reporting_borrower_dim ';
    $query .= 'inner join categories on categories.categorycode = reporting_borrower_dim.categorycode ';
    $query .= "where reporting_borrower_dim.categorycode not in ('EITILASTO', 'VIRKAILIJA') ";
    $query .= 'order by categorycode ';

    my $stmnt = $dbh->prepare($query);
    $stmnt->execute();
    if ($stmnt->rows >= 1){
        while ( my $row = $stmnt->fetchrow_hashref ) {
            my $option = {'name' => $row->{'categorycode'}, 'description' => $row->{'description'}};
            push @{$options}, $option;
        }
    }
    return $options;
}

1;
