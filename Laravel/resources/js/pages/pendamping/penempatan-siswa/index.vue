<script setup>
import { ref, watch } from "vue";
import { router, Link } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    placements: Object,
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
    { value: "berjalan", title: "Berjalan" },
    { value: "selesai", title: "Selesai" },
];

// --- HEADERS ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Siswa", key: "siswa_info" },
    { title: "Mitra Industri", key: "mitra" },
    { title: "Pembimbing", key: "pembimbing" },
    { title: "Periode", key: "periode" },
    { title: "Status", key: "status", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
];

// --- FILTER ---
const applyFilters = () => {
    router.get(
        route("penempatan-siswa.index"),
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
    if (status === "berjalan") return "success";
    if (status === "selesai") return "info";
    return "warning";
};

const formatDate = (date) => {
    if (!date) return "-";
    return new Date(date).toLocaleDateString("id-ID", {
        year: "numeric",
        month: "short",
        day: "numeric",
    });
};

const title = [
    {
        title: "Penempatan Siswa",
        disabled: false,
        href: route("penempatan-siswa.index"),
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
                    Data Penempatan Siswa PKL
                </h3>
            </v-card-title>

            <!-- SUMMARY -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Penempatan</div>
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
                    <div class="text-caption text-grey">Berjalan</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ props.summary?.berjalan || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-cyan-500" elevation="2">
                    <div class="text-caption text-grey">Selesai</div>
                    <div class="text-h4 font-weight-bold text-cyan-600">
                        {{ props.summary?.selesai || 0 }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER -->
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
                <v-text-field
                    v-model="search"
                    label="Cari Siswa / Mitra"
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
                :items="props.placements?.data || []"
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
                            NISN: {{ item.siswa?.nisn || "-" }}
                        </div>
                        <div class="text-caption text-grey">
                            {{ item.siswa?.jurusan?.nama_jurusan || "-" }}
                        </div>
                    </div>
                </template>

                <template v-slot:item.mitra="{ item }">
                    <div style="min-width: 150px">
                        <div class="font-weight-medium">
                            {{ item.mitra?.nama_instansi || "-" }}
                        </div>
                    </div>
                </template>

                <template v-slot:item.pembimbing="{ item }">
                    {{ item.pembimbing?.name || "-" }}
                </template>

                <template v-slot:item.periode="{ item }">
                    <div style="min-width: 160px">
                        <div class="text-caption">
                            <v-icon size="small" class="mr-1"
                                >mdi-calendar-start</v-icon
                            >
                            {{ formatDate(item.tgl_mulai) }}
                        </div>
                        <div class="text-caption">
                            <v-icon size="small" class="mr-1"
                                >mdi-calendar-end</v-icon
                            >
                            {{ formatDate(item.tgl_selesai) }}
                        </div>
                    </div>
                </template>

                <template v-slot:item.status="{ item }">
                    <v-chip
                        :color="getStatusColor(item.status)"
                        size="small"
                        class="text-capitalize"
                    >
                        {{ item.status || "pending" }}
                    </v-chip>
                </template>

                <template v-slot:item.actions="{ item }">
                    <Link :href="route('penempatan-siswa.show', item.id)">
                        <v-btn
                            color="primary"
                            size="x-small"
                            variant="flat"
                            prepend-icon="mdi-eye"
                        >
                            Detail
                        </v-btn>
                    </Link>
                </template>
            </v-data-table>
        </v-card>
    </PendampingDashboardLayout>
</template>
