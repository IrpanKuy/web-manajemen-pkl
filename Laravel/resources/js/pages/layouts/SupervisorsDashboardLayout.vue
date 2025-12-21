<script setup>
import { usePage, Link, router } from "@inertiajs/vue3";
import { computed, onMounted, ref, watch } from "vue";
import DashboardLayout from "./dashboardLayout.vue";

const page = usePage();
const currentRouteName = computed(() => page.props.currentRoute.name);
const supervisorNotifications = computed(
    () => page.props.supervisorNotifications
);

// State untuk dropdown Laporan
const openLaporan = ref(false);

// pengkondisian route
const isLinkActive = (routeName) => {
    return currentRouteName.value === routeName;
};
</script>
<template>
    <DashboardLayout>
        <template #sidebar-menu>
            <!-- Profile Instansi -->
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

            <!-- Pengajuan Masuk dengan Badge -->
            <Link
                :href="route('pengajuan-masuk.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('pengajuan-masuk.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'pengajuan-masuk.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center justify-between px-3 py-2 rounded-md"
            >
                <div class="flex items-center gap-3">
                    <Icon icon="mdi:inbox-arrow-down" width="24" />
                    <div>Pengajuan Masuk</div>
                </div>
                <span
                    v-if="supervisorNotifications?.pengajuan_masuk_pending > 0"
                    class="bg-yellow-500 text-black text-xs font-bold px-2 py-0.5 rounded-full"
                >
                    {{ supervisorNotifications.pengajuan_masuk_pending }}
                </span>
            </Link>

            <!-- Akun Pembimbing -->
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
                <Icon icon="mdi:account-tie" width="24" />
                <div>Akun Pembimbing</div>
            </Link>

            <!-- Data Siswa PKL -->
            <Link
                :href="route('data-siswa-pkl.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('data-siswa-pkl.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive(
                        'data-siswa-pkl.index'
                    ),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:account-group" width="24" />
                <div>Data Siswa PKL</div>
            </Link>

            <!-- Data Izin -->
            <Link
                :href="route('data-izin.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('data-izin.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive('data-izin.index'),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:file-document" width="24" />
                <div>Data Izin</div>
            </Link>

            <!-- Data Jurnal -->
            <Link
                :href="route('data-jurnal.index')"
                :class="{
                    'bg-[#4A60AA]!': isLinkActive('data-jurnal.index'),
                    'hover:bg-[#2C48A5]! ': !isLinkActive('data-jurnal.index'),
                }"
                class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
            >
                <Icon icon="mdi:notebook" width="24" />
                <div>Data Jurnal</div>
            </Link>

            <!-- Dropdown Laporan Absensi -->
            <v-btn
                variant="text"
                @click="openLaporan = !openLaporan"
                :class="{
                    'bg-[#4A60AA]!':
                        isLinkActive('data-absensi-harian.index') ||
                        isLinkActive('data-absensi-bulanan.index'),
                    'hover:bg-[#2C48A5]!': !(
                        isLinkActive('data-absensi-harian.index') ||
                        isLinkActive('data-absensi-bulanan.index')
                    ),
                }"
                class="font-medium! transition duration-150 flex items-center justify-between w-full px-3 py-2 rounded-md"
            >
                <div class="flex text-white items-center gap-3">
                    <Icon icon="mdi:chart-bar" width="24" />
                    <div>Laporan Absensi</div>
                </div>
                <Icon
                    :icon="openLaporan ? 'mdi:chevron-up' : 'mdi:chevron-down'"
                    class="text-white"
                    width="20"
                />
            </v-btn>
            <transition name="fade-slide">
                <div
                    v-if="openLaporan"
                    class="ml-6 mt-1 space-y-1 border-[#4A60AA] pl-3"
                >
                    <!-- Absensi Harian -->
                    <Link
                        :href="route('data-absensi-harian.index')"
                        :class="{
                            'bg-[#4A60AA]!': isLinkActive(
                                'data-absensi-harian.index'
                            ),
                            'hover:bg-[#2C48A5]!': !isLinkActive(
                                'data-absensi-harian.index'
                            ),
                        }"
                        class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
                    >
                        <Icon icon="mdi:clock-check" width="20" />
                        <div>Harian</div>
                    </Link>

                    <!-- Rekap Absensi Bulanan -->
                    <Link
                        :href="route('data-absensi-bulanan.index')"
                        :class="{
                            'bg-[#4A60AA]!': isLinkActive(
                                'data-absensi-bulanan.index'
                            ),
                            'hover:bg-[#2C48A5]!': !isLinkActive(
                                'data-absensi-bulanan.index'
                            ),
                        }"
                        class="text-white font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
                    >
                        <Icon icon="mdi:calendar-check" width="20" />
                        <div>Bulanan</div>
                    </Link>
                </div>
            </transition>
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
    transition: all 0.2s ease;
}
.fade-slide-enter-from,
.fade-slide-leave-to {
    opacity: 0;
    transform: translateY(-10px);
}
</style>
