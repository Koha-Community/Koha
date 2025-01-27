use Modern::Perl;

return {
    bug_number  => "24381",
    description => "Update accounts notices",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # ACCOUNT_CREDIT
        my $account_credit = q{
[%- USE AuthorisedValues -%]
[%- USE KohaDates -%]
[%- USE Price -%]
[%- PROCESS "accounts.inc" -%]
<table>
    [% IF ( LibraryName ) %]
    <tr>
        <th colspan="2" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
        </th>
    </tr>
    [% END %]
    [% IF credit.library %]
    <tr>
        <th colspan="2" class="centerednames">
        <h2>[% credit.library.branchname | html %]</h2>
        </th>
    </tr>
    [% END %]
    <tr>
        <th colspan="2" class="centerednames">
        <h3>[% today | $KohaDates %]</h3>
        </th>
    </tr>
    <tr>
        <td>Transaction ID: </td>
        <td>[% credit.accountlines_id %]</td>
    </tr>
    <tr>
        <td>Operator ID: </td>
        <td>[% credit.manager_id %]</td>
    </tr>
    [% IF credit.payment_type %]
    <tr>
        <td>Payment type: </td>
        <td>[% AuthorisedValues.GetByCode('PAYMENT_TYPE', credit.payment_type) %]</td>
    </tr>
    [% END %]
    <tr>
        <th colspan="2" class="centerednames">
        <h2><u>[%- PROCESS credit_type_description credit_type = credit.credit_type -%] receipt</u></h2>
        </th>
    </tr>
    [% IF ( credit.credit_type_code == 'PAYMENT' ) %]
    <tr>
        <th colspan="2">
        Received with thanks from  [% credit.patron.firstname | html %] [% credit.patron.surname | html %] <br />
        Card number: [% credit.patron.cardnumber | html %]<br />
        </th>
    </tr>
    [% ELSIF ( credit.credit_type_code == 'CREDIT' ) %]
    <tr>
        <th colspan="2">
        Credit added to account for [% credit.patron.firstname | html %] [% credit.patron.surname | html %] <br />
        Card number: [% credit.patron.cardnumber | html %]<br />
        </th>
    </tr>
    [% ELSIF ( credit.credit_type_code == 'WRITEOFF' ) %]
    <tr>
        <th colspan="2">
        Writeoff added to account for [% credit.patron.firstname | html %] [% credit.patron.surname | html %] <br />
        Card number: [% credit.patron.cardnumber | html %]<br />
        </th>
    </tr>
    [% END %]
    [% IF credit.amountoutstanding + 0 != 0 %]
    <tr>
        <th>Description of credit</th>
        <th>Amount</th>
    </tr>
    <tr>
        <td>[%- PROCESS credit_type_description credit_type = credit.credit_type -%]</td>
        <td>[% credit.amount * -1 | $Price %]</td>
    </tr>
    <tr>
        <th style="text-align:right;">Total available:</th>
        <td>[% credit.amountoutstanding * -1 | $Price %]</td>
    </tr>
    [% END %]
    [% IF credit.amount != credit.amountoutstanding %]
    <tr>
        <th>Description of charges</th>
        <th>Amount</th>
    </tr>
    [% FOREACH offset IN credit.credit_offsets %]
    <tr>
        <td>[% PROCESS account_type_description account=offset.debit %][% IF ( offset.debit.itemnumber ) %] - [% offset.debit.item.biblio.title %][% END %]</td>
        <td>[% offset.amount * -1 | $Price %]</td>
    </tr>
    [% END %]
    [% END %]
    <tfoot>
    <tr class="highlight">
        <td>Total:</td>
        <td>[% credit.amount * -1 | $Price %]</td>
    </tr>
    [% IF change.defined %]
    <tr>
        <td>Change given: </td>
        <td>[% change | $Price %]</td>
    </tr>
    [% END %]
    <tr>
        <td colspan="2"></td>
    </tr>
    <tr>
        <td>Account balance as on date:</td>
        <td>[% credit.patron.account.balance * -1 | $Price %]</td>
    </tr>
    </tfoot>
</table>
        };

        my $account_credit_old =
            q{<table>[%IF(LibraryName)%]<tr><thcolspan="4"class="centerednames"><h3>[%LibraryName|html%]</h3></th></tr>[%END%]<tr><thcolspan="4"class="centerednames"><h2><u>Feereceipt</u></h2></th></tr><tr><thcolspan="4"class="centerednames"><h2>[%Branches.GetName(patron.branchcode)|html%]</h2></th></tr><tr><thcolspan="4">Receivedwiththanksfrom[%patron.firstname|html%][%patron.surname|html%]<br/>Cardnumber:[%patron.cardnumber|html%]<br/></th></tr><tr><th>Date</th><th>Descriptionofcharges</th><th>Note</th><th>Amount</th></tr>[%FOREACHaccountINaccounts%]<trclass="highlight"><td>[%account.date|$KohaDates%]</td><td>[%PROCESSaccount_type_descriptionaccount=account%][%-IFaccount.description%],[%account.description|html%][%END%]</td><td>[%account.note|html%]</td>[%IF(account.amountcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%account.amount|$Price%]</td></tr>[%END%]<tfoot><tr><tdcolspan="3">Totaloutstandingduesasondate:</td>[%IF(totalcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%total|$Price%]</td></tr></tfoot></table>};

        my $sth = $dbh->prepare(
            q{
            UPDATE letter SET content = ? WHERE code = 'ACCOUNT_CREDIT' AND REPLACE(REPLACE(content, ' ', ''), '\n','') = ?
        }
        );
        $sth->execute( $account_credit, $account_credit_old );

        # replace patron variable with credit.patron
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, '[% patron', '[% credit.patron') WHERE code = 'ACCOUNT_CREDIT' "
        );

        # replace library variable with credit.library.branchname
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, '[% library', '[% credit.library.branchname') WHERE code = 'ACCOUNT_CREDIT' "
        );

        # replace offsets variable with credit.offsets
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, ' offsets %]', ' credit.offsets %]') WHERE code = 'ACCOUNT_CREDIT' "
        );

        # replace change_given variable with change
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, '[% change_given', '[% change') WHERE code = 'ACCOUNT_CREDIT' "
        );

        # ACCOUNT_DEBIT
        my $account_debit = q{
[% PROCESS "accounts.inc" %]
[%- USE Price -%]
[%- USE KohaDates -%]
<table>
    [% IF ( LibraryName ) %]
    <tr>
        <th colspan="3" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
        </th>
    </tr>
    [% END %]
    [% IF debit.library %]
    <tr>
        <th colspan="3" class="centerednames">
        <h2>[% debit.library.branchname | html %]</h2>
        </th>
    </tr>
    [% END %]
    <tr>
        <td colspan="2" style="text-align:right;">Fee ID: </td>
        <td>[% debit.accountlines_id %]</td>
    </tr>
    [% IF credit.manager_id %]
    <tr>
        <td colspan="2" style="text-align:right;">Operator ID: </td>
        <td>[% credit.manager_id %]</td>
    </tr>
    [% END %]
    <tr>
        <th colspan="3" class="centerednames">
        <h2><u>Invoice</u></h2>
        </th>
    </tr>
    <tr>
        <th colspan="3" >
        Bill to: [% debit.patron.firstname | html %] [% debit.patron.surname | html %] <br />
        Card number: [% debit.patron.cardnumber | html %]<br />
        </th>
    </tr>
    [% IF debit.amountoutstanding != 0 %]
    <tr>
        <th>Date</th>
        <th>Description of charges</th>
        <th>Amount</th>
    </tr>
    <tr>
        <td>[% debit.date | $KohaDates %]</td>
        <td>[% PROCESS account_type_description account=debit %]</td>
        <td>[% debit.amount | $Price %]</td>
    </tr>
    <tr>
        <td colspan="2" style="text-align:right;">Total owed:</td>
        <td>[% debit.amount | $Price %]</td>
    </tr>
    [% END %]
    [% IF debit.amount != debit.amountoutstanding %]
    <tr>
        <th>Date</th>
        <th>Description of payments</th>
        <th>Amount</th>
    </tr>
    [% FOREACH offset IN debit.debit_offsets %]
    <tr>
        <td>[% offset.credit.date | $KohaDates %]</td>
        <td>[% PROCESS account_type_description account=offset.credit %]</td>
        <td>[% offset.amount * -1 | $Price %]</td>
    </tr>
    [% END %]
    <tr class="highlight">
        <td colspan="2" style="text-align:right;">Total paid:</td>
        <td>[% debit.amount - debit.amountoutstanding | $Price %]</td>
    </tr>
    [% END %]
    </tr>
        <td colspan="3"></td>
    <tr>
    <tfoot>
    <tr>
        <th colspan="2" style="text-align:right;">Total outstanding:</th>
        <td>[% debit.amountoutstanding | $Price %]</td>
    </tr>
    </tfoot>
</table>
        };

        my $account_debit_old =
            q{<table>[%IF(LibraryName)%]<tr><thcolspan="5"class="centerednames"><h3>[%LibraryName|html%]</h3></th></tr>[%END%]<tr><thcolspan="5"class="centerednames"><h2><u>INVOICE</u></h2></th></tr><tr><thcolspan="5"class="centerednames"><h2>[%Branches.GetName(patron.branchcode)|html%]</h2></th></tr><tr><thcolspan="5">Billto:[%patron.firstname|html%][%patron.surname|html%]<br/>Cardnumber:[%patron.cardnumber|html%]<br/></th></tr><tr><th>Date</th><th>Descriptionofcharges</th><th>Note</th><thstyle="text-align:right;">Amount</th><thstyle="text-align:right;">Amountoutstanding</th></tr>[%FOREACHaccountINaccounts%]<trclass="highlight"><td>[%account.date|$KohaDates%]</td><td>[%PROCESSaccount_type_descriptionaccount=account%][%-IFaccount.description%],[%account.description|html%][%END%]</td><td>[%account.note|html%]</td>[%IF(account.amountcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%account.amount|$Price%]</td>[%IF(account.amountoutstandingcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%account.amountoutstanding|$Price%]</td></tr>[%END%]<tfoot><tr><tdcolspan="4">Totaloutstandingduesasondate:</td>[%IF(totalcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%total|$Price%]</td></tr></tfoot></table>};

        $sth = $dbh->prepare(
            q{
            UPDATE letter SET content = ? WHERE code = 'ACCOUNT_DEBIT' AND REPLACE(REPLACE(content, ' ', ''), '\n','') = ?
        }
        );
        $sth->execute( $account_debit, $account_debit_old );

        # replace patron variable with debit.patron
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, '[% patron', '[% debit.patron') WHERE code = 'ACCOUNT_DEBIT' "
        );

        # replace library variable with debit.library.branchname
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, '[% library', '[% debit.library.branchname') WHERE code = 'ACCOUNT_DEBIT' "
        );

        # replace offsets variable with debit.offsets
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, ' offsets %]', ' debit.offsets %]') WHERE code = 'ACCOUNT_DEBIT' "
        );

        # replace total variable with debit.patron.account.balance
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, '[% total ', '[% debit.patron.account.balance ') WHERE code = 'ACCOUNT_DEBIT' "
        );

        # replace totalcredit variable with debit.patron.account.balance <= 0
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, 'totalcredit', 'debit.patron.account.balance <= 0') WHERE code = 'ACCOUNT_DEBIT' "
        );

        # RECEIPT
        my $receipt = q{
[% PROCESS "accounts.inc" %]
[%- USE KohaDates -%]
[%- USE Price -%]
<table>
    [% IF ( LibraryName ) %]
    <tr>
        <th colspan="2" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
        </th>
    </tr>
    [% END %]
    [% IF credit.library %]
    <tr>
        <th colspan="2" class="centerednames">
        <h2>[% payment.library.branchname | html %]</h2>
        </th>
    </tr>
    [% END %]
    <tr>
        <th colspan="2" class="centerednames">
        <h3>[% payment.date | $KohaDates %]</h3>
        </th>
    </tr>
    <tr>
        <td>Transaction ID: </td>
        <td>[% payment.accountlines_id %]</td>
    </tr>
    <tr>
        <td>Operator ID: </td>
        <td>[% payment.manager_id %]</td>
    </tr>
    <tr>
        <td>Payment type: </td>
        <td>[% payment.payment_type %]</td>
    </tr>
    <tr>
        <th colspan="2" class="centerednames">
        <h2><u>Payment receipt</u></h2>
        </th>
    </tr>
    <tr>
        <th>Description of charges</th>
        <th>Amount</th>
    </tr>
    [% FOREACH offset IN payment.credit_offsets %]
    <tr>
        <td>[% PROCESS account_type_description account=offset.debit %]</td>
        <td>[% offset.amount * -1 | $Price %]</td>
    </tr>
    [% END %]
    <tfoot>
    <tr class="highlight">
        <td>Total:</td>
        <td>[% payment.amount * -1 | $Price %]</td>
    </tr>
    <tr>
        <td>Tendered: </td>
        <td>[% tendered | $Price %]</td>
    </tr>
    <tr>
        <td>Change given:</td>
        <td>[% change | $Price %]</td>
    </tr>
    </tfoot>
</table>
        };

        my $receipt_old =
            q{[%PROCESS"accounts.inc"%]<table>[%IF(LibraryName)%]<tr><thcolspan="2"class="centerednames"><h3>[%LibraryName|html%]</h3></th></tr>[%END%]<tr><thcolspan="2"class="centerednames"><h2>[%Branches.GetName(payment.branchcode)|html%]</h2></th></tr><tr><thcolspan="2"class="centerednames"><h3>[%payment.date|$KohaDates%]</h3></tr><tr><td>TransactionID:</td><td>[%payment.accountlines_id%]</td></tr><tr><td>OperatorID:</td><td>[%payment.manager_id%]</td></tr><tr><td>Paymenttype:</td><td>[%payment.payment_type%]</td></tr><tr></tr><tr><thcolspan="2"class="centerednames"><h2><u>Feereceipt</u></h2></th></tr><tr></tr><tr><th>Descriptionofcharges</th><th>Amount</th></tr>[%FOREACHoffsetINoffsets%]<tr><td>[%PROCESSaccount_type_descriptionaccount=offset.debit%]</td><td>[%offset.amount*-1|$Price%]</td></tr>[%END%]<tfoot><trclass="highlight"><td>Total:</td><td>[%payment.amount*-1|$Price%]</td></tr><tr><td>Tendered:</td><td>[%collected|$Price%]</td></tr><tr><td>Change:</td><td>[%change|$Price%]</td></tr></tfoot></table>};

        $sth = $dbh->prepare(
            q{
            UPDATE letter SET content = ? WHERE code = 'RECEIPT' AND REPLACE(REPLACE(content, ' ', ''), '\n','') = ?
        }
        );
        $sth->execute( $receipt, $receipt_old );

        # replace offsets variable with debit.offsets
        $dbh->do(
            "UPDATE letter SET content = REPLACE(content, ' offsets %]', ' payment.offsets %]') WHERE code = 'RECEIPT' "
        );

        # replace collected variable with tendered
        $dbh->do("UPDATE letter SET content = REPLACE(content, '[% collected', '[% tendered') WHERE code = 'RECEIPT' ");
    },
};
