ALTER TABLE issues ADD COLUMN auto_renew_error VARCHAR(32) DEFAULT NULL AFTER auto_renew;
ALTER TABLE old_issues ADD COLUMN auto_renew_error VARCHAR(32) DEFAULT NULL AFTER auto_renew;

INSERT INTO letter (module, code, name, title, content, message_transport_type) VALUES ('circulation', 'AUTO_RENEWALS', 'notification on auto renewing', 'Auto renewals',
"Dear [% borrower.firstname %] [% borrower.surname %],
[% IF checkout.auto_renew_error %]
The following item [% biblio.title %] has not been correctly renewed
[% IF checkout.auto_renew_error == 'too_many' %]
You have reach the maximum of checkouts possible.
[% ELSIF checkout.auto_renew_error == 'on_reserve' %]
This item is on hold for another patron.
[% ELSIF checkout.auto_renew_error == 'restriction' %]
You are currently restricted.
[% ELSIF checkout.auto_renew_error == 'overdue' %]
You have overdues.
[% ELSIF checkout.auto_renew_error == 'auto_too_late' %]
It\'s too late to renew this checkout.
[% ELSIF checkout.auto_renew_error == 'auto_too_much_oweing' %]
You have too much unpaid fines.
[% END %]
[% ELSE %]
The following item [% biblio.title %] as correctly been renewed.
[% END %]", 'email');
