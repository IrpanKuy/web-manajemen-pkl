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

// --- DETAIL DIALOG STATE ---
const detailDialog = ref(false);
const selectedIzin = ref(null);

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
    { title: "Status", key: "status", align: "center" },
    { title: "Diproses Oleh", key: "approver", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
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

// --- DETAIL FUNCTION ---
const openDetail = (item) => {
    selectedIzin.value = item;
    detailDialog.value = true;
};

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

                <template v-slot:item.actions="{ item }">
                    <v-btn
                        icon="mdi-eye"
                        color="primary"
                        size="small"
                        variant="text"
                        @click="openDetail(item)"
                    ></v-btn>
                </template>
            </v-data-table>
        </v-card>

        <!-- DETAIL DIALOG -->
        <v-dialog v-model="detailDialog" max-width="600px">
            <v-card>
                <v-card-title class="bg-primary text-white">
                    <span class="text-h6">Detail Izin</span>
                </v-card-title>

                <v-card-text class="pt-4">
                    <v-list lines="two" density="compact">
                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Siswa</v-list-item-title
                            >
                            <v-list-item-subtitle
                                >{{
                                    selectedIzin?.siswa?.user?.name || "-"
                                }}
                                ({{
                                    selectedIzin?.siswa?.jurusan
                                        ?.nama_jurusan || "-"
                                }})</v-list-item-subtitle
                            >
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Tanggal Izin</v-list-item-title
                            >
                            <v-list-item-subtitle>
                                {{
                                    selectedIzin?.tgl_mulai
                                        ? formatDate(selectedIzin.tgl_mulai)
                                        : "-"
                                }}
                                -
                                {{
                                    selectedIzin?.tgl_selesai
                                        ? formatDate(selectedIzin.tgl_selesai)
                                        : "-"
                                }}
                                ({{ selectedIzin?.durasi_hari || 0 }} hari)
                            </v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Keterangan</v-list-item-title
                            >
                            <v-list-item-subtitle class="text-wrap">{{
                                selectedIzin?.keterangan || "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item v-if="selectedIzin?.bukti_path">
                            <v-list-item-title class="font-weight-bold"
                                >Bukti</v-list-item-title
                            >
                            <v-list-item-subtitle>
                                <a
                                    :href="`/storage/${selectedIzin.bukti_path}`"
                                    target="_blank"
                                    class="text-primary"
                                >
                                    <v-icon size="small"
                                        >mdi-file-document</v-icon
                                    >
                                    Lihat Bukti
                                </a>
                            </v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Status</v-list-item-title
                            >
                            <v-list-item-subtitle>
                                <v-chip
                                    :color="
                                        getStatusColor(selectedIzin?.status)
                                    "
                                    size="small"
                                    class="text-capitalize"
                                >
                                    {{ getStatusLabel(selectedIzin?.status) }}
                                </v-chip>
                            </v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item v-if="selectedIzin?.approver">
                            <v-list-item-title class="font-weight-bold"
                                >Diproses Oleh</v-list-item-title
                            >
                            <v-list-item-subtitle>{{
                                selectedIzin.approver.name
                            }}</v-list-item-subtitle>
                        </v-list-item>
                    </v-list>
                </v-card-text>

                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        color="primary"
                        variant="flat"
                        @click="detailDialog = false"
                    >
                        Tutup
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </SupervisorsDashboardLayout>
</template>
