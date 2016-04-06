describe("RadialMenu", function() {
  var radialMenu;
  var testClosure = 0;

  beforeAll(function() {
    var html = $('<div id="radialMenuTest"></div>');
    $('body').append(html);
  });

  it("Instantiate", function () {
    radialMenu = new RadialMenu($("#radialMenuTest"), [
                            {   class: "fa fa-trash-o fa-2x",
                                title: "DELETE",
                                events: {   click: function (event) { testClosure += 1; }    }
                            },
                            {   class: "fa fa-sign-in fa-2x",
                                title: "OPEN IN HOME",
                                href: 'http::/home.example.com',
                                target: '_blank'
                            },
                    ]);
    expect( radialMenu instanceof RadialMenu ).toBe(true);
  });
  it("Callback handler clickable", function () {
    radialMenu.container.find('.fa.fa-trash-o.fa-2x').click();
    radialMenu.container.find('.fa.fa-trash-o.fa-2x').click();
    expect( testClosure ).toEqual(2);
  });
  it("Link deployed", function () {
    expect( radialMenu.container.find('.fa.fa-sign-in.fa-2x').attr('href') ).toEqual('http::/home.example.com');
  });

  afterAll(function() {
    $("#radialMenuTest").remove();
  });
});
