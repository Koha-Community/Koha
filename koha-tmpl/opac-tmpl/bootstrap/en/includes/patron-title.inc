[%- IF patron.category.category_type == 'I' -%]
    <span class="surname">[% patron.surname | html %]</span>[% IF patron.othernames %]<span class="othername">([% ' ' _ patron.othernames | html %])</span>[%- END -%]
[%- ELSE -%]
    [%- IF patron.title -%]
        [%- IF no_html -%]
            [% patron.title | html %]
        [%- ELSE -%]
            <span class="patron-title"></span>
        [%- END -%]
    [%- END -%]
    <span class="preferred_name">[% patron.preferred_name | html %]</span> <span class="middle_name">[% patron.middle_name | html %]</span> <span class="surname">[% patron.surname | html %] </span>
[%- END -%]
