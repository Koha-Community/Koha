INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`, `lang`)
    VALUES
        ('circulation', 'ACCOUNT_PAYMENT', '', 'Account payment', 0, 'Account payment', '[%- USE Price -%]\r\nA payment of [% credit.amount * -1 | $Price %] has been applied to your account.\r\n\r\nThis payment affected the following fees:\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nAmount paid: [% o.amount * -1 | $Price %]\r\nAmount remaining: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default'),
            ('circulation', 'ACCOUNT_WRITEOFF', '', 'Account Writeoff', 0, 'Account Writeoff', '[%- USE Price -%]\r\nAn account writeoff of [% credit.amount * -1 | $Price %] has been applied to your account.\r\n\r\nThis writeoff affected the following fees:\r\n[%- FOREACH o IN offsets %]\r\nDescription: [% o.debit.description %]\r\nAmount paid: [% o.amount * -1 | $Price %]\r\nAmount remaining: [% o.debit.amountoutstanding | $Price %]\r\n[% END %]', 'email', 'default');

$dbh->do(q{
    INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
    VALUES ('UseEmailReceipts','0','','Send email receipts for payments and write-offs','YesNo')
});
