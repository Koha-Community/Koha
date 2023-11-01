use Modern::Perl;

return {
    bug_number  => "21159",
    description => "Add new system preference UpdateItemLocationOnCheckout",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('UpdateItemLocationOnCheckout', '', 'NULL', 'This is a list of value pairs.\n Examples:\n\nPROC: FIC - causes an item in the Processing Center location to be updated into the Fiction location on check out.\nFIC: GEN - causes an item in the Fiction location to be updated into the General stacks location on check out.\n_BLANK_:FIC - causes an item that has no location to be updated into the Fiction location on check out.\nFIC: _BLANK_ - causes an item in location FIC to be updated to a blank location on check out.\n_ALL_:FIC - causes all items to be updated into the Fiction location on check out.\nPROC: _PERM_ - causes an item that is in the Processing Center to be updated to it''s permanent location.\n\nGeneral rule: if the location value on the left matches the item''s current location, it will be updated to match the location value on the right.\nNote: PROC and CART are special values, for these locations only can location and permanent_location differ, in all other cases an update will affect both. Items in the CART location will be returned to their permanent location on checkout.\n\nThe special term _BLANK_ may be used on either side of a value pair to update or remove the location from items with no location assigned.\nThe special term _ALL_ is used on the left side of the colon (:) to affect all items.\nThe special term _PERM_ is used on the right side of the colon (:) to return items to their permanent location.', 'Free') }
        );
        say $out "Added new system preference 'UpdateItemLocationOnCheckout'";
    },
};
