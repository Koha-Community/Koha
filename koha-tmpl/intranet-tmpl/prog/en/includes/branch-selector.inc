[%# First check to see if we have anything selected, otherwise we select all %]
[% selectall = 1 %]
[% FOREACH branch IN branches;
    IF branch.selected;
        selectall = 0;
    END;
END %]
<div class="branchselector">
    <div class="branchgridrow">
    [% FOREACH branch IN branches %]
        <div class="branchgriditem">
            <input id="branch_[% branch.value %]" type="checkbox" name="branch" value="[% branch.value %]"[% IF branch.selected || (selectall == 1) %] checked="checked" [% END %]/>
            <label for="branch_[% branch.value %]">[% branch.branchname %]</label>
        </div>
        [% IF loop.count() % 4 == 0 && !loop.last() %]
            </div>
            <div class="branchgridrow">
        [% END %]
    [% END %]
    </div>
</div>
