# RELEASE NOTES FOR KOHA 19.11.06
21 May 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.06 is a bugfix/maintenance release.

It includes 23 enhancements, 122 bugfixes.

### System requirements

Koha is continiously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5
- Debian Stretch with MariaDB 10.1 (MySQL 8.0 support is experimental)
- Ubuntu Bionic with MariaDB 10.1 (MariaDB 10.3 support is experimental) 

Additional notes:
    
- Perl 5.10 is required
- Zebra or Elasticsearch is required




## Enhancements

### Architecture, internals, and plumbing

- [[24994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24994) TableExists should be used instead of IF NOT EXISTS in updatedatabase

### Cataloging

- [[25231]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25231) Remove alert when replacing a bibliographic record via Z39.50

### Command-line Utilities

- [[21865]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21865) Add Elasticsearch support to, and improve verbose output of, `remove_unused_authorities.pl`

### Course reserves

- [[25341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25341) When adding a single item to course reserves, ignore whitespace

### Fines and fees

- [[24604]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24604) Add 'Pay' button under Transactions tab in patron accounting

### Hold requests

- [[24547]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24547) Add more action logs for holds

  >Trapping and filling holds will now create entries in the logs, when HoldsLog system preference is activated.

### Lists

- [[20754]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20754) Db revision to remove double accepted list shares

### MARC Authority data support

- [[25235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25235) Don't alert when replacing an authority record via Z39.50

### MARC Bibliographic data support

- [[15727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15727) Add 385$a - Audience to MARC21 detail pages

### OPAC

- [[24740]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24740) Use biblio title if available rather than biblio number in OPAC search result cover images tooltips

### Plugin architecture

- [[24183]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24183) Introduce `before_send_messages` hook

  >This patch adds a new `plugin hook` to allow pre-processing of the message queue prior to sending messages.

### REST API

- [[24908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24908) Allow fetching text-formatted MARC data

### SIP2

- [[20816]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20816) Add ability to send custom field(s) containing patron information in SIP patron responses

### Searching - Elasticsearch

- [[22828]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22828) Add display of errors encountered during indexing on the command line
- [[23137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23137) Add a command line tool to reset elasticsearch mappings

### Staff Client

- [[23601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23601) Middle clicking a title from search results creates two tabs or a new tab and a new window in Firefox

  >This fixes an issue in Firefox where middle-clicking or CTRL-clicking a title in the results screen of the staff client opens two new tabs.
- [[24522]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24522) Nothing happens when trying to add nothing to a list in staff
- [[24995]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24995) Add issuedate to table_account_fines and finest in Accounting tab
- [[25027]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25027) Result browser should not overload onclick event
- [[25053]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25053) PatronSelfRegistrationExpireTemporaryAccountsDelay system preference is unclear

### System Administration

- [[20484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20484) Always show Elasticsearch configuration page when permission is set

### Templates

- [[22468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22468) Standardize on labeling ccode table columns as collection
- [[25416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25416) Add information about anonymous session for XSLT use

  **Sponsored by** *Universidad ORT Uruguay*


## Critical bugs fixed

### Acquisitions

- [[25223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25223) Ordered.pl can have poor performance on large databases

### Architecture, internals, and plumbing

- [[25040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25040) Problematic current_timestamp syntax generated by DBIx::Class::Schema::Loader
- [[25481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25481) koha-plack not working under D10
- [[25485]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25485) TinyMCE broken in Debian package installs

### Cataloging

- [[25335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25335) Use of an authorised value in a marc subfield causes strict mode SQL error

### Circulation

- [[25133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25133) Specify Due date changes from PM to AM if library has their TimeFormat set to 12hr
- [[25184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25184) Items with a negative notforloan status should not be captured for holds
- [[25418]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25418) Backdated check out date loses time
- [[25531]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25531) Patron may not be debarred if backdated return

### Course reserves

- [[23727]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23727) Editing course reserve items is broken

### Fines and fees

- [[24339]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24339) SIP codes are missing from the default payment_types on installation
- [[25123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25123) MaxFines does not count the current updating fine
- [[25127]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25127) Fines with an amountoutstanding of 0 can be created due to maxFine but cannot be forgiven
- [[25417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25417) Backdating returns and forgiving fines causes and internal server error
- [[25478]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25478) Inconsistent naming of account_credit_type for lost and returned items [19.11 Version]

### ILL

- [[24043]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24043) ILL module can't show requests from more than one backend

### MARC Authority data support

- [[22437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22437) Subsequent authority merges in cron may cause biblios to lose authority information

### OPAC

- [[25024]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25024) OPAC incorrectly marks branch as invalid pickup location when similarly named branch is blocked
- [[25086]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25086) OPAC Self Registration - Field 'changed_fields' doesn't have a default value

  **Sponsored by** *Orex Digital*

### Packaging

- [[25510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25510) Typo in koha-common.postinst causing shell errors
- [[25524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25524) Debian packages always append to /etc/koha/sites/$site/log4perl.conf

### Patrons

- [[24964]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24964) Do not filter patrons AFTER they have been fetched from the DB (when searching with permissions)

### SIP2

- [[23403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23403) SIP2 lends to wrong patron if cardnumber is missing
- [[24800]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24800) Koha does incomplete checkin when no return date is provided
- [[24966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24966) Fix calls to maybe_add where method call does not return a value

### Searching

- [[24458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24458) Search results don't use Koha::Filter::MARC::ViewPolicy

### Searching - Elasticsearch

- [[25050]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25050) Elasticsearch - authority indexing depends on mapping order
- [[25342]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25342) Scripts not running under plack can cause duplication of ES records

### Serials

- [[25081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25081) new item for a received issue is (stochastically) not created

### System Administration

- [[25400]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25400) Circulation and fine rules cloning from one table to another does not copy "current checkouts allowed"

### Z39.50 / SRU / OpenSearch Servers

- [[25277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25277) Z3950responder keyword search does not work with Elasticsearch 6


## Other bugs fixed

### Acquisitions

- [[21927]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21927) Acq: Allow blank values in pull downs in the item form when subfield is mandatory
- [[22778]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22778) Suggestions with no "suggester" can cause errors
- [[25130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25130) Reason for accepting/rejecting a suggestion is not visible when viewing (not editing)

### Architecture, internals, and plumbing

- [[18227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18227) Koha::Logger utf8 handling defeating "wide characters in print"
- [[18670]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18670) RewriteLog and RewriteLogLevel unavailable in Apache 2.4
- [[20370]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20370) Misleading comment for bcrypt - #encrypt it; Instead it should be #hash it
- [[25006]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25006) Koha::Item->as_marc_field generates undef subfields
- [[25008]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25008) Koha::RecordProcessor->options doesn't refresh the filters
- [[25019]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25019) Non standard initialization in ViewPolicy filter
- [[25095]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25095) Remove warn left in FeePayment.pm
- [[25107]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25107) Remove double passing of $server variable to maybe_add in C4::SIP::Sip::MsgType
- [[25311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25311) Better error handling when creating/updating a patron
- [[25535]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25535) Hold API mapping maps cancellationdate to cancelation_date, but it should be cancellation_date

### Cataloging

- [[11446]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11446) Authority not searching full corporate name with and (&) symbol
- [[17232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17232) When creating a new framework from an old one, several fields are not copies (important, link, default value, max length, is URL)
- [[19312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19312) Typo in UNIMARC field 121a plugin
- [[25308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25308) When cataloguing search fields are prefilled from record, content after & is cut off

### Circulation

- [[13557]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13557) Add hint for on-site checkouts to list of current checkouts in OPAC
- [[15751]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15751) Koha offline circulation Firefox addon does not update last seen date for check-ins
- [[24620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24620) Existing transfers not closed when hold is set to waiting
- [[24768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24768) "Return claims" column is missing from column configuration page
- [[24840]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24840) Datetime issues in automatic_renewals / CanBookBeReserved
- [[25291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25291) Barcode should be escaped everywhere in html code
- [[25468]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25468) Preserve line breaks in hold notes

### Command-line Utilities

- [[20101]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20101) Cronjob automatic_item_modification_by_age.pl does not log run in action logs
- [[24266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24266) Noisy error in reconcile_balances.pl

  **Sponsored by** *Horowhenua District Council*
- [[25157]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25157) delete_patrons.pl is never quiet, even when run without -v
- [[25480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25480) koha-create may hide useful error

### Course reserves

- [[24750]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24750) Instructor search does not return results if a comma is included after surname or if first name is included

### Developer documentation

- [[22335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22335) Comment on column suggestions.STATUS is not complete

### Documentation

- [[25388]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25388) There is no link for the "online help"

### I18N/L10N

- [[24636]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24636) Acquisitions planning sections untranslatable
- [[25118]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25118) Return claims has some translation issues

### Label/patron card printing

- [[14369]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14369) Only show 'Create labels' link on staged records import when status is 'Imported'
- [[23514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23514) Call numbers are not splitted in Label Creator with layout types other than Biblio

### MARC Bibliographic data support

- [[23119]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23119) MARC21 added title 246, 730 subfield i should display before subfield a
- [[25082]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25082) Unknown language code if 041 $a is linked to an authorized value list

### Notices

- [[19014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19014) Patrons should not get an 'on_reserve' notification if the due date is far into the future
- [[24826]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24826) Use of uninitialized value $mail{"Cc"} in substitution (s///) at /usr/share/perl5/Mail/Sendmail.pm

### OPAC

- [[17853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17853) MARC21: Don't remove () from link text for 780/785
- [[17938]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17938) XSLT: Label of 583 is repeated for multiple tags and private notes don't display in staff

  >This fixes the display for records with multiple 583s. Previously the label "Action note" was repeated, now the label appears once and multiple fields are separated by a |. There is now a space between $z and other subfields.
  >
  >Private notes are now displayed in the staff interface.
  >
  >Notes:
  >Indicator 1 = private: These will not display in the OPAC.
  >Indicator 1 = 0 or empty: These will display in the OPAC.
  >The staff interface  will display all 583s.
- [[22515]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22515) OPACViewOthersSuggestions if set to Show will only show when patron has made a suggestion
- [[24854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24854) Remove IDreamBooks integration
- [[24957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24957) OpenLibrarySearch shouldnt display if nothing is returned
- [[25038]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25038) OPAC reading history checkouts and on-site tabs not working
- [[25211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25211) Missing share icon on OPAC lists page
- [[25233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25233) Staff XSLT material type label "Book" should be "Text"
- [[25274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25274) JavaScript error in OPAC cart when more details are shown
- [[25276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25276) Correct hover style of list share button in the OPAC
- [[25340]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25340) opac-review.pl doesn't show title when commenting

### Patrons

- [[18680]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18680) sort1/sort1 dropdowns (when mapped to authorized value) have no empty entry
- [[21211]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21211) Patron toolbar does not appear on all tabs in patron account in staff
- [[25046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25046) C4::Utils::DataTables::Members does not SELECT othernames from borrowers table

  **Sponsored by** *Eugenides Foundation Library*
- [[25069]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25069) AddressFormat="fr" behavior is broken
- [[25299]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25299) Date not showing on Details page when patron is going to expire
- [[25300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25300) Edit details in "Library use" section uses bad $op for Expiration Date
- [[25301]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25301) Category code is blank when renewing or editing expired/expiring patron
- [[25309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25309) Unable to save patron if streetnumber is too long

### Plugin architecture

- [[25099]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25099) Sending a LANG variable to plug-in template

  **Sponsored by** *Bibliothèque Universitaire des Langues et Civilisations (BULAC)*

### Reports

- [[24940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24940) Serials statistics wizard: order vendor list alphabetically

### SIP2

- [[24993]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24993) koha-sip --restart is too fast, doesn't always start SIP
- [[25227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25227) SIP server returns wrong error message if item was lost and not checked out

### Searching

- [[22937]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22937) Searching by library groups uses  group Title rather than Description
- [[23081]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23081) Make items.issues and deleteditems.issues default to 0 instead of null

### Searching - Elasticsearch

- [[25229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25229) Elasticsearch should use the authid (record id) rather than the 001 when returning auth search results
- [[25278]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25278) Search fields cache must be separate for different indexes under Elasticsearch

### Self checkout

- [[21565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21565) SCO checkout confirm should be modal

### Serials

- [[24903]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24903) Special characters like parentheses in numbering pattern cause duplication in recievedlist
- [[24941]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24941) Serials: Link to basket in acqusition details is broken

### Staff Client

- [[20501]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20501) Unhighlight in search results when the search terms contain the same word twice removes the word
- [[25007]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25007) AmazonCoverImages doesnt check for ISBN in details.tt

  >This fixes the display of cover images in the staff interface where there is no ISBN and both Amazon and local cover images are enabled.
  >
  >Covers different combinations:
  >- Amazon cover present, no local cover.
  >- No Amazon cover, local cover image present.
  >- Both Amazon and local cover image present.
- [[25022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25022) Display problem in authority editor with repeatable field
- [[25072]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25072) Printing details.tt is broken
- [[25224]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25224) Add "Large Print" from 008 position 23 to default XSLT

### System Administration

- [[10561]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10561) DisplayOPACiconsXSLT and DisplayIconsXSLT descriptions should be clearer
- [[25120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25120) In system preference editor first tab is now Accounting and not Acquisitions

### Templates

- [[25010]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25010) Fix typo in debit type description: rewewal
- [[25012]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25012) Fix class on OPAC view link in staff detail page
- [[25013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25013) Fix capitalization: Edit Items on batch item edit
- [[25014]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25014) Capitalization: Call Number in sort options in staff and OPAC
- [[25016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25016) Coce should not return a 1-pixel Amazon cover image

  >This patch improves the display of cover images where Coce is enabled and Amazon is a source. Where the image from Amazon is a 1x1 pixel placeholder (meaning Amazon has no image) it is no longer displayed.
- [[25176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25176) Styling problem with checkout form
- [[25186]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25186) Lots of white space at the bottom of each tab on columns configuration
- [[25343]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25343) Use of item in review/comment feature is misleading
- [[25409]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25409) Required dropdown missing "required" class near label

### Test Suite

- [[24801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24801) selenium/administration_tasks.t failing if too many categories/libraries displayed
- [[24881]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24881) Circulation.t still fails if tests are ran slowly

### Tools

- [[9422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9422) Patron picture uploader ignores patronimages syspref
- [[19475]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19475) Calendar copy creates duplicates

  **Sponsored by** *Koha-Suomi Oy*
- [[24764]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24764) TinyMCE shouldnt do automatic code cleanup when editing HTML in News Feature
- [[25247]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25247) Exporting 'modification log' to a file should not send objects
## New sysprefs

- TrapHoldsOnOrder

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.5%)
- Armenian (100%)
- Basque (56.2%)
- Chinese (China) (57%)
- Chinese (Taiwan) (99.2%)
- Czech (91.3%)
- English (New Zealand) (78.9%)
- English (USA)
- Finnish (74.9%)
- French (95.5%)
- French (Canada) (94.5%)
- German (100%)
- German (Switzerland) (81.5%)
- Greek (70.8%)
- Hindi (100%)
- Italian (86.4%)
- Norwegian Bokmål (84%)
- Occitan (post 1500) (53.5%)
- Polish (78.3%)
- Portuguese (99.5%)
- Portuguese (Brazil) (100%)
- Slovak (83.7%)
- Spanish (100%)
- Swedish (85.7%)
- Telugu (62.9%)
- Turkish (99.4%)
- Ukrainian (73.7%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.06 is


- Release Manager: Martin Renvoize

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Jonathon Druart

- QA Manager: Katrin Fischer

- QA Team:
  - Tomás Cohen Arazi
  - Joonas Kylmälä 
  - Nick Clemens
  - Jonathan Druart
  - Kyle Hall
  - Josef Moravec
  - Marcel de Rooy

- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Colin Campbell
  - UI Design -- Owen Leonard
  - Elasticsearch -- Fridolin Somers
  - ILS-DI -- Arthur Suzuki

- Bug Wranglers:
  - Michal Denár
  - Lisette Scheer
  - Cori Lynn Arnold
  - Amit Gupta

- Packaging Manager: Mason James

- Documentation Manager: Caroline Cyr La Rose and David Nind

- Documentation Team:
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey
  - Donna Bachowski
  - Sugandha Bajaj
  - David Nind 

- Translation Managers: 
  - Bernardo González Kriegel

- Release Maintainers:
  - 19.11 -- Joy Nelson
  - 19.05 -- Lucas Gass
  - 18.11 -- Hayley Mapley

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.11.06:

- [Bibliothèque Universitaire des Langues et Civilisations (BULAC)](http://www.bulac.fr/)
- Eugenides Foundation Library
- Horowhenua District Council
- Koha-Suomi Oy
- Orex Digital
- Universidad ORT Uruguay

We thank the following individuals who contributed patches to Koha 19.11.06.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (13)
- Nick Clemens (35)
- David Cook (6)
- Jonathan Druart (45)
- Katrin Fischer (24)
- Andrew Fuerste-Henry (4)
- Lucas Gass (8)
- Didier Gautheron (2)
- Kyle Hall (23)
- Andrew Isherwood (1)
- Janusz Kaczmarek (1)
- Olli-Antti Kivilahti (1)
- Bernardo González Kriegel (3)
- Nicolas Legrand (1)
- Owen Leonard (13)
- Julian Maurice (1)
- Grace McKenzie (1)
- Josef Moravec (1)
- Agustín Moyano (1)
- Joy Nelson (21)
- Liz Rea (1)
- Martin Renvoize (20)
- Phil Ringnalda (4)
- David Roberts (6)
- Marcel de Rooy (7)
- Andreas Roussos (1)
- Slava Shishkin (2)
- Joseph Sikowitz (1)
- Fridolin Somers (4)
- Emmi Takkinen (2)
- Theodoros Theodoropoulos (1)
- Petro Vashchuk (2)
- George Veranis (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.06

- ACPL (13)
- BibLibre (7)
- BSZ BW (24)
- Bulac (1)
- ByWater-Solutions (91)
- chetcolibrary.org (4)
- dataly.gr (2)
- flo.org (1)
- Independant Individuals (11)
- jns.fi (1)
- Koha Community Developers (45)
- koha-ptfs.co.uk (6)
- lib.auth.gr (1)
- live.nl (2)
- Prosentient Systems (6)
- PTFS-Europe (21)
- Rijks Museum (5)
- Theke Solutions (14)
- Universidad Nacional de Córdoba (3)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (18)
- Nick Clemens (23)
- David Cook (6)
- Chris Cormack (3)
- Frédéric Demians (5)
- Michal Denar (1)
- Devinim (1)
- Jonathan Druart (110)
- Clemens Elmlinger (2)
- Bouzid Fergani (2)
- Katrin Fischer (55)
- Andrew Fuerste-Henry (13)
- Lucas Gass (10)
- Didier Gautheron (2)
- Victor Grousset/tuxayo (22)
- Kyle Hall (23)
- Stina Hallin (3)
- Felix Hemme (1)
- Heather Hernandez (2)
- Abbey Holt (1)
- Catherine Ingram (1)
- Bernardo González Kriegel (12)
- Owen Leonard (12)
- Ere Maijala (1)
- Kelly McElligott (3)
- Josef Moravec (5)
- Joy Nelson (230)
- David Nind (33)
- Séverine Queune (1)
- Laurence Rault (3)
- Liz Rea (3)
- Martin Renvoize (222)
- Phil Ringnalda (2)
- David Roberts (9)
- Marcel de Rooy (27)
- Sally (2)
- Joel Sasse (1)
- Lisette Scheer (1)
- Fridolin Somers (5)
- Lari Taskula (1)
- Mark Tompsett (1)
- Mengü Yazıcıoğlu (2)

We thank the following individuals who mentored new contributors to the Koha project.

- Andrew Nugged
- Andreas Roussos
- Peter Vashchuk


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 21 May 2020 22:26:06.
