[% IF NotPaid %]
    [% IF NotEnabled %]
        <h3>Online payments are not activated in your library.</h3>
    [% ELSIF paid > 0 && paid < minimumSum %]
        <h3>You don't have enough outstanding fines and charges. A minimum sum of [% minimumSum %] must be outstanding in order to use online payment. Your current outstanding sum is [% paid %]. Please return to <a href="/cgi-bin/koha/opac-account.pl">your fines</a>.</h3>
    [% ELSE %]
        <h3>You have no outstanding fines and charges. Please return to <a href="/cgi-bin/koha/opac-account.pl">your fines</a>.</h3>
    [% END %]
[% ELSIF error == "TRANSACTION_NOT_FOUND" %]
    <h3>Invalid transaction number! Please write this error down and contact our library.</h3>
[% ELSIF error == "INVALID_HASH" %]
    <h3>Invalid notification checksum. Please write this error down and contact our library.</h3>
[% ELSIF transaction %]
    <h3>Payment has been [% IF transaction.status == "paid" %]completed[% ELSIF transaction.status == "cancelled" %]cancelled[% ELSE %]set pending. Please wait a minute and then go to <a href="/cgi-bin/koha/opac-account.pl">fines and charges</a> to see status of the payment. In case of a problem, please contact our library[% END %].</h3>
    <p>The payment has been [% IF transaction.status == "paid" %]completed[% ELSIF transaction.status == "cancelled" %]cancelled[% ELSE %]set pending[% END %]. See your <a href="/cgi-bin/koha/opac-account.pl">fines and charges</a>.</p>
[% ELSIF Payment %]
    <h3>Preparing to pay fines</h3>
    <p>Making a payment of <strong>[% paid_format %]</strong>.</p>
    <p>You will be automatically redirected to online payment in 5 seconds. If you are not automatically redirected, you can manually proceed to the <a href="[% response.PaymentAddress %]">online payment</a>.</p>
    [% IF response.PaymentAddress %]
        <meta http-equiv="refresh" content="5;URL=[% response.PaymentAddress %]" />
    [% ELSIF response.error %]
        [% IF response.status %]
            [% IF response.status == 99 %]
                <h2>Payment Server error: Invalid request (99)</h2>
            [% ELSIF response.status == 98 %]
                <h2>Payment Server error: Server error (98)</h2>
            [% ELSIF response.status == 97 %]
                <h2>Payment Server error: Duplicate payment ID (97)</h2>
            [% END %]
            <p>[% response.error %]. Please write down this error and contact our library.</p>
        [% END %]
    [% END %]
[% END %]
