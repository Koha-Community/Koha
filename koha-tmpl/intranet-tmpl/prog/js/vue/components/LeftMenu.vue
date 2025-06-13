<template>
    <aside v-if="leftNavigation !== 'none'">
        <VendorMenu v-if="leftNavigation === 'VendorMenu'" />
        <AcquisitionsMenu v-else-if="leftNavigation === 'AcquisitionsMenu'" />
        <div v-else class="sidebar_menu">
            <h5>{{ $__(title) }}</h5>
            <ul>
                <NavigationItem
                    v-for="(item, key) in leftNavigation"
                    v-bind:key="key"
                    :item="item"
                ></NavigationItem>
            </ul>
        </div>
        <!-- /.sidebar_menu -->
    </aside>
</template>

<script>
import { inject, onBeforeMount, ref } from "vue";
import NavigationItem from "./NavigationItem.vue";
import VendorMenu from "./Islands/VendorMenu.vue";
import AcquisitionsMenu from "./Islands/AcquisitionsMenu.vue";

export default {
    name: "LeftMenu",
    setup(props) {
        const navigationStore = inject("navigationStore");
        const { leftNavigation } = navigationStore;

        const navigationTree = ref(leftNavigation);
        onBeforeMount(async () => {
            if (props.condition)
                navigationTree.value = await props.condition(
                    navigationTree.value
                );
        });
        return {
            leftNavigation,
            navigationTree,
        };
    },
    props: {
        title: String,
        condition: Function,
    },
    components: {
        NavigationItem,
        VendorMenu,
        AcquisitionsMenu,
    },
};
</script>

<style scoped>
.sidebar_menu a.router-link-active {
    font-weight: 700;
}
#menu ul ul,
.sidebar_menu ul ul {
    padding-left: 2em;
    font-size: 100%;
}

.sidebar_menu ul li a.disabled {
    color: #666;
    pointer-events: none;
    font-weight: 700;
}
.sidebar_menu ul li a.disabled.router-link-active {
    color: #000;
}
</style>
