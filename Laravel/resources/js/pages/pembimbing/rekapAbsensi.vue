<script setup>
import { ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
import PembimbingDashboardLayout from "../layouts/pembimbingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    rekapAbsensi: Array,
    summary: Object,
    bulan: String,
});

// --- STATE LOKAL ---
const filterBulan = ref(props.bulan || "");

// --- HEADER TABEL ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Siswa", key: "siswa_info" },
    { title: "Mitra", key: "mitra" },
    { title: "Hadir", key: "rekap.hadir", align: "center" },
    { title: "Telat", key: "rekap.telat", align: "center" },
    { title: "Izin", key: "rekap.izin", align: "center" },
    { title: "Sakit", key: "rekap.sakit", align: "center" },
    { title: "Alpha", key: "rekap.alpha", align: "center" },
    { title: "Total", key: "total_hari", align: "center" },
    { title: "Kehadiran", key: "persentase_kehadiran", align: "center" },
];

// --- FUNGSI FILTER ---
watch(filterBulan, (newValue) => {
    router.get(
        route("rekap-absensi.index"),
        { bulan: newValue || undefined },
        { preserveState: true, replace: true }
    );
});

// --- HELPER ---
const getPersentaseColor = (persentase) => {
    if (persentase >= 90) return "success";
    if (persentase >= 75) return "warning";
    return "error";
};

const formatBulan = (bulan) => {
    if (!bulan) return "-";
    const date = new Date(bulan + "-01");
    return date.toLocaleDateString("id-ID", {
        year: "numeric",
        month: "long",
    });
};

const title = [
    {
        title: "Rekap Absensi Bulanan",
        disabled: false,
        href: route("rekap-absensi.index"),
    },
];
</script>

<template>
    <PembimbingDashboardLayout>
        <template #headerTitle>
            <v-breadcrumbs :items="title" class="text-base md:text-xl">
                <template v-slot:divider>
                    <v-icon icon="mdi-chevron-right"></v-icon>
                </template>
            </v-breadcrumbs>
        </template>

        <v-card class="pa-4 border border-gray-700" elevation="2" rounded="lg">
            <v-card-title>
                <h3 class="text-lg md:text-xl mb-2 font-bold text-wrap">
                    Rekap Absensi Siswa - {{ formatBulan(props.bulan) }}
                </h3>
            </v-card-title>

            <!-- SUMMARY CARDS -->
            <div class="grid grid-cols-2 md:grid-cols-6 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Siswa</div>
                    <div class="text-h4 font-weight-bold text-blue-600">
                        {{ props.summary?.total_siswa || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-green-500" elevation="2">
                    <div class="text-caption text-grey">Total Hadir</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ props.summary?.total_hadir || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-orange-500" elevation="2">
                    <div class="text-caption text-grey">Total Telat</div>
                    <div class="text-h4 font-weight-bold text-orange-600">
                        {{ props.summary?.total_telat || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-cyan-500" elevation="2">
                    <div class="text-caption text-grey">Total Izin</div>
                    <div class="text-h4 font-weight-bold text-cyan-600">
                        {{ props.summary?.total_izin || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-purple-500" elevation="2">
                    <div class="text-caption text-grey">Total Sakit</div>
                    <div class="text-h4 font-weight-bold text-purple-600">
                        {{ props.summary?.total_sakit || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-red-500" elevation="2">
                    <div class="text-caption text-grey">Total Alpha</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ props.summary?.total_alpha || 0 }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER SECTION -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                <v-text-field
                    v-model="filterBulan"
                    label="Pilih Bulan"
                    type="month"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-text-field>
            </div>

            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :items="props.rekapAbsensi || []"
                class="elevation-0 border"
                hover
            >
                <!-- No -->
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <!-- Info Siswa -->
                <template v-slot:item.siswa_info="{ item }">
                    <div
                        class="d-flex flex-column py-2"
                        style="min-width: 180px"
                    >
                        <span class="font-weight-bold">
                            {{ item.siswa?.name || "N/A" }}
                        </span>
                        <span class="text-caption text-grey">
                            {{ item.siswa?.jurusan || "-" }}
                        </span>
                    </div>
                </template>

                <!-- Mitra -->
                <template v-slot:item.mitra="{ item }">
                    <span>{{ item.mitra || "-" }}</span>
                </template>

                <!-- Hadir -->
                <template v-slot:item.rekap.hadir="{ item }">
                    <v-chip color="success" size="small" variant="flat">
                        {{ item.rekap?.hadir || 0 }}
                    </v-chip>
                </template>

                <!-- Telat -->
                <template v-slot:item.rekap.telat="{ item }">
                    <v-chip color="orange" size="small" variant="flat">
                        {{ item.rekap?.telat || 0 }}
                    </v-chip>
                </template>

                <!-- Izin -->
                <template v-slot:item.rekap.izin="{ item }">
                    <v-chip color="cyan" size="small" variant="flat">
                        {{ item.rekap?.izin || 0 }}
                    </v-chip>
                </template>

                <!-- Sakit -->
                <template v-slot:item.rekap.sakit="{ item }">
                    <v-chip color="purple" size="small" variant="flat">
                        {{ item.rekap?.sakit || 0 }}
                    </v-chip>
                </template>

                <!-- Alpha -->
                <template v-slot:item.rekap.alpha="{ item }">
                    <v-chip color="error" size="small" variant="flat">
                        {{ item.rekap?.alpha || 0 }}
                    </v-chip>
                </template>

                <!-- Total -->
                <template v-slot:item.total_hari="{ item }">
                    <span class="font-weight-bold">{{
                        item.total_hari || 0
                    }}</span>
                </template>

                <!-- Persentase Kehadiran -->
                <template v-slot:item.persentase_kehadiran="{ item }">
                    <v-chip
                        :color="getPersentaseColor(item.persentase_kehadiran)"
                        size="small"
                        variant="flat"
                    >
                        {{ item.persentase_kehadiran || 0 }}%
                    </v-chip>
                </template>
            </v-data-table>

            <!-- EMPTY STATE -->
            <div
                v-if="!props.rekapAbsensi || props.rekapAbsensi.length === 0"
                class="text-center py-8 text-grey"
            >
                <v-icon
                    icon="mdi-account-group"
                    size="64"
                    class="mb-4"
                ></v-icon>
                <p>
                    Tidak ada siswa yang dibimbing atau belum ada data absensi.
                </p>
            </div>
        </v-card>
    </PembimbingDashboardLayout>
</template>
