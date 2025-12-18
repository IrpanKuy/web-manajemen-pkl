<script setup>
import { ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
import SupervisorsDashboardLayout from "../layouts/SupervisorsDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    izins: Object,
    filters: Object,
});

// --- STATE ---
const search = ref(props.filters?.search || "");
const filterStatus = ref(props.filters?.status || null);

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
    { title: "Tanggal Izin", key: "tanggal" },
    { title: "Durasi", key: "durasi_hari", align: "center" },
    { title: "Keterangan", key: "keterangan" },
    { title: "Status", key: "status", align: "center" },
    { title: "Diproses Oleh", key: "approver", align: "center" },
];

// --- FILTER ---
const applyFilters = () => {
    router.get(
        route("data-izin.index"),
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
        title: "Data Izin Siswa",
        disabled: false,
        href: route("data-izin.index"),
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
                    Daftar Pengajuan Izin Siswa
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
    </SupervisorsDashboardLayout>
</template>
