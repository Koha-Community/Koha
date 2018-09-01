'use strict'

const hetula_url          = $("input[name=hetula_url]").val()
const hetula_organization = $("input[name=hetula_organization]").val()

let hetula
let activeSession = false

const ssnkey_container = $("input[value=SSN]").siblings("textarea")
const notification_container = $("#ssn_notifier")

const hetulaSuccessHandler = (msg) => {
  $(notification_container).text(msg)
  .css("background-image","linear-gradient(#d7e5d7, #bcdbbc)")
  .css("border","#0003 1px solid")
  .addClass('dialog alert')
}
const hetulaErrorHandler = (msg, error) => {
  console.log(error && error.response ? error.response : error)
  $(notification_container).text(msg)
  .css("background-image","linear-gradient(#f8b379, #d89b9b)")
  .css("border","#0003 1px solid")
  .addClass('dialog alert')
}
const errorPayload = (error) => error && error.response ? error.response.data : ''

/**
 * Turns the short Hetula-integer into something which can be used internally more easily.
 * @param {Integer} Hetula SSN-id to normalize
 * @returns {String} The normalized key which can be searched and sorted
 */
const transformSSNKey = (id) => {
  const desiredSSNKeyLength = 12
  const idLength = Math.floor(Math.log10(id))+1;
  if (idLength >= desiredSSNKeyLength && id.toString().includes("ssn")) {
    return id //id is already properly formatted and long enough
  }
  const paddingNeeded = desiredSSNKeyLength - idLength
  let ssnKey = "ssn"
  while (ssnKey.length < paddingNeeded) {
    ssnKey += "0"
  }
  ssnKey += id
  return ssnKey
}

if (! hetula_url) {
  console.log("No hetula_url defined. It must be defined in the KOHA_CONF if you want to use Hetula")
}
else if (! hetula_organization) {
  console.log("No hetula_organization defined. It must be defined in the KOHA_CONF if you want to use Hetula")
}
else {
  hetula = new Hetula(hetula_url)

  hetula.loggedIn()
  .then((response) => activeSession = true)
  .catch((error) => {
    //Hetula responds with 404 when nothin is found, but passes a textual error object in data.
    //Typical 404s' don't pass data.
    if (error && error.response && error.response.status === 404 && error.response.data) {
      return //No active login found
    }
    hetulaErrorHandler("Aktiivisen kirjautumisen tarkastus epäonnistui? "+error+". Lisätietoa konsolissa", error)
  })

  $("input[id=ssn_submit]").click(function( event ) {
    //var ssn_username = $(".loggedinusername").html().trim()
    var ssn_username = $("input[name=ssn_username]").val()
    var ssn_password = $("input[name=ssn_password]").val()
    var ssn_value =    $("input[name=ssn_ssn]").val()

    hetula.login(ssn_username, ssn_password, hetula_organization)
    .then((response) => {

      hetula.ssnAdd(ssn_value)
      .then((response) => {
        const ssnKey = transformSSNKey(response.data.id)
        $(ssnkey_container).val( ssnKey )
        hetulaSuccessHandler("Hetu '"+ssnKey+"' lisätty")
      })
      .catch((error) => {
        if (error && error.response && error.response.status === 409 && error.response.data.id) {
          const ssnKey = transformSSNKey(error.response.data.id)
          $(ssnkey_container).val( ssnKey )
          hetulaErrorHandler("Hetu '"+ssnKey+"' on jo olemassa", '')
          return
        }
        hetulaErrorHandler("Hetun lisääminen epäonnistui: "+errorPayload(error)+". Lisätietoa konsolissa", error)
      })
    })
    .catch((error) => hetulaErrorHandler("Tunnistautuminen epäonnistui: "+errorPayload(error), error))
  })
}

