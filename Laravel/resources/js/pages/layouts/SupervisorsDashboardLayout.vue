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
            <Link
                :href="route('pengajuan-masuk.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('pengajuan-masuk.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'pengajuan-masuk.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:inbox-arrow-down" width="24" />
                <div>Pengajuan Masuk</div>
            </Link>
            <Link
                :href="route('akun-pembimbing.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('akun-pembimbing.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'akun-pembimbing.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:user-badge-outline" width="24" />
                <div>Akun Pembimbing</div>
            </Link>
        </template>
        <template #content>
            <slot />
        </template>
        <template #headerTitle>
            <slot name="headerTitle" />
        </template>
    </DashboardLayout>
</template>
