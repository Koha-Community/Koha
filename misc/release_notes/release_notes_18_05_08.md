# RELEASE NOTES FOR KOHA 18.05.08
22 Jan 2019

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.08 is a bugfix/maintenance release.

It includes 23 bugfixes.






## Critical bugs fixed

### Acquisitions

- [[21605]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21605) Cannot create EDI account

### Architecture, internals, and plumbing

- [[22052]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22052) DeleteExpiredOpacRegistrations should skip bad borrowers

### Cataloging

- [[21986]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21986) Quotation marks are wrongly escaped in several places

### Circulation

- [[21065]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21065) Data in account_offsets and accountlines is deleted with the patron leaving gaps in financial reports
- [[21928]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21928) CircAutoPrintQuickSlip 'clear' is not working
- [[22020]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22020) Configure Columns for Patron Issues checkin hides renewal

### Database

- [[21931]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21931) Upgrade from 3.22 fails when running updatedatabase.pl script

### OPAC

- [[22030]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22030) OverDrive requires configuration for field passed as username

### REST api

- [[22071]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22071) authenticate_api_request does not stash koha.user in the OAuth use case

### Reports

- [[21984]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21984) Unable to load second page of results for reports with reused parameters
- [[21991]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21991) Displaying more rows on report results does not work for reports with parameters


## Other bugs fixed

### Acquisitions

- [[21929]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21929) Typo in orderreceive.tt

### Architecture, internals, and plumbing

- [[21848]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21848) Resolve unac_string warning from Circulation.t

### Command-line Utilities

- [[21908]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21908) biblio_metadata is missing from the rebuild_zebra.pl tables list

### MARC Bibliographic data support

- [[22034]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22034) Viewing record with Default framework doesn't work on MARC tab

### Notices

- [[21571]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21571) Translate notices fail on ACCTDETAILS

### Packaging

- [[17108]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17108) Automatic debian/control updates (stable/18.11.x)
- [[17111]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17111) Automatic debian/control updates (oldstable/18.05.x)

### Searching - Zebra

- [[22073]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22073) Diacritics Ž and ž not being mapped for searching (Non-ICU)

### Templates

- [[21990]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21990) No background color for div.error, must be .alert

### Test Suite

- [[14334]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14334) DBI fighting DBIx over Autocommit in tests

### Tools

- [[21465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21465) Cannot overlay patrons when matching by cardnumber if userid exists in file and in Koha
- [[22022]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22022) Authorised values on the batch item modification page are not displayed in order (order by code, not lib)

## New sysprefs

- OverDriveUsername

## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in DocBook. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](http://git.koha-community.org/gitweb/?p=kohadocs.git;a=summary)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.9%)
- Armenian (100%)
- Basque (72.6%)
- Chinese (China) (77.1%)
- Chinese (Taiwan) (98.9%)
- Czech (92.5%)
- Danish (63.7%)
- English (New Zealand) (95.6%)
- English (USA)
- Finnish (92.5%)
- French (98.9%)
- French (Canada) (94.1%)
- German (100%)
- German (Switzerland) (98.5%)
- Greek (80.5%)
- Hindi (99.1%)
- Italian (97.5%)
- Norwegian BokmÃ¥l (67.7%)
- Occitan (post 1500) (70.4%)
- Persian (53%)
- Polish (93.8%)
- Portuguese (100%)
- Portuguese (Brazil) (87.6%)
- Slovak (94.5%)
- Spanish (98.8%)
- Swedish (94%)
- Turkish (100%)
- Vietnamese (65.2%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.08 is

- Release Manager: [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
- Release Manager assistant: [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: 

- QA Team:
  - [TomÃ¡s Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - Josef Moravec
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Marc VÃ©ron](mailto:veron@veron.ch)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 17.11 -- [Nick Clemens](mailto:nick@bywatersolutions.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 16.11 -- [Chris Cormack](mailto:chrisc@catalyst.net.nz)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.08:


We thank the following individuals who contributed patches to Koha 18.05.08.

- Nightly Build Bot (2)
- Colin Campbell (1)
- Nick Clemens (8)
- TomÃ¡s Cohen Arazi (4)
- Marcel de Rooy (3)
- Jonathan Druart (11)
- Lucas Gass (2)
- Andrew Isherwood (1)
- Jesse Maseto (2)
- Julian Maurice (1)
- Martin Renvoize (1)
- Fridolin Somers (2)
- Koha translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.08

- abunchofthings.net (2)
- BibLibre (5)
- bugs.koha-community.org (11)
- ByWater-Solutions (12)
- PTFS-Europe (3)
- Rijksmuseum (3)
- Theke Solutions (4)

We also especially thank the following individuals who tested patches
for Koha.

- Hugo Agud (1)
- Alex Arnaud (2)
- NazlÄ± Ãetin (1)
- Nick Clemens (32)
- Tomas Cohen Arazi (1)
- Marcel de Rooy (8)
- Jonathan Druart (6)
- Charles Farmer (4)
- Katrin Fischer (4)
- Lucas Gass (24)
- âLucas Gassâ (1)
- Owen Leonard (4)
- Jesse Maseto (15)
- Julian Maurice (3)
- Kyle M Hall (2)
- Josef Moravec (3)
- Eric Phetteplace (1)
- Martin Renvoize (47)
- Pierre-Marc Thibault (3)
- Mirko Tietgen (2)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is rmain1805.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Jan 2019 17:06:47.
