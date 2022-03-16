import {createApp} from 'vue'
import BootstrapVue3 from 'bootstrap-vue-3'

//import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue-3/dist/bootstrap-vue-3.css'

import {library} from "@fortawesome/fontawesome-svg-core"
import {faPlus, faPencil, faTrash} from "@fortawesome/free-solid-svg-icons"
import {FontAwesomeIcon} from "@fortawesome/vue-fontawesome"

library.add(faPlus, faPencil, faTrash)

import App from './Agreements.vue'

createApp(App)
    .component("font-awesome-icon", FontAwesomeIcon)
    .use(BootstrapVue3)
    .mount('#agreements')
