<script setup>
import { computed, ref } from "vue";
import { router } from "@inertiajs/vue3";
import Swal from "sweetalert2";
import PembimbingDashboardLayout from "../layouts/pembimbingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    requests: Object, // Data Paginator
});

// --- STATUS COUNTS ---
const statusCounts = computed(() => {
    const list = props.requests?.data || [];
    return list.reduce(
        (acc, item) => {
            const status = item.status || "pending";
            if (!acc[status]) acc[status] = 0;
            acc[status]++;
            return acc;
        },
        { pending: 0, disetujui: 0, ditolak: 0 }
    );
});

// --- HEADER TABEL ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Tanggal", key: "created_at" },
    { title: "Siswa", key: "siswa_info" },
    { title: "Pembimbing Lama", key: "pembimbing_lama" },
    { title: "Alasan", key: "alasan" },
    { title: "Status", key: "status", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
];

// --- FUNGSI AKSI ---

// 1. Terima Permintaan
const terimaPermintaan = (id) => {
    Swal.fire({
        title: "Terima Permintaan?",
        text: "Anda akan menjadi pembimbing baru siswa ini",
        icon: "question",
        showCancelButton: true,
        cancelButtonText: "Batal",
        confirmButtonText: "Ya, Terima",
        confirmButtonColor: "#4CAF50",
    }).then((result) => {
        if (result.isConfirmed) {
            router.put(route("mentor-request.update", id), {
                status: "disetujui",
            });
        }
    });
};

// 2. Tolak Permintaan
const tolakPermintaan = (id) => {
    Swal.fire({
        title: "Tolak Permintaan?",
        text: "Permintaan ganti pembimbing akan ditolak",
        icon: "warning",
        showCancelButton: true,
        cancelButtonText: "Batal",
        confirmButtonText: "Ya, Tolak",
        confirmButtonColor: "#F44336",
    }).then((result) => {
        if (result.isConfirmed) {
            router.put(route("mentor-request.update", id), {
                status: "ditolak",
            });
        }
    });
};

// --- HELPER ---
const getStatusColor = (status) => {
    if (status === "disetujui") return "success";
    if (status === "ditolak") return "error";
    return "warning";
};

const formatDate = (date) => {
    return new Date(date).toLocaleDateString("id-ID", {
        year: "numeric",
        month: "long",
        day: "numeric",
    });
};

const title = [
    {
        title: "Permintaan Ganti Pembimbing",
        disabled: false,
        href: route("mentor-request.index"),
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
                    Daftar Permintaan Ganti Pembimbing
                </h3>
            </v-card-title>

            <!-- STATUS SUMMARY CARDS -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Permintaan</div>
                    <div class="text-h4 font-weight-bold text-blue-600">
                        {{ props.requests?.data?.length || 0 }}
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
                        {{ statusCounts.disetujui }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-red-500" elevation="2">
                    <div class="text-caption text-grey">Ditolak</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ statusCounts.ditolak }}
                    </div>
                </v-card>
            </div>

            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :items="props.requests?.data || []"
                class="elevation-0 border"
                hover
            >
                <!-- No -->
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <!-- Tanggal -->
                <template v-slot:item.created_at="{ item }">
                    <div style="min-width: 120px">
                        {{ formatDate(item.created_at) }}
                    </div>
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

                <!-- Pembimbing Lama -->
                <template v-slot:item.pembimbing_lama="{ item }">
                    <span>{{ item.pembimbing_lama?.name || "Belum ada" }}</span>
                </template>

                <!-- Alasan -->
                <template v-slot:item.alasan="{ item }">
                    <div style="min-width: 250px; max-width: 500px">
                        <span class="text-wrap">{{ item.alasan || "-" }}</span>
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
                            @click="terimaPermintaan(item.id)"
                        >
                            Terima
                        </v-btn>
                        <v-btn
                            color="error"
                            size="x-small"
                            variant="flat"
                            prepend-icon="mdi-close"
                            @click="tolakPermintaan(item.id)"
                        >
                            Tolak
                        </v-btn>
                    </div>
                    <div v-else class="text-caption text-grey text-center">
                        Selesai
                    </div>
                </template>
            </v-data-table>
        </v-card>
    </PembimbingDashboardLayout>
</template>
