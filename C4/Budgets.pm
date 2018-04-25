package C4::Budgets;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use Koha::Database;
use Koha::Patrons;
use Koha::InvoiceAdjustments;
use C4::Debug;
use vars qw(@ISA @EXPORT);

BEGIN {
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(

        &GetBudget
        &GetBudgetByOrderNumber
        &GetBudgetByCode
        &GetBudgets
        &BudgetsByActivity
        &GetBudgetsReport
        &GetBudgetReport
        &GetBudgetHierarchy
	    &AddBudget
        &ModBudget
        &DelBudget
        &GetBudgetSpent
        &GetBudgetOrdered
        &GetBudgetName
        &GetPeriodsCount
        GetBudgetHierarchySpent
        GetBudgetHierarchyOrdered

        &GetBudgetUsers
        &ModBudgetUsers
        &CanUserUseBudget
        &CanUserModifyBudget

	    &GetBudgetPeriod
        &GetBudgetPeriods
        &ModBudgetPeriod
        &AddBudgetPeriod
	    &DelBudgetPeriod

        &ModBudgetPlan

		&GetBudgetsPlanCell
        &AddBudgetPlanValue
        &GetBudgetAuthCats
        &BudgetHasChildren
        &CheckBudgetParent
        &CheckBudgetParentPerm

        &HideCols
        &GetCols
	);
}

# ----------------------------BUDGETS.PM-----------------------------";

=head1 FUNCTIONS ABOUT BUDGETS

=cut

sub HideCols {
    my ( $authcat, @hide_cols ) = @_;
    my $dbh = C4::Context->dbh;

    my $sth1 = $dbh->prepare(
        qq|
        UPDATE aqbudgets_planning SET display = 0 
        WHERE authcat = ? 
        AND  authvalue = ? |
    );
    foreach my $authvalue (@hide_cols) {
#        $sth1->{TraceLevel} = 3;
        $sth1->execute(  $authcat, $authvalue );
    }
}

sub GetCols {
    my ( $authcat, $authvalue ) = @_;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        qq|
        SELECT count(display) as cnt from aqbudgets_planning
        WHERE  authcat = ? 
        AND authvalue = ? and display  = 0   |
    );

#    $sth->{TraceLevel} = 3;
    $sth->execute( $authcat, $authvalue );
    my $res  = $sth->fetchrow_hashref;

    return  $res->{cnt} > 0 ? 0: 1

}

sub CheckBudgetParentPerm {
    my ( $budget, $borrower_id ) = @_;
    my $depth = $budget->{depth};
    my $parent_id = $budget->{budget_parent_id};
    while ($depth) {
        my $parent = GetBudget($parent_id);
        $parent_id = $parent->{budget_parent_id};
        if ( $parent->{budget_owner_id} == $borrower_id ) {
            return 1;
        }
        $depth--
    }
    return 0;
}

sub AddBudgetPeriod {
    my ($budgetperiod) = @_;
    return unless($budgetperiod->{budget_period_startdate} && $budgetperiod->{budget_period_enddate});

    my $resultset = Koha::Database->new()->schema->resultset('Aqbudgetperiod');
    return $resultset->create($budgetperiod)->id;
}
# -------------------------------------------------------------------
sub GetPeriodsCount {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
        SELECT COUNT(*) AS sum FROM aqbudgetperiods ");
    $sth->execute();
    my $res = $sth->fetchrow_hashref;
    return $res->{'sum'};
}

# -------------------------------------------------------------------
sub CheckBudgetParent {
    my ( $new_parent, $budget ) = @_;
    my $new_parent_id = $new_parent->{'budget_id'};
    my $budget_id     = $budget->{'budget_id'};
    my $dbh           = C4::Context->dbh;
    my $parent_id_tmp = $new_parent_id;

    # check new-parent is not a child (or a child's child ;)
    my $sth = $dbh->prepare(qq|
        SELECT budget_parent_id FROM
            aqbudgets where budget_id = ? | );
    while (1) {
        $sth->execute($parent_id_tmp);
        my $res = $sth->fetchrow_hashref;
        if ( $res->{'budget_parent_id'} == $budget_id ) {
            return 1;
        }
        if ( not defined $res->{'budget_parent_id'} ) {
            return 0;
        }
        $parent_id_tmp = $res->{'budget_parent_id'};
    }
}

# -------------------------------------------------------------------
sub BudgetHasChildren {
    my ( $budget_id  ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(qq|
       SELECT count(*) as sum FROM  aqbudgets
        WHERE budget_parent_id = ?   | );
    $sth->execute( $budget_id );
    my $sum = $sth->fetchrow_hashref;
    return $sum->{'sum'};
}

sub GetBudgetChildren {
    my ( $budget_id ) = @_;
    my $dbh = C4::Context->dbh;
    return $dbh->selectall_arrayref(q|
       SELECT  * FROM  aqbudgets
        WHERE budget_parent_id = ?
    |, { Slice => {} }, $budget_id );
}

sub SetOwnerToFundHierarchy {
    my ( $budget_id, $borrowernumber ) = @_;

    my $budget = GetBudget( $budget_id );
    $budget->{budget_owner_id} = $borrowernumber;
    ModBudget( $budget );
    my $children = GetBudgetChildren( $budget_id );
    for my $child ( @$children ) {
        SetOwnerToFundHierarchy( $child->{budget_id}, $borrowernumber );
    }
}

# -------------------------------------------------------------------
sub GetBudgetsPlanCell {
    my ( $cell, $period, $budget ) = @_;
    my ($actual, $sth);
    my $dbh = C4::Context->dbh;
    if ( $cell->{'authcat'} eq 'MONTHS' ) {
        # get the actual amount
        $sth = $dbh->prepare( qq|

            SELECT SUM(ecost_tax_included) AS actual FROM aqorders
                WHERE    budget_id = ? AND
                entrydate like "$cell->{'authvalue'}%"  |
        );
        $sth->execute( $cell->{'budget_id'} );
    } elsif ( $cell->{'authcat'} eq 'BRANCHES' ) {
        # get the actual amount
        $sth = $dbh->prepare( qq|

            SELECT SUM(ecost_tax_included) FROM aqorders
                LEFT JOIN aqorders_items
                ON (aqorders.ordernumber = aqorders_items.ordernumber)
                LEFT JOIN items
                ON (aqorders_items.itemnumber = items.itemnumber)
                WHERE budget_id = ? AND homebranch = ? |          );

        $sth->execute( $cell->{'budget_id'}, $cell->{'authvalue'} );
    } elsif ( $cell->{'authcat'} eq 'ITEMTYPES' ) {
        # get the actual amount
        $sth = $dbh->prepare(  qq|

            SELECT SUM( ecost_tax_included *  quantity) AS actual
                FROM aqorders JOIN biblioitems
                ON (biblioitems.biblionumber = aqorders.biblionumber )
                WHERE aqorders.budget_id = ? and itemtype  = ? |
        );
        $sth->execute(  $cell->{'budget_id'},
                        $cell->{'authvalue'} );
    }
    # ELSE GENERIC ORDERS SORT1/SORT2 STAT COUNT.
    else {
        # get the actual amount
        $sth = $dbh->prepare( qq|

        SELECT  SUM(ecost_tax_included * quantity) AS actual
            FROM aqorders
            JOIN aqbudgets ON (aqbudgets.budget_id = aqorders.budget_id )
            WHERE  aqorders.budget_id = ? AND
                ((aqbudgets.sort1_authcat = ? AND sort1 =?) OR
                (aqbudgets.sort2_authcat = ? AND sort2 =?))    |
        );
        $sth->execute(  $cell->{'budget_id'},
                        $budget->{'sort1_authcat'},
                        $cell->{'authvalue'},
                        $budget->{'sort2_authcat'},
                        $cell->{'authvalue'}
        );
    }
    $actual = $sth->fetchrow_array;

    # get the estimated amount
    $sth = $dbh->prepare( qq|

        SELECT estimated_amount AS estimated, display FROM aqbudgets_planning
            WHERE budget_period_id = ? AND
                budget_id = ? AND
                authvalue = ? AND
                authcat = ?         |
    );
    $sth->execute(  $cell->{'budget_period_id'},
                    $cell->{'budget_id'},
                    $cell->{'authvalue'},
                    $cell->{'authcat'},
    );


    my $res  = $sth->fetchrow_hashref;
  #  my $display = $res->{'display'};
    my $estimated = $res->{'estimated'};


    return $actual, $estimated;
}

# -------------------------------------------------------------------
sub ModBudgetPlan {
    my ( $budget_plan, $budget_period_id, $authcat ) = @_;
    my $dbh = C4::Context->dbh;
    foreach my $buds (@$budget_plan) {
        my $lines = $buds->{lines};
        my $sth = $dbh->prepare( qq|
                DELETE FROM aqbudgets_planning
                    WHERE   budget_period_id   = ? AND
                            budget_id   = ? AND
                            authcat            = ? |
        );
    #delete a aqplan line of cells, then insert new cells, 
    # these could be UPDATES rather than DEL/INSERTS...
        $sth->execute( $budget_period_id,  $lines->[0]{budget_id}   , $authcat );

        foreach my $cell (@$lines) {
            my $sth = $dbh->prepare( qq|

                INSERT INTO aqbudgets_planning
                     SET   budget_id     = ?,
                     budget_period_id  = ?,
                     authcat          = ?,
                     estimated_amount  = ?,
                     authvalue       = ?  |
            );
            $sth->execute(
                            $cell->{'budget_id'},
                            $cell->{'budget_period_id'},
                            $cell->{'authcat'},
                            $cell->{'estimated_amount'},
                            $cell->{'authvalue'},
            );
        }
    }
}

# -------------------------------------------------------------------
sub GetBudgetSpent {
    my ($budget_id) = @_;
    my $dbh = C4::Context->dbh;
    # unitprice_tax_included should always been set here
    # we should not need to retrieve ecost_tax_included
    my $sth = $dbh->prepare(qq|
        SELECT SUM( COALESCE(unitprice_tax_included, ecost_tax_included) * quantity ) AS sum FROM aqorders
            WHERE budget_id = ? AND
            quantityreceived > 0 AND
            datecancellationprinted IS NULL
    |);
	$sth->execute($budget_id);
    my $sum = 0 + $sth->fetchrow_array;

    $sth = $dbh->prepare(qq|
        SELECT SUM(shipmentcost) AS sum
        FROM aqinvoices
        WHERE shipmentcost_budgetid = ?
    |);

    $sth->execute($budget_id);
    my ($shipmentcost_sum) = $sth->fetchrow_array;
    $sum += $shipmentcost_sum;

    my $adjustments = Koha::InvoiceAdjustments->search({budget_id => $budget_id, closedate => { '!=' => undef } },{ join => 'invoiceid' });
    while ( my $adj = $adjustments->next ){
        $sum += $adj->adjustment;
    }

	return $sum;
}

# -------------------------------------------------------------------
sub GetBudgetOrdered {
	my ($budget_id) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare(qq|
        SELECT SUM(ecost_tax_included *  quantity) AS sum FROM aqorders
            WHERE budget_id = ? AND
            quantityreceived = 0 AND
            datecancellationprinted IS NULL
    |);
	$sth->execute($budget_id);
    my $sum =  0 + $sth->fetchrow_array;

    my $adjustments = Koha::InvoiceAdjustments->search({budget_id => $budget_id, encumber_open => 1, closedate => undef},{ join => 'invoiceid' });
    while ( my $adj = $adjustments->next ){
        $sum += $adj->adjustment;
    }

	return $sum;
}

=head2 GetBudgetName

  my $budget_name = &GetBudgetName($budget_id);

get the budget_name for a given budget_id

=cut

sub GetBudgetName {
    my ( $budget_id ) = @_;
    my $dbh         = C4::Context->dbh;
    my $sth         = $dbh->prepare(
        qq|
        SELECT budget_name
        FROM aqbudgets
        WHERE budget_id = ?
    |);

    $sth->execute($budget_id);
    return $sth->fetchrow_array;
}

=head2 GetBudgetAuthCats

  my $auth_cats = &GetBudgetAuthCats($budget_period_id);

Return the list of authcat for a given budget_period_id

=cut

sub GetBudgetAuthCats  {
    my ($budget_period_id) = shift;
    # now, populate the auth_cats_loop used in the budget planning button
    # we must retrieve all auth values used by at least one budget
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("SELECT sort1_authcat,sort2_authcat FROM aqbudgets WHERE budget_period_id=?");
    $sth->execute($budget_period_id);
    my %authcats;
    while (my ($sort1_authcat,$sort2_authcat) = $sth->fetchrow) {
        $authcats{$sort1_authcat}=1 if $sort1_authcat;
        $authcats{$sort2_authcat}=1 if $sort2_authcat;
    }
    return [ sort keys %authcats ];
}

# -------------------------------------------------------------------
sub GetBudgetPeriods {
	my ($filters,$orderby) = @_;

    my $rs = Koha::Database->new()->schema->resultset('Aqbudgetperiod');
    $rs = $rs->search( $filters, { order_by => $orderby } );
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    return [ $rs->all ];
}
# -------------------------------------------------------------------
sub GetBudgetPeriod {
	my ($budget_period_id) = @_;
	my $dbh = C4::Context->dbh;
	## $total = number of records linked to the record that must be deleted
	my $total = 0;
	## get information about the record that will be deleted
	my $sth;
	if ($budget_period_id) {
		$sth = $dbh->prepare( qq|
              SELECT      *
                FROM aqbudgetperiods
                WHERE budget_period_id=? |
		);
		$sth->execute($budget_period_id);
	} else {         # ACTIVE BUDGET
		$sth = $dbh->prepare(qq|
			  SELECT      *
                FROM aqbudgetperiods
                WHERE budget_period_active=1 |
		);
		$sth->execute();
	}
	my $data = $sth->fetchrow_hashref;
	return $data;
}

sub DelBudgetPeriod{
	my ($budget_period_id) = @_;
	my $dbh = C4::Context->dbh;
	  ; ## $total = number of records linked to the record that must be deleted
    my $total = 0;

	## get information about the record that will be deleted
	my $sth = $dbh->prepare(qq|
		DELETE 
         FROM aqbudgetperiods
         WHERE budget_period_id=? |
	);
	return $sth->execute($budget_period_id);
}

# -------------------------------------------------------------------
sub ModBudgetPeriod {
    my ($budget_period) = @_;
    my $result = Koha::Database->new()->schema->resultset('Aqbudgetperiod')->find($budget_period);
    return unless($result);

    $result = $result->update($budget_period);
    return $result->in_storage;
}

# -------------------------------------------------------------------
sub GetBudgetHierarchy {
    my ( $budget_period_id, $branchcode, $owner ) = @_;
    my @bind_params;
    my $dbh   = C4::Context->dbh;
    my $query = qq|
                    SELECT aqbudgets.*, aqbudgetperiods.budget_period_active, aqbudgetperiods.budget_period_description,
                           b.firstname as budget_owner_firstname, b.surname as budget_owner_surname, b.borrowernumber as budget_owner_borrowernumber
                    FROM aqbudgets 
                    LEFT JOIN borrowers b on b.borrowernumber = aqbudgets.budget_owner_id
                    JOIN aqbudgetperiods USING (budget_period_id)|;

	my @where_strings;
    # show only period X if requested
    if ($budget_period_id) {
        push @where_strings," aqbudgets.budget_period_id = ?";
        push @bind_params, $budget_period_id;
    }
	# show only budgets owned by me, my branch or everyone
    if ($owner) {
        if ($branchcode) {
            push @where_strings,
            qq{ (budget_owner_id = ? OR budget_branchcode = ? OR ((budget_branchcode IS NULL or budget_branchcode="") AND (budget_owner_id IS NULL OR budget_owner_id="")))};
            push @bind_params, ( $owner, $branchcode );
        } else {
            push @where_strings, ' (budget_owner_id = ? OR budget_owner_id IS NULL or budget_owner_id ="") ';
            push @bind_params, $owner;
        }
    } else {
        if ($branchcode) {
            push @where_strings," (budget_branchcode =? or budget_branchcode is NULL OR budget_branchcode='')";
            push @bind_params, $branchcode;
        }
    }
	$query.=" WHERE ".join(' AND ', @where_strings) if @where_strings;
	$debug && warn $query,join(",",@bind_params);
	my $sth = $dbh->prepare($query);
	$sth->execute(@bind_params);

    my %links;
    # create hash with budget_id has key
    while ( my $data = $sth->fetchrow_hashref ) {
        $links{ $data->{'budget_id'} } = $data;
    }

    # link child to parent
    my @first_parents;
    foreach my $budget ( sort { $a->{budget_code} cmp $b->{budget_code} } values %links ) {
        my $child = $links{$budget->{budget_id}};
        if ( $child->{'budget_parent_id'} ) {
            my $parent = $links{ $child->{'budget_parent_id'} };
            if ($parent) {
                unless ( $parent->{'children'} ) {
                    # init child arrayref
                    $parent->{'children'} = [];
                }
                # add as child
                push @{ $parent->{'children'} }, $child;
            }
        } else {
            push @first_parents, $child;
        }
    }

    my @sort = ();
    foreach my $first_parent (@first_parents) {
        _add_budget_children(\@sort, $first_parent, 0);
    }

    # Get all the budgets totals in as few queries as possible
    my $hr_budget_spent = $dbh->selectall_hashref(q|
        SELECT aqorders.budget_id, aqbudgets.budget_parent_id,
               SUM( COALESCE(unitprice_tax_included, ecost_tax_included) * quantity ) AS budget_spent
        FROM aqorders JOIN aqbudgets USING (budget_id)
        WHERE quantityreceived > 0 AND datecancellationprinted IS NULL
        GROUP BY budget_id
        |, 'budget_id');
    my $hr_budget_ordered = $dbh->selectall_hashref(q|
        SELECT aqorders.budget_id, aqbudgets.budget_parent_id,
               SUM(ecost_tax_included *  quantity) AS budget_ordered
        FROM aqorders JOIN aqbudgets USING (budget_id)
        WHERE quantityreceived = 0 AND datecancellationprinted IS NULL
        GROUP BY budget_id
        |, 'budget_id');
    my $hr_budget_spent_shipment = $dbh->selectall_hashref(q|
        SELECT shipmentcost_budgetid as budget_id,
               SUM(shipmentcost) as shipmentcost
        FROM aqinvoices
        WHERE closedate IS NOT NULL
        GROUP BY shipmentcost_budgetid
        |, 'budget_id');
    my $hr_budget_ordered_shipment = $dbh->selectall_hashref(q|
        SELECT shipmentcost_budgetid as budget_id,
               SUM(shipmentcost) as shipmentcost
        FROM aqinvoices
        WHERE closedate IS NULL
        GROUP BY shipmentcost_budgetid
        |, 'budget_id');


    foreach my $budget (@sort) {
        if ( not defined $budget->{budget_parent_id} ) {
            _recursiveAdd( $budget, undef, $hr_budget_spent, $hr_budget_spent_shipment, $hr_budget_ordered, $hr_budget_ordered_shipment );
        }
    }
    return \@sort;
}

sub _recursiveAdd {
    my ($budget, $parent, $hr_budget_spent, $hr_budget_spent_shipment, $hr_budget_ordered, $hr_budget_ordered_shipment ) = @_;

    foreach my $child (@{$budget->{children}}){
        _recursiveAdd($child, $budget, $hr_budget_spent, $hr_budget_spent_shipment, $hr_budget_ordered, $hr_budget_ordered_shipment );
    }

    $budget->{budget_spent} += $hr_budget_spent->{$budget->{budget_id}}->{budget_spent};
    $budget->{budget_spent} += $hr_budget_spent_shipment->{$budget->{budget_id}}->{shipmentcost};
    $budget->{budget_ordered} += $hr_budget_ordered->{$budget->{budget_id}}->{budget_ordered};
    $budget->{budget_ordered} += $hr_budget_ordered_shipment->{$budget->{budget_id}}->{shipmentcost};

    $budget->{total_spent} += $budget->{budget_spent};
    $budget->{total_ordered} += $budget->{budget_ordered};

    if ($parent) {
        $parent->{total_spent} += $budget->{total_spent};
        $parent->{total_ordered} += $budget->{total_ordered};
    }
}

# Recursive method to add a budget and its chidren to an array
sub _add_budget_children {
    my $res = shift;
    my $budget = shift;
    $budget->{budget_level} = shift;
    push @$res, $budget;
    my $children = $budget->{'children'} || [];
    return unless @$children; # break recursivity
    foreach my $child (@$children) {
        _add_budget_children($res, $child, $budget->{budget_level} + 1);
    }
}

# -------------------------------------------------------------------

sub AddBudget {
    my ($budget) = @_;
    return unless ($budget);

    my $resultset = Koha::Database->new()->schema->resultset('Aqbudget');
    return $resultset->create($budget)->id;
}

# -------------------------------------------------------------------
sub ModBudget {
    my ($budget) = @_;
    my $result = Koha::Database->new()->schema->resultset('Aqbudget')->find($budget);
    return unless($result);

    $result = $result->update($budget);
    return $result->in_storage;
}

# -------------------------------------------------------------------
sub DelBudget {
	my ($budget_id) = @_;
	my $dbh         = C4::Context->dbh;
	my $sth         = $dbh->prepare("delete from aqbudgets where budget_id=?");
	my $rc          = $sth->execute($budget_id);
	return $rc;
}


# -------------------------------------------------------------------

=head2 GetBudget

  &GetBudget($budget_id);

get a specific budget

=cut

sub GetBudget {
    my ( $budget_id ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT *
        FROM   aqbudgets
        WHERE  budget_id=?
        ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $budget_id );
    my $result = $sth->fetchrow_hashref;
    return $result;
}

# -------------------------------------------------------------------

=head2 GetBudgetByOrderNumber

  &GetBudgetByOrderNumber($ordernumber);

get a specific budget by order number

=cut

sub GetBudgetByOrderNumber {
    my ( $ordernumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT aqbudgets.*
        FROM   aqbudgets, aqorders
        WHERE  ordernumber=?
        AND    aqorders.budget_id = aqbudgets.budget_id
        ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $ordernumber );
    my $result = $sth->fetchrow_hashref;
    return $result;
}

=head2 GetBudgetReport

  &GetBudgetReport( [$budget_id] );

Get all orders for a specific budget, without cancelled orders.

Returns an array of hashrefs.

=cut

# --------------------------------------------------------------------
sub GetBudgetReport {
    my ( $budget_id ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = '
        SELECT o.*, b.budget_name
        FROM   aqbudgets b
        INNER JOIN aqorders o
        ON b.budget_id = o.budget_id
        WHERE  b.budget_id=?
        AND (o.orderstatus != "cancelled")
        ORDER BY b.budget_name';

    my $sth = $dbh->prepare($query);
    $sth->execute( $budget_id );

    my @results = ();
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    return @results;
}

=head2 GetBudgetsByActivity

  &GetBudgetsByActivity( $budget_period_active );

Get all active or inactive budgets, depending of the value
of the parameter.

1 = active
0 = inactive

=cut

# --------------------------------------------------------------------
sub GetBudgetsByActivity {
    my ( $budget_period_active ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
        SELECT DISTINCT b.*
        FROM   aqbudgetperiods bp
        INNER JOIN aqbudgets b
        ON bp.budget_period_id = b.budget_period_id
        WHERE  bp.budget_period_active=?
        ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $budget_period_active );
    my @results = ();
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    return @results;
}
# --------------------------------------------------------------------

=head2 GetBudgetsReport

  &GetBudgetsReport( [$activity] );

Get all but cancelled orders for all funds.

If the optionnal activity parameter is passed, returns orders for active/inactive budgets only.

active = 1
inactive = 0

Returns an array of hashrefs.

=cut

sub GetBudgetsReport {
    my ($activity) = @_;
    my $dbh = C4::Context->dbh;
    my $query = '
        SELECT o.*, b.budget_name
        FROM   aqbudgetperiods bp
        INNER JOIN aqbudgets b
        ON bp.budget_period_id = b.budget_period_id
        INNER JOIN aqorders o
        ON b.budget_id = o.budget_id ';
    if($activity ne ''){
        $query .= 'WHERE  bp.budget_period_active=? ';
    }
    $query .= 'AND (o.orderstatus != "cancelled")
               ORDER BY b.budget_name';

    my $sth = $dbh->prepare($query);
    if($activity ne ''){
        $sth->execute($activity);
    }
    else{
        $sth->execute;
    }
    my @results = ();
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    return @results;
}

=head2 GetBudgetByCode

    my $budget = &GetBudgetByCode($budget_code);

Retrieve all aqbudgets fields as a hashref for the budget that has
given budget_code

=cut

sub GetBudgetByCode {
    my ( $budget_code ) = @_;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT aqbudgets.*
        FROM aqbudgets
        JOIN aqbudgetperiods USING (budget_period_id)
        WHERE budget_code = ?
        ORDER BY budget_period_active DESC, budget_id DESC
        LIMIT 1
    };
    my $sth = $dbh->prepare( $query );
    $sth->execute( $budget_code );
    return $sth->fetchrow_hashref;
}

=head2 GetBudgetHierarchySpent

  my $spent = GetBudgetHierarchySpent( $budget_id );

Gets the total spent of the level and sublevels of $budget_id

=cut

sub GetBudgetHierarchySpent {
    my ( $budget_id ) = @_;
    my $dbh = C4::Context->dbh;
    my $children_ids = $dbh->selectcol_arrayref(q|
        SELECT budget_id
        FROM   aqbudgets
        WHERE  budget_parent_id = ?
    |, {}, $budget_id );

    my $total_spent = GetBudgetSpent( $budget_id );
    for my $child_id ( @$children_ids ) {
        $total_spent += GetBudgetHierarchySpent( $child_id );
    }
    return $total_spent;
}

=head2 GetBudgetHierarchyOrdered

  my $ordered = GetBudgetHierarchyOrdered( $budget_id );

Gets the total ordered of the level and sublevels of $budget_id

=cut

sub GetBudgetHierarchyOrdered {
    my ( $budget_id ) = @_;
    my $dbh = C4::Context->dbh;
    my $children_ids = $dbh->selectcol_arrayref(q|
        SELECT budget_id
        FROM   aqbudgets
        WHERE  budget_parent_id = ?
    |, {}, $budget_id );

    my $total_ordered = GetBudgetOrdered( $budget_id );
    for my $child_id ( @$children_ids ) {
        $total_ordered += GetBudgetHierarchyOrdered( $child_id );
    }
    return $total_ordered;
}

=head2 GetBudgets

  &GetBudgets($filter, $order_by);

gets all budgets

=cut

# -------------------------------------------------------------------
sub GetBudgets {
    my ($filters, $orderby) = @_;
    $orderby = 'budget_name' unless($orderby);

    my $rs = Koha::Database->new()->schema->resultset('Aqbudget');
    $rs = $rs->search( $filters, { order_by => $orderby } );
    $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');
    return [ $rs->all  ];
}

=head2 GetBudgetUsers

    my @borrowernumbers = &GetBudgetUsers($budget_id);

Return the list of borrowernumbers linked to a budget

=cut

sub GetBudgetUsers {
    my ($budget_id) = @_;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT borrowernumber
        FROM aqbudgetborrowers
        WHERE budget_id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($budget_id);

    my @borrowernumbers;
    while (my ($borrowernumber) = $sth->fetchrow_array) {
        push @borrowernumbers, $borrowernumber
    }

    return @borrowernumbers;
}

=head2 ModBudgetUsers

    &ModBudgetUsers($budget_id, @borrowernumbers);

Modify the list of borrowernumbers linked to a budget

=cut

sub ModBudgetUsers {
    my ($budget_id, @budget_users_id) = @_;

    return unless $budget_id;

    my $dbh = C4::Context->dbh;
    my $query = "DELETE FROM aqbudgetborrowers WHERE budget_id = ?";
    my $sth = $dbh->prepare($query);
    $sth->execute($budget_id);

    $query = qq{
        INSERT INTO aqbudgetborrowers (budget_id, borrowernumber)
        VALUES (?,?)
    };
    $sth = $dbh->prepare($query);
    foreach my $borrowernumber (@budget_users_id) {
        next unless $borrowernumber;
        $sth->execute($budget_id, $borrowernumber);
    }
}

sub CanUserUseBudget {
    my ($borrower, $budget, $userflags) = @_;

    if (not ref $borrower) {
        $borrower = Koha::Patrons->find( $borrower );
        return 0 unless $borrower;
        $borrower = $borrower->unblessed;
    }
    if (not ref $budget) {
        $budget = GetBudget($budget);
    }

    return 0 unless ($borrower and $budget);

    if (not defined $userflags) {
        $userflags = C4::Auth::getuserflags($borrower->{flags},
            $borrower->{userid});
    }

    unless ($userflags->{superlibrarian}
    || (ref $userflags->{acquisition}
        && $userflags->{acquisition}->{budget_manage_all})
    || (!ref $userflags->{acquisition} && $userflags->{acquisition}))
    {
        if (not exists $userflags->{acquisition}) {
            return 0;
        }

        if (!ref $userflags->{acquisition} && !$userflags->{acquisition}) {
            return 0;
        }

        # Budget restricted to owner
        if ( $budget->{budget_permission} == 1 ) {
            if (    $budget->{budget_owner_id}
                and $budget->{budget_owner_id} != $borrower->{borrowernumber} )
            {
                return 0;
            }
        }

        # Budget restricted to owner, users and library
        elsif ( $budget->{budget_permission} == 2 ) {
            my @budget_users = GetBudgetUsers( $budget->{budget_id} );

            if (
                (
                        $budget->{budget_owner_id}
                    and $budget->{budget_owner_id} !=
                    $borrower->{borrowernumber}
                    or not $budget->{budget_owner_id}
                )
                and ( 0 == grep { $borrower->{borrowernumber} == $_ }
                    @budget_users )
                and defined $budget->{budget_branchcode}
                and $budget->{budget_branchcode} ne
                C4::Context->userenv->{branch}
              )
            {
                return 0;
            }
        }

        # Budget restricted to owner and users
        elsif ( $budget->{budget_permission} == 3 ) {
            my @budget_users = GetBudgetUsers( $budget->{budget_id} );
            if (
                (
                        $budget->{budget_owner_id}
                    and $budget->{budget_owner_id} !=
                    $borrower->{borrowernumber}
                    or not $budget->{budget_owner_id}
                )
                and ( 0 == grep { $borrower->{borrowernumber} == $_ }
                    @budget_users )
              )
            {
                return 0;
            }
        }
    }

    return 1;
}

sub CanUserModifyBudget {
    my ($borrower, $budget, $userflags) = @_;

    if (not ref $borrower) {
        $borrower = Koha::Patrons->find( $borrower );
        return 0 unless $borrower;
        $borrower = $borrower->unblessed;
    }
    if (not ref $budget) {
        $budget = GetBudget($budget);
    }

    return 0 unless ($borrower and $budget);

    if (not defined $userflags) {
        $userflags = C4::Auth::getuserflags($borrower->{flags},
            $borrower->{userid});
    }

    unless ($userflags->{superlibrarian}
    || (ref $userflags->{acquisition}
        && $userflags->{acquisition}->{budget_manage_all})
    || (!ref $userflags->{acquisition} && $userflags->{acquisition}))
    {
        if (!CanUserUseBudget($borrower, $budget, $userflags)) {
            return 0;
        }

        if (ref $userflags->{acquisition}
        && !$userflags->{acquisition}->{budget_modify}) {
            return 0;
        }
    }

    return 1;
}

sub _round {
    my ($value, $increment) = @_;

    if ($increment && $increment != 0) {
        $value = int($value / $increment) * $increment;
    }

    return $value;
}

=head2 CloneBudgetPeriod

  my $new_budget_period_id = CloneBudgetPeriod({
    budget_period_id => $budget_period_id,
    budget_period_startdate => $budget_period_startdate,
    budget_period_enddate   => $budget_period_enddate,
    mark_original_budget_as_inactive => 1n
    reset_all_budgets => 1,
  });

Clone a budget period with all budgets.
If the mark_origin_budget_as_inactive is set (0 by default),
the original budget will be marked as inactive.

If the reset_all_budgets is set (0 by default), all budget (fund)
amounts will be reset.

=cut

sub CloneBudgetPeriod {
    my ($params)                  = @_;
    my $budget_period_id          = $params->{budget_period_id};
    my $budget_period_startdate   = $params->{budget_period_startdate};
    my $budget_period_enddate     = $params->{budget_period_enddate};
    my $budget_period_description = $params->{budget_period_description};
    my $amount_change_percentage  = $params->{amount_change_percentage};
    my $amount_change_round_increment = $params->{amount_change_round_increment};
    my $mark_original_budget_as_inactive =
      $params->{mark_original_budget_as_inactive} || 0;
    my $reset_all_budgets = $params->{reset_all_budgets} || 0;

    my $budget_period = GetBudgetPeriod($budget_period_id);

    $budget_period->{budget_period_startdate}   = $budget_period_startdate;
    $budget_period->{budget_period_enddate}     = $budget_period_enddate;
    $budget_period->{budget_period_description} = $budget_period_description;
    # The new budget (budget_period) should be active by default
    $budget_period->{budget_period_active}    = 1;

    if ($amount_change_percentage) {
        my $total = $budget_period->{budget_period_total};
        $total += $total * $amount_change_percentage / 100;
        $total = _round($total, $amount_change_round_increment);
        $budget_period->{budget_period_total} = $total;
    }

    my $original_budget_period_id = $budget_period->{budget_period_id};
    delete $budget_period->{budget_period_id};
    my $new_budget_period_id = AddBudgetPeriod( $budget_period );

    my $budgets = GetBudgetHierarchy($budget_period_id);
    CloneBudgetHierarchy(
        {
            budgets              => $budgets,
            new_budget_period_id => $new_budget_period_id
        }
    );

    if ($mark_original_budget_as_inactive) {
        ModBudgetPeriod(
            {
                budget_period_id     => $budget_period_id,
                budget_period_active => 0,
            }
        );
    }

    if ( $reset_all_budgets ) {
        my $budgets = GetBudgets({ budget_period_id => $new_budget_period_id });
        for my $budget ( @$budgets ) {
            $budget->{budget_amount} = 0;
            ModBudget( $budget );
        }
    } elsif ($amount_change_percentage) {
        my $budgets = GetBudgets({ budget_period_id => $new_budget_period_id });
        for my $budget ( @$budgets ) {
            my $amount = $budget->{budget_amount};
            $amount += $amount * $amount_change_percentage / 100;
            $amount = _round($amount, $amount_change_round_increment);
            $budget->{budget_amount} = $amount;
            ModBudget( $budget );
        }
    }

    return $new_budget_period_id;
}

=head2 CloneBudgetHierarchy

  CloneBudgetHierarchy({
    budgets => $budgets,
    new_budget_period_id => $new_budget_period_id;
  });

Clone a budget hierarchy.

=cut

sub CloneBudgetHierarchy {
    my ($params)             = @_;
    my $budgets              = $params->{budgets};
    my $new_budget_period_id = $params->{new_budget_period_id};
    next unless @$budgets or $new_budget_period_id;

    my $children_of   = $params->{children_of};
    my $new_parent_id = $params->{new_parent_id};

    my @first_level_budgets =
      ( not defined $children_of )
      ? map { ( not $_->{budget_parent_id} )             ? $_ : () } @$budgets
      : map { ( $_->{budget_parent_id} == $children_of ) ? $_ : () } @$budgets;

    # get only the columns of aqbudgets
    my @columns = Koha::Database->new()->schema->source('Aqbudget')->columns;

    for my $budget ( sort { $a->{budget_id} <=> $b->{budget_id} }
        @first_level_budgets )
    {

        my $tidy_budget =
          { map { join( ' ', @columns ) =~ /$_/ ? ( $_ => $budget->{$_} ) : () }
              keys %$budget };
        my $new_budget_id = AddBudget(
            {
                %$tidy_budget,
                budget_id        => undef,
                budget_parent_id => $new_parent_id,
                budget_period_id => $new_budget_period_id
            }
        );
        CloneBudgetHierarchy(
            {
                budgets              => $budgets,
                new_budget_period_id => $new_budget_period_id,
                children_of          => $budget->{budget_id},
                new_parent_id        => $new_budget_id
            }
        );
    }
}

=head2 MoveOrders

  my $report = MoveOrders({
    from_budget_period_id => $from_budget_period_id,
    to_budget_period_id   => $to_budget_period_id,
  });

Move orders from one budget period to another.

=cut

sub MoveOrders {
    my ($params)              = @_;
    my $from_budget_period_id = $params->{from_budget_period_id};
    my $to_budget_period_id   = $params->{to_budget_period_id};
    my $move_remaining_unspent = $params->{move_remaining_unspent};
    return
      if not $from_budget_period_id
          or not $to_budget_period_id
          or $from_budget_period_id == $to_budget_period_id;

    # Can't move orders to an inactive budget (budgetperiod)
    my $budget_period = GetBudgetPeriod($to_budget_period_id);
    return unless $budget_period->{budget_period_active};

    my @report;
    my $dbh     = C4::Context->dbh;
    my $sth_update_aqorders = $dbh->prepare(
        q|
            UPDATE aqorders
            SET budget_id = ?
            WHERE ordernumber = ?
        |
    );
    my $sth_update_budget_amount = $dbh->prepare(
        q|
            UPDATE aqbudgets
            SET budget_amount = ?
            WHERE budget_id = ?
        |
    );
    my $from_budgets = GetBudgetHierarchy($from_budget_period_id);
    for my $from_budget (@$from_budgets) {
        my $new_budget_id = $dbh->selectcol_arrayref(
            q|
                SELECT budget_id
                FROM aqbudgets
                WHERE budget_period_id = ?
                    AND budget_code = ?
            |, {}, $to_budget_period_id, $from_budget->{budget_code}
        );
        $new_budget_id = $new_budget_id->[0];
        my $new_budget = GetBudget( $new_budget_id );
        unless ( $new_budget ) {
            push @report,
              {
                moved       => 0,
                budget      => $from_budget,
                error       => 'budget_code_not_exists',
              };
            next;
        }
        my $orders_to_move = C4::Acquisition::SearchOrders(
            {
                budget_id => $from_budget->{budget_id},
                pending   => 1,
            }
        );

        my @orders_moved;
        for my $order (@$orders_to_move) {
            $sth_update_aqorders->execute( $new_budget->{budget_id}, $order->{ordernumber} );
            push @orders_moved, $order;
        }

        my $unspent_moved = 0;
        if ($move_remaining_unspent) {
            my $spent   = GetBudgetHierarchySpent( $from_budget->{budget_id} );
            my $unspent = $from_budget->{budget_amount} - $spent;
            my $new_budget_amount = $new_budget->{budget_amount};
            if ( $unspent > 0 ) {
                $new_budget_amount += $unspent;
                $unspent_moved = $unspent;
            }
            $new_budget->{budget_amount} = $new_budget_amount;
            $sth_update_budget_amount->execute( $new_budget_amount,
                $new_budget->{budget_id} );
        }

        push @report,
          {
            budget        => $new_budget,
            orders_moved  => \@orders_moved,
            moved         => 1,
            unspent_moved => $unspent_moved,
          };
    }
    return \@report;
}

END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
