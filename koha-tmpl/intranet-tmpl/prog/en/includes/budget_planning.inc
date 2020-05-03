[%- BLOCK planning -%]
  [%- SWITCH plan -%]
    [%- CASE 'MONTHS'    -%]<span>by months</span>
    [%- CASE 'BRANCHES'  -%]<span>by libraries</span>
    [%- CASE 'ITEMTYPES' -%]<span>by item types</span>
  [%- END -%]
[%- END -%]
