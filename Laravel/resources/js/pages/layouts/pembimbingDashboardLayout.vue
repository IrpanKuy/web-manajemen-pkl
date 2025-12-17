<script setup>
import { usePage, Link, router } from "@inertiajs/vue3";
import { computed, onMounted, ref, watch } from "vue";
import DashboardLayout from "./dashboardLayout.vue";

const page = usePage();
const currentRouteName = computed(() => page.props.currentRoute.name);

// pengkondisian route
const isLinkActive = (routeName) => {
    return currentRouteName.value === routeName;
};
</script>
<template>
    <DashboardLayout>
        <template #sidebar-menu>
            <Link
                :href="route('profile-instansi.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('profile-instansi.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'profile-instansi.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:company" width="24" />
                <div>Profile Instansi</div>
            </Link>
        </template>
        <template #content>
            <slot />
        </template>
    </DashboardLayout>
</template>
