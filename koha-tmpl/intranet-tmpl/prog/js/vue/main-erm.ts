import {createApp} from 'vue'

import {library} from "@fortawesome/fontawesome-svg-core"
import {faPlus, faPencil, faTrash} from "@fortawesome/free-solid-svg-icons"
import {FontAwesomeIcon} from "@fortawesome/vue-fontawesome"

library.add(faPlus, faPencil, faTrash)

import App from './Agreements.vue'

createApp(App)
    .component("font-awesome-icon", FontAwesomeIcon)
    .mount('#agreements')
