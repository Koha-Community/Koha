[% IF ( context == "authval" ) %]
    [% SET image_location = av.imageurl %]
[% ELSE %]
    [% SET image_location = itemtype.image_location("intranet") %]
[% END %]

[% WRAPPER tabs id= "icons" %]
    <h5>Choose an icon:</h5>
    [% WRAPPER tabs_nav %]
        [% WRAPPER tab_item tabname="none" %]
            <span>None</span>
        [% END %]
        [% FOREACH imageset IN imagesets %]
            [% IF ( imageset.imagesetactive ) %]
                [% SET bt_active = 1 %]
            [% ELSE %]
                [% SET bt_active = 0 %]
            [% END %]
            [% WRAPPER tab_item tabname= imageset.imagesetname bt_active= bt_active %] [% imageset.imagesetname | html %] [% END %]
        [% END %]
        [% IF image_location.match('^http') %]
            [% SET bt_active = 1 %]
        [% ELSE %]
            [% SET bt_active = 0 %]
        [% END %]
        [% WRAPPER tab_item tabname= "remote" bt_active= bt_active %] <span>Remote image</span> [% END %]
    [% END %]

    [% WRAPPER tab_panels %]
        [% WRAPPER tab_panel tabname="none" bt_active= 0 %]
            <div class="[% context | html %]-icons">
                <label for="noimage">No image:
                    <input type="radio" name="image" id="noimage" value="removeImage" />
                </label>
            </div> <!-- /.[% context | html %]-icons -->
        [% END %]

        [% FOREACH imageset IN imagesets %]
            [% IF ( imageset.imagesetactive ) %]
                [% SET bt_active = 1 %]
            [% ELSE %]
                [% SET bt_active = 0 %]
            [% END %]
            [% WRAPPER tab_panel tabname=imageset.imagesetname bt_active= bt_active %]
                <div class="[% context | html %]-icons">
                    [% FOREACH image IN imageset.images %]
                        <label>
                            [% IF image.StaffImageUrl %]
                                <img src="[% image.StaffImageUrl | html %]" alt="[% image.StaffImageUrl | html %]" title="[% image.StaffImageUrl | html %]" />
                            [% END %]
                            [% IF image.checked %]
                                <input type="radio" name="image" value="[% image.KohaImage | html %]" checked="checked" />
                            [% ELSIF image.KohaImage %] <!-- to delete the radio button if there is no image after -->
                                <input type="radio" name="image" value="[% image.KohaImage | html %]" />
                            [% END %]
                        </label>
                    [% END #/ FOREACH image %]
                </div> <!-- /.[% context | html %]-icons -->
            [% END # /tab_panel %]
        [% END # /FOREACH imageset %]

        [% IF image_location.match('^http') %]
            [% SET bt_active = 1 %]
        [% ELSE %]
            [% SET bt_active = 0 %]
        [% END %]
        [% WRAPPER tab_panel tabname="remote" %]
            <label for="remote_image_check"> Remote image:</label>
            [% IF image_location.match('^http') %]
                <input type="radio" id="remote_image_check" name="image" value="remoteImage" checked="checked" />
                <input type="text" name="remoteImage" size="48" maxlength="200" value="[% image_location | html %]" onmousedown="document.getElementById('remote_image_check').checked = true;" />
                <img src="[% image_location | html %]" alt="" />
            [% ELSE %]
                <input type="radio" id="remote_image_check" name="image" value="remoteImage" />
                <input type="text" name="remoteImage" size="48" maxlength="200" value="" onmousedown="document.getElementById('remote_image_check').checked = true;" />
            [% END %]
        [% END %]
    [% END # /tab_panels %]
[% END # /tabs#icons %]
