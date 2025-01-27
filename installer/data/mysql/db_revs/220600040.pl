use Modern::Perl;

return {
    bug_number  => "30619",
    description => "Add email notice for Point of Sale > RECEIPT",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add RECEIPT email notice
        $dbh->do(
            q{
             INSERT IGNORE INTO letter (module, code, name, is_html, title, content, message_transport_type) VALUES ('pos', 'RECEIPT', 'Point of sale receipt', 1, "Receipt", "[% USE KohaDates %]\r\n[% USE Branches %]\r\n[% USE Price %]\r\n[% PROCESS \'accounts.inc\' %]\r\n<table>\r\n[% IF ( LibraryName ) %]\r\n <tr>\r\n    <th colspan=\'2\' class=\'centerednames\'>\r\n        <h3>[% LibraryName | html %]</h3>\r\n    </th>\r\n </tr>\r\n[% END %]\r\n <tr>\r\n    <th colspan=\'2\' class=\'centerednames\'>\r\n        <h2>[% Branches.GetName( credit.branchcode ) | html %]</h2>\r\n    </th>\r\n </tr>\r\n<tr>\r\n    <th colspan=\'2\' class=\'centerednames\'>\r\n        <h3>[% credit.date | $KohaDates %]</h3>\r\n</tr>\r\n<tr>\r\n  <td>Transaction ID: </td>\r\n  <td>[% credit.accountlines_id %]</td>\r\n</tr>\r\n<tr>\r\n  <td>Operator ID: </td>\r\n  <td>[% credit.manager_id %]</td>\r\n</tr>\r\n<tr>\r\n  <td>Payment type: </td>\r\n  <td>[% credit.payment_type %]</td>\r\n</tr>\r\n <tr></tr>\r\n <tr>\r\n    <th colspan=\'2\' class=\'centerednames\'>\r\n        <h2><u>Fee receipt</u></h2>\r\n    </th>\r\n </tr>\r\n <tr></tr>\r\n <tr>\r\n    <th>Description of charges</th>\r\n    <th>Amount</th>\r\n  </tr>\r\n\r\n  [% FOREACH debit IN credit.debits %]\r\n    <tr>\r\n        <td>[% PROCESS account_type_description account=debit %]</td>\r\n        <td>[% debit.amount * -1 | $Price %]</td>\r\n    </tr>\r\n  [% END %]\r\n\r\n<tfoot>\r\n  <tr class=\'highlight\'>\r\n    <td>Total: </td>\r\n    <td>[% credit.amount * -1| $Price %]</td>\r\n  </tr>\r\n  <tr>\r\n    <td>Tendered: </td>\r\n    <td>[% collected | $Price %]</td>\r\n  </tr>\r\n  <tr>\r\n    <td>Change: </td>\r\n    <td>[% change | $Price %]</td>\r\n    </tr>\r\n</tfoot>\r\n</table>\r\n", 'email');
        }
        );

        say $out "Added new letter 'RECEIPT' (email)";
    },
};
