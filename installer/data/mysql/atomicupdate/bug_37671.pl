use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37671",
    description => "Add PAYOUT notice template for POS refund receipts",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add new PAYOUT letter template for POS
        $dbh->do(
            q{
            INSERT INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type, lang, updated_on)
            VALUES (
                'pos', 'PAYOUT', '', 'Point of sale payout receipt', 1, 'Payout receipt',
                "[% USE KohaDates %]
[% USE Branches %]
[% USE Price %]
[% USE AuthorisedValues %]
[% PROCESS 'accounts.inc' %]
<table>
[% IF ( LibraryName ) %]
 <tr>
    <th colspan='2' class='centerednames'>
        <h3>[% LibraryName | html %]</h3>
    </th>
 </tr>
[% END %]
 <tr>
    <th colspan='2' class='centerednames'>
        <h2>[% Branches.GetName( debit.branchcode ) | html %]</h2>
    </th>
 </tr>
<tr>
    <th colspan='2' class='centerednames'>
        <h3>[% debit.date | $KohaDates %]</h3>
</tr>
<tr>
  <td>Transaction ID: </td>
  <td>[% debit.accountlines_id %]</td>
</tr>
<tr>
  <td>Operator ID: </td>
  <td>[% debit.manager_id %]</td>
</tr>
<tr>
  <td>Payout type: </td>
  <td>[% AuthorisedValues.GetByCode( 'PAYMENT_TYPE', debit.payment_type ) | html %]</td>
</tr>
 <tr></tr>
 <tr>
    <th colspan='2' class='centerednames'>
        <h2><u>Refund Payout Receipt</u></h2>
    </th>
 </tr>
 <tr></tr>
 [% IF debit.patron %]
 <tr>
    <th colspan='2'>
        Paid to: [% debit.patron.firstname | html %] [% debit.patron.surname | html %]<br>
        Card number: [% debit.patron.cardnumber | html %]
    </th>
 </tr>
 <tr></tr>
 [% END %]
 <tr>
    <th colspan='2'>Refund details</th>
  </tr>
  <tr>
    <th>Item / Original charge</th>
    <th>Refund amount</th>
  </tr>

  [% FOREACH credit IN debit.credits %]
    [% FOREACH offset IN credit.credit_offsets %]
      [% IF offset.debit && offset.debit.debit_type_code != 'PAYOUT' %]
        <tr>
            <td>
                [% PROCESS account_type_description account=offset.debit %]
                [% IF offset.debit.description %] - [% offset.debit.description | html %][% END %]
                [% IF offset.debit.itemnumber %]<br><i>[% offset.debit.item.biblio.title | html %]</i>[% END %]
                <br>Original charge: [% offset.debit.amount | $Price %]
            </td>
            <td>[% credit.amount * -1 | $Price %]</td>
        </tr>
      [% END %]
    [% END %]
  [% END %]

<tfoot>
  <tr class='highlight'>
    <td>Total payout: </td>
    <td>[% debit.amount | $Price %]</td>
  </tr>
</tfoot>
</table>",
                'print', 'default', NOW()
            )
        }
        );

        say_success( $out, "Added new PAYOUT letter template for POS refunds" );
    },
};
