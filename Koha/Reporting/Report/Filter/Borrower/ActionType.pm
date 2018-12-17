#!/usr/bin/perl
package Koha::Reporting::Report::Filter::Borrower::ActionType;

use Modern::Perl;
use Moose;
use Data::Dumper;

extends 'Koha::Reporting::Report::Filter::Abstract';

sub BUILD {
    my $self = shift;
    $self->setName('borrower_activity_type');
    $self->setDescription('Borrower Activity');
    $self->setType('multiselect');
    $self->setDimension('fact');
    $self->setField('activity_type');
    $self->setRule('in');
}

sub getConditionString{
    my $self = shift;
    my ($table, $options) = @_;
    my $conditionString = '';
    my $dbh = C4::Context->dbh;
    my ($value, $notLoaned);
    my $field = $table->getTableName() . '.' . $self->getField();
    if(ref($options) eq 'ARRAY'){
        my $tmpOptions = [];
        foreach my $option (@$options){
            if($option eq '0'){
                $notLoaned = $self->getNotLoanedCondition($table);
            }
            else{
                push $tmpOptions, $option;
            }
        }
        $options = $tmpOptions;
        $value = $self->getArrayCondition($options);
    }
    elsif($options eq '0'){
       $notLoaned = $self->getNotLoanedCondition($table);
    }
    else{
        $value = $dbh->quote($options);
    }
    if($value){
        $conditionString = $self->getConditionByName($self->getRule());
    }
    if($conditionString && $value){
        $conditionString =~ s/\Q{{field}}\E/$field/g;
        $conditionString = sprintf($conditionString, $value);
        if($notLoaned && $notLoaned ne ''){
            $conditionString .= ' OR ' . $notLoaned;
        }
    }
    elsif($notLoaned && $notLoaned ne ''){
        $self->setLogic('OR');
        $conditionString = $notLoaned;
    }
#    die Dumper $conditionString;
    return $conditionString;
}

sub getNotLoanedCondition{
   my $self = shift;
   my $table = $_[0];
   my $condition = '';

   $condition .= '( '. $table->getTableName(). '.borrower_id not in ( select '. $table->getTableName(). '.borrower_id from '. $table->getTableName(). ' where activity_type = "1" ';
   $condition .= 'and '. $table->getTableName() . '.date_id >= '. $self->getFromDate() .' and '. $table->getTableName() . '.date_id <= '. $self->getToDate() . ') ';
   $condition .= 'and '. $table->getTableName(). '.borrower_id in ( select '. $table->getTableName(). '.borrower_id from '. $table->getTableName(). ' where activity_type = "2"' ;
   $condition .= 'and '. $table->getTableName() . '.date_id <= ' . $self->getToDate() . '))';
   return $condition;
}

sub loadOptions{
   my $self = shift;
   my $options = [
       {'name' =>'0', 'description' => 'Not Loaned'},
       {'name' =>'1', 'description' => 'Loaned'},
       {'name' =>'2', 'description' => 'New'},
       {'name' =>'3', 'description' => 'Deleted'}
   ];
   return $options;
}

1;
