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
            <!-- Menu Persetujuan Jurnal -->
            <Link
                :href="route('jurnal-siswa.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('jurnal-siswa.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive('jurnal-siswa.index'),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:notebook-edit" width="24" />
                <div>Persetujuan Jurnal</div>
            </Link>

            <!-- Menu Permintaan Ganti Pembimbing -->
            <Link
                :href="route('mentor-request.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('mentor-request.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'mentor-request.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:account-switch" width="24" />
                <div>Permintaan Ganti Pembimbing</div>
            </Link>

            <!-- Menu Rekap Absensi -->
            <Link
                :href="route('rekap-absensi.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('rekap-absensi.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'rekap-absensi.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:calendar-check" width="24" />
                <div>Rekap Absensi</div>
            </Link>
        </template>
        <template #content>
            <slot />
        </template>
    </DashboardLayout>
</template>
