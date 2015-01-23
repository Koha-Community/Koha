[%- IF patron.category.category_type == 'I' -%]
    [% patron.surname | html %][% IF patron.othernames %] ([% patron.othernames | html %]) [%- END -%]
[%- ELSE -%]
    [%- IF patron.title -%]
        <span class="patron-title">[% patron.title | html %]</span>
    [%- END -%]
    [% patron.firstname | html %] [% patron.surname | html %]
[%- END -%]
