[% IF ( biblio.title ) %]
    <span class="biblio-title">[% biblio.title | html %]</span>
[% ELSE %]
    No title
[% END %]
[% IF ( biblio.medium ) %]
    <span class="biblio-medium">[% biblio.medium | html %]</span>
[% END %]
[% FOREACH subtitle IN biblio.subtitle.split(' \\| ') %][% IF Koha.Preference('marcflavour')=='UNIMARC' %],[% END %]
    <span class="subtitle">[% subtitle | html %]</span>
[% END %]
[% IF ( biblio.part_number ) %]
    <span class="part-number">[% biblio.part_number | html %]</span>
[% END %]
[% IF ( biblio.part_name ) %]
    <span class="part-name">[% biblio.part_name | html %]</span>
[% END %]
