<script setup>
import { usePage, Link, router } from "@inertiajs/vue3";
import { computed, onMounted, ref, watch } from "vue";
import DashboardLayout from "./dashboardLayout.vue";

const page = usePage();
const currentRouteName = computed(() => page.props.currentRoute.name);

// Notification badges
const notifications = computed(() => page.props.pembimbingNotifications);

// pengkondisian route
const isLinkActive = (routeName) => {
    return currentRouteName.value === routeName;
};
</script>
<template>
    <DashboardLayout>
        <template #sidebar-menu>
            <!-- Menu Siswa Bimbingan -->
            <Link
                :href="route('siswa-bimbingan.index')"
                :class="{
                    'bg-[#4A60AA]!':
                        isLinkActive('siswa-bimbingan.index') ||
                        isLinkActive('siswa-bimbingan.show'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'siswa-bimbingan.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:account-group" width="24" />
                <div>Siswa Bimbingan</div>
            </Link>

            <!-- Menu Persetujuan Jurnal -->
            <Link
                :href="route('jurnal-siswa.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('jurnal-siswa.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive('jurnal-siswa.index'),
                }"
                class="text-white font-medium! transition duration-150 flex items-center justify-between px-3 py-2 rounded-md"
            >
                <div class="flex items-center gap-3">
                    <Icon icon="mdi:notebook-edit" width="24" />
                    <div>Persetujuan Jurnal</div>
                </div>
                <v-badge
                    v-if="notifications?.jurnal_pending > 0"
                    :content="notifications.jurnal_pending"
                    color="warning"
                    inline
                ></v-badge>
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
                class="text-white font-medium! transition duration-150 flex items-center justify-between px-3 py-2 rounded-md"
            >
                <div class="flex items-center gap-3">
                    <Icon icon="mdi:account-switch" width="24" />
                    <div>Ganti Pembimbing</div>
                </div>
                <v-badge
                    v-if="notifications?.mentor_request_pending > 0"
                    :content="notifications.mentor_request_pending"
                    color="warning"
                    inline
                ></v-badge>
            </Link>

            <!-- Menu Pengajuan Izin -->
            <Link
                :href="route('pengajuan-izin.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('pengajuan-izin.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'pengajuan-izin.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center justify-between px-3 py-2 rounded-md"
            >
                <div class="flex items-center gap-3">
                    <Icon icon="mdi:file-document-edit" width="24" />
                    <div>Pengajuan Izin</div>
                </div>
                <v-badge
                    v-if="notifications?.izin_pending > 0"
                    :content="notifications.izin_pending"
                    color="warning"
                    inline
                ></v-badge>
            </Link>

            <!-- Menu Absensi Harian -->
            <Link
                :href="route('absensi-harian.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('absensi-harian.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'absensi-harian.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:clock-check" width="24" />
                <div>Absensi Harian</div>
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
        <template #headerTitle>
            <slot name="headerTitle" />
        </template>
    </DashboardLayout>
</template>
