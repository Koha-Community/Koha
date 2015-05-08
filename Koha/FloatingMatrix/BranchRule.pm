package Koha::FloatingMatrix::BranchRule;

# Copyright 2015 Vaara-kirjastot
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 Rule

Koha::FloatingMatrix::BranchRule - Object representing floating rules for one branch

=head1 DESCRIPTION


=cut

use Modern::Perl;
use Carp qw(carp croak confess longmess);
use Scalar::Util 'blessed';
use Data::Dumper;

use C4::Context qw(dbh);
use Koha::Cache;
use Koha::Database;

use Koha::Exception::BadParameter;


=head new

    my ($branchRule, $error) = Koha::FloatingMatrix::BranchRule->new({
                                    fromBranch => 'CPL',
                                    toBranch => 'FFL',
                                    floating => ['ALWAYS'|'POSSIBLE'|'CONDITIONAL'],
                                    conditionRules => "items->{itype} eq 'BK' && $items->{permanent_location} eq 'CART'"
                                });

BranchRule defines the floating rule for one transfer route.
Eg. If you check-in an Item to CFL and based on your library policies tha Item is transferred to IPT,
We check if there is a floating rule for that fromBranch-toBranch -combination and apply that if applicable.

@PARAM1, HASH
@RETURN, Koha::FloatingMatrix::BranchRule-object,
@THROWS Koha::Exception::BadParameter if given parameters don't validate properly.
=cut

sub new {
    my ($class, $params) = @_;

    ValidateParams($params);

    bless $params, $class;
    return $params;
}

=head newFromDBIx

    Koha::FloatingMatrix::BranchRule->newFromDBIx(  $Koha::Schema::Result::FloatingMatrix  );

Creates a BranchRule-object from DBIx.
See new() for more info.
=cut

sub newFromDBIx {
    my ($class, $dbix) = @_;

    my $params = {
                id => $dbix->id(),
                fromBranch => $dbix->get_column('from_branch'),
                toBranch => $dbix->get_column('to_branch'),
                floating => $dbix->get_column('floating'),
                conditionRules => $dbix->get_column('condition_rules'),
            };
    return $class->new($params);
}

=head ValidateParams, Static subroutine

    my $error = Koha::Overdues::OverdueRule::ValidateParams($params);

@PARAM1, HASH, see new() for valid values.
@THROWS Koha::Exception::BadParameter if given parameters don't validate properly.
=cut

my $maximumConditionRulesDatabaseLength = 100;
sub ValidateParams {
    my ($params) = @_;
    my $errorMsg;

    if (not($params->{fromBranch}) || length $params->{fromBranch} < 1) {
        $errorMsg = "No 'fromBranch'";
    }
    elsif (not($params->{toBranch}) || length $params->{toBranch} < 1) {
        $errorMsg = "No 'toBranch'";
    }
    elsif (not($params->{floating}) || length $params->{floating} < 1) {
        $errorMsg = "No 'floating'";
    }
    elsif ($params->{floating} &&  ($params->{floating} ne 'CONDITIONAL' &&
                                    $params->{floating} ne 'ALWAYS' &&
                                    $params->{floating} ne 'POSSIBLE')
                                   ) {
        $errorMsg = "Bad enum '".$params->{floating}."' for 'floating'";
    }
    elsif (not($params->{conditionRules}) && $params->{floating} eq 'CONDITIONAL') {
        $errorMsg = "No 'conditionRules' when floating = 'CONDITIONAL'";
    }
    elsif ($params->{conditionRules} && $params->{conditionRules} =~ /[};{]/gsmi) {
        $errorMsg = "Not allowed 'conditionRules' characters '};{' present";
    }
    elsif ($params->{conditionRules} && length($params->{conditionRules}) > $maximumConditionRulesDatabaseLength) {
        $errorMsg = "'conditionRules' text is too long. Maximum length is '$maximumConditionRulesDatabaseLength' characters";
    }
    elsif ($params->{conditionRules}) {
        ParseConditionRules(undef, $params->{conditionRules});
    }

    if ($errorMsg) {
        my $fb = $params->{fromBranch} || '';
        my $tb = $params->{toBranch} || '';
        my $id = $params->{id} || '';
        Koha::Exception::BadParameter->throw(error => "Koha::FloatingMatrix::BranchRule::ValidateParams():> $errorMsg. For branch rule id '$id', fromBranch '$fb', toBranch '$tb'.");
    }
    #Now that we have sanitated the input, we can rest assured that bad input won't crash this Object :)
}

=head parseConditionRules, Static method

    my $evalCondition = ParseConditionRules($item, $conditionRules);
    my $evalCondition = ParseConditionRules(undef, $conditionRules);

Parses the given Perl boolean expression into an eval()-able expression.
If Item is given, uses the Item's columns to create a executable expression to check for
conditional floating for this specific Item.

@PARAM1 {Reference to HASH of koha.items-row} Item to check for conditional floating.
@PARAM2 {String koha.floating_matrix.condition_rules} The boolean expression to turn
                    into a Perl code to check the floating condition.
@THROWS Koha::Exception::BadParameter, if the conditionRules couldn't be parsed.
=cut
sub ParseConditionRules {
    my ($item, $conditionRulesString) = @_;
    my $evalCondition = '';
    if (my @conds = $conditionRulesString =~ /(\w+)\s+(ne|eq|gt|lt|<|>|==|!=)\s+(\w+)\s*(and|or|xor|&&|\|\|)?/ig) {

        #If we haven't got no Item, simply stop here to aknowledge that the given condition logic is valid (atleast parseable)
        return undef unless $item;

        #If we have an Item, then prepare and return an eval-expression to test if the Item should float.
        #Iterate the condition quads, with the fourth index being the logical join operator.
        for (my $i=0 ; $i<scalar(@conds) ; $i+=4) {
            my $column = $conds[$i];
            my $operator = $conds[$i+1];
            my $value = $conds[$i+2];
            my $join = $conds[$i+3] || '';

            $evalCondition .= join(' ',"\$item->{'$column'}",$operator,"'$value'",$join,'');
        }

        return $evalCondition;
    }
    else {
        Koha::Exception::BadParameter->throw(error =>
                    "Koha::FloatingMatrix::parseConditionRules():> Bad condition rules '$conditionRulesString' couldn't be parsed\n".
                    "See 'Help' for more info");
    }
}

=head replace

    my $fmBranchRule->replace( $replacementBranchRule );

Replaces the calling branch rule's keys with the given parameters'.
=cut

sub replace {
    my ($branchRule, $replacementBranchRule) = @_;

    foreach my $key (keys %$replacementBranchRule) {
        $branchRule->{$key} = $replacementBranchRule->{$key};
    }
}

=head clone
    $fmBranchCode->clone();
Returns a duplicate of self
=cut
sub clone {
    my ($branchRule) = @_;

    my %newBranchRuleParams;
    foreach my $key (keys %$branchRule) {
        $newBranchRuleParams{$key} = $branchRule->{$key};
    }
    return Koha::FloatingMatrix::BranchRule->new(\%newBranchRuleParams);
}

=head store
Saves the BranchRule into the floating_matrix-table
@THROWS Koha::Exception::BadParameter if id given but no object exists with that id.
=cut
sub store {
    my $branchRule = shift;
    my $schema = Koha::Database->new()->schema();

    my $params = $branchRule->_buildBranchRuleColumns();
    my $id = $branchRule->getId();
    my $oldBranchRule;
    if ($id) {
        $oldBranchRule = $schema->resultset( 'FloatingMatrix' )->find( $id );
    }
    if ($id && not($oldBranchRule)) {
        Koha::Exception::BadParameter->throw(error => "Koha::FloatingMatrix::BranchRule->store():> floating_matrix.id given, but no matching row exist in DB");
    }

    if ($oldBranchRule) {
        $oldBranchRule->update( $params );
    }
    else {
        my $newBranchRule = $schema->resultset( 'FloatingMatrix' )->create( $params );
        $branchRule->setId( $newBranchRule->id() );
    }
}

=head _buildBranchRuleColumns
Transforms the BranchRule into a DBIx $parameters HASH which can be UPDATED to DB.
DBIx is crazy about excess parameters with no mapped DB column, so we cannot just pass the
BranchRule-object to the DBIx.
=cut
sub _buildBranchRuleColumns {
    my ($branchRule) = @_;

    my $columns = {};
    $columns->{"from_branch"} = $branchRule->getFromBranch();
    $columns->{"to_branch"} = $branchRule->getToBranch();
    $columns->{"floating"} = $branchRule->getFloating();
    $columns->{"condition_rules"} = $branchRule->getConditionRules();

    return $columns;
}

sub delete {
    my ($branchRule) = @_;
    my $schema = Koha::Database->new()->schema();
    $schema->resultset('FloatingMatrix')->find($branchRule->getId())->delete();
}

sub setId {
    my ($self, $val) = @_;
    if ($val) {
        $self->{id} = $val;
    }
    else {
        delete $self->{id};
    }
}
sub getId {
    my ($self) = @_;
    return $self->{id};
}
sub setFromBranch {
    my ($self, $fromBranch) = @_;
    $self->{fromBranch} = $fromBranch;
}
sub getFromBranch {
    my ($self) = @_;
    return $self->{fromBranch};
}
sub setToBranch {
    my ($self, $toBranch) = @_;
    $self->{toBranch} = $toBranch;
}
sub getToBranch {
    my ($self) = @_;
    return $self->{toBranch};
}
sub setFloating {
    my ($self, $val) = @_;
    $self->{floating} = $val;
}
sub getFloating {
    my ($self) = @_;
    return $self->{floating};
}
=head setConditionRules
See parseConditionRules()
@THROWS Koha::Exception::BadParameter, if the conditionRules couldn't be parsed.
=cut
sub setConditionRules {
    my ($self, $val) = @_;
    #Validate the conditinal rules.
    ParseConditionRules(undef, $val);
    $self->{conditionRules} = $val;
}
sub getConditionRules {
    my ($self) = @_;
    return $self->{conditionRules};
}

=head toString

    my $stringRepresentationOfThisObject = $branchRule->toString();
    print $stringRepresentationOfThisObject."\n";

=cut

sub toString {
    my ($self) = @_;

    return Data::Dumper::Dump($self);
}
=head TO_JSON

    my $json = JSON::XS->new->utf8->convert_blessed->encode( $branchRule );
    or
    my $json = $branchRule->TO_JSON();

Used to serialize this object as JSON.
=cut
sub TO_JSON {
    my ($branchRule) = @_;

    my $json = {};
    while (my ($key, $val) = each(%$branchRule)) {
        $json->{$key} = $val;
    }
    return $json;
}

1; #Satisfy the compiler