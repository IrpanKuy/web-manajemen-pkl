<script setup>
import { ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    dataMingguan: Array,
    summary: Object,
    tanggalMulai: String,
    tanggalSelesai: String,
    filters: Object,
    pembimbings: Array,
    mitras: Array,
});

// --- STATE ---
const filterTanggalMulai = ref(props.tanggalMulai || "");
const filterTanggalSelesai = ref(props.tanggalSelesai || "");
const search = ref(props.filters?.search || "");
const filterPembimbing = ref(props.filters?.pembimbing_id || null);
const filterMitra = ref(props.filters?.mitra_id || null);

// --- HEADERS ---
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

// --- FILTER ---
const applyFilters = () => {
    router.get(
        route("laporan-mingguan.index"),
        {
            tanggal_mulai: filterTanggalMulai.value || undefined,
            tanggal_selesai: filterTanggalSelesai.value || undefined,
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

watch(
    [filterTanggalMulai, filterTanggalSelesai, filterPembimbing, filterMitra],
    () => {
        if (filterTanggalMulai.value && filterTanggalSelesai.value) {
            applyFilters();
        }
    }
);

// --- HELPERS ---
const getPersentaseColor = (persentase) => {
    if (persentase >= 90) return "success";
    if (persentase >= 75) return "warning";
    return "error";
};

const formatDate = (date) => {
    return new Date(date).toLocaleDateString("id-ID", {
        year: "numeric",
        month: "short",
        day: "numeric",
    });
};

const title = [
    { title: "Laporan Absensi", disabled: true },
    {
        title: "Mingguan",
        disabled: false,
        href: route("laporan-mingguan.index"),
    },
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
                    Laporan Absensi Mingguan ({{
                        formatDate(props.tanggalMulai)
                    }}
                    - {{ formatDate(props.tanggalSelesai) }})
                </h3>
            </v-card-title>

            <!-- SUMMARY -->
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
                    v-model="filterTanggalMulai"
                    label="Tanggal Mulai"
                    type="date"
                    variant="outlined"
                    density="compact"
                    hide-details
                ></v-text-field>
                <v-text-field
                    v-model="filterTanggalSelesai"
                    label="Tanggal Selesai"
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
                :items="props.dataMingguan || []"
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
                            {{ item.siswa?.jurusan || "-" }}
                        </div>
                    </div>
                </template>

                <template v-slot:item.mitra="{ item }">
                    {{ item.mitra || "-" }}
                </template>

                <template v-slot:item.rekap.hadir="{ item }">
                    <v-chip color="success" size="small" variant="flat">{{
                        item.rekap?.hadir || 0
                    }}</v-chip>
                </template>

                <template v-slot:item.rekap.telat="{ item }">
                    <v-chip color="orange" size="small" variant="flat">{{
                        item.rekap?.telat || 0
                    }}</v-chip>
                </template>

                <template v-slot:item.rekap.izin="{ item }">
                    <v-chip color="cyan" size="small" variant="flat">{{
                        item.rekap?.izin || 0
                    }}</v-chip>
                </template>

                <template v-slot:item.rekap.sakit="{ item }">
                    <v-chip color="purple" size="small" variant="flat">{{
                        item.rekap?.sakit || 0
                    }}</v-chip>
                </template>

                <template v-slot:item.rekap.alpha="{ item }">
                    <v-chip color="error" size="small" variant="flat">{{
                        item.rekap?.alpha || 0
                    }}</v-chip>
                </template>

                <template v-slot:item.total_hari="{ item }">
                    <span class="font-weight-bold">{{
                        item.total_hari || 0
                    }}</span>
                </template>

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
        </v-card>
    </PendampingDashboardLayout>
</template>
