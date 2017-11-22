# RELEASE NOTES FOR KOHA 17.05.06
22 nov. 2017

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 17.05.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-17.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 17.05.06 is a bugfix/maintenance release.

It includes 5 enhancements, 38 bugfixes.




## Enhancements

### Cataloging

- [[16204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16204) Show friendly error message when trying to edit record which no longer exists

### OPAC

- [[18616]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18616) The "Add forgot password link to OPAC" should allow patrons to use their library card number in addition to username
- [[19068]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19068) OPAC purchase suggestion doesn't allow users to enter quantity of items

### Patrons

- [[15644]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15644) City dropdown default selection when modifying a patron matches only on city

### Test Suite

- [[19337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19337) Allow basic_workflow.t be configured by ENV


## Critical bugs fixed

### Acquisitions

- [[18999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18999) Acq: Shipping cost not included in total spent on acq home and funds page
- [[19296]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19296) Tax is being subtracted from orders when vendor price does not include gst and ordering from a file
- [[19425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19425) Adding orders from order file with multiple budgets per record triggers error

### Cataloging

- [[19503]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19503) Duplicating a dropdown menu subfield yields an empty subfield tag

### Circulation

- [[19374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19374) CircSidebar overlapping transferred items table
- [[19487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19487) Internal server error when writing off lost fine for item not checked out

### Hold requests

- [[19135]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19135) AllowHoldsOnPatronsPossessions is not working

### MARC Authority data support

- [[19415]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19415) FindDuplicateAuthority is searching on biblioserver since 16.05

### Reports

- [[19495]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19495) Automatic report conversion needs to do global replace on 'biblioitems' and 'marcxml'

### Searching - Elasticsearch

- [[18374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18374) Respect QueryAutoTruncate syspref in Elasticsearch

### Staff Client

- [[18884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18884) Advanced search on staff client, Availability limit not properly limiting

### System Administration

- [[15173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15173) SubfieldsToAllowForRestrictedEditing not working properly

### Templates

- [[19329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19329) IntranetSlipPrinterJS label is obsoleted


## Other bugs fixed

### Acquisitions

- [[19180]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19180) Vendor name is missing from breadcrumbs when closing an order
- [[19195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19195) Noisy warns when creating or editing a basket

### Architecture, internals, and plumbing

- [[18584]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18584) Our legacy code contains trailing-spaces
- [[19317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19317) Move of checkouts - Remove leftover
- [[19344]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19344) DB fields login_attempts and lang may be inverted

### Cataloging

- [[18422]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18422) Add Select2 to authority editor

### MARC Authority data support

- [[17380]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17380) Resolve several problems related to Default authority framework
- [[18801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18801) Merging authorities has an invalid 'Default' type in the merge framework selector
- [[18811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18811) Visibility settings inconsistent between framework and authority editor

### OPAC

- [[16463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16463) OPAC discharge page should warn the user about checkouts before they request
- [[19345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19345) SendMail error does not display error message in password recovery

### Patrons

- [[12346]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=12346) False patron modification alerts on members-home.pl
- [[19398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19398) Wrong date format in quick patron search table

### Reports

- [[18742]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18742) Circulation statistics wizard no longer exports the total row

### Serials

- [[19315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19315) Routing preview may use wrong biblionumber

### Staff Client

- [[19193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19193) When displaying the fines of the guarantee on the guarantor account, price is not in correct format.

### System Administration

- [[16726]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16726) Text in Preferences search box does not clear

### Test Suite

- [[17664]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17664) Silence non-zebra warnings in t/db_dependent/Search.t
- [[19262]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19262) pod_spell.t does not work
- [[19307]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19307) t/db_dependent/Circulation/NoIssuesChargeGuarantees.t fails if AllowFineOverride set to allow
- [[19386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19386) t/db_dependent/SIP/Patron.t is failing randomly
- [[19392]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19392) auth_values_input_www.t does not clean up
- [[19403]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19403) Again and again, Circulation.t is failing randomly
- [[19405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19405) t/db_dependent/api/v1/holds.t fails randomly
- [[19423]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19423) DecreaseLoanHighHolds.t is failing randomly



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook.The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://manual.koha-community.org//en/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- English (USA)
- Arabic (99%)
- Armenian (100%)
- Chinese (China) (83%)
- Chinese (Taiwan) (99%)
- Czech (94%)
- Danish (69%)
- English (New Zealand) (91%)
- Finnish (99%)
- French (96%)
- French (Canada) (94%)
- German (100%)
- German (Switzerland) (99%)
- Greek (79%)
- Hindi (96%)
- Italian (99%)
- Norwegian Bokmål (57%)
- Occitan (76%)
- Persian (57%)
- Polish (100%)
- Portuguese (99%)
- Portuguese (Brazil) (84%)
- Slovak (90%)
- Spanish (99%)
- Swedish (96%)
- Turkish (100%)
- Vietnamese (71%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

for information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 17.05.06 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- RM Assistants :
  - [Alex Sassmannshausen](mailto:alex.sassmannshausen@ptfs-europe.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
- QA Team:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Alex Sassmannshausen](mailto:alex.sassmannshausen@ptfs-europe.com)
  - [Nick Clemens](mailto:nick@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
- Bug Wranglers:
  - [Marc Véron](mailto:veron@veron.ch)
  - [Claire Gravely](mailto:claire_gravely@hotmail.com)
  - [Josef Moravec](mailto:josef.moravec@gmail.com)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Wiki curators:
  - [Thomas Dukleth](mailto:kohadevel@agogme.com)
- Release Maintainers:
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)
  - 16.05 -- [Mason James](mtj@kohaaloha.com)

## Credits

We thank the following libraries who are known to have sponsored
new features in Koha 17.05.06:

- Catalyst IT

We thank the following individuals who contributed patches to Koha 17.05.06.

- root (1)
- Aleisha Amohia (7)
- David Bourgault (1)
- Alex Buckley (3)
- Nick Clemens (11)
- Tomás Cohen Arazi (3)
- David Cook (1)
- Marcel de Rooy (16)
- Jonathan Druart (19)
- Jon Knight (1)
- David Kuhn (1)
- Owen Leonard (1)
- Julian Maurice (5)
- Kyle M Hall (3)
- Josef Moravec (1)
- Dominic Pichette (1)
- Andreas Roussos (1)
- Fridolin Somers (5)
- Lari Taskula (1)
- Mark Tompsett (1)
- Oleg Vasylenko (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 17.05.06

- ACPL (1)
- BibLibre (10)
- bugs.koha-community.org (19)
- ByWater-Solutions (14)
- Catalyst (3)
- jns.fi (1)
- lboro.ac.uk (1)
- Prosentient Systems (1)
- Rijksmuseum (16)
- Solutions inLibro inc (2)
- Theke Solutions (3)
- translate.koha-community.org (1)
- unidentified (12)

We also especially thank the following individuals who tested patches
for Koha.

- Alex Buckley (2)
- Amit Gupta (1)
- Christopher Brannon (2)
- Christopher Kellermeyer (1)
- Claire Gravely (1)
- Colin Campbell (1)
- David Bourgault (2)
- Dilan Johnpullé (2)
- Dominic Pichette (2)
- Fridolin Somers (77)
- Jonathan Druart (83)
- Josef Moravec (11)
- Julian Maurice (13)
- Katrin Fischer (5)
- Lee Jamison (2)
- Marc Véron (2)
- Mark Tompsett (4)
- Nick Clemens (15)
- Owen Leonard (1)
- Simon Pouchol (1)
- Tomas Cohen Arazi (12)
- Kyle M Hall (6)
- Caroline Cyr La Rose (4)
- Marcel de Rooy (31)

We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 17.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 nov. 2017 14:03:35.
