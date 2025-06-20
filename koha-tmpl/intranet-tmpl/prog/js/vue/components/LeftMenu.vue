<template>
    <aside v-if="navigationTree !== 'none'">
        <VendorMenu v-if="navigationTree === 'VendorMenu'" />
        <AcquisitionsMenu v-else-if="navigationTree === 'AcquisitionsMenu'" />
        <div v-else class="sidebar_menu">
            <h5>{{ $__(title) }}</h5>
            <ul>
                <NavigationItem
                    v-for="(item, key) in navigationTree"
                    v-bind:key="key"
                    :item="item"
                ></NavigationItem>
            </ul>
        </div>
        <!-- /.sidebar_menu -->
    </aside>
</template>

<script>
import { computed, inject, onBeforeMount } from "vue";
import NavigationItem from "./NavigationItem.vue";
import VendorMenu from "./Islands/VendorMenu.vue";
import AcquisitionsMenu from "./Islands/AcquisitionsMenu.vue";
import { storeToRefs } from "pinia";

export default {
    name: "LeftMenu",
    setup(props) {
        const navigationStore = inject("navigationStore");
        const { leftNavigation } = storeToRefs(navigationStore);

        const navigationTree = computed(() => {
            if (props.condition) return props.condition(leftNavigation.value);
            return leftNavigation.value;
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
