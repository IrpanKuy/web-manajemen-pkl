<script setup>
import { ref, watch } from "vue";
import { router, useForm } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";
import Swal from "sweetalert2";

// --- PROPS ---
const props = defineProps({
    pengajuans: Object,
    summary: Object,
    filters: Object,
    mitras: Array,
});

// --- STATE ---
const search = ref(props.filters?.search || "");
const filterStatus = ref(props.filters?.status || null);
const filterMitra = ref(props.filters?.mitra_id || null);

// --- OPTIONS ---
const statusOptions = [
    { value: null, title: "Semua Status" },
    { value: "pending", title: "Pending" },
    { value: "diterima", title: "Diterima" },
    { value: "ditolak", title: "Ditolak" },
];

// --- HEADERS ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Tanggal Ajuan", key: "tgl_ajuan" },
    { title: "Siswa", key: "siswa_info" },
    { title: "Mitra Industri", key: "mitra" },
    { title: "Alasan Pengeluaran", key: "alasan_pengeluaran" },
    { title: "Status", key: "status", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
];

// --- FILTER ---
const applyFilters = () => {
    router.get(
        route("pengajuan-pengeluaran.index"),
        {
            search: search.value || undefined,
            status: filterStatus.value || undefined,
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

watch([filterStatus, filterMitra], applyFilters);

// --- ACTIONS ---
const handleApprove = (item) => {
    Swal.fire({
        title: "Setujui Pengeluaran?",
        html: `
            <p>Anda yakin ingin menyetujui pengeluaran siswa <strong>${item.siswa?.user?.name}</strong>?</p>
            <p class="text-red-500 mt-2"><strong>Perhatian:</strong> Status PKL siswa akan diubah menjadi GAGAL.</p>
        `,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#22c55e",
        cancelButtonColor: "#6b7280",
        confirmButtonText: "Ya, Setujui",
        cancelButtonText: "Batal",
    }).then((result) => {
        if (result.isConfirmed) {
            router.post(
                route("pengajuan-pengeluaran.approve", item.id),
                {},
                {
                    onSuccess: () => {
                        Swal.fire({
                            icon: "success",
                            title: "Berhasil!",
                            text: "Pengajuan pengeluaran telah disetujui. Status PKL siswa diubah menjadi gagal.",
                            timer: 2000,
                            showConfirmButton: false,
                        });
                    },
                }
            );
        }
    });
};

const handleReject = (item) => {
    Swal.fire({
        title: "Tolak Pengeluaran?",
        html: `Anda yakin ingin menolak pengeluaran siswa <strong>${item.siswa?.user?.name}</strong>?`,
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#ef4444",
        cancelButtonColor: "#6b7280",
        confirmButtonText: "Ya, Tolak",
        cancelButtonText: "Batal",
    }).then((result) => {
        if (result.isConfirmed) {
            router.post(
                route("pengajuan-pengeluaran.reject", item.id),
                {},
                {
                    onSuccess: () => {
                        Swal.fire({
                            icon: "success",
                            title: "Berhasil!",
                            text: "Pengajuan pengeluaran telah ditolak.",
                            timer: 2000,
                            showConfirmButton: false,
                        });
                    },
                }
            );
        }
    });
};

// --- HELPERS ---
const getStatusColor = (status) => {
    if (status === "diterima") return "success";
    if (status === "ditolak") return "error";
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
        title: "Pengajuan Pengeluaran Siswa",
        disabled: false,
        href: route("pengajuan-pengeluaran.index"),
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
                    Daftar Pengajuan Pengeluaran Siswa
                </h3>
            </v-card-title>

            <!-- SUMMARY -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Pengajuan</div>
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
                    <div class="text-caption text-grey">Diterima</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ props.summary?.diterima || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-red-500" elevation="2">
                    <div class="text-caption text-grey">Ditolak</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ props.summary?.ditolak || 0 }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
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
                :items="props.pengajuans?.data || []"
                class="elevation-0 border"
                hover
            >
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <template v-slot:item.tgl_ajuan="{ item }">
                    <div style="min-width: 100px">
                        {{ formatDate(item.tgl_ajuan) }}
                    </div>
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
                        {{ item.mitra?.nama_instansi || "-" }}
                    </div>
                </template>

                <template v-slot:item.alasan_pengeluaran="{ item }">
                    <div style="min-width: 200px; max-width: 300px">
                        <span class="text-wrap">{{
                            item.alasan_pengeluaran || "-"
                        }}</span>
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
                    <div v-if="item.status === 'pending'" class="d-flex gap-2">
                        <v-btn
                            color="success"
                            size="x-small"
                            variant="flat"
                            prepend-icon="mdi-check"
                            @click="handleApprove(item)"
                        >
                            Setujui
                        </v-btn>
                        <v-btn
                            color="error"
                            size="x-small"
                            variant="flat"
                            prepend-icon="mdi-close"
                            @click="handleReject(item)"
                        >
                            Tolak
                        </v-btn>
                    </div>
                    <span v-else class="text-grey text-caption">-</span>
                </template>
            </v-data-table>
        </v-card>
    </PendampingDashboardLayout>
</template>
