<script setup>
import { ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    dataHarian: Array,
    summary: Object,
    tanggal: String,
    filters: Object,
    pembimbings: Array,
    mitras: Array,
});

// --- STATE ---
const filterTanggal = ref(props.tanggal || "");
const search = ref(props.filters?.search || "");
const filterPembimbing = ref(props.filters?.pembimbing_id || null);
const filterMitra = ref(props.filters?.mitra_id || null);

// --- HEADERS ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Siswa", key: "siswa_info" },
    { title: "Mitra Industri", key: "mitra" },
    { title: "Pembimbing", key: "pembimbing" },
    { title: "Jam Masuk", key: "jam_masuk", align: "center" },
    { title: "Jam Pulang", key: "jam_pulang", align: "center" },
    { title: "Status", key: "status", align: "center" },
];

// --- FILTER ---
const applyFilters = () => {
    router.get(
        route("laporan-harian.index"),
        {
            tanggal: filterTanggal.value || undefined,
            search: search.value || undefined,
            pembimbing_id: filterPembimbing.value || undefined,
            mitra_id: filterMitra.value || undefined,
        },
        { preserveState: true, replace: true }
    );
};

let searchTimeout = null;
watch(search, () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applyFilters, 500);
});

watch([filterTanggal, filterPembimbing, filterMitra], applyFilters);

// --- HELPERS ---
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
    return time.substring(0, 5);
};

const title = [
    { title: "Laporan Absensi", disabled: true },
    { title: "Harian", disabled: false, href: route("laporan-harian.index") },
];
</script>

<template>
    <PendampingDashboardLayout>
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
                    Laporan Absensi Harian - {{ formatDate(props.tanggal) }}
                </h3>
            </v-card-title>

            <!-- SUMMARY -->
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

            <!-- FILTER -->
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
                <v-text-field
                    v-model="search"
                    label="Cari Nama Siswa"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-text-field>
                <v-text-field
                    v-model="filterTanggal"
                    label="Pilih Tanggal"
                    type="date"
                    variant="outlined"
                    density="compact"
                    hide-details
                ></v-text-field>
                <v-select
                    v-model="filterPembimbing"
                    :items="props.pembimbings"
                    item-title="name"
                    item-value="id"
                    label="Filter Pembimbing"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-select>
                <v-select
                    v-model="filterMitra"
                    :items="props.mitras"
                    item-title="nama_instansi"
                    item-value="id"
                    label="Filter Mitra"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-select>
            </div>

            <!-- TABLE -->
            <v-data-table
                :headers="headers"
                :items="props.dataHarian || []"
                class="elevation-0 border"
                hover
            >
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <template v-slot:item.siswa_info="{ item }">
                    <div class="py-2" style="min-width: 180px">
                        <div class="font-weight-bold">
                            {{ item.siswa?.name || "N/A" }}
                        </div>
                        <div class="text-caption text-grey">
                            NISN: {{ item.siswa?.nisn || "-" }}
                        </div>
                        <div class="text-caption text-grey">
                            {{ item.siswa?.jurusan || "-" }}
                        </div>
                    </div>
                </template>

                <template v-slot:item.mitra="{ item }">
                    {{ item.mitra || "-" }}
                </template>

                <template v-slot:item.pembimbing="{ item }">
                    {{ item.pembimbing || "-" }}
                </template>

                <template v-slot:item.jam_masuk="{ item }">
                    <span
                        :class="{
                            'text-green-600': item.absensi?.jam_masuk,
                            'text-grey': !item.absensi?.jam_masuk,
                        }"
                    >
                        {{ formatTime(item.absensi?.jam_masuk) }}
                    </span>
                </template>

                <template v-slot:item.jam_pulang="{ item }">
                    <span
                        :class="{
                            'text-blue-600': item.absensi?.jam_pulang,
                            'text-grey': !item.absensi?.jam_pulang,
                        }"
                    >
                        {{ formatTime(item.absensi?.jam_pulang) }}
                    </span>
                </template>

                <template v-slot:item.status="{ item }">
                    <v-chip
                        :color="getStatusColor(item.absensi?.status_kehadiran)"
                        size="small"
                        variant="flat"
                    >
                        {{ getStatusLabel(item.absensi?.status_kehadiran) }}
                    </v-chip>
                </template>
            </v-data-table>
        </v-card>
    </PendampingDashboardLayout>
</template>
