$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    # ACCOUNT_CREDIT UPDATES
    # replace patron variable with credit.patron
    $dbh->do("UPDATE letter SET content = REPLACE(content, '[% patron', '[% credit.patron') WHERE code = 'ACCOUNT_CREDIT' ");
    # replace library variable with credit.library.branchname
    $dbh->do("UPDATE letter SET content = REPLACE(content, '[% library', '[% credit.library.branchname') WHERE code = 'ACCOUNT_CREDIT' ");

    # replace offsets variable with credit.offsets
    $dbh->do("UPDATE letter SET content = REPLACE(content, ' offsets %]', ' credit.offsets %]') WHERE code = 'ACCOUNT_CREDIT' ");
    # replace change_given variable with change
    $dbh->do("UPDATE letter SET content = REPLACE(content, '[% change_given', '[% change') WHERE code = 'ACCOUNT_CREDIT' ");

    # replace accounts foreach with basic check
    $dbh->do("UPDATE letter SET content = REPLACE(content, '[% FOREACH account IN accounts %]', '[% IF credit %]') WHERE code = 'ACCOUNT_CREDIT' ");
    # replace account with credit
    $dbh->do("UPDATE letter SET content = REPLACE(content, 'account.', 'credit.') WHERE code = 'ACCOUNT_CREDIT' ");
    # replace amountcredit with amount >= 0
    $dbh->do("UPDATE letter SET content = REPLACE(content, '( credit.amountcredit )', '( credit.amount <= 0 )') WHERE code = 'ACCOUNT_CREDIT' ");

    # ACCOUNT_DEBIT UPDATES
    # replace patron variable with debit.patron
    $dbh->do("UPDATE letter SET content = REPLACE(content, '[% patron', '[% debit.patron') WHERE code = 'ACCOUNT_DEBIT' ");
    # replace library variable with debit.library.branchname
    $dbh->do("UPDATE letter SET content = REPLACE(content, '[% library', '[% debit.library.branchname') WHERE code = 'ACCOUNT_DEBIT' ");
    # replace offsets variable with debit.offsets
    $dbh->do("UPDATE letter SET content = REPLACE(content, ' offsets %]', ' debit.offsets %]') WHERE code = 'ACCOUNT_DEBIT' ");

    # replace accounts foreach with basic check
    $dbh->do("UPDATE letter SET content = REPLACE(content, '[% FOREACH account IN accounts %]', '[% IF debit %]') WHERE code = 'ACCOUNT_DEBIT' ");
    # replace account with debit
    $dbh->do("UPDATE letter SET content = REPLACE(content, 'account.', 'debit.') WHERE code = 'ACCOUNT_DEBIT' ");
    # replace amountcredit with amount >= 0
    $dbh->do("UPDATE letter SET content = REPLACE(content, '( debit.amountcredit )', '( debit.amount <= 0 )') WHERE code = 'ACCOUNT_DEBIT' ");
    # replace amountoutstandingcredit with amount >= 0
    $dbh->do("UPDATE letter SET content = REPLACE(content, '( debit.amountoutstandingcredit )', '( debit.amountoutstanding <= 0 )') WHERE code = 'ACCOUNT_DEBIT' ");

    # replace total variable with debit.patron.account.balance
    $dbh->do("UPDATE letter SET content = REPLACE(content, '[% total ', '[% debit.patron.account.balance ') WHERE code = 'ACCOUNT_DEBIT' ");
    # replace totalcredit variable with debit.patron.account.balance <= 0
    $dbh->do("UPDATE letter SET content = REPLACE(content, 'totalcredit', 'debit.patron.account.balance <= 0') WHERE code = 'ACCOUNT_DEBIT' ");

    NewVersion( $DBversion, 26734, "Update notices to use standard variables");
}
