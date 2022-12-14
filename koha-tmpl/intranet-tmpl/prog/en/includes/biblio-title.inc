[%- IF ( link ) -%]
    <a href="[%- PROCESS biblio_a_href biblionumber => biblio.biblionumber -%]" class="title">
[%- END -%]

[%- IF ( biblio.title ) -%]
    <span class="biblio-title">[%- biblio.title | html -%]</span>
[%- ELSE -%]
    <span>No title</span>
[%- END -%]
[%- IF ( biblio.medium ) -%]
    <span class="biblio-medium">[%- biblio.medium | html -%]</span>
[%- END -%]
[%- FOREACH subtitle IN biblio.subtitle.split(' \\| ') -%][%- IF Koha.Preference('marcflavour')=='UNIMARC' -%],[%- END -%]
    <span class="subtitle">[%- subtitle | html -%]</span>
[%- END -%]
[%- part_numbers = biblio.part_number.split(' \\| ') -%]
[%- part_names = biblio.part_name.split(' \\| ') -%]
[%- i = 0 -%]
[%- WHILE ( part_numbers.$i.defined || part_names.$i.defined ) -%]
    [%- IF ( part_numbers.$i.defined ) -%]
        <span class="part-number">[%- part_numbers.$i | html -%]</span>
    [%- END -%]
    [%- IF ( part_names.$i.defined ) -%]
        <span class="part-name">[%- part_names.$i | html -%]</span>
    [%- END -%]
    [%- i = i + 1 -%]
[%- END -%]

[%- IF ( link ) -%]
    </a>
[%- END -%]
