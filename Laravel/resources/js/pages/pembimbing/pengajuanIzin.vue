<script setup>
import { computed, ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
import Swal from "sweetalert2";
import PembimbingDashboardLayout from "../layouts/pembimbingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    izins: Object, // Data Paginator
    filters: Object,
});

// --- STATE LOKAL ---
const search = ref(props.filters?.search || "");
const filterStatus = ref(props.filters?.status || null);

// --- DIALOG STATE ---
const dialogBukti = ref(false);
const selectedBukti = ref(null);

// --- STATUS OPTIONS ---
const statusOptions = [
    { value: null, title: "Semua Status" },
    { value: "pending", title: "Pending" },
    { value: "approved", title: "Disetujui" },
    { value: "rejected", title: "Ditolak" },
];

// --- STATUS COUNTS ---
const statusCounts = computed(() => {
    const list = props.izins?.data || [];
    return list.reduce(
        (acc, item) => {
            const status = item.status || "pending";
            if (!acc[status]) acc[status] = 0;
            acc[status]++;
            return acc;
        },
        { pending: 0, approved: 0, rejected: 0 }
    );
});

// --- HEADER TABEL ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Siswa", key: "siswa_info" },
    { title: "Tanggal Izin", key: "tanggal" },
    { title: "Durasi", key: "durasi_hari", align: "center" },
    { title: "Keterangan", key: "keterangan" },
    { title: "Bukti", key: "bukti_path", align: "center", sortable: false },
    { title: "Status", key: "status", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
];

// --- FUNGSI FILTER ---
const applyFilters = () => {
    router.get(
        route("pengajuan-izin.index"),
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

// --- FUNGSI AKSI ---

// 1. Lihat Bukti
const openBukti = (path) => {
    if (path) {
        window.open(`/storage/${path}`, "_blank");
    }
};

// 2. Setujui Izin
const setujuiIzin = (id) => {
    Swal.fire({
        title: "Setujui Pengajuan Izin?",
        text: "Izin siswa akan disetujui",
        icon: "question",
        showCancelButton: true,
        cancelButtonText: "Batal",
        confirmButtonText: "Ya, Setujui",
        confirmButtonColor: "#4CAF50",
    }).then((result) => {
        if (result.isConfirmed) {
            router.put(route("pengajuan-izin.update", id), {
                status: "approved",
            });
        }
    });
};

// 3. Tolak Izin
const tolakIzin = (id) => {
    Swal.fire({
        title: "Tolak Pengajuan Izin?",
        text: "Izin siswa akan ditolak",
        icon: "warning",
        showCancelButton: true,
        cancelButtonText: "Batal",
        confirmButtonText: "Ya, Tolak",
        confirmButtonColor: "#F44336",
    }).then((result) => {
        if (result.isConfirmed) {
            router.put(route("pengajuan-izin.update", id), {
                status: "rejected",
            });
        }
    });
};

// --- HELPER ---
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
        title: "Pengajuan Izin Siswa",
        disabled: false,
        href: route("pengajuan-izin.index"),
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
                    Daftar Pengajuan Izin Siswa
                </h3>
            </v-card-title>

            <!-- STATUS SUMMARY CARDS -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Pengajuan</div>
                    <div class="text-h4 font-weight-bold text-blue-600">
                        {{ props.izins?.data?.length || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-yellow-500" elevation="2">
                    <div class="text-caption text-grey">Menunggu</div>
                    <div class="text-h4 font-weight-bold text-yellow-600">
                        {{ statusCounts.pending }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-green-500" elevation="2">
                    <div class="text-caption text-grey">Disetujui</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ statusCounts.approved }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-red-500" elevation="2">
                    <div class="text-caption text-grey">Ditolak</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ statusCounts.rejected }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER SECTION -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
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
                :items="props.izins?.data || []"
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
                            {{ item.siswa?.user?.name || "N/A" }}
                        </span>
                        <span class="text-caption text-grey">
                            {{ item.siswa?.jurusan?.nama_jurusan || "-" }}
                        </span>
                    </div>
                </template>

                <!-- Tanggal -->
                <template v-slot:item.tanggal="{ item }">
                    <div style="min-width: 140px">
                        {{ formatDate(item.tgl_mulai) }} -
                        {{ formatDate(item.tgl_selesai) }}
                    </div>
                </template>

                <!-- Durasi -->
                <template v-slot:item.durasi_hari="{ item }">
                    <v-chip color="info" size="small" variant="flat">
                        {{ item.durasi_hari }} hari
                    </v-chip>
                </template>

                <!-- Keterangan -->
                <template v-slot:item.keterangan="{ item }">
                    <div style="min-width: 200px; max-width: 300px">
                        <span class="text-wrap">{{
                            item.keterangan || "-"
                        }}</span>
                    </div>
                </template>

                <!-- Bukti -->
                <template v-slot:item.bukti_path="{ item }">
                    <v-tooltip text="Lihat Bukti" location="top">
                        <template v-slot:activator="{ props }">
                            <v-btn
                                v-bind="props"
                                icon="mdi-file-document"
                                color="primary"
                                variant="text"
                                size="small"
                                @click="openBukti(item.bukti_path)"
                                :disabled="!item.bukti_path"
                            ></v-btn>
                        </template>
                    </v-tooltip>
                </template>

                <!-- Status -->
                <template v-slot:item.status="{ item }">
                    <v-chip
                        :color="getStatusColor(item.status)"
                        size="small"
                        class="text-capitalize"
                    >
                        {{ getStatusLabel(item.status) }}
                    </v-chip>
                </template>

                <!-- Aksi -->
                <template v-slot:item.actions="{ item }">
                    <div
                        v-if="!item.status || item.status === 'pending'"
                        class="d-flex gap-2 justify-center flex-wrap"
                        style="min-width: 160px"
                    >
                        <v-btn
                            color="success"
                            size="x-small"
                            variant="flat"
                            prepend-icon="mdi-check"
                            @click="setujuiIzin(item.id)"
                        >
                            Setujui
                        </v-btn>
                        <v-btn
                            color="error"
                            size="x-small"
                            variant="flat"
                            prepend-icon="mdi-close"
                            @click="tolakIzin(item.id)"
                        >
                            Tolak
                        </v-btn>
                    </div>
                    <div v-else class="text-caption text-grey text-center">
                        {{ item.approver?.name || "Selesai" }}
                    </div>
                </template>
            </v-data-table>
        </v-card>
    </PembimbingDashboardLayout>
</template>
