<h3>Fines and charges</h3>

[% IF ( ACCOUNT_LINES ) %]
    <form method="post" action="opac-account-pay.pl" class="form-horizontal">
    <table class="table table-bordered table-striped" id="finestable">
        <thead>
            <tr>
                [% IF ENABLE_OPAC_PAYMENTS %]<th>&nbsp;</th>[% END %]
                <th class="title-string">Date</th>
                <th>Type</th>
                <th>Description</th>
                <th>Amount</th>
                <th>Amount outstanding</th>
            </tr>
        </thead>

        <tbody>
            [% FOREACH ACCOUNT_LINE IN ACCOUNT_LINES %]
                <tr [% IF ACCOUNT_LINE.amountoutstanding > 0 || ACCOUNT_LINE.amountoutstanding < 0 %]class="outstanding"[% END%]>
                    [% IF ENABLE_OPAC_PAYMENTS %]
                        <td>
                            [% IF ACCOUNT_LINE.amountoutstanding > 0 %]
                                [% SET DISPLAY_PAYMENT_BLOCK = 1 %]
                                <input class="checkbox-pay pay-online hidden" name="accountline" type="checkbox" id="checkbox-pay-[% ACCOUNT_LINE.accountlines_id | html %]" value="[% ACCOUNT_LINE.accountlines_id | html %]">
                                <input type="hidden" id="amount-[% ACCOUNT_LINE.accountlines_id | html %]" value="[% ACCOUNT_LINE.amountoutstanding | html %]" />
                            [% END %]
                        </td>
                    [% END %]
                    <td><span title="[% ACCOUNT_LINE.date | html %]">[% ACCOUNT_LINE.date | $KohaDates %]</span></td>
                    <td>
                        [% SWITCH ACCOUNT_LINE.accounttype %]
                        [% CASE 'Pay' %]Payment
                        [% CASE 'Pay00' %]Payment (cash via SIP2)
                        [% CASE 'Pay01' %]Payment (VISA via SIP2)
                        [% CASE 'Pay02' %]Payment (credit card via SIP2)
                        [% CASE 'VOID' %]Voided
                        [% CASE 'N' %]New card
                        [% CASE 'OVERDUE' %]Fine
                        [% CASE 'A' %]Account management fee
                        [% CASE 'M' %]Sundry
                        [% CASE 'L' %]Lost item
                        [% CASE 'W' %]Writeoff
                        [% CASE 'HE' %]Hold waiting too long
                        [% CASE 'Rent' %]Rental fee
                        [% CASE 'FOR' %]Forgiven
                        [% CASE 'LR' %]Lost item fee refund
                        [% CASE 'PF' %]Lost item processing fee
                        [% CASE 'PAY' %]Payment
                        [% CASE 'WO' %]Writeoff
                        [% CASE 'C' %]Credit
                        [% CASE 'CR' %]Credit
                        [%-CASE 'Res' %]Hold fee
                        [% CASE %][% ACCOUNT_LINE.accounttype | html %]
                        [%- END -%]
                        [%- PROCESS account_status_description account=ACCOUNT_LINE -%]
                    </td>
                    <td>
                        [%- IF ACCOUNT_LINE.payment_type %][% AuthorisedValues.GetByCode('PAYMENT_TYPE', ACCOUNT_LINE.payment_type, 1) | html %][% END %]
                        [%- IF ACCOUNT_LINE.description %][% ACCOUNT_LINE.description | html %][% END %]
                        [% IF ACCOUNT_LINE.itemnumber %]([% ACCOUNT_LINE.item.biblio.title | html %])[% END %]
                    </td>
                    [% IF ( ACCOUNT_LINE.is_credit ) %]<td class="credit">[% ACCOUNT_LINE.amount * -1 | $Price %][% ELSE %]<td class="debit">[% ACCOUNT_LINE.amount | $Price %][% END %]</td>
                    [% IF ( ACCOUNT_LINE.is_credit ) %]<td class="credit">[% ACCOUNT_LINE.amountoutstanding * -1 | $Price %][% ELSE %]<td class="debit">[% ACCOUNT_LINE.amountoutstanding | $Price %][% END %]</td>
                </tr>
            [% END %]
        </tbody>

        <tfoot>
            <tr>
                [%- IF ENABLE_OPAC_PAYMENTS -%]
                    [%- SET COLSPAN = 5 -%]
                [%- ELSE -%]
                    [%- SET COLSPAN = 4 -%]
                [%- END -%]
                <th class="sum" colspan="[% COLSPAN | html %]">Total due</th>
                <td class="sum">[% total | $Price %]</td>
            </tr>
            [% IF outstanding_credits.total_outstanding < 0 %]
            [% FOREACH outstanding_credit IN outstanding_credits %]
                <tr [% IF outstanding_credit.amountoutstanding < 0 %]class="outstanding"[% END%]>
                    [% IF ENABLE_OPAC_PAYMENTS %]<td></td>[% END %]
                    <td><span title="[% outstanding_credit.date | html %]">[% outstanding_credit.date | $KohaDates %]</span></td>
                    <td>
                        [% SWITCH outstanding_credit.accounttype %]
                        [% CASE 'Pay' %]Payment
                        [% CASE 'Pay00' %]Payment (cash via SIP2)
                        [% CASE 'Pay01' %]Payment (VISA via SIP2)
                        [% CASE 'Pay02' %]Payment (credit card via SIP2)
                        [% CASE 'VOID' %]Voided
                        [% CASE 'N' %]New card
                        [% CASE 'OVERDUE' %]Fine
                        [% CASE 'A' %]Account management fee
                        [% CASE 'M' %]Sundry
                        [% CASE 'L' %]Lost item
                        [% CASE 'W' %]Writeoff
                        [% CASE 'HE' %]Hold waiting too long
                        [% CASE 'Rent' %]Rental fee
                        [% CASE 'FOR' %]Forgiven
                        [% CASE 'LR' %]Lost item fee refund
                        [% CASE 'PF' %]Lost item processing fee
                        [% CASE 'PAY' %]Payment
                        [% CASE 'WO' %]Writeoff
                        [% CASE 'C' %]Credit
                        [% CASE 'CR' %]Credit
                        [%-CASE 'Res' %]Hold fee
                        [% CASE %][% outstanding_credit.accounttype | html %]
                        [%- END -%]
                        [%- PROCESS account_status_description account=outstanding_credit -%]
                    </td>
                    <td>
                        [%- IF outstanding_credit.payment_type %][% AuthorisedValues.GetByCode('PAYMENT_TYPE', outstanding_credit.payment_type, 1) | html %][% END %]
                        [%- IF outstanding_credit.description %][% outstanding_credit.description | html %][% END %]
                        [% IF outstanding_credit.itemnumber %]([% outstanding_credit.item.biblio.title | html %])[% END %]
                    </td>
                    <td class="credit">[% outstanding_credit.amount * -1 | $Price %]</td>
                    <td class="credit">[% outstanding_credit.amountoutstanding * -1 | $Price %]</td>
                </tr>
            [% END %]
            <tr>
                <th class="sum" colspan="[% COLSPAN | html %]">Total due if credit(s) applied:</th>
                <td class="sum">[% total + outstanding_credits.total_outstanding | $Price %]</td>
            </tr>
            [% END %]
        </tfoot>

    </table>

        [% IF ENABLE_OPAC_PAYMENTS && DISPLAY_PAYMENT_BLOCK %]
            <fieldset class="pay-online hidden">
                <legend>Pay selected fines and charges</legend>
                    <span class="help-block"><h3>Payment method</h3></span>

                    [% IF Koha.Preference('EnablePayPalOpacPayments') %]
                        <div class="control-group">
                            <label class="radio">
                                <input type="radio" name="payment_method" id="payment_method-paypal" value="paypal" checked="checked">
                                <!-- PayPal Logo --><a href="https://www.paypal.com/webapps/mpp/paypal-popup" title="How PayPal Works" class="paypal"><img src="https://www.paypalobjects.com/webstatic/mktg/logo/AM_SbyPP_mc_vs_dc_ae.jpg" border="0" alt="PayPal Acceptance Mark"></a><!-- PayPal Logo -->
                            </label>
                        </div>
                    [% END %]

                    [% FOREACH p IN plugins %]
                        <div class="control-group">
                            <label class="radio">
                                <input type="radio" name="payment_method" id="payment_method-[% p.class | html %]" value="[% p.class | html %]" checked="checked">
                                [% p.get_metadata.name | html %]
                            </label>
                        </div>
                    [% END %]

                    <div class="control-group">
                        <input type="hidden" id="payment-amount" name="payment_amount" value="0" />
                        <button id="submit-pay" type="submit" class="btn" disabled="disabled">Make payment</button>
                        <span id="amount-to-pay-label">
                            Amount to pay: <span id="amount-to-pay">0.00</span>
                        </span>
                    </div>
            </fieldset>
        [% END %]
    </form>
[% ELSE %]
    <h4>You have no fines or charges</h4>
[% END %]

[%- BLOCK account_status_description -%]
    [%- SWITCH account.status -%]
        [%- CASE 'UNRETURNED' -%]<span> (Accruing)</span>
        [%- CASE 'RETURNED'   -%]<span> (Returned)</span>
        [%- CASE 'REPLACED'   -%]<span> (Replaced)</span>
        [%- CASE 'FORGIVEN'   -%]<span> (Forgiven)</span>
        [%- CASE 'VOID'       -%]<span> (Voided)</span>
        [%- CASE              -%]
    [%- END -%]
[%- END -%]
