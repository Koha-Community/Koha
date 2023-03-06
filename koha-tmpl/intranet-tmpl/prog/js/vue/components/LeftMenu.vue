<template>
    <aside>
        <div id="navmenu">
            <div id="navmenulist">
                <h5>{{ $__(title) }}</h5>
                <ul>
                    <NavigationItem
                        v-for="(item, key) in navigationTree"
                        v-bind:key="key"
                        :item="item"
                    ></NavigationItem>
                </ul>
            </div>
        </div>
    </aside>
</template>

<script>
import { inject } from "vue"
import NavigationItem from "./NavigationItem.vue"
export default {
    name: "LeftMenu",
    data() {
        return {
            navigationTree: this.leftNavigation,
        }
    },
    setup: () => {
        const navigationStore = inject("navigationStore")
        const { leftNavigation } = navigationStore
        return {
            leftNavigation,
        }
    },
    async beforeMount() {
        if (this.condition)
            this.navigationTree = await this.condition(this.navigationTree)
    },
    props: {
        title: String,
        condition: Function,
    },
    components: {
        NavigationItem,
    },
}
</script>

<style scoped>
#navmenulist a.router-link-active {
    font-weight: 700;
}
#menu ul ul,
#navmenulist ul ul {
    padding-left: 2em;
    font-size: 100%;
}

#navmenulist ul li a.disabled {
    color: #666;
    pointer-events: none;
    font-weight: 700;
}
#navmenulist ul li a.disabled.router-link-active {
    color: #000;
}
</style>
