[% USE KohaAuthorisedValues %]

[% IF ( item.damaged or item.datedue or item.itemlost or item.transfertwhen or item.waiting ) %]
    <link property="availability" href="http://schema.org/OutOfStock" />
[% ELSIF ( item.wthdrawn ) %]
    <link property="availability" href="http://schema.org/Discontinued" />
[% ELSIF ( item.itemnotforloan or item.notforloan_per_itemtype ) %]
    <link property="availability" href="http://schema.org/InStoreOnly" />
[% ELSE %]
    <link property="availability" href="http://schema.org/InStock" />
[% END %]
