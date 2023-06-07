/* getAuthValueDropbox from js/acq.js is needed */
$(document).ready(function() {
    // keep copy of the inactive budgets
    disabledAllBudgetsCopy = $("select[name='all_budget_id']").html();
    disabledBudgetsCopy = $("select[name='budget_id']").first().html();
    $("select[name='all_budget_id'] .b_inactive").remove();
    $("select[name='budget_id'] .b_inactive").remove();

    $("#showallbudgets").click(function() {
        if ($(this).is(":checked")) {
            $("select[name='budget_id']").html(disabledBudgetsCopy)
        }
        else {
            $("select[name='budget_id'] .b_inactive").remove();
        }
    });

    $("#all_showallbudgets").click(function() {
        if ($(this).is(":checked")) {
            $("select[name='all_budget_id']").html(disabledAllBudgetsCopy);
        }
        else {
            $("select[name='all_budget_id'] .b_inactive").remove();
        }
    });

    $("select[name='budget_id']").change(function(){
        var sort1_authcat = $(this).find("option:selected").attr('data-sort1-authcat');
        var sort2_authcat = $(this).find("option:selected").attr('data-sort2-authcat');
        var destination_sort1 = $(this).parents('fieldset').find('li.sort1').find('input[name="sort1"]');
        var sort1 = $(destination_sort1).val() || "";
        if ( destination_sort1.length < 1 ) {
            destination_sort1 = $(this).parents('fieldset').find('li.sort1 > select[name="sort1"]');
        }
        var destination_sort2 = $(this).parents('fieldset').find('li.sort2').find('input[name="sort2"]');
        var sort2 = $(destination_sort2).val() || "";
        if ( destination_sort2.length < 1 ) {
            destination_sort2 = $(this).parents('fieldset').find('li.sort2').find('select[name="sort2"]');
        }
        getAuthValueDropbox( 'sort1', sort1_authcat, destination_sort1, sort1 );

        getAuthValueDropbox( 'sort2', sort2_authcat, destination_sort2, sort2 );
    } );

    $("select[name='budget_id']").change();

    $("select[name='all_budget_id']").change(function(){
        var sort1_authcat = $(this).find("option:selected").attr('data-sort1-authcat');
        var sort2_authcat = $(this).find("option:selected").attr('data-sort2-authcat');
        var destination_sort1 = $(this).parent().siblings('li').find('input[name="all_sort1"]');
        if ( destination_sort1.length < 1 ) {
            destination_sort1 = $(this).parent().siblings('li').find('select[name="all_sort1"]');
        }
        var destination_sort2 = $(this).parent().siblings('li').find('input[name="all_sort2"]');
        if ( destination_sort2.length < 1 ) {
            destination_sort2 = $(this).parent().siblings('li').find('select[name="all_sort2"]');
        }
        getAuthValueDropbox( 'sort1', sort1_authcat, destination_sort1 );
        getAuthValueDropbox( 'sort2', sort2_authcat, destination_sort2 );
        $(this).parent().siblings('li').find('select[name="sort1"]').attr('name', 'all_sort1');
        $(this).parent().siblings('li').find('input[name="sort1"]').attr('name', 'all_sort1');
        $(this).parent().siblings('li').find('select[name="sort2"]').attr('name', 'all_sort2');
        $(this).parent().siblings('li').find('input[name="sort2"]').attr('name', 'all_sort2');
    } );

    $("select[name='all_budget_id']").change();

});
