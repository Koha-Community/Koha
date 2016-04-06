describe("Catalogue.RecordPusher environment set", function() {
  it("Display element container", function () {
    expect( $("#saveDropdownContainer .dropdown-menu").length ).toEqual(1);
  });
  it("Operations menu container", function () {
    expect( $("#catalogue_detail_biblio").length ).toEqual(1);
  });
  it("Remote APIs loaded", function () {
    expect( remoteAPIs ).toBeDefined();
  });
  it("Biblio loaded", function () {
    expect( biblio.biblionumber ).toBeGreaterThan(0);
  });
  it("Remote API 'Test Remote' is legit", function () {
    var expectedTestRemote = {
      name     : "Test Remote",
      id       : "test_remote",
      host     : "http://testcluster.koha-suomi.fi:7653",
      basePath : "api/v1",
      authentication : "cookies",
      api      : "Koha-Suomi"
    };
    expect( remoteAPIs["test_remote"] ).toEqual( expectedTestRemote );
  });
});

var recordPusher;
describe("Catalogue.RecordPusher instantiate", function() {

  it("RecordPusher instantiated", function () {
    recordPusher = new Cataloguing.RecordPusher("#saveDropdownContainer .dropdown-menu", "dropdown-menu-list", "body", remoteAPIs, biblio);
    expect(recordPusher instanceof Cataloguing.RecordPusher).toBe(true);
  });
  it("Push targets listed", function () {
    expect($("a[id^='pushTarget_']").length).toEqual(2); //Push targets listed
    expect($("#pushTarget_test_remote").html()).toMatch(/Test Remote/);
    expect($("#pushTarget_test_stub").html()).toMatch(/Test Stub/);
  });
  it("Operations menu not created yet", function () {
    expect($("#pushRecordOpMenu").length).toEqual(0); //Push operations menu created
  });
});

describe("Catalogue.RecordPusher perform actions", function() {

  var oldWindowConfirm = window.confirm;
  var oldAPIfuncs = [];
  beforeAll(function() {
    //Overload the default confirmation behaviour with always return true
    window.confirm = function() {return 1;};

    //Mock API-calls
    spyOn(RemoteAPIs.Driver.KohaSuomi, 'records_get').and.callFake( RemoteAPIs.Driver.KohaSuomi.mock_records_get );
    spyOn(RemoteAPIs.Driver.KohaSuomi, 'records_add').and.callFake( RemoteAPIs.Driver.KohaSuomi.mock_records_get );
    spyOn(RemoteAPIs.Driver.KohaSuomi, 'records_delete').and.callFake( RemoteAPIs.Driver.KohaSuomi.mock_records_delete );
    //oldAPIfuncs[0] = RemoteAPIs.Driver.KohaSuomi.records_get;
    //oldAPIfuncs[1] = RemoteAPIs.Driver.KohaSuomi.records_add;
    //RemoteAPIs.Driver.KohaSuomi.records_get = RemoteAPIs.Driver.KohaSuomi.mock_records_get;
    //RemoteAPIs.Driver.KohaSuomi.records_add = RemoteAPIs.Driver.KohaSuomi.mock_records_get;
  });

  it("Push to 'Test Remote'", function () {
    $("#pushTarget_test_remote").click(); //Dispatch the push operation to the API
    expect(RemoteAPIs.Driver.KohaSuomi.records_get).toHaveBeenCalledTimes(1);
    expect(RemoteAPIs.Driver.KohaSuomi.records_add).toHaveBeenCalledTimes(1);
  });

  it("Hateoas links consumed", function () {
    expect($("#pushRecordOpMenu a[data-verb='DELETE']").length).toEqual(1);
    expect($("#pushRecordOpMenu a[data-verb='GET']").length).toEqual(1);
  });

  it("DELETE what was just pushed", function () {
    $("#pushRecordOpMenu a[data-verb='DELETE']").click(); //Dispatch the DELETE
    expect($("#pushRecordOpMenu a[data-verb='DELETE']").length).toEqual(0); //After a successfull deletion, the delete button is removed
    expect(RemoteAPIs.Driver.KohaSuomi.records_delete).toHaveBeenCalledTimes(1);
  });

  afterAll(function() {
    window.confirm = oldWindowConfirm; //Revert overloading
    //RemoteAPIs.Driver.KohaSuomi.records_get = oldAPIfuncs[0];
    //RemoteAPIs.Driver.KohaSuomi.records_add = oldAPIfuncs[1];
  });
});
