[%- USE KohaDates -%]
[%- USE I18N -%]
[%- IF ( patron ) -%]
    [%- IF ( patron.dateofbirth ) -%]
        [%- patron.dateofbirth | $KohaDates %]
        [%- SET age = (patron.get_age != undef) ? patron.get_age : patron.age -%]
        <span class='age_years'>[% I18N.tnx('({age} year)', '({age} years)', age, { age => age }) | html %]</span>
   [%- END -%]
[%- END -%]
