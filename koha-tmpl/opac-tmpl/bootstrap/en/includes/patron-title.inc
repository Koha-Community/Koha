[%- IF patron.category.category_type == 'I' -%]
    [% patron.surname %][% IF patron.othernames %] ([% patron.othernames %]) [%- END -%]
[%- ELSE -%]
    [%- IF patron.title -%]
        <span class="patron-title">[% patron.title %]</span>
    [%- END -%]
    [% patron.firstname %] [% patron.surname %]
[%- END -%]
