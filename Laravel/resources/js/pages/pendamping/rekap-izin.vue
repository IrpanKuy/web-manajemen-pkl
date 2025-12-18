<script setup>
import { ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../layouts/PendampingDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    izins: Object,
    summary: Object,
    filters: Object,
    pembimbings: Array,
    mitras: Array,
});

// --- STATE ---
const search = ref(props.filters?.search || "");
const filterStatus = ref(props.filters?.status || null);
const filterPembimbing = ref(props.filters?.pembimbing_id || null);
const filterMitra = ref(props.filters?.mitra_id || null);

// --- OPTIONS ---
const statusOptions = [
    { value: null, title: "Semua Status" },
    { value: "pending", title: "Pending" },
    { value: "approved", title: "Disetujui" },
    { value: "rejected", title: "Ditolak" },
];

// --- HEADERS ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Siswa", key: "siswa_info" },
    { title: "Mitra", key: "mitra" },
    { title: "Tanggal Izin", key: "tanggal" },
    { title: "Durasi", key: "durasi_hari", align: "center" },
    { title: "Keterangan", key: "keterangan" },
    { title: "Status", key: "status", align: "center" },
    { title: "Diproses Oleh", key: "approver", align: "center" },
];

// --- FILTER ---
const applyFilters = () => {
    router.get(
        route("rekap-izin.index"),
        {
            search: search.value || undefined,
            status: filterStatus.value || undefined,
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

watch([filterStatus, filterPembimbing, filterMitra], applyFilters);

// --- HELPERS ---
const getStatusColor = (status) => {
    if (status === "approved") return "success";
    if (status === "rejected") return "error";
    return "warning";
};

const getStatusLabel = (status) => {
    if (status === "approved") return "Disetujui";
    if (status === "rejected") return "Ditolak";
    return "Pending";
};

const formatDate = (date) => {
    return new Date(date).toLocaleDateString("id-ID", {
        year: "numeric",
        month: "short",
        day: "numeric",
    });
};

const title = [
    {
        title: "Rekap Izin",
        disabled: false,
        href: route("rekap-izin.index"),
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
                    Rekap Pengajuan Izin Siswa
                </h3>
            </v-card-title>

            <!-- SUMMARY -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Izin</div>
                    <div class="text-h4 font-weight-bold text-blue-600">
                        {{ props.summary?.total || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-yellow-500" elevation="2">
                    <div class="text-caption text-grey">Pending</div>
                    <div class="text-h4 font-weight-bold text-yellow-600">
                        {{ props.summary?.pending || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-green-500" elevation="2">
                    <div class="text-caption text-grey">Disetujui</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ props.summary?.approved || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-red-500" elevation="2">
                    <div class="text-caption text-grey">Ditolak</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ props.summary?.rejected || 0 }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER -->
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
                <v-text-field
                    v-model="search"
                    label="Cari Siswa / Keterangan"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-text-field>
                <v-select
                    v-model="filterStatus"
                    :items="statusOptions"
                    item-title="title"
                    item-value="value"
                    label="Filter Status"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-select>
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
                :items="props.izins?.data || []"
                class="elevation-0 border"
                hover
            >
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <template v-slot:item.siswa_info="{ item }">
                    <div class="py-2" style="min-width: 180px">
                        <div class="font-weight-bold">
                            {{ item.siswa?.user?.name || "N/A" }}
                        </div>
                        <div class="text-caption text-grey">
                            {{ item.siswa?.jurusan?.nama_jurusan || "-" }}
                        </div>
                    </div>
                </template>

                <template v-slot:item.mitra="{ item }">
                    {{ item.mitra?.nama_instansi || "-" }}
                </template>

                <template v-slot:item.tanggal="{ item }">
                    <div style="min-width: 140px">
                        {{ formatDate(item.tgl_mulai) }} -
                        {{ formatDate(item.tgl_selesai) }}
                    </div>
                </template>

                <template v-slot:item.durasi_hari="{ item }">
                    <v-chip color="info" size="small" variant="flat">
                        {{ item.durasi_hari }} hari
                    </v-chip>
                </template>

                <template v-slot:item.keterangan="{ item }">
                    <div style="min-width: 200px; max-width: 300px">
                        <span class="text-wrap">{{
                            item.keterangan || "-"
                        }}</span>
                    </div>
                </template>

                <template v-slot:item.status="{ item }">
                    <v-chip
                        :color="getStatusColor(item.status)"
                        size="small"
                        class="text-capitalize"
                    >
                        {{ getStatusLabel(item.status) }}
                    </v-chip>
                </template>

                <template v-slot:item.approver="{ item }">
                    <span v-if="item.approver" class="font-medium">
                        {{ item.approver.name }}
                    </span>
                    <span v-else class="text-grey">-</span>
                </template>
            </v-data-table>
        </v-card>
    </PendampingDashboardLayout>
</template>
