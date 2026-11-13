<template>
    <li :class="{ 'breadcrumb-item': isBreadcrumb }">
        <span>
            <a
                v-if="item.is_external && item.path && !item.disabled"
                :href="item.path"
                :title="item.title ? $__(item.title) : null"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span class="menu-label" v-if="item.title">{{
                    $__(item.title)
                }}</span>
                <template v-if="item.is_external">
                    &nbsp;<i
                        class="fa fa-external-link"
                        aria-hidden="true"
                        style="font-size: 0.8em; opacity: 0.7"
                    ></i>
                </template>
            </a>
            <router-link
                v-else-if="item.name && !item.disabled"
                :to="{ name: item.name, params: item.is_base ? {} : params }"
                :title="item.title ? $__(item.title) : null"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span class="menu-label" v-if="item.title">{{
                    $__(item.title)
                }}</span>
            </router-link>
            <router-link
                v-else-if="item.path && !item.disabled"
                :to="item.path"
                :title="item.title ? $__(item.title) : null"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span class="menu-label" v-if="item.title">{{
                    $__(item.title)
                }}</span>
            </router-link>
            <a
                v-else-if="item.href && !item.disabled"
                :href="item.href"
                :title="item.title ? $__(item.title) : null"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span class="menu-label" v-if="item.title">{{
                    $__(item.title)
                }}</span>
            </a>
            <a
                v-else
                href="#"
                aria-current="page"
                :class="{ disabled: item.disabled }"
                :title="item.title ? $__(item.title) : null"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span class="menu-label" v-if="item.title">{{
                    $__(item.title)
                }}</span>
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
