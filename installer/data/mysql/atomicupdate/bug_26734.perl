$DBversion = 'XXX';
if ( CheckVersion($DBversion) ) {

    # ACCOUNT_CREDIT UPDATES
    # backup existing notice to action_logs
    my $credit_arr = $dbh->selectall_arrayref(
        "SELECT lang FROM letter WHERE code = 'ACCOUNT_CREDIT'", { Slice => {} });
    my $c_sth = $dbh->prepare(q{
      INSERT INTO action_logs ( timestamp, module, action, object, info, interface )
      SELECT NOW(), 'NOTICES', 'UPGRADE', id, content, 'cli'
      FROM letter
      WHERE lang = ? AND code = 'ACCOUNT_CREDIT'
    });

    for my $c ( @{$credit_arr} ) {
        $c_sth->execute( $c->{lang} );
    }

    # replace notice with default
    my $c_notice = q{
[% USE Price %]
[% PROCESS 'accounts.inc' %]
<table>
[% IF ( LibraryName ) %]
 <tr>
    <th colspan="4" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
    </th>
 </tr>
[% END %]
 <tr>
    <th colspan="4" class="centerednames">
        <h2><u>Fee receipt</u></h2>
    </th>
 </tr>
 <tr>
    <th colspan="4" class="centerednames">
        <h2>[% Branches.GetName( credit.patron.branchcode ) | html %]</h2>
    </th>
 </tr>
 <tr>
    <th colspan="4">
        Received with thanks from  [% credit.patron.firstname | html %] [% credit.patron.surname | html %] <br />
        Card number: [% credit.patron.cardnumber | html %]<br />
    </th>
 </tr>
  <tr>
    <th>Date</th>
    <th>Description of charges</th>
    <th>Note</th>
    <th>Amount</th>
 </tr>

 <tr class="highlight">
    <td>[% credit.date | $KohaDates %]</td>
    <td>
      [% PROCESS account_type_description account=credit %]
      [%- IF credit.description %], [% credit.description | html %][% END %]
    </td>
    <td>[% credit.note | html %]</td>
    <td class="credit">[% credit.amount | $Price %]</td>
 </tr>

<tfoot>
  <tr>
    <td colspan="3">Total outstanding dues as on date: </td>
    [% IF ( credit.patron.account.balance >= 0 ) %]<td class="credit">[% ELSE %]<td class="debit">[% END %][% credit.patron.account.balance | $Price %]</td>
  </tr>
</tfoot>
</table>
    };

    my $c_insert = $dbh->prepare("UPDATE letter SET content = ?, is_html = 1 WHERE code = 'ACCOUNT_CREDIT'");
    $c_insert->execute($c_notice);

    # ACCOUNT_DEBIT UPDATES
    # backup existing notice to action_logs
    my $debit_arr = $dbh->selectall_arrayref(
        "SELECT lang FROM letter WHERE code = 'ACCOUNT_DEBIT'", { Slice => {} });
    my $d_sth = $dbh->prepare(q{
      INSERT INTO action_logs ( timestamp, module, action, object, info, interface )
      SELECT NOW(), 'NOTICES', 'UPGRADE', id, content, 'cli'
      FROM letter
      WHERE lang = ? AND code = 'ACCOUNT_DEBIT'
    });

    for my $d ( @{$debit_arr} ) {
        $d_sth->execute( $d->{lang} );
    }

    # replace notice with default
    my $d_notice = q{
[% USE Price %]
[% PROCESS 'accounts.inc' %]
<table>
  [% IF ( LibraryName ) %]
    <tr>
      <th colspan="5" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
      </th>
    </tr>
  [% END %]

  <tr>
    <th colspan="5" class="centerednames">
      <h2><u>INVOICE</u></h2>
    </th>
  </tr>
  <tr>
    <th colspan="5" class="centerednames">
      <h2>[% Branches.GetName( debit.patron.branchcode ) | html %]</h2>
    </th>
  </tr>
  <tr>
    <th colspan="5" >
      Bill to: [% debit.patron.firstname | html %] [% debit.patron.surname | html %] <br />
      Card number: [% debit.patron.cardnumber | html %]<br />
    </th>
  </tr>
  <tr>
    <th>Date</th>
    <th>Description of charges</th>
    <th>Note</th>
    <th style="text-align:right;">Amount</th>
    <th style="text-align:right;">Amount outstanding</th>
  </tr>

  <tr class="highlight">
    <td>[% debit.date | $KohaDates%]</td>
    <td>
      [% PROCESS account_type_description account=debit %]
      [%- IF debit.description %], [% debit.description | html %][% END %]
    </td>
    <td>[% debit.note | html %]</td>
    <td class="debit">[% debit.amount | $Price %]</td>
    <td class="debit">[% debit.amountoutstanding | $Price %]</td>
  </tr>

  <tfoot>
    <tr>
      <td colspan="4">Total outstanding dues as on date: </td>
      [% IF ( debit.patron.account.balance <= 0 ) %]<td class="credit">[% ELSE %]<td class="debit">[% END %][% debit.patron.account.balance | $Price %]</td>
    </tr>
  </tfoot>
</table>
    };
    my $d_insert = $dbh->prepare("UPDATE letter SET content = ?, is_html = 1 WHERE code = 'ACCOUNT_DEBIT'");
    $d_insert->execute($d_notice);

    NewVersion( $DBversion, 26734, "Update notices to use defaults" );
}
