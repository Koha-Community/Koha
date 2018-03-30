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
  getURL: function(host,provider,newWindow) {
    var ids = [];
    $("[id^=coce-thumbnail]").each(function(i) {
        var id = $(this).attr("class"); // id=isbn
        if ( id !== '' ) { ids.push(id); }
    });
    if (ids.length == 0) return;
    ids = ids.join(',');
    var coceURL = host + '/cover?id=' + ids + '&provider=' + provider;
    $.ajax({
      url: coceURL,
      dataType: 'jsonp',
      success: function(urlPerID){
        for (var id in urlPerID) {
          var url = urlPerID[id];
          $("[id^=coce-thumbnail]."+id).each(function() {
            var img = document.createElement("img");
            img.src = url;
            img.title = url; //FIXME: to delete
            $(this).html(img);
         });
        }
      }
    });
  }

};
