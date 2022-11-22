if (KOHA === undefined || !KOHA) { var KOHA = {}; }


/**
 * A namespace for Coce cover images cache
 */
KOHA.coce = {

    /**
     * Search all:
     *    <div title="biblionumber" id="isbn" class="coce-thumbnail"></div>
     * or
     *    <div title="biblionumber" id="isbn" class="coce-thumbnail-preview"></div>
     * and run a search with all collected isbns to coce cover service.
     * The result is asynchronously returned, and used to append <img>.
     */
    getURL: function(host, provider) {
        var ids = [];
        $("[id^=coce-thumbnail]").each(function() {
            var id = $(this).attr("class"); // id=isbn
            if (id !== '') { ids.push(id); }
        });
        if (ids.length == 0) { this.done = 1; return; }
        ids = ids.join(',');
        var coceURL = host + '/cover?id=' + ids + '&provider=' + provider;
        $.ajax({
            url: coceURL,
            dataType: 'jsonp',
            success: function(urlPerID) {
                for (var id in urlPerID) {
                    var url = urlPerID[id];
                    $("[id^=coce-thumbnail]." + id).each(function() {
                        var img = document.createElement("img");
                        img.src = url;
                        img.alt = "Cover image";
                        img.onload = function() {
                            // image dimensions can't be known until image has loaded
                            if (img.height == 1 && img.width == 1) {
                                $(this).closest(".coce-coverimg").remove();
                            }
                        };
                        $(this).attr('href', url);
                        $(this).append(img);
                    });
                }
            },
        }).then(function(){
            // Cannot access 'this' from here
            KOHA.coce.done = 1;
        });
    }

};
