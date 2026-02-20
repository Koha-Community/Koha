<template>
    <li :class="{ 'breadcrumb-item': isBreadcrumb }">
        <span>
            <router-link
                v-if="item.name && !item.disabled"
                :to="{ name: item.name, params }"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span v-if="item.title">{{ $__(item.title) }}</span>
            </router-link>
            <router-link
                v-else-if="item.path && !item.disabled"
                :to="item.path"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span v-if="item.title">{{ $__(item.title) }}</span>
            </router-link>
            <a v-else-if="item.href && !item.disabled" :href="item.href">
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span v-if="item.title">{{ $__(item.title) }}</span>
            </a>
            <a
                v-else
                href="#"
                aria-current="page"
                :class="{ disabled: item.disabled }"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span class="" v-if="item.title">{{ $__(item.title) }}</span>
            </a>
        </span>
        <ul v-if="item.children && item.children.length">
            <NavigationItem
                v-for="(child, key) in item.children"
                v-bind:key="key"
                :item="child"
                :isBreadcrumb="isBreadcrumb"
            ></NavigationItem>
        </ul>
    </li>
</template>

<script>
export default {
    name: "NavigationItem",
    props: {
        item: Object,
        params: Object,
        isBreadcrumb: {
            type: Boolean,
            default: false,
        },
    },
};
</script>

<style></style>
