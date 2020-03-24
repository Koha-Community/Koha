function select_user(borrowernumber, borrower) {
    var suggested = '<input type="hidden" id="suggestedby" name="suggestedby" value="' + borrowernumber + '" />';
    suggested += '<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=' + borrowernumber + '">';
    suggested += borrower.surname + ', ' + borrower.firstname + ' (' + borrower.cardnumber + ')';
    suggested += '</a> ';
    suggested += borrower.branchname + ' (' + borrower.category_description + ')';
    $("#tdsuggestedby").html(suggested);
    return 0;
}

$(document).ready(function(){
    $('body').on('click', '#suggestor_search', function(e) {
        e.preventDefault();
        var newin = window.open('suggestor_search.pl','popup','width=600,height=400,resizable=no,toolbar=false,scrollbars=yes,top');
    });

});
