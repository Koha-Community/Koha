$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    # ACCOUNT_CREDIT
    my $account_credit = q{
        [% PROCESS "accounts.inc" %]
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
                <h3>[% credit.date | $KohaDates %]</h3>
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
            <tr>
              <td>Payment type: </td>
              <td>[% credit.payment_type %]</td>
            </tr>
            <tr>
              <th colspan="2" class="centerednames">
                <h2><u>Payment receipt</u></h2>
              </th>
            </tr>
            <tr>
              <th colspan="2">
                Received with thanks from  [% credit.patron.firstname | html %] [% credit.patron.surname | html %] <br />
                Card number: [% credit.patron.cardnumber | html %]<br />
              </th>
            </tr>
            <tr>
              <th>Description of charges</th>
              <th>Amount</th>
            </tr>
            [% FOREACH offset IN credit.credit_offsets %]
            <tr>
              <td>[% PROCESS account_type_description account=offset.debit %]</td>
              <td>[% offset.amount * -1 | $Price %]</td>
            </tr>
            [% END %]
          <tfoot>
            <tr class="highlight">
              <td>Total:</td>
              <td>[% credit.amount * -1 | $Price %]</td>
            </tr>
            <tr>
              <td>Change given: </td>
              <td>[% change | $Price %]</td>
            </tr>
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

    my $account_credit_old = q{<table>[%IF(LibraryName)%]<tr><thcolspan="4"class="centerednames"><h3>[%LibraryName|html%]</h3></th></tr>[%END%]<tr><thcolspan="4"class="centerednames"><h2><u>Feereceipt</u></h2></th></tr><tr><thcolspan="4"class="centerednames"><h2>[%Branches.GetName(patron.branchcode)|html%]</h2></th></tr><tr><thcolspan="4">Receivedwiththanksfrom[%patron.firstname|html%][%patron.surname|html%]<br/>Cardnumber:[%patron.cardnumber|html%]<br/></th></tr><tr><th>Date</th><th>Descriptionofcharges</th><th>Note</th><th>Amount</th></tr>[%FOREACHaccountINaccounts%]<trclass="highlight"><td>[%account.date|$KohaDates%]</td><td>[%PROCESSaccount_type_descriptionaccount=account%][%-IFaccount.description%],[%account.description|html%][%END%]</td><td>[%account.note|html%]</td>[%IF(account.amountcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%account.amount|$Price%]</td></tr>[%END%]<tfoot><tr><tdcolspan="3">Totaloutstandingduesasondate:</td>[%IF(totalcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%total|$Price%]</td></tr></tfoot></table>};

    my $sth = $dbh->prepare(
q{UPDATE letter SET content = ? WHERE code = 'ACCOUNT_CREDIT' AND REPLACE(REPLACE(content, ' ', ''), '\n','') = ?}
    );
    $sth->execute( $account_credit, $account_credit_old );


    # ACCOUNT_DEBIT
    my $account_debit = q{
        [% PROCESS "accounts.inc" %]
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
              <th colspan="3" class="centerednames">
                <h3>[% debit.date | $KohaDates %]</h3>
              </th>
            </tr>
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
              <td colspan="2" style="text-align:right;">Total owed:</td>
              <td>[% debit.amount | $Price %]</td>
            </tr>
            <tr>
              <td colspan="2" style="text-align:right;">Total outstanding:</td>
              <td>[% debit.amountoutstanding | $Price %]</td>
            </tr>
          </tfoot>
        </table>
    };

    my $account_debit_old = q{<table>[%IF(LibraryName)%]<tr><thcolspan="5"class="centerednames"><h3>[%LibraryName|html%]</h3></th></tr>[%END%]<tr><thcolspan="5"class="centerednames"><h2><u>INVOICE</u></h2></th></tr><tr><thcolspan="5"class="centerednames"><h2>[%Branches.GetName(patron.branchcode)|html%]</h2></th></tr><tr><thcolspan="5">Billto:[%patron.firstname|html%][%patron.surname|html%]<br/>Cardnumber:[%patron.cardnumber|html%]<br/></th></tr><tr><th>Date</th><th>Descriptionofcharges</th><th>Note</th><thstyle="text-align:right;">Amount</th><thstyle="text-align:right;">Amountoutstanding</th></tr>[%FOREACHaccountINaccounts%]<trclass="highlight"><td>[%account.date|$KohaDates%]</td><td>[%PROCESSaccount_type_descriptionaccount=account%][%-IFaccount.description%],[%account.description|html%][%END%]</td><td>[%account.note|html%]</td>[%IF(account.amountcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%account.amount|$Price%]</td>[%IF(account.amountoutstandingcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%account.amountoutstanding|$Price%]</td></tr>[%END%]<tfoot><tr><tdcolspan="4">Totaloutstandingduesasondate:</td>[%IF(totalcredit)%]<tdclass="credit">[%ELSE%]<tdclass="debit">[%END%][%total|$Price%]</td></tr></tfoot></table>};

    $sth = $dbh->prepare(
q{UPDATE letter SET content = ? WHERE code = 'ACCOUNT_DEBIT' AND REPLACE(REPLACE(content, ' ', ''), '\n','') = ?}
    );
    $sth->execute($account_debit, $account_debit_old);

    # RECEIPT
    my $receipt = q{
        [% PROCESS "accounts.inc" %]
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
                <h2>[% payment.library.branchname ) | html %]</h2>
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

    my $receipt_old = q{[%PROCESS"accounts.inc"%]<table>[%IF(LibraryName)%]<tr><thcolspan="2"class="centerednames"><h3>[%LibraryName|html%]</h3></th></tr>[%END%]<tr><thcolspan="2"class="centerednames"><h2>[%Branches.GetName(payment.branchcode)|html%]</h2></th></tr><tr><thcolspan="2"class="centerednames"><h3>[%payment.date|$KohaDates%]</h3></tr><tr><td>TransactionID:</td><td>[%payment.accountlines_id%]</td></tr><tr><td>OperatorID:</td><td>[%payment.manager_id%]</td></tr><tr><td>Paymenttype:</td><td>[%payment.payment_type%]</td></tr><tr></tr><tr><thcolspan="2"class="centerednames"><h2><u>Feereceipt</u></h2></th></tr><tr></tr><tr><th>Descriptionofcharges</th><th>Amount</th></tr>[%FOREACHoffsetINoffsets%]<tr><td>[%PROCESSaccount_type_descriptionaccount=offset.debit%]</td><td>[%offset.amount*-1|$Price%]</td></tr>[%END%]<tfoot><trclass="highlight"><td>Total:</td><td>[%payment.amount*-1|$Price%]</td></tr><tr><td>Tendered:</td><td>[%collected|$Price%]</td></tr><tr><td>Change:</td><td>[%change|$Price%]</td></tr></tfoot></table>};

    $sth = $dbh->prepare(
q{UPDATE letter SET content = ? WHERE code = 'RECEIPT' AND REPLACE(REPLACE(content, ' ', ''), '\n','') = ? }
    );
    $sth->execute($receipt,$receipt_old);

    NewVersion( $DBversion, 24381, "Update accounts notices" );
}
