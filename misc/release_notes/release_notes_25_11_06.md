# RELEASE NOTES FOR KOHA 25.11.06
24 Jun 2026

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](https://koha-community.org)

Koha 25.11.06 can be downloaded from:

- [Download](https://download.koha-community.org/koha-25.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](https://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 25.11.06 is a bugfix/maintenance release with security patches.

It includes 25 bugfixes (5 security).

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [42360](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42360) SQL Injection in reports/acquisitions_stats.pl via Filter parameter
- [42363](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42363) SQL Injection in reports/catalogue_stats.pl via the Line request parameter
- [42368](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42368) SQL Injection in reports/issues_avg_stats.pl via the Filter request parameter (unvalidated string context, no placeholders)
- [42369](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42369) SQL Injection in reports/bor_issues_top.pl via the Filter request parameter (unvalidated string context, no placeholders)
- [42735](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42735) SQL Injection in reports/issues_stats.pl via PeriodTypeSel / PeriodDaySel / PeriodMonthSel / Filter parameters (unvalidated string context, no placeholders)

## Bugfixes

### About

#### Other bugs fixed

- [42726](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42726) Release team 26.11
  >Updates changes to the 25.11 release team, and adds the details of people in the 26.05 release team. (More > About Koha > Koha team.)

### Accessibility

#### Other bugs fixed

- [42498](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42498) Accessibility - Page tabs/pagination on results in opac produces accessibility error  "Aria state or property has invalid value"

  **Sponsored by** *Athens County Public Libraries*

### Acquisitions

#### Critical bugs fixed

- [42723](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42723) Purchase suggestion 500 page error when EmailPurchaseSuggestions is set to "email address of library"
  >This fixes a 500 page error[1] when creating a suggestion in the staff interface if:
  >- the EmailPurchaseSuggestions system preference is set to "email address of library", and
  >- the library for acquisition information is set to "Any".
  >
  >[1] Can't call method "inbound_email_address" on an undefined value at /kohadevbox/koha/Koha/Suggestion.pm line 107

#### Other bugs fixed

- [41998](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41998) Some templates in suggestion.pl are computed even through a redirection
- [42710](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42710) Purchase suggestion creation form (staff interface) no longer defaults to logged-in library
  >This fixes entering suggestions using the staff interface. When making a suggestion the default library selected was "Any". The default library is now the current library you are logged in as.
- [42740](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42740) Suggestion status is not kept when editing a suggestion
- [42750](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42750) Purchase suggestions made from members/purchase-suggestions.pl no longer redirect back
  >This fixes the redirect when making a suggestion for a patron (Patrons > [Selected patron] > Purchase suggestions).
  >
  >After creating a suggestion, the staff patron is now redirected back to the patron's purchase suggestion page. Previously, they stayed on the list of suggestions on the suggestion management page in acquisitions.
  >
  >(This fixes an error introduced by Bug 39721 - Remove GetSuggestion from C4/Suggestions.pm, added to Koha 26.05 and 25.11.)

### Cataloging

#### Other bugs fixed

- [42701](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42701) Ability to click anywhere in item row for edit and delete options is missing

### Circulation

#### Other bugs fixed

- [41705](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=41705) Popup blockers may be triggered by options to automatically display payment receipt for printing after making a payments

  **Sponsored by** *OpenFifth*
- [42454](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42454) Terminology: Use "and" instead of "&" for curbside pickups "Staged & ready (0)" tab
  >This fixes the "Staged & ready (0)" tab for curbside pickups (Circulation > Holds and bookings > Curbside pickup) so that it uses "and" instead of "&" in the table title, as per the terminology guidelines (when CurbsidePickup is enabled).

### ERM

#### Other bugs fixed

- [42130](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42130) Holdings created in ERM with a linked bibliographic record does not index the record
  >This fixes indexing of records, so that when a new title is added in the ERM module (ERM > eHoldings > Local > Titles) and 'Create bibliographic record' is selected, the new record can be found when searching.

### Mana-kb

#### Other bugs fixed

- [42194](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42194) Sharing a report to Mana does not give feedback

### OPAC

#### Critical bugs fixed

- [42555](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42555) (Bug 25314 follow-up) ID incorrectly used for facet label for customized facets in the OPAC
  >This fixes the labels for facets in the OPAC. Customized facets generated from mappings.yaml were displayed with the technical type_id instead of the proper label.
  >
  >For example, for a facet defined as "su-gen" with a label of "Genre/Form", "su-gen" was used as the label instead of "Genre/Form".
  >
  >(This is related to Bug 25314 - Make OPAC facets collapse, added to Koha 26.05.00,25.11.04.)

#### Other bugs fixed

- [42193](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42193) The "Suspend hold" modal in the OPAC sometimes tries to resume hold

### Staff interface

#### Other bugs fixed

- [42084](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42084) Incorrect interface shown in log viewer for system preference changes
- [42133](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42133) Cataloguing plugins are broken on the batch item mod tool (again)

### Templates

#### Other bugs fixed

- [42154](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42154) Bug 38714 hid the "New match check" link in record matching rules

  **Sponsored by** *Athens County Public Libraries*
- [42441](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42441) Remove event attributes from authority merge template

  **Sponsored by** *Athens County Public Libraries*
- [42475](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42475) Terminology: OPAC is an abbreviation
  >Changes opac to OPAC for these system preference descriptions:
  >- NovelistSelectProfile
  >- item-level_itypes
  >- OpacSuppressionByIPRange

### Test Suite

#### Other bugs fixed

- [42733](https://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=42733) Tools/ManageMarcImport_spec.ts is failing (again)

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](https://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [English (USA)](https://koha-community.org/manual/25.11/en/html/)
- [French](https://koha-community.org/manual/25.11/fr/html/) (80%)
- [German](https://koha-community.org/manual/25.11/de/html/) (87%)
- [Greek](https://koha-community.org/manual/25.11/el/html/) (92%)
- [Hindi](https://koha-community.org/manual/25.11/hi/html/) (62%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (89%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Simplified Han script) (81%)
- Chinese (Traditional Han script) (94%)
- Czech (65%)
- Dutch (87%)
- English (100%)
- English (New Zealand) (60%)
- English (USA)
- Finnish (99%)
- French (100%)
- French (Canada) (96%)
- German (99%)
- Greek (64%)
- Hindi (92%)
- Italian (79%)
- Norwegian Bokmål (69%)
- Persian (fa_ARAB) (90%)
- Polish (99%)
- Portuguese (Brazil) (99%)
- Portuguese (Portugal) (88%)
- Russian (90%)
- Slovak (57%)
- Spanish (96%)
- Swedish (88%)
- Telugu (63%)
- Turkish (78%)
- Ukrainian (72%)
- Western Armenian (hyw_ARMN) (59%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](https://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](https://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](https://translate.koha-community.org/)

## Release Team

The release team for Koha 25.11.06 is


- Release Manager: Lucas Gass

- QA Manager: Martin Renvoize

- QA Team:
  - Andrew Fuerste-Henry
  - Andrii Nugged
  - Baptiste Wojtkowski
  - Brendan Lawlor
  - David Cook
  - Emily Lamancusa
  - Jonathan Druart
  - Julian Maurice
  - Kyle Hall
  - Laura Escamilla
  - Lisette Scheer
  - Marcel de Rooy
  - Nick Clemens
  - Paul Derscheid
  - Petro V
  - Tomás Cohen Arazi
  - Victor Grousset

- Documentation Manager: David Nind

- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Donna Bachowski
  - Heather Hernandez
  - Kristi Krueger
  - Philip Orr

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - George Williams
  - Thomas Dukleth

- Release Maintainers:
  - 25.11 -- Baptiste Wojtkowski
  - 25.05 -- Paul Derscheid
  - 24.11 -- Fridolin Somers
  - 24.05 -- Jesse Maseto
  - 22.11 -- Catalyst IT (Wainui, Alex, Aleisha)

- Release Maintainer assistants:
  - 25.05 -- Martin Renvoize
  - 24.05 -- Laura Escamilla

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 25.11.06
<div style="column-count: 2;">

- Athens County Public Libraries
- [OpenFifth](https://openfifth.co.uk)
</div>

We thank the following individuals who contributed patches to Koha 25.11.06
<div style="column-count: 2;">

- Pedro Amorim (2)
- David Cook (5)
- Jonathan Druart (8)
- Lucas Gass (3)
- Janusz Kaczmarek (1)
- Emily Lamancusa (1)
- Owen Leonard (4)
- Julian Maurice (1)
- David Nind (1)
- Eric Phetteplace (1)
- Martin Renvoize (5)
- Marcel de Rooy (1)
- Maryse Simard (1)
- Hammat Wele (1)
- Baptiste Wojtkowski (3)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 25.11.06
<div style="column-count: 2;">

- Athens County Public Libraries (4)
- [BibLibre](https://www.biblibre.com) (4)
- [ByWater Solutions](https://bywatersolutions.com) (3)
- David Nind (1)
- Independant Individuals (2)
- Koha Community Developers (8)
- [Montgomery County Public Libraries](https://montgomerycountymd.gov) (1)
- [OpenFifth](https://openfifth.co.uk) (7)
- [Prosentient Systems](https://www.prosentient.com.au) (5)
- Rijksmuseum, Netherlands (1)
- [Solutions inLibro inc](https://inlibro.com) (2)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Alex Carver [Acerock7] (1)
- Tomás Cohen Arazi (1)
- Emmanuel Bétemps (1)
- Nick Clemens (1)
- Roman Dolny (1)
- Jonathan Druart (9)
- Laura Escamilla (4)
- Andrew Fuerste-Henry (2)
- Lucas Gass (23)
- Barbara Johnson (1)
- Owen Leonard (3)
- David Nind (11)
- Sanjar Tulkinov Anvar o'g'li (6)
- Martin Renvoize (5)
- Phil Ringnalda (1)
- Marcel de Rooy (5)
- Emmi Takkinen (1)
- Baptiste Wojtkowski (25)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 25.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](https://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Jun 2026 11:52:40.
