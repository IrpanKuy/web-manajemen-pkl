<script setup>
import { computed, ref, watch } from "vue";
import { useForm, router } from "@inertiajs/vue3";
import Swal from "sweetalert2";
import PembimbingDashboardLayout from "../layouts/pembimbingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    jurnals: Object, // Data Paginator
    siswaList: Array, // List siswa untuk filter
    filters: Object, // Current filters
});

// --- STATE LOKAL ---
const search = ref(props.filters?.search || "");
const filterSiswa = ref(props.filters?.siswa_id || null);
const filterBulan = ref(props.filters?.bulan || "");

// --- DIALOG STATE ---
const dialogRevisi = ref(false);
const dialogDetail = ref(false);
const selectedJurnal = ref(null);
const komentarRevisi = ref("");

// --- FILTER OPTIONS ---
const siswaOptions = computed(() => {
    return [{ id: null, name: "Semua Siswa" }, ...props.siswaList];
});

// --- STATUS COUNTS ---
const statusCounts = computed(() => {
    const list = props.jurnals?.data || [];
    return list.reduce(
        (acc, item) => {
            const status = item.status || "pending";
            if (!acc[status]) acc[status] = 0;
            acc[status]++;
            return acc;
        },
        { pending: 0, disetujui: 0, revisi: 0 }
    );
});

// --- HEADER TABEL ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Tanggal", key: "tanggal" },
    { title: "Siswa", key: "siswa_info" },
    { title: "Judul Jurnal", key: "judul" },
    { title: "Status", key: "status", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
];

// --- FUNGSI FILTER ---
const applyFilters = () => {
    router.get(
        route("jurnal-siswa.index"),
        {
            search: search.value || undefined,
            siswa_id: filterSiswa.value || undefined,
            bulan: filterBulan.value || undefined,
        },
        {
            preserveState: true,
            replace: true,
        }
    );
};

// Debounce search
let searchTimeout = null;
watch(search, () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applyFilters, 500);
});

watch([filterSiswa, filterBulan], () => {
    applyFilters();
});

// --- FUNGSI AKSI ---

// 1. Lihat Foto
const openFoto = (path) => {
    if (path) {
        window.open(`/storage/${path}`, "_blank");
    }
};

// 2. Lihat Detail Jurnal
const openDetail = (jurnal) => {
    selectedJurnal.value = jurnal;
    dialogDetail.value = true;
};

// 3. Setujui Jurnal
const setujuiJurnal = (id) => {
    Swal.fire({
        title: "Setujui Jurnal?",
        text: "Jurnal akan ditandai sebagai disetujui",
        icon: "question",
        showCancelButton: true,
        cancelButtonText: "Batal",
        confirmButtonText: "Ya, Setujui",
        confirmButtonColor: "#4CAF50",
    }).then((result) => {
        if (result.isConfirmed) {
            router.put(route("jurnal-siswa.update", id), {
                status: "disetujui",
            });
        }
    });
};

// 4. Buka Dialog Revisi
const bukaDialogRevisi = (jurnal) => {
    selectedJurnal.value = jurnal;
    komentarRevisi.value = "";
    dialogRevisi.value = true;
};

// 5. Submit Revisi
const submitRevisi = () => {
    if (!komentarRevisi.value.trim()) {
        return Swal.fire("Gagal!", "Komentar revisi wajib diisi", "error");
    }

    router.put(route("jurnal-siswa.update", selectedJurnal.value.id), {
        status: "revisi",
        komentar: komentarRevisi.value,
    });

    dialogRevisi.value = false;
};

// --- HELPER ---
const getStatusColor = (status) => {
    if (status === "disetujui") return "success";
    if (status === "revisi") return "error";
    return "warning";
};

const formatDate = (date) => {
    return new Date(date).toLocaleDateString("id-ID", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
    });
};

const title = [
    {
        title: "Persetujuan Jurnal Siswa",
        disabled: false,
        href: route("jurnal-siswa.index"),
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
                    Daftar Jurnal Harian Siswa
                </h3>
            </v-card-title>

            <!-- STATUS SUMMARY CARDS -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Jurnal</div>
                    <div class="text-h4 font-weight-bold text-blue-600">
                        {{ props.jurnals?.data?.length || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-yellow-500" elevation="2">
                    <div class="text-caption text-grey">Menunggu Review</div>
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
                    <div class="text-caption text-grey">Revisi</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ statusCounts.revisi }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER SECTION -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                <v-text-field
                    v-model="search"
                    label="Cari Siswa / Judul Jurnal"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-text-field>
                <v-select
                    :items="siswaOptions"
                    v-model="filterSiswa"
                    label="Filter Siswa"
                    item-title="name"
                    item-value="id"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-select>
                <v-text-field
                    v-model="filterBulan"
                    label="Filter Bulan"
                    type="month"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-text-field>
            </div>

            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :items="props.jurnals?.data || []"
                class="elevation-0 border"
                hover
            >
                <!-- No -->
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <!-- Tanggal -->
                <template v-slot:item.tanggal="{ item }">
                    <div style="min-width: 120px">
                        {{ formatDate(item.tanggal) }}
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

                <!-- Judul -->
                <template v-slot:item.judul="{ item }">
                    <div style="min-width: 200px">
                        <span
                            class="font-weight-medium cursor-pointer hover:text-blue-600"
                            @click="openDetail(item)"
                        >
                            {{ item.judul }}
                        </span>
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
                    <v-tooltip
                        v-if="item.status === 'revisi' && item.komentar"
                        activator="parent"
                        location="bottom"
                    >
                        Komentar: {{ item.komentar }}
                    </v-tooltip>
                </template>

                <!-- Aksi Dropdown -->
                <template v-slot:item.actions="{ item }">
                    <v-menu>
                        <template v-slot:activator="{ props }">
                            <v-btn
                                v-bind="props"
                                icon="mdi-dots-vertical"
                                variant="text"
                                size="small"
                            ></v-btn>
                        </template>
                        <v-list density="compact">
                            <v-list-item
                                prepend-icon="mdi-eye"
                                title="Lihat Detail"
                                @click="openDetail(item)"
                            ></v-list-item>
                            <v-list-item
                                v-if="item.foto_kegiatan"
                                prepend-icon="mdi-image"
                                title="Lihat Foto"
                                @click="openFoto(item.foto_kegiatan)"
                            ></v-list-item>
                            <v-divider
                                v-if="!item.status || item.status === 'pending'"
                            ></v-divider>
                            <v-list-item
                                v-if="!item.status || item.status === 'pending'"
                                prepend-icon="mdi-check"
                                title="Setujui"
                                class="text-success"
                                @click="setujuiJurnal(item.id)"
                            ></v-list-item>
                            <v-list-item
                                v-if="!item.status || item.status === 'pending'"
                                prepend-icon="mdi-pencil"
                                title="Revisi"
                                class="text-error"
                                @click="bukaDialogRevisi(item)"
                            ></v-list-item>
                        </v-list>
                    </v-menu>
                </template>
            </v-data-table>
        </v-card>

        <!-- DIALOG REVISI -->
        <transition name="fade">
            <div
                v-if="dialogRevisi"
                class="fixed inset-0 bg-black/50 flex items-center justify-center z-50 px-4"
            >
                <div
                    class="bg-white rounded-lg shadow-lg max-w-lg w-full animate-scale overflow-hidden"
                >
                    <v-card flat>
                        <v-card-title class="text-h6 bg-error text-white">
                            Revisi Jurnal
                        </v-card-title>
                        <v-card-text class="pt-4">
                            <p class="mb-2">
                                Berikan komentar revisi untuk jurnal:
                                <strong>{{ selectedJurnal?.judul }}</strong>
                            </p>
                            <v-textarea
                                v-model="komentarRevisi"
                                label="Komentar Revisi"
                                variant="outlined"
                                rows="3"
                                auto-grow
                                placeholder="Jelaskan apa yang perlu diperbaiki..."
                            ></v-textarea>
                        </v-card-text>
                        <v-card-actions class="px-4 pb-4">
                            <v-spacer></v-spacer>
                            <v-btn variant="text" @click="dialogRevisi = false">
                                Batal
                            </v-btn>
                            <v-btn
                                color="error"
                                variant="elevated"
                                @click="submitRevisi"
                            >
                                Kirim Revisi
                            </v-btn>
                        </v-card-actions>
                    </v-card>
                </div>
            </div>
        </transition>

        <!-- DIALOG DETAIL -->
        <v-dialog v-model="dialogDetail" max-width="600px">
            <v-card v-if="selectedJurnal">
                <v-card-title class="bg-primary text-white">
                    <span class="text-h6">Detail Jurnal</span>
                </v-card-title>
                <v-card-text class="pt-4">
                    <div class="space-y-3">
                        <div>
                            <strong>Tanggal:</strong>
                            {{ formatDate(selectedJurnal.tanggal) }}
                        </div>
                        <div>
                            <strong>Siswa:</strong>
                            {{ selectedJurnal.siswa?.user?.name }}
                        </div>
                        <div>
                            <strong>Judul:</strong>
                            {{ selectedJurnal.judul }}
                        </div>
                        <div>
                            <strong>Deskripsi:</strong>
                            <p class="mt-1 text-gray-700">
                                {{ selectedJurnal.deskripsi }}
                            </p>
                        </div>
                        <div v-if="selectedJurnal.komentar">
                            <strong>Komentar Pembimbing:</strong>
                            <p class="mt-1 text-gray-700">
                                {{ selectedJurnal.komentar }}
                            </p>
                        </div>
                        <div>
                            <strong>Status:</strong>
                            <v-chip
                                :color="getStatusColor(selectedJurnal.status)"
                                size="small"
                                class="ml-2 text-capitalize"
                            >
                                {{ selectedJurnal.status || "pending" }}
                            </v-chip>
                        </div>
                    </div>
                </v-card-text>
                <v-card-actions class="pb-4 px-4">
                    <v-btn
                        v-if="selectedJurnal.foto_kegiatan"
                        color="primary"
                        variant="text"
                        @click="openFoto(selectedJurnal.foto_kegiatan)"
                    >
                        Lihat Foto
                    </v-btn>
                    <v-spacer></v-spacer>
                    <v-btn
                        v-if="
                            !selectedJurnal?.status ||
                            selectedJurnal?.status === 'pending'
                        "
                        color="success"
                        variant="flat"
                        @click="
                            dialogDetail = false;
                            setujuiJurnal(selectedJurnal.id);
                        "
                    >
                        Setujui
                    </v-btn>
                    <v-btn
                        v-if="
                            !selectedJurnal?.status ||
                            selectedJurnal?.status === 'pending'
                        "
                        color="error"
                        variant="flat"
                        @click="
                            dialogDetail = false;
                            bukaDialogRevisi(selectedJurnal);
                        "
                    >
                        Revisi
                    </v-btn>
                    <v-btn
                        color="grey-darken-1"
                        variant="text"
                        @click="dialogDetail = false"
                    >
                        Tutup
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </PembimbingDashboardLayout>
</template>

<style scoped>
.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

.fade-enter-active,
.fade-leave-active {
    transition: 0.2s;
}

.animate-scale {
    animation: scaleIn 0.2s ease;
}

@keyframes scaleIn {
    0% {
        transform: scale(0.95);
        opacity: 0;
    }
    100% {
        transform: scale(1);
        opacity: 1;
    }
}
</style>
