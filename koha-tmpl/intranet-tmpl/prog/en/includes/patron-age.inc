[%- USE KohaDates -%]
[%- IF ( patron ) -%]
    [%- IF ( patron.dateofbirth ) -%]
        [% patron.dateofbirth | $KohaDates -%]
        [%- IF ( patron.get_age ) %] ([% patron.get_age | html %])
        [%- ELSIF ( patron.age ) %] ([% patron.age | html %])[% END -%]
   [%- END -%]
[%- END -%]
