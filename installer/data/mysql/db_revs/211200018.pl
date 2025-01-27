use Modern::Perl;

return {
    bug_number  => "19532",
    description => "Add Recalls",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('recalls') ) {

            # Add recalls table
            $dbh->do(
                q{
                CREATE TABLE recalls (
                    recall_id int(11) NOT NULL auto_increment,
                    borrowernumber int(11) NOT NULL DEFAULT 0,
                    recalldate datetime DEFAULT NULL,
                    biblionumber int(11) NOT NULL DEFAULT 0,
                    branchcode varchar(10) DEFAULT NULL,
                    cancellationdate datetime DEFAULT NULL,
                    recallnotes mediumtext,
                    priority smallint(6) DEFAULT NULL,
                    status ENUM('requested','overdue','waiting','in_transit','cancelled','expired','fulfilled') DEFAULT 'requested',
                    timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    itemnumber int(11) DEFAULT NULL,
                    waitingdate datetime DEFAULT NULL,
                    expirationdate datetime DEFAULT NULL,
                    old TINYINT(1) NOT NULL DEFAULT 0,
                    item_level_recall TINYINT(1) NOT NULL DEFAULT 0,
                    PRIMARY KEY (recall_id),
                    KEY borrowernumber (borrowernumber),
                    KEY biblionumber (biblionumber),
                    KEY itemnumber (itemnumber),
                    KEY branchcode (branchcode),
                    CONSTRAINT recalls_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT recalls_ibfk_2 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT recalls_ibfk_3 FOREIGN KEY (itemnumber) REFERENCES items (itemnumber) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT recalls_ibfk_4 FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            # Add RecallsLog, RecallsMaxPickUpDelay and UseRecalls system preferences
            $dbh->do(
                q{
                INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
                ('RecallsLog','1',NULL,'If ON, log create/cancel/expire/fulfill actions on recalls','YesNo'),
                ('RecallsMaxPickUpDelay','7',NULL,'Define the maximum time a recall can be awaiting pickup','Integer'),
                ('UseRecalls','0',NULL,'Enable or disable recalls','YesNo')
            }
            );

            # Add recalls notices: RETURN_RECALLED_ITEM, PICKUP_RECALLED_ITEM, RECALL_REQUESTER_DET
            $dbh->do(
                q{
                INSERT IGNORE INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
                ('circulation','RETURN_RECALLED_ITEM','','Notification to return a recalled item','0','Notification to return a recalled item','Date: <<today>>

<<borrowers.firstname>> <<borrowers.surname>>,

A recall has been placed on the following item: <<biblio.title>> / <<biblio.author>> (<<items.barcode>>). The due date has been updated, and is now <<issues.date_due>>. Please return the item before the due date.

Thank you!','email'),
        ('circulation','PICKUP_RECALLED_ITEM','','Recalled item awaiting pickup','0','Recalled item awaiting pickup','Date: <<today>>

<<borrowers.firstname>> <<borrowers.surname>>,

A recall that you requested on the following item: <<biblio.title>> / <<biblio.author>> (<<items.barcode>>) is now ready for you to pick up at <<recalls.branchcode>>. Please pick up your item by <<recalls.expirationdate>>.

Thank you!','email'),
        ('circulation','RECALL_REQUESTER_DET','','Details of patron who recalled item',0,'Details of patron who recalled item','Date: <<today>>

Recall for pickup at <<branches.branchname>>
<<borrowers.surname>>, <<borrowers.firstname>> (<<borrowers.cardnumber>>)
<<borrowers.phone>>
<<borrowers.streetnumber>> <<borrowers.address>>, <<borrowers.address2>>, <<borrowers.city>> <<borrowers.zipcode>>
<<borrowers.email>>

ITEM RECALLED
<<biblio.title>> by <<biblio.author>>
Barcode: <<items.barcode>>
Callnumber: <<items.itemcallnumber>>
Waiting since: <<recalls.waitingdate>>
Notes: <<recalls.recallnotes>>', 'print')
            }
            );

            # Add recalls user flag and manage_recalls user permission
            $dbh->do(
                q{
                INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton) VALUES (27, 'recalls', 'Recalls', 0)
            }
            );
            $dbh->do(
                q{
                INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (27, 'manage_recalls', 'Manage recalls for patrons')
            }
            );

            # Add Recall ENUM option to branchtransfers.reason
            $dbh->do(
                q{
                ALTER TABLE branchtransfers MODIFY COLUMN reason
                ENUM('Manual', 'StockrotationAdvance', 'StockrotationRepatriation', 'ReturnToHome', 'ReturnToHolding', 'RotatingCollection', 'Reserve', 'LostReserve', 'CancelReserve', 'TransferCancellation', 'Recall')
            }
            );

            # Add CancelRecall ENUM option to branchtransfers.cancellation_reason
            $dbh->do(
                q{
                ALTER TABLE branchtransfers MODIFY COLUMN cancellation_reason
                ENUM('Manual', 'StockrotationAdvance', 'StockrotationRepatriation', 'ReturnToHome', 'ReturnToHolding', 'RotatingCollection', 'Reserve', 'LostReserve', 'CancelReserve', 'ItemLost', 'WrongTransfer', 'CancelRecall')
            }
            );

        }
    },
};
