# RELEASE NOTES FOR KOHA 19.05.02
23 juil. 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.05.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.05.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.05.02 is a bugfix/maintenance release.

It includes 1 enhancements, 30 bugfixes.




## Enhancements

### System Administration

- [[23179]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23179) Add 'Edit subfields' to framework management tag dropdown and clarify options


## Critical bugs fixed

### Authentication

- [[22585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22585) Fix remaining double-escaped CAS links

### Circulation

- [[23103]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23103) Cannot checkin items lost by deleted patrons with fines attached
- [[23120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23120) Internal server error when checking in item to transfer and printing slip

### Hold requests

- [[13640]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13640) Holds To Pull List includes items unreserveable items
- [[23116]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23116) Cannot place overridden holds

### Installation and upgrade (command-line installer)

- [[23090]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23090) MySQL validate_password plugin breaks koha-create
- [[23250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23250) koha-create generates broken mysql password

### Mana-kb

- [[22210]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22210) Allow organisations to sign up to Mana KB (don't only ask for firstname lastname)

> This enhancement changes the Mana registration form to make it easier for organizations to register. It now only requires name and email address, rather than first name, last name and email address.



### OPAC

- [[23150]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23150) GDPR feature breaks patron self modification on OPAC
- [[23151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23151) Patron self modification sends null dateofbirth

### SIP2

- [[23057]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23057) If checked_in_ok is set and item is not checked out, alert flag is supressed for *any* reason

### Tools

- [[15814]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15814) Templates for MARC modification: Edit action does not work when Description contains '


## Other bugs fixed

### Architecture, internals, and plumbing

- [[23144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23144) Bad POD breaks svc/barcode

### Circulation

- [[22617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22617) Checkout notes pending dashboard link - error received even though manage_checkout_notes permission set

> This fixes an error that occurs when an account with full circulate permissions (but not super librarian permissions) clicks on 'Checkout notes pending' and is then automatically logged out with the message "Error: you do not have permission to view this page. Log in as a different user".


- [[23061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23061) The column/print/export buttons are missing on the checkout history page
- [[23097]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23097) Circulation Overdues report patron link  goes to patron's holds tab
- [[23140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23140) Typo in returns.tt prevents printing branchcode in transfer slips

### I18N/L10N

- [[22783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22783) 'Location' not picked up by translation toolchain

### Installation and upgrade (web-based installer)

- [[22966]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22966) Add Norwegian library and patron names for the web-based installer

### Mana-kb

- [[23034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23034) Warning when in Mana KB settings Auto subscription sharing is unchecked

> Sponsored by The National Library of Finland

- [[23130]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23130) Incorrect alternative mana server URL in etc/koha-conf.xml

> This fix updates the alternative Mana KB server URL in  
etc/koha-conf.xml to https://mana-test.koha-community.org. If the updated URL is used the account creation request is successful and doesn't cause any error messages.



### OPAC

- [[22946]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22946) Markup error in OPAC search results around selection links
- [[23122]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23122) When searching callnumber in simple search, search option is not retained

### Patrons

- [[22944]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22944) avoid AnonymousPatron in search_patrons_to_anonymise

### Searching

- [[23132]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23132) Encoding issues in facets with show more link

### Serials

- [[23065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23065) 'New subscription' button in serials sometimes uses a blank form and sometimes defaults to current serial

### System Administration

- [[23153]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23153) In framework management action subfields goes directly to edition

### Templates

- [[22851]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22851) Navigation links in the serials module should be styled the same as other modules

### Test Suite

- [[23177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23177) Rollback cleanup in Circulation.t

### Tools

- [[22571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22571) MARC modification templates do not handle control fields in conditional



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/19.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

(sorry translation website was down).

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.05.02 is

- Release Manager: Martin Renvoize
- Release Manager assistants:
  - Tomás Cohen Arazi
  - Nick Clemens
- QA Manager: Katrin Fischer
- QA Team:
  - Tomás Cohen Arazi
  - Alex Arnaud
  - Nick Clemens
  - Jonathan Druart
  - Kyle Hall
  - Julian Maurice
  - Josef Moravec
  - Marcel de Rooy
- Topic Experts:
  - REST API -- Tomás Cohen Arazi
  - SIP2 -- Kyle Hall
  - UI Design -- Owen Leonard
  - Elasticsearch -- Alex Arnaud
  - ILS-DI -- Arthur Suzuki
  - Authentication -- Martin Renvoize
- Bug Wranglers:
  - Michal Denár
  - Indranil Das Gupta
  - Jon Knight
  - Lisette Scheer
  - Arthur Suzuki
- Packaging Manager: Mirko Tietgen
- Documentation Manager: David Nind
- Documentation Team:
  - Andy Boze
  - Caroline Cyr-La-Rose
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel
- Release Maintainers:
  - 19.05 -- Fridolin Somers
  - 18.11 -- Lucas Gass
  - 18.05 -- Liz Rea
## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 19.05.02:

- The National Library of Finland

We thank the following individuals who contributed patches to Koha 19.05.02.

- Alex Arnaud (1)
- Nick Clemens (4)
- David Cook (1)
- Jonathan Druart (8)
- Katrin Fischer (1)
- Kyle Hall (7)
- Petter von Krogh (1)
- Joonas Kylmälä (1)
- Owen Leonard (4)
- Julian Maurice (1)
- David Nind (1)
- Martin Renvoize (8)
- Marcel de Rooy (6)
- Fridolin Somers (8)
- Mark Tompsett (8)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.05.02

- ACPL (4)
- BibLibre (10)
- BSZ BW (1)
- ByWater-Solutions (11)
- davidnind.com (1)
- Independant Individuals (8)
- Koha Community Developers (8)
- Libriotech (1)
- Prosentient Systems (1)
- PTFS-Europe (8)
- Rijks Museum (6)
- University of Helsinki (1)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (1)
- Arthur Bousquet (1)
- Nick Clemens (15)
- Chris Cormack (2)
- Michal Denar (3)
- Jonathan Druart (3)
- Katrin Fischer (7)
- Martha Fuerst (5)
- Claire Gravely (1)
- Kyle Hall (10)
- Owen Leonard (1)
- Julian Maurice (4)
- Nadine Pierre (1)
- Martin Renvoize (62)
- Marcel de Rooy (24)
- Maryse Simard (1)
- Fridolin Somers (58)
- Mark Tompsett (11)
- Bin Wen (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 19.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 juil. 2019 13:03:46.
