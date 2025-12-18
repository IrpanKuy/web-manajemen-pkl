<script setup>
import { ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
import PembimbingDashboardLayout from "../layouts/pembimbingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    dataHarian: Array,
    summary: Object,
    tanggal: String,
});

// --- STATE LOKAL ---
const filterTanggal = ref(props.tanggal || "");

// --- HEADER TABEL ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Siswa", key: "siswa_info" },
    { title: "Mitra", key: "mitra" },
    { title: "Jam Masuk", key: "absensi.jam_masuk", align: "center" },
    { title: "Jam Pulang", key: "absensi.jam_pulang", align: "center" },
    { title: "Status", key: "absensi.status_kehadiran", align: "center" },
];

// --- FUNGSI FILTER ---
watch(filterTanggal, (newValue) => {
    router.get(
        route("absensi-harian.index"),
        { tanggal: newValue || undefined },
        { preserveState: true, replace: true }
    );
});

// --- HELPER ---
const getStatusColor = (status) => {
    if (status === "hadir") return "success";
    if (status === "telat") return "orange";
    if (status === "izin") return "cyan";
    if (status === "sakit") return "purple";
    if (status === "alpha") return "error";
    return "grey";
};

const getStatusLabel = (status) => {
    if (!status) return "Belum Absen";
    return status.charAt(0).toUpperCase() + status.slice(1);
};

const formatDate = (date) => {
    return new Date(date).toLocaleDateString("id-ID", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
    });
};

const formatTime = (time) => {
    if (!time) return "-";
    return time.substring(0, 5); // Format HH:mm
};

const title = [
    {
        title: "Absensi Harian",
        disabled: false,
        href: route("absensi-harian.index"),
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
                    Absensi Harian - {{ formatDate(props.tanggal) }}
                </h3>
            </v-card-title>

            <!-- SUMMARY CARDS -->
            <div class="grid grid-cols-2 md:grid-cols-7 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Siswa</div>
                    <div class="text-h4 font-weight-bold text-blue-600">
                        {{ props.summary?.total_siswa || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-green-500" elevation="2">
                    <div class="text-caption text-grey">Hadir</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ props.summary?.hadir || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-orange-500" elevation="2">
                    <div class="text-caption text-grey">Telat</div>
                    <div class="text-h4 font-weight-bold text-orange-600">
                        {{ props.summary?.telat || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-cyan-500" elevation="2">
                    <div class="text-caption text-grey">Izin</div>
                    <div class="text-h4 font-weight-bold text-cyan-600">
                        {{ props.summary?.izin || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-purple-500" elevation="2">
                    <div class="text-caption text-grey">Sakit</div>
                    <div class="text-h4 font-weight-bold text-purple-600">
                        {{ props.summary?.sakit || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-red-500" elevation="2">
                    <div class="text-caption text-grey">Alpha</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ props.summary?.alpha || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-gray-500" elevation="2">
                    <div class="text-caption text-grey">Belum Absen</div>
                    <div class="text-h4 font-weight-bold text-gray-600">
                        {{ props.summary?.belum_absen || 0 }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER SECTION -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                <v-text-field
                    v-model="filterTanggal"
                    label="Pilih Tanggal"
                    type="date"
                    variant="outlined"
                    density="compact"
                    hide-details
                ></v-text-field>
            </div>

            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :items="props.dataHarian || []"
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

                <!-- Jam Masuk -->
                <template v-slot:item.absensi.jam_masuk="{ item }">
                    <span
                        :class="{
                            'text-green-600': item.absensi?.jam_masuk,
                            'text-grey': !item.absensi?.jam_masuk,
                        }"
                    >
                        {{ formatTime(item.absensi?.jam_masuk) }}
                    </span>
                </template>

                <!-- Jam Pulang -->
                <template v-slot:item.absensi.jam_pulang="{ item }">
                    <span
                        :class="{
                            'text-blue-600': item.absensi?.jam_pulang,
                            'text-grey': !item.absensi?.jam_pulang,
                        }"
                    >
                        {{ formatTime(item.absensi?.jam_pulang) }}
                    </span>
                </template>

                <!-- Status -->
                <template v-slot:item.absensi.status_kehadiran="{ item }">
                    <v-chip
                        :color="getStatusColor(item.absensi?.status_kehadiran)"
                        size="small"
                        variant="flat"
                    >
                        {{ getStatusLabel(item.absensi?.status_kehadiran) }}
                    </v-chip>
                </template>
            </v-data-table>

            <!-- EMPTY STATE -->
            <div
                v-if="!props.dataHarian || props.dataHarian.length === 0"
                class="text-center py-8 text-grey"
            >
                <v-icon
                    icon="mdi-account-group"
                    size="64"
                    class="mb-4"
                ></v-icon>
                <p>Tidak ada siswa yang dibimbing.</p>
            </div>
        </v-card>
    </PembimbingDashboardLayout>
</template>
