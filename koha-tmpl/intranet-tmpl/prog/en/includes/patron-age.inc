[%- USE KohaDates -%]
[%- IF ( patron ) -%]
    [%- IF ( patron.dateofbirth ) -%]
        [% patron.dateofbirth | $KohaDates -%]
        [%- IF ( patron.get_age ) %] ([% patron.get_age | html %] years)
        [%- ELSIF ( patron.age ) %] ([% patron.age | html %] years)[% END -%]
   [%- END -%]
[%- END -%]
