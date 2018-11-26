# RELEASE NOTES FOR KOHA 17.11.12
26 nov. 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.11.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.11.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.11.12 is a bugfix/maintenance release.

It includes 5 enhancements, 33 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[19802]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19802) Move Selenium code to its own module

### Authentication

- [[3511]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3511) Integration with Moodle

### Cataloging

- [[3509]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3509) Batch item edit

### Circulation

- [[3510]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=3510) Allow staff to change checkin date and time

### Test Suite

- [[19181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19181) Intranet and OPAC authentication selenium test


## Critical bugs fixed

### Acquisitions

- [[21587]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21587) Patrons to notify on receiving doesn't work on new order creation, only on modification

### Architecture, internals, and plumbing

- [[21599]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21599) Incorrect decimal value: '' for column 'defaultreplacecost' - Cannot create item type

### Authentication

- [[21311]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21311) Remove locked message from opac-auth.tt

> It is good security practice to not provide details which could confirm or deny the existence of an account. Previously, the simple "This account has been locked!" confirmed its existence which would only encourage more attacks by hackers.  
To prevent aiding malicious attacks, the message has been changed to something that does not expressly state the account has been locked. It only mentions that accounts will be locked after a number of failed attempts, instead of saying whether it is locked or not.  
So while a successful attempt will seem to have an invalid username or password suggestion after the account is locked, users should be reminded that they can always reset their password or contact library staff for help.



### Cataloging

- [[21742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21742) Incorrect count of youtube videos

### Circulation

- [[21641]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21641) Software error when checking out an item with a charge associated with it

### Database

- [[21617]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21617) statistics.ccode is not long enough (see also dbrev 18.06.00.032)

### Installation and upgrade (command-line installer)

- [[16690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16690) Improve security of remote database installations

### OPAC

- [[21476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21476) Incorrect filter prevents HTML5 media from playing in the OPAC
- [[21479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21479) Removing from cart removes 2 items
- [[21771]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21771) Password recovery is broken (see 20023)

### Staff Client

- [[21766]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21766) Default sounds broken in 18.05 - wrong filter/link


## Other bugs fixed

### Acquisitions

- [[21417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21417) EDI ordering fails when basket and EAN libraries do not match

### Architecture, internals, and plumbing

- [[15734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15734) Audio Alerts broken
- [[21115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21115) Add multi_param call and add divider in cache key in svc/report and opac counterpart
- [[21396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21396) Missing use statements in Koha::Account
- [[21500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21500) Warnings in rotating collections

### Circulation

- [[16420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16420) Buttons inconsistent between "Hold found" and "Hold found (waiting)" dialogs in checkin

### Hold requests

- [[21076]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21076) Javascript error on article requests page
- [[21320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21320) Holds to pull should honor syspref AllowHoldsOnDamagedItems
- [[21389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21389) Javascript error on article requests page

### I18N/L10N

- [[21351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21351) Traditional Chinese Language pack should have file name "zh-Hant-TW" not "zh-Hans-TW"
- [[21490]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21490) Disambiguation of "Order"

### MARC Bibliographic data support

- [[20910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20910) 773$g not displayed if $0 is present

> Sponsored by Escuela de Orientacion Lacaniana


### Packaging

- [[17237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17237) Stop koha-create from creating MySQL users without host restriction

### Searching

- [[9968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9968) Incorrect index used for 'Standard number' in advanced search
- [[21455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21455) Authority search options get shuffled around when you click on 'Search'

### Staff Client

- [[21456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21456) The 'New authority' button lists authority types inconsistently

### System Administration

- [[21279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21279) Transport cost matrix shows html entity in all empty cells

### Templates

- [[21506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21506) DataTables four button pagination uses the wrong icon for First and Last buttons
- [[21513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21513) Add a 'Cancel' button to the authority editor and remove duplicate 'Save' button
- [[21550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21550) DataTables four button pagination uses the wrong icon for disabled buttons

### Test Suite

- [[21155]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21155) SwitchOnSiteCheckouts.t is failing randomly

### Tools

- [[21579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21579) showdiffmarc tool during manage staged batches always looks for biblios even when matching authorities



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

- [Koha Manual](http://koha-community.org/manual/17.11/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.4%)
- Armenian (100%)
- Basque (75.3%)
- Chinese (China) (79.7%)
- Chinese (Taiwan) (99.7%)
- Czech (94.1%)
- Danish (65.7%)
- English (New Zealand) (99.4%)
- English (USA)
- Finnish (95.6%)
- French (98.9%)
- French (Canada) (92%)
- German (100%)
- German (Switzerland) (99.4%)
- Greek (82.7%)
- Hindi (100%)
- Italian (99.8%)
- Norwegian Bokmål (54.5%)
- Occitan (post 1500) (72.8%)
- Persian (54.8%)
- Polish (97.5%)
- Portuguese (100%)
- Portuguese (Brazil) (84.5%)
- Slovak (96.6%)
- Spanish (100%)
- Swedish (91.6%)
- Turkish (100%)
- Vietnamese (67.4%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.11.12 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 17.11.12:

- Escuela de Orientacion Lacaniana

We thank the following individuals who contributed patches to Koha 17.11.12.

- Tomás Cohen Arazi (2)
- Alex Buckley (1)
- Colin Campbell (1)
- Nick Clemens (5)
- Jonathan Druart (10)
- Katrin Fischer (1)
- Victor Grousset (1)
- Kyle Hall (1)
- Andrew Isherwood (2)
- Owen Leonard (2)
- Dobrica Pavlinusic (1)
- Martin Renvoize (3)
- Marcel de Rooy (6)
- Caroline Cyr La Rose (2)
- Andreas Roussos (4)
- Fridolin Somers (6)
- Mark Tompsett (1)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.11.12

- ACPL (2)
- BibLibre (7)
- BSZ BW (1)
- bugs.koha-community.org (10)
- ByWater-Solutions (6)
- Catalyst (1)
- PTFS-Europe (6)
- Rijks Museum (6)
- rot13.org (1)
- Solutions inLibro inc (2)
- Theke Solutions (2)
- unidentified (5)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (7)
- Marjorie Barry-Vila (1)
- Alex Buckley (3)
- Colin Campbell (1)
- Nick Clemens (39)
- Chris Cormack (4)
- Michal Denar (5)
- Devinim (1)
- Jonathan Druart (13)
- Katrin Fischer (9)
- Claire Gravely (2)
- Kyle Hall (1)
- Andrew Isherwood (1)
- Owen Leonard (3)
- Jesse Maseto (1)
- Julian Maurice (1)
- Josef Moravec (2)
- Séverine Queune (1)
- Martin Renvoize (56)
- Marcel de Rooy (7)
- Caroline Cyr La Rose (1)
- Fridolin Somers (44)
- Pierre-Marc Thibault (3)
- Mark Tompsett (5)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 26 nov. 2018 15:22:49.
