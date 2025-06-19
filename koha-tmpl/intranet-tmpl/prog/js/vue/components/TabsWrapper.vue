<template>
    <ul class="nav nav-tabs" role="tablist">
        <li
            v-for="(tab, counter) in tabList"
            class="nav-item"
            :key="`tab${counter}`"
        >
            <a
                href="#"
                :class="['nav-link', { active: counter == 0 }]"
                data-bs-toggle="tab"
                :data-bs-target="'#' + tab.name?.replace(/\s/g, '_')"
                role="tab"
                :aria-controls="tab.name?.replace(/\s/g, '_')"
                :data-content="tab.name"
                >{{ tab.name }}</a
            >
        </li>
    </ul>
    <div class="tab-content">
        <div
            v-for="(group, counter) in tabList"
            v-bind:key="counter"
            :id="group.name?.replace(/\s/g, '_')"
            role="tabpanel"
            :aria-labelledby="group.name?.replace(/\s/g, '_') + '-tab'"
            :class="[
                'tab-pane',
                'rows',
                { show: counter == 0 },
                { active: counter == 0 },
            ]"
        >
            <slot name="tabContent" :tabGroup="group" />
        </div>
    </div>
</template>

<script>
export default {
    props: {
        tabList: Array,
    },
};
</script>

<style></style>
