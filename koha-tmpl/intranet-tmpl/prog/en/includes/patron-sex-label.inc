[%# The variable sex must be passed, containing a patron's gender code (F, M, O, or blank) -%]
[%- IF sex == 'F' -%]
    Female
[%- ELSIF sex == 'M' -%]
    Male
[%- ELSIF sex == 'O' -%]
    [% tp('gender', 'Other') | html %]
[%- END -%]
