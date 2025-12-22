<script setup>
import { usePage, Link, router } from "@inertiajs/vue3";
import { computed, onMounted, ref, watch } from "vue";
import DashboardLayout from "./dashboardLayout.vue";

const showMasterDataDropdown = ref(false);
const showLaporanDropdown = ref(false);

const page = usePage();
const currentRouteName = computed(() => page.props.currentRoute.name);

// Check if user is admin
const isAdmin = computed(() => page.props.auth?.user?.is_admin || false);

// Pendamping notifications badge count
const pendampingNotifications = computed(
    () => page.props.pendampingNotifications
);

// pengkondisian route
const isLinkActive = (routeName) => {
    return currentRouteName.value === routeName;
};
</script>
<template>
    <DashboardLayout>
        <template #sidebar-menu>
            <!-- Dashboard -->
            <Link
                :href="route('pendamping.dashboard')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('pendamping.dashboard'),
                    'hover:bg-[#2C48A5]!': !isLinkActive(
                        'pendamping.dashboard'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:view-dashboard" width="24" />
                <div>Dashboard</div>
            </Link>

            <button
                @click="showMasterDataDropdown = !showMasterDataDropdown"
                :class="{
                    'bg-[#4A60AA]!':
                        isLinkActive('jurusan.index') ||
                        isLinkActive('kelas.binaan'),
                    'hover:bg-[#2C48A5]! ':
                        !isLinkActive('jurusan.index') &&
                        !isLinkActive('kelas.binaan'),
                }"
                class="w-full text-lg text-white font-medium! transition duration-150 flex items-center justify-between px-3 py-2 rounded-md cursor-pointer"
            >
                <div class="flex items-center gap-3">
                    <Icon icon="mdi:folder" width="24" class="text-white" />
                    <div>Master Data</div>
                </div>

                <Icon
                    icon="mdi:chevron-down"
                    width="18"
                    class="transition-transform duration-200 text-white"
                    :class="{
                        'rotate-180': showMasterDataDropdown,
                    }"
                />
            </button>

            <!-- Dropdown -->
            <Transition name="fade">
                <div
                    v-if="showMasterDataDropdown"
                    class="flex flex-col flex-start pl-8 gap-1 mt-1 rounded-md transition-all duration-300"
                >
                    <!-- Submenu 1 -->
                    <Link
                        :href="route('jurusan.index')"
                        :class="{
                            'bg-[#4A60AA]!': isLinkActive('jurusan.index'),
                            'hover:bg-[#2C48A5]!':
                                !isLinkActive('jurusan.index'),
                        }"
                        class="text-white font-medium! transition duration-150 flex items-center gap-3 px-4 py-2 rounded-md"
                    >
                        <Icon icon="mdi:school" width="20" />
                        <div>Jurusan</div>
                    </Link>

                    <!-- Submenu 2 -->
                    <Link
                        :href="route('data-siswa.index')"
                        :class="{
                            'bg-[#4A60AA]!': isLinkActive('data-siswa.index'),
                            'hover:bg-[#2C48A5]!':
                                !isLinkActive('data-siswa.index'),
                        }"
                        class="text-white font-medium! transition duration-150 flex items-center gap-3 px-4 py-2 rounded-md"
                    >
                        <Icon icon="mdi:user-group" width="20" />
                        <div>Data Siswa</div>
                    </Link>
                </div>
            </Transition>

            <Link
                :href="route('mitra-industri.index')"
                :class="{
                    'bg-[#4A60AA]!':
                        isLinkActive('mitra-industri.index') ||
                        isLinkActive('mitra-industri.create') ||
                        isLinkActive('mitra-industri.edit'),
                    'hover:bg-[#2C48A5]!': !isLinkActive(
                        'mitra-industri.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:sitemap" width="24" />
                <div>Mitra Industri</div>
            </Link>

            <!-- Manajemen Role - Only for Admin -->
            <Link
                v-if="isAdmin"
                :href="route('manajemen-role.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('manajemen-role.index'),
                    'hover:bg-[#2C48A5]!': !isLinkActive(
                        'manajemen-role.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:account-key" width="24" />
                <div>Manajemen Pendamping</div>
            </Link>

            <!-- Laporan Absensi Dropdown -->
            <button
                @click="showLaporanDropdown = !showLaporanDropdown"
                :class="{
                    'bg-[#4A60AA]!':
                        isLinkActive('laporan-harian.index') ||
                        isLinkActive('laporan-bulanan.index'),
                    'hover:bg-[#2C48A5]! ':
                        !isLinkActive('laporan-harian.index') &&
                        !isLinkActive('laporan-bulanan.index'),
                }"
                class="w-full text-lg text-white font-medium! transition duration-150 flex items-center justify-between px-3 py-2 rounded-md cursor-pointer"
            >
                <div class="flex items-center gap-3">
                    <Icon icon="mdi:chart-bar" width="24" class="text-white" />
                    <div>Laporan Absensi</div>
                </div>

                <Icon
                    icon="mdi:chevron-down"
                    width="18"
                    class="transition-transform duration-200 text-white"
                    :class="{
                        'rotate-180': showLaporanDropdown,
                    }"
                />
            </button>

            <!-- Laporan Dropdown Items -->
            <Transition name="fade">
                <div
                    v-if="showLaporanDropdown"
                    class="flex flex-col flex-start pl-8 gap-1 mt-1 rounded-md transition-all duration-300"
                >
                    <!-- Laporan Harian -->
                    <Link
                        :href="route('laporan-harian.index')"
                        :class="{
                            'bg-[#4A60AA]!': isLinkActive(
                                'laporan-harian.index'
                            ),
                            'hover:bg-[#2C48A5]!': !isLinkActive(
                                'laporan-harian.index'
                            ),
                        }"
                        class="text-white font-medium! transition duration-150 flex items-center gap-3 px-4 py-2 rounded-md"
                    >
                        <Icon icon="mdi:calendar-today" width="20" />
                        <div>Harian</div>
                    </Link>

                    <!-- Laporan Bulanan -->
                    <Link
                        :href="route('laporan-bulanan.index')"
                        :class="{
                            'bg-[#4A60AA]!': isLinkActive(
                                'laporan-bulanan.index'
                            ),
                            'hover:bg-[#2C48A5]!': !isLinkActive(
                                'laporan-bulanan.index'
                            ),
                        }"
                        class="text-white font-medium! transition duration-150 flex items-center gap-3 px-4 py-2 rounded-md"
                    >
                        <Icon icon="mdi:calendar-month" width="20" />
                        <div>Bulanan</div>
                    </Link>
                </div>
            </Transition>

            <!-- Rekap Jurnal -->
            <Link
                :href="route('rekap-jurnal.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('rekap-jurnal.index'),
                    'hover:bg-[#2C48A5]!': !isLinkActive('rekap-jurnal.index'),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:notebook-multiple" width="24" />
                <div>Rekap Jurnal</div>
            </Link>

            <!-- Rekap Izin -->
            <Link
                :href="route('rekap-izin.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('rekap-izin.index'),
                    'hover:bg-[#2C48A5]!': !isLinkActive('rekap-izin.index'),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:file-document-multiple" width="24" />
                <div>Rekap Izin</div>
            </Link>

            <!-- Penempatan Siswa -->
            <Link
                :href="route('penempatan-siswa.index')"
                :class="{
                    'bg-[#4A60AA]!':
                        isLinkActive('penempatan-siswa.index') ||
                        isLinkActive('penempatan-siswa.show'),
                    'hover:bg-[#2C48A5]!':
                        !isLinkActive('penempatan-siswa.index') &&
                        !isLinkActive('penempatan-siswa.show'),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:map-marker-account" width="24" />
                <div>Penempatan Siswa</div>
            </Link>

            <!-- Pengajuan Pengeluaran Siswa -->
            <Link
                :href="route('pengajuan-pengeluaran.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive(
                        'pengajuan-pengeluaran.index'
                    ),
                    'hover:bg-[#2C48A5]!': !isLinkActive(
                        'pengajuan-pengeluaran.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center justify-between px-3 py-2 rounded-md"
            >
                <div class="flex items-center gap-3">
                    <Icon icon="mdi:account-remove" width="24" />
                    <div>Pengajuan Pengeluaran</div>
                </div>
                <span
                    v-if="
                        pendampingNotifications?.pengajuan_pengeluaran_pending >
                        0
                    "
                    class="bg-yellow-500 text-black text-xs font-bold px-2 py-0.5 rounded-full"
                >
                    {{ pendampingNotifications.pengajuan_pengeluaran_pending }}
                </span>
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

<style scoped>
.fade-slide-enter-active,
.fade-slide-leave-active {
    transition: all 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.86);
}
/* Status awal saat muncul (enter-from) & status akhir saat menghilang (leave-to) */
.fade-slide-enter-from,
.fade-slide-leave-to {
    transform: translateX(-100%);
}

/* Status normal (di layar) */
.fade-slide-enter-to,
.fade-slide-leave-from {
    transform: translateX(0);
}

/*
 * TRANSITION: FADE (Memudar Masuk/Keluar)
 * Target: name="fade"
 */

/* Aktifkan Transisi */
.fade-enter-active,
.fade-leave-active {
    /* Hanya transisi opacity, durasi 0.3 detik */
    transition: opacity 0.3s ease-in-out;
}

/* Status Awal (Saat Masuk) & Status Akhir (Saat Keluar) */
.fade-enter-from,
.fade-leave-to {
    /* Dimulai dari transparan (tidak terlihat) */
    opacity: 0;
}

/* Status Normal (Di layar) */
.fade-enter-to,
.fade-leave-from {
    /* Opacity penuh (terlihat jelas) */
    opacity: 1;
}
</style>
