<div class="results_summary ratings" id="rating-[% item.itemnumber | html %]">

    [% SET rating_avg = item.ratings.get_avg_rating() %]
    [% rating_avg_int = BLOCK %][% rating_avg | format("%.0f") %][% END %]

    <div class="br-wrapper br-theme-fontawesome-stars js-hide">
        <div class="br-widget br-readonly">
            [% FOREACH i IN [ 1 2 3 4 5  ] %]
                [% IF rating_avg_int == i %]
                    <a href="#" class="br-selected br-current"></a>
                [% ELSIF rating_avg_int > i %]
                    <a href="#" class="br-selected"></a>
                [% ELSE %]
                    <a href="#"></a>
                [% END %]
            [% END %]
        </div>
    </div>

    <select class="star_rating" id="star_rating-[% item.itemnumber | html %]" name="rating" autocomplete="off" data-biblionumber="[% item.biblionumber | html %]" data-context="rating-[% item.itemnumber | html %]">

        [% IF ( rating_avg_int == 0 ) %]
            <option value="" selected="selected"></option>
        [% END %]
        [% FOREACH i IN [ 1 2 3 4 5  ] %]
            [% IF rating_avg_int == i %]
                <option value="[% i | html %]" selected="selected">[% i | html %]</option>
            [% ELSE %]
                <option value="[% i | html %]">[% i | html %]</option>
            [% END %]
        [% END %]
    </select>
    <img id="rating-loading" style="display:none" src="[% interface | html %]/[% theme | html %]/images/spinner-small.gif" alt="" />

    <!-- define some hidden vars for ratings -->

    <input type="hidden" name="biblionumber" value="[% item.biblionumber | html %]" />
    <input type="hidden" name="rating_value" class="rating_value" value="[% item.my_rating.rating_value | html %]" />

    <input name="rate_button" type="submit" class="js-show" value="Rate me" />

    [% IF item.my_rating %]
        <div>
            <span class="rating_value_text">Your rating: [% item.my_rating.rating_value | html %].</span>
            <span class="cancel_rating_text js-show"><a href="#" data-context="star_rating-[% item.itemnumber | html %]"><i class="fa fa-times" aria-hidden="true"></i> Cancel rating</a>.</span>
        </div>
    [% ELSE %]
        <span class="rating_value_text"></span>
        <span class="cancel_rating_text" style="display:none;"><a href="#" data-context="star_rating-[% item.itemnumber | html %]"><i class="fa fa-times" aria-hidden="true"></i> Cancel rating</a>.</span>
    [% END %]

    <div class="rating_text">Average rating: [% rating_avg | html %] ([% item.ratings.count | html %] votes)</div>
</div>
