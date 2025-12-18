<script setup>
import { ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
import SupervisorsDashboardLayout from "../layouts/SupervisorsDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    placements: Object,
    mitra: Object,
    filters: Object,
});

// --- STATE ---
const search = ref(props.filters?.search || "");
const filterStatus = ref(props.filters?.status || null);

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
    { title: "Pembimbing", key: "pembimbing" },
    { title: "Periode PKL", key: "periode" },
    { title: "Status", key: "status", align: "center" },
];

// --- FILTER ---
const applyFilters = () => {
    router.get(
        route("data-siswa-pkl.index"),
        {
            search: search.value || undefined,
            status: filterStatus.value || undefined,
        },
        { preserveState: true, replace: true }
    );
};

let searchTimeout = null;
watch(search, () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applyFilters, 500);
});

watch(filterStatus, applyFilters);

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
        title: "Data Siswa PKL",
        disabled: false,
        href: route("data-siswa-pkl.index"),
    },
];
</script>

<template>
    <SupervisorsDashboardLayout>
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
                    Daftar Siswa PKL di {{ props.mitra?.nama_mitra || "Mitra" }}
                </h3>
            </v-card-title>

            <!-- FILTER -->
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
                    <div class="py-2" style="min-width: 200px">
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
            </v-data-table>
        </v-card>
    </SupervisorsDashboardLayout>
</template>
