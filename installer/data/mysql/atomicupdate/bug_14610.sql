ALTER TABLE `issuingrules` ADD `article_requests` ENUM( 'no', 'yes', 'bib_only', 'item_only' ) NOT NULL DEFAULT 'no' AFTER `opacitemholds`;

INSERT INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES
    ('ArticleRequests', '0', NULL, 'Enables the article request feature', 'YesNo'),
    ('ArticleRequestsMandatoryFields', '', NULL, 'Comma delimited list of required fields for bibs where article requests rule = ''yes''', 'multiple'),
    ('ArticleRequestsMandatoryFieldsItemsOnly', '', NULL, 'Comma delimited list of required fields for bibs where article requests rule = ''item_only''', 'multiple'),
    ('ArticleRequestsMandatoryFieldsRecordOnly', '', NULL, 'Comma delimited list of required fields for bibs where article requests rule = ''bib_only''', 'multiple');

CREATE TABLE IF NOT EXISTS `article_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `borrowernumber` int(11) NOT NULL,
  `biblionumber` int(11) NOT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `branchcode` varchar(10) CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` text,
  `author` text,
  `volume` text,
  `issue` text,
  `date` text,
  `pages` text,
  `chapters` text,
  `patron_notes` text,
  `status` enum('PENDING','PROCESSING','COMPLETED','CANCELED') NOT NULL DEFAULT 'PENDING',
  `notes` text,
  `created_on` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_on` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `borrowernumber` (`borrowernumber`),
  KEY `biblionumber` (`biblionumber`),
  KEY `itemnumber` (`itemnumber`),
  KEY `branchcode` (`branchcode`),
  CONSTRAINT `article_requests_ibfk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_2` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_3` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `article_requests_ibfk_4` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

INSERT INTO `letter` (`module`, `code`, `branchcode`, `name`, `is_html`, `title`, `content`, `message_transport_type`) VALUES
('circulation', 'AR_CANCELED', '', 'Article Request - Email - Canceled', 0, 'Article Request Canceled', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nYour request for an article from <<biblio.title>> (<<items.barcode>>) has been canceled for the following reason:\r\n\r\n<<article_requests.notes>>\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n', 'email'),
('circulation', 'AR_COMPLETED', '', 'Article Request - Email - Completed', 0, 'Article Request Completed', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nWe are have completed your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\nYou may pick your article up at <<branches.branchname>>.\r\n\r\nThank you!', 'email'),
('circulation', 'AR_PENDING', '', 'Article Request - Email - Open', 0, 'Article Request Received', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nWe have received your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\n\r\nThank you!', 'email'),
('circulation', 'AR_SLIP', '', 'Article Request - Print Slip', 0, 'Test', 'Article Request:\r\n\r\n<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nTitle: <<biblio.title>>\r\nBarcode: <<items.barcode>>\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n', 'print'),
('circulation', 'AR_PROCESSING', '', 'Article Request - Email - Processing', 0, 'Article Request Processing', '<<borrowers.firstname>> <<borrowers.surname>> (<<borrowers.cardnumber>>)\r\n\r\nWe are now processing your request for an article from <<biblio.title>> (<<items.barcode>>).\r\n\r\nArticle requested:\r\nTitle: <<article_requests.title>>\r\nAuthor: <<article_requests.author>>\r\nVolume: <<article_requests.volume>>\r\nIssue: <<article_requests.issue>>\r\nDate: <<article_requests.date>>\r\nPages: <<article_requests.pages>>\r\nChapters: <<article_requests.chapters>>\r\nNotes: <<article_requests.patron_notes>>\r\n\r\nThank you!', 'email');
