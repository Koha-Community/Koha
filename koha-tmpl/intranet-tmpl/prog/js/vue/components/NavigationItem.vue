<template>
    <li>
        <span>
            <router-link
                v-if="item.name"
                :to="{ name: item.name, params }"
                :class="{ disabled: item.disabled }"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span v-if="item.title">{{ $__(item.title) }}</span>
            </router-link>
            <router-link
                v-else-if="item.path"
                :to="item.path"
                :class="{ disabled: item.disabled }"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span v-if="item.title">{{ $__(item.title) }}</span>
            </router-link>
            <a
                v-else-if="item.href"
                :href="item.href"
                :class="{ disabled: item.disabled }"
            >
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span v-if="item.title">{{ $__(item.title) }}</span>
            </a>
            <span v-else :class="{ disabled: item.disabled }">
                <template v-if="item.icon">
                    <i :class="`${item.icon}`"></i>&nbsp;
                </template>
                <span class="item-last" v-if="item.title">{{
                    $__(item.title)
                }}</span>
            </span>
        </span>
        <ul v-if="item.children && item.children.length">
            <NavigationItem
                v-for="(item, key) in item.children"
                :item="item"
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
    },
}
</script>

<style>
span.item-last {
    padding: 7px 3px;
}
</style>
