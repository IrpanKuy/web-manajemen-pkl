<script setup>
import { computed, ref, watch } from "vue";
import { router, Link } from "@inertiajs/vue3";
import PembimbingDashboardLayout from "../layouts/pembimbingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    placements: Object, // Data Paginator
    summary: Object,
    filters: Object,
});

// --- STATE LOKAL ---
const search = ref(props.filters?.search || "");
const filterStatus = ref(props.filters?.status || null);

// --- STATUS OPTIONS ---
const statusOptions = [
    { value: null, title: "Semua Status" },
    { value: "pending", title: "Pending" },
    { value: "berjalan", title: "Berjalan" },
    { value: "selesai", title: "Selesai" },
    { value: "gagal", title: "Gagal" },
];

// --- HEADER TABEL ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Siswa", key: "siswa_info" },
    { title: "Periode PKL", key: "periode" },
    { title: "Status", key: "status", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
];

// --- FUNGSI FILTER ---
const applyFilters = () => {
    router.get(
        route("siswa-bimbingan.index"),
        {
            search: search.value || undefined,
            status: filterStatus.value || undefined,
        },
        { preserveState: true, replace: true }
    );
};

// Debounce search
let searchTimeout = null;
watch(search, () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applyFilters, 500);
});

watch(filterStatus, () => {
    applyFilters();
});

// --- HELPER ---
const getStatusColor = (status) => {
    if (status === "berjalan") return "success";
    if (status === "selesai") return "info";
    if (status === "gagal") return "error";
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
        title: "Siswa Bimbingan",
        disabled: false,
        href: route("siswa-bimbingan.index"),
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
                    Daftar Siswa Bimbingan
                </h3>
            </v-card-title>

            <!-- SUMMARY CARDS -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Siswa</div>
                    <div class="text-h4 font-weight-bold text-blue-600">
                        {{ props.summary?.total || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-green-500" elevation="2">
                    <div class="text-caption text-grey">Sedang PKL</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ props.summary?.berjalan || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-cyan-500" elevation="2">
                    <div class="text-caption text-grey">Selesai PKL</div>
                    <div class="text-h4 font-weight-bold text-cyan-600">
                        {{ props.summary?.selesai || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-yellow-500" elevation="2">
                    <div class="text-caption text-grey">Pending</div>
                    <div class="text-h4 font-weight-bold text-yellow-600">
                        {{ props.summary?.pending || 0 }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER SECTION -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                <v-text-field
                    v-model="search"
                    label="Cari Nama Siswa"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-text-field>
                <v-select
                    :items="statusOptions"
                    v-model="filterStatus"
                    label="Filter Status"
                    item-title="title"
                    item-value="value"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-select>
            </div>

            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :items="props.placements?.data || []"
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
                        style="min-width: 200px"
                    >
                        <span class="font-weight-bold">
                            {{ item.siswa?.user?.name || "N/A" }}
                        </span>
                        <span class="text-caption text-grey">
                            NISN: {{ item.siswa?.nisn || "-" }}
                        </span>
                        <span class="text-caption text-grey">
                            {{ item.siswa?.jurusan?.nama_jurusan || "-" }}
                        </span>
                    </div>
                </template>
                <!-- Periode -->
                <template v-slot:item.periode="{ item }">
                    <div style="min-width: 180px">
                        <div class="d-flex flex-column">
                            <span class="text-caption">
                                <v-icon size="small" class="mr-1"
                                    >mdi-calendar-start</v-icon
                                >
                                {{ formatDate(item.tgl_mulai) }}
                            </span>
                            <span class="text-caption">
                                <v-icon size="small" class="mr-1"
                                    >mdi-calendar-end</v-icon
                                >
                                {{ formatDate(item.tgl_selesai) }}
                            </span>
                        </div>
                    </div>
                </template>

                <!-- Status -->
                <template v-slot:item.status="{ item }">
                    <v-chip
                        :color="getStatusColor(item.status)"
                        size="small"
                        class="text-capitalize"
                    >
                        {{ item.status || "pending" }}
                    </v-chip>
                </template>

                <!-- Aksi -->
                <template v-slot:item.actions="{ item }">
                    <Link :href="route('siswa-bimbingan.show', item.id)">
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

            <!-- EMPTY STATE -->
            <div
                v-if="
                    !props.placements?.data ||
                    props.placements?.data.length === 0
                "
                class="text-center py-8 text-grey"
            >
                <v-icon
                    icon="mdi-account-group"
                    size="64"
                    class="mb-4"
                ></v-icon>
                <p>Belum ada siswa yang dibimbing.</p>
            </div>
        </v-card>
    </PembimbingDashboardLayout>
</template>
