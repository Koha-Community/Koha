# RELEASE NOTES FOR KOHA 19.11.02
22 Jan 2020

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 19.11.02 can be downloaded from:

- [Download](http://download.koha-community.org/koha-19.11.02.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 19.11.02 is a bugfix/maintenance release.

It includes 13 enhancements, 48 bugfixes.

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

### Cataloging

- [[24173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24173) Advanced Editor: Show subtitle & published date on the search page

  >This enhancement adds Subtitle (all parts) and date published to the results that come up for the Advanced Editor Search.

### Circulation

- [[24308]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24308) Suggestions table on suggestions.pl should have separate columns for dates

### I18N/L10N

- [[24063]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24063) Add Sami language characters to Zebra

  >This patch adds some additional characters to the default zebra mappings for Sami languages to aid in searching on systems with such data present.

### Installation and upgrade (web-based installer)

- [[24314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24314) Update de-DE MARC21 frameworks for updates 28+29 (May and November 2019)

### MARC Bibliographic data support

- [[23783]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23783) Add display of languages from MARC21 field 041 to the OPAC

  >This enhancement adds display handling for the 041 MARC21 languages field, into the OPAC results and item details pages.
- [[24312]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24312) Update MARC21 frameworks to Updates 28+29 (May and November 2019)

### Notices

- [[24253]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24253) process_message_queue.pl fail if not to address is defined

### OPAC

- [[23261]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23261) RecordedBooks - notify patron of need to login / register to see availability

  >This enhancement makes the RBDigital Recorded Books subscription more discoverable to library patrons by adding a notice to the OPAC for patrons to register and login with RBDigital if they have not already done so.

### REST API

- [[23893]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23893) Add ->new_from_api and ->set_from_api methods to Koha::Object

  >This development introduces generic methods to deal with API-to-DB attribute names translations, and some data transformations (dates and booleans).
  >
  >With this design we can overload this methods to handle specific cases without repeating the code as we did on initial implementations of API controllers.
  >
  >Testing becomes easier as well.
- [[24228]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24228) Add a parameter to recursively embed objects in Koha::Object(s)->to_api

  >This patch introduces a parameter to the Koha::Object class ('embed') that should be a hashref pointing to a data structure following what's documented in the code. This parameter allows the caller to specify things to embed recursively in the API representation of the object. For example: you could request a biblio object with its items attached, like this:
  >
  >    $biblio_json = $biblio->to_api({ embed => { items => {} } });
  >
  >The names specified for embedding, are used as attribute names on the resulting JSON object, and are expected to be class accessors.
  >
  >The main use of this is the API, as introduced by bug 24302.
  >
  >Koha::Objects->to_api is adjusted to pass its parameters down to the Koha::Object.

### Templates

- [[10469]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10469) Display more when editing subfields in frameworks
- [[23889]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23889) Improve style of menu header in advanced cataloging editor

  >This enhancement updates the styling of dropdown menu headers to make them apply more consistently across the system.
- [[24181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24181) Make our datepicker inputs sexy


## Critical bugs fixed

### About

- [[24215]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24215) Warnings about guarantor relationships show ARRAY errors

### Acquisitions

- [[24242]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24242) Funds with no library assigned do not appear on edit suggestions page
- [[24244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24244) Cannot create suggestion with branch set to 'Any'
- [[24277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24277) Date Received in acquisitions cannot be changed

### Architecture, internals, and plumbing

- [[24263]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24263) borrowers.relationship should not contain an empty string

### Circulation

- [[24259]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24259) Circulation fails if no circ rule defined but checkout override confirmed

### Hold requests

- [[20948]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20948) Item-level hold info displayed regardless its priority (detail.pl)

### Installation and upgrade (command-line installer)

- [[24316]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24316) Fix non-English web installers by removing obsolete authorised value MANUAL_INV
- [[24445]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24445) Add missing Z3950 updates to Makefile.PL

### Installation and upgrade (web-based installer)

- [[24137]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24137) Marc21 bibliographic fails to install for ru-Ru and uk-UA
- [[24317]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24317) Sample patron data not loading for non-English installations

### Notices

- [[24235]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24235) /misc/cronjobs/advance_notices.pl DUEDGST does NOT send sms, just e-mail

### Serials

- [[21232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21232) Problems when linking a subscription to a non-existing biblionumber

### System Administration

- [[24329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24329) Patron cardnumber change times are lost during upgrade for bug 3820

### Templates

- [[24241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24241) Description missing for subpermission manage_accounts


## Other bugs fixed

### Architecture, internals, and plumbing

- [[24016]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24016) manager_id in Koha::Patron::Message->store should not depend on userenv alone

  **Sponsored by** *Koha-Suomi Oy*

  >Using `userenv` within Koha::* object classes is deprecated in favour of passing parameters.

### Cataloging

- [[11500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=11500) Use dateformat syspref and datepicker on additems.pl (and other item cataloguing pages)
- [[24232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24232) Fix permissions for deleting a bib record after attaching the last item to another bib

### Circulation

- [[23233]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23233) AllowItemsOnHoldCheckout is misnamed and should only work for for SIP-based checkouts
- [[24085]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24085) Double submission of forms on returns.pl
- [[24166]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24166) Barcode removal breaks circulation.pl/moremember.pl
- [[24257]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24257) item-transfer-modal does not initiate transfer when 'yes, print slip' is selected
- [[24335]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24335) Cannot mark checkout notes seen/not seen in bulk
- [[24337]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24337) Checkout note cannot be marked seen if more than 20 exist

### Command-line Utilities

- [[19465]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19465) Allow choosing Elasticsearch server on instance creation

### Course reserves

- [[24283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24283) Missing close parens and closing strong tag in course reserves

### Fines and fees

- [[24208]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24208) Remove change calculation for writeoffs

### I18N/L10N

- [[18688]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18688) Warnings about UTF-8 charset when creating a new language
- [[24046]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24046) 'Activate filters' untranslatable
- [[24358]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24358) "Bibliographic record does not exist!" is not translatable

### ILL

- [[21270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21270) "Not finding what you're looking" display needs to be fixed

### Installation and upgrade (command-line installer)

- [[24328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24328) Bibliographic frameworks fail to install

### MARC Authority data support

- [[24267]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24267) C4::Breeding::ImportBreedingAuth is ineffective

### MARC Bibliographic data support

- [[24274]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24274) New installations should not contain field 01e Coded field error (RLIN)
- [[24281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24281) Fix the list of types of visual materials

### OPAC

- [[24212]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24212) OPAC send list dialog opens too small in IE

  **Sponsored by** *Toi Ohomai Institute of Technology*
- [[24240]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24240) List on opac missing close form tag under some conditions
- [[24245]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24245) opac-registration-confirmation.tt has incorrect HTML body id
- [[24327]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24327) Anonymous suggestions should not be allowed if AnonymousPatron misconfigured

### Searching

- [[24121]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24121) Item types icons in intra search results are requesting icons from opac images path

  **Sponsored by** *Governo Regional dos A�ores*

### Staff Client

- [[22381]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22381) Wording on Calendar-related system preferences not standardized

### System Administration

- [[24184]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24184) Reword FallbackToSMSIfNoEmail syspref text

### Templates

- [[23956]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23956) Replace famfamfam calendar icon in staff client with CSS data-url
- [[23957]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23957) Remove button style with famfamfam icon background and replace with Font Awesome
- [[24054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24054) Typo in ClaimReturnedWarningThreshold system preference
- [[24104]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24104) Item search - dropdown buttons overflow
- [[24169]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24169) Advanced editor: icons/buttons for sorting the search results are missing
- [[24282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24282) SCSS conversion broke style in search results item status
## New sysprefs

- AllowItemsOnHoldCheckoutSIP

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

- Arabic (99.6%)
- Armenian (100%)
- Basque (56.8%)
- Chinese (China) (57.3%)
- Chinese (Taiwan) (100%)
- Czech (91.9%)
- English (New Zealand) (79.7%)
- English (USA)
- Finnish (75.7%)
- French (95.6%)
- French (Canada) (95.5%)
- German (100%)
- German (Switzerland) (82.3%)
- Greek (71.3%)
- Hindi (100%)
- Italian (87.3%)
- Norwegian Bokmål (84.9%)
- Occitan (post 1500) (54.1%)
- Polish (79.1%)
- Portuguese (100%)
- Portuguese (Brazil) (89.6%)
- Slovak (80.6%)
- Spanish (98.1%)
- Swedish (85.6%)
- Turkish (93.1%)
- Ukrainian (70.9%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 19.11.02 is


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
  - Caroline Cyr La Rose
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
new features in Koha 19.11.02:

- Governo Regional dos A�ores
- Koha-Suomi Oy
- Toi Ohomai Institute of Technology

We thank the following individuals who contributed patches to Koha 19.11.02.

- Aleisha Amohia (1)
- Pedro Amorim (1)
- Tomás Cohen Arazi (15)
- Cori Lynn Arnold (1)
- Philippe Blouin (1)
- Nick Clemens (8)
- Jonathan Druart (33)
- Katrin Fischer (4)
- Lucas Gass (4)
- Kyle Hall (4)
- Mason James (1)
- Pasi Kallinen (1)
- Bernardo González Kriegel (4)
- Joonas Kylmälä (4)
- Owen Leonard (9)
- Agustín Moyano (1)
- Joy Nelson (7)
- Martin Renvoize (10)
- Marcel de Rooy (2)
- Maryse Simard (3)
- Fridolin Somers (1)
- Lari Taskula (2)
- Koha Translators (1)
- Radek Šiman (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 19.11.02

- ACPL (9)
- BibLibre (1)
- BSZ BW (4)
- ByWater-Solutions (23)
- hypernova.fi (2)
- Independant Individuals (2)
- Koha Community Developers (33)
- koha-suomi.fi (1)
- KohaAloha (1)
- PTFS-Europe (10)
- rbit.cz (1)
- Rijks Museum (2)
- Solutions inLibro inc (4)
- The Donohue Group (1)
- Theke Solutions (16)
- Universidad Nacional de Córdoba (4)
- University of Helsinki (4)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (21)
- Cori Lynn Arnold (1)
- Nick Clemens (2)
- Holly Cooper (5)
- Michal Denar (1)
- Jonathan Druart (42)
- Bouzid Fergani (1)
- Katrin Fischer (28)
- Andrew Fuerste-Henry (4)
- Lucas Gass (5)
- Kyle Hall (12)
- Andrew Isherwood (1)
- Dilan Johnpullé (1)
- Pasi Kallinen (1)
- Bernardo González Kriegel (10)
- Joonas Kylmälä (10)
- Owen Leonard (9)
- Kelly McElligott (3)
- Josef Moravec (5)
- Agustín Moyano (1)
- Joy Nelson (112)
- Martin Renvoize (114)
- Marcel de Rooy (10)
- Lisette Scheer (2)
- Maryse Simard (4)
- Fridolin Somers (1)
- Lari Taskula (3)
- Jessica Zairo (1)



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

Autogenerated release notes updated last on 22 Jan 2020 16:03:02.
