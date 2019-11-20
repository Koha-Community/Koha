$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO account_offset_types ( type ) VALUES ( 'Purchase' );
    });

    $dbh->do(q{
        INSERT INTO account_credit_types ( code, description, can_be_added_manually, is_system )
        VALUES ('PURCHASE', 'Purchase', 0, 1);
    });

    my $sth = $dbh->prepare(q{
        SELECT COUNT(*) FROM authorised_values WHERE category = 'PAYMENT_TYPE' AND authorised_value = 'CASH'
    });
    $sth->execute;
    my $already_exists = $sth->fetchrow;
    if ( not $already_exists ) {
        $dbh->do(q{
           INSERT INTO authorised_values (category,authorised_value,lib) VALUES ('PAYMENT_TYPE','CASH','Cash')
        });
    }

    # Updating field in account_debit_types
    unless ( column_exists('account_debit_types', 'can_be_invoiced') ) {
        $dbh->do(
            qq{
                ALTER TABLE account_debit_types
                CHANGE COLUMN
                  can_be_added_manually can_be_invoiced tinyint(1) NOT NULL DEFAULT 1
              }
        );
    }
    unless ( column_exists('account_debit_types', 'can_be_sold') ) {
        $dbh->do(
            qq{
                ALTER IGNORE TABLE account_debit_types
                ADD
                  can_be_sold tinyint(1) DEFAULT 0
                AFTER
                  can_be_invoiced
              }
        );
    }

    $dbh->do(q{
INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`) VALUES
('pos', 'RECEIPT', '', 'Point of sale receipt', 0, 'Receipt', '[% PROCESS "accounts.inc" %]
<table>
[% IF ( LibraryName ) %]
 <tr>
    <th colspan="2" class="centerednames">
        <h3>[% LibraryName | html %]</h3>
    </th>
 </tr>
[% END %]
 <tr>
    <th colspan="2" class="centerednames">
        <h2>[% Branches.GetName( payment.branchcode ) | html %]</h2>
    </th>
 </tr>
<tr>
    <th colspan="2" class="centerednames">
        <h3>[% payment.date | $KohaDates %]</h3>
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
 <tr></tr>
 <tr>
    <th colspan="2" class="centerednames">
        <h2><u>Fee receipt</u></h2>
    </th>
 </tr>
 <tr></tr>
 <tr>
    <th>Description of charges</th>
    <th>Amount</th>
  </tr>

  [% FOREACH offset IN offsets %]
    <tr>
        <td>[% PROCESS account_type_description account=offset.debit %]</td>
        <td>[% offset.amount * -1 | $Price %]</td>
    </tr>
  [% END %]

<tfoot>
  <tr class="highlight">
    <td>Total: </td>
    <td>[% payment.amount * -1| $Price %]</td>
  </tr>
  <tr>
    <td>Tendered: </td>
    <td>[% collected | $Price %]</td>
  </tr>
  <tr>
    <td>Change: </td>
    <td>[% change | $Price %]</td>
    </tr>
</tfoot>
</table>', 'print', 'default');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23354 - Add 'Purchase' account offset type)\n";
    print "Upgrade to $DBversion done (Bug 23354 - Add 'RECEIPT' notice for Point of Sale)\n";
}
