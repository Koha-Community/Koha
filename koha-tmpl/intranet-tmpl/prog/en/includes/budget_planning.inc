[%- BLOCK planning -%]
  [%- SWITCH plan -%]
    [%- CASE 'MONTHS'    -%]<span>months</span>
    [%- CASE 'BRANCHES'  -%]<span>libraries</span>
    [%- CASE 'ITEMTYPES' -%]<span>item types</span>
  [%- END -%]
[%- END -%]
