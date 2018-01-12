-- For installations having the note already
UPDATE letter SET code = 'CHECKOUT_NOTE', name = 'Checkout note on item set by patron', title = 'Checkout note', content = REPLACE(content, "<<biblio.item>>", "<<biblio.title>>") WHERE code = 'PATRON_NOTE';
-- For installations coming from 17.11
INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES ('circulation', 'CHECKOUT_NOTE', '', 'Checkout note on item set by patron', '0', 'Checkout note', '<<borrowers.firstname>> <<borrowers.surname>> has added a note to the item <<biblio.title>> - <<biblio.author>> (<<biblio.biblionumber>>).','email');
