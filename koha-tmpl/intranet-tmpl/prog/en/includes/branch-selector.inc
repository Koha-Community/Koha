[%# First check to see if we have anything selected, otherwise we select all %]
[% selectall = 1 %]
[% FOREACH branch IN branches;
    IF branch.selected;
        selectall = 0;
    END;
END %]
<div class="branchselector">
    <p><a href="#" id="checkall"> <i class="fa fa-check"></i> Select all</a> | <a href="#" id="checknone"> <i class="fa fa-remove"></i> Clear all</a></p>
    <div class="branchgridrow">
    [% FOREACH branch IN branches %]
        <div class="branchgriditem">
            [% IF branch.selected || (selectall == 1) %]
                <input id="branch_[% branch.value %]" class="branch_select" type="checkbox" name="branch" value="[% branch.value %]" checked="checked" />
            [% ELSE %]
                <input id="branch_[% branch.value %]" class="branch_select" type="checkbox" name="branch" value="[% branch.value %]" />
            [% END %]

            <label for="branch_[% branch.value %]">[% branch.branchname %]</label>
        </div>
        [% IF loop.count() % 4 == 0 && !loop.last() %]
            </div>
            <div class="branchgridrow">
        [% END %]
    [% END %]
    </div>
</div>
