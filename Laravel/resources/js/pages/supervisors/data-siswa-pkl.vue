<script setup>
import { ref, watch, computed } from "vue";
import { router, useForm } from "@inertiajs/vue3";
import SupervisorsDashboardLayout from "../layouts/SupervisorsDashboardLayout.vue";
import Swal from "sweetalert2";

// --- PROPS ---
const props = defineProps({
    placements: Object,
    mitra: Object,
    filters: Object,
});

// --- STATE ---
const search = ref(props.filters?.search || "");
const filterStatus = ref(props.filters?.status || null);

// --- DIALOG STATE ---
const dialogPengeluaran = ref(false);
const dialogBeriNilai = ref(false);
const selectedSiswa = ref(null);

// --- FORM PENGELUARAN ---
const form = useForm({
    profile_siswa_id: null,
    alasan_pengeluaran: "",
});

// --- FORM BERI NILAI ---
const formNilai = useForm({
    nilai: null,
    komentar_supervisor: "",
});

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
    { title: "Email", key: "email" },
    { title: "No HP", key: "phone" },
    { title: "Pembimbing", key: "pembimbing" },
    { title: "Periode PKL", key: "periode" },
    { title: "Status", key: "status", align: "center" },
    { title: "Nilai", key: "nilai", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
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

// --- ACTIONS: PENGELUARAN ---
const openPengeluaranDialog = (item) => {
    selectedSiswa.value = item;
    form.reset();
    form.clearErrors();
    form.profile_siswa_id = item.siswa?.id;
    dialogPengeluaran.value = true;
};

const submitPengeluaran = () => {
    form.post(route("pengajuan-pengeluaran.store"), {
        onSuccess: () => {
            dialogPengeluaran.value = false;
            Swal.fire({
                title: "Pengajuan Berhasil!",
                text: "Kamu akan segera dihubungi pendamping siswa.",
                icon: "success",
                confirmButtonText: "OK",
            });
        },
        onError: () => {
            Swal.fire({
                title: "Gagal!",
                text: "Terjadi kesalahan saat mengirim pengajuan.",
                icon: "error",
            });
        },
    });
};

// --- ACTIONS: BERI NILAI ---
const openBeriNilaiDialog = (item) => {
    selectedSiswa.value = item;
    formNilai.reset();
    formNilai.clearErrors();
    // Pre-fill if already has nilai
    if (item.nilai !== null) {
        formNilai.nilai = item.nilai;
        formNilai.komentar_supervisor = item.komentar_supervisor || "";
    }
    dialogBeriNilai.value = true;
};

const submitBeriNilai = () => {
    formNilai.post(route("data-siswa-pkl.beri-nilai", selectedSiswa.value.id), {
        onSuccess: () => {
            dialogBeriNilai.value = false;
            Swal.fire({
                title: "Nilai Tersimpan!",
                text: "Nilai siswa berhasil disimpan.",
                icon: "success",
                confirmButtonText: "OK",
            });
        },
        onError: () => {
            Swal.fire({
                title: "Gagal!",
                text: "Terjadi kesalahan saat menyimpan nilai.",
                icon: "error",
            });
        },
    });
};

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

                <template v-slot:item.email="{ item }">
                    {{ item.siswa?.user?.email || "-" }}
                </template>

                <template v-slot:item.phone="{ item }">
                    {{ item.siswa?.user?.phone || "-" }}
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

                <!-- KOLOM NILAI -->
                <template v-slot:item.nilai="{ item }">
                    <template v-if="item.status === 'selesai'">
                        <v-chip
                            v-if="item.nilai !== null"
                            :color="item.nilai >= 70 ? 'success' : 'warning'"
                            size="small"
                        >
                            {{ item.nilai }}
                        </v-chip>
                        <span v-else class="text-grey text-caption"
                            >Belum dinilai</span
                        >
                    </template>
                    <span v-else class="text-grey text-caption">-</span>
                </template>

                <!-- AKSI: Berdasarkan Status -->
                <template v-slot:item.actions="{ item }">
                    <!-- Status Berjalan: Ajukan Pengeluaran -->
                    <v-btn
                        v-if="item.status === 'berjalan'"
                        color="error"
                        size="x-small"
                        variant="flat"
                        prepend-icon="mdi-account-remove"
                        @click="openPengeluaranDialog(item)"
                    >
                        Ajukan Pengeluaran
                    </v-btn>
                    <!-- Status Selesai: Beri Nilai -->
                    <v-btn
                        v-else-if="item.status === 'selesai'"
                        :color="item.nilai !== null ? 'secondary' : 'primary'"
                        size="x-small"
                        variant="flat"
                        prepend-icon="mdi-star-check"
                        @click="openBeriNilaiDialog(item)"
                    >
                        {{ item.nilai !== null ? "Edit Nilai" : "Beri Nilai" }}
                    </v-btn>
                    <!-- Status lain -->
                    <span v-else class="text-grey text-caption">-</span>
                </template>
            </v-data-table>
        </v-card>

        <!-- DIALOG FORM PENGAJUAN PENGELUARAN -->
        <v-dialog v-model="dialogPengeluaran" max-width="500px" persistent>
            <v-card>
                <v-card-title
                    class="bg-error text-white d-flex justify-space-between align-center"
                >
                    <span class="text-h6">Ajukan Pengeluaran Siswa</span>
                    <v-btn
                        icon="mdi-close"
                        variant="text"
                        density="compact"
                        color="white"
                        @click="dialogPengeluaran = false"
                    ></v-btn>
                </v-card-title>

                <v-card-text class="pt-4">
                    <!-- Info Siswa -->
                    <div class="mb-4 pa-3 bg-grey-lighten-4 rounded">
                        <div class="font-weight-bold">
                            {{ selectedSiswa?.siswa?.user?.name }}
                        </div>
                        <div class="text-caption text-grey">
                            {{
                                selectedSiswa?.siswa?.jurusan?.nama_jurusan ||
                                "-"
                            }}
                        </div>
                        <div class="text-caption text-grey">
                            Email:
                            {{ selectedSiswa?.siswa?.user?.email || "-" }}
                        </div>
                    </div>

                    <v-form @submit.prevent="submitPengeluaran">
                        <!-- Alasan Pengeluaran -->
                        <v-textarea
                            v-model="form.alasan_pengeluaran"
                            label="Alasan Pengeluaran"
                            variant="outlined"
                            density="compact"
                            rows="4"
                            :error-messages="form.errors.alasan_pengeluaran"
                            prepend-inner-icon="mdi-text"
                        ></v-textarea>
                    </v-form>
                </v-card-text>

                <v-card-actions class="px-4 pb-4">
                    <v-spacer></v-spacer>
                    <v-btn
                        variant="text"
                        color="grey-darken-1"
                        @click="dialogPengeluaran = false"
                    >
                        Batal
                    </v-btn>
                    <v-btn
                        color="error"
                        variant="elevated"
                        @click="submitPengeluaran"
                        :loading="form.processing"
                        prepend-icon="mdi-send"
                    >
                        Ajukan
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- DIALOG FORM BERI NILAI -->
        <v-dialog v-model="dialogBeriNilai" max-width="500px" persistent>
            <v-card>
                <v-card-title
                    class="bg-primary text-white d-flex justify-space-between align-center"
                >
                    <span class="text-h6">Beri Nilai Siswa</span>
                    <v-btn
                        icon="mdi-close"
                        variant="text"
                        density="compact"
                        color="white"
                        @click="dialogBeriNilai = false"
                    ></v-btn>
                </v-card-title>

                <v-card-text class="pt-4">
                    <!-- Info Siswa -->
                    <div class="mb-4 pa-3 bg-grey-lighten-4 rounded">
                        <div class="font-weight-bold">
                            {{ selectedSiswa?.siswa?.user?.name }}
                        </div>
                        <div class="text-caption text-grey">
                            {{
                                selectedSiswa?.siswa?.jurusan?.nama_jurusan ||
                                "-"
                            }}
                        </div>
                        <div class="text-caption text-grey">
                            Periode:
                            {{ formatDate(selectedSiswa?.tgl_mulai) }} -
                            {{ formatDate(selectedSiswa?.tgl_selesai) }}
                        </div>
                    </div>

                    <v-form @submit.prevent="submitBeriNilai">
                        <!-- Nilai -->
                        <v-text-field
                            v-model.number="formNilai.nilai"
                            label="Nilai (0-100)"
                            variant="outlined"
                            density="compact"
                            type="number"
                            min="0"
                            max="100"
                            :error-messages="formNilai.errors.nilai"
                            prepend-inner-icon="mdi-star"
                            class="mb-4"
                        ></v-text-field>

                        <!-- Komentar (Opsional) -->
                        <v-textarea
                            v-model="formNilai.komentar_supervisor"
                            label="Komentar (Opsional)"
                            variant="outlined"
                            density="compact"
                            rows="3"
                            :error-messages="
                                formNilai.errors.komentar_supervisor
                            "
                            prepend-inner-icon="mdi-comment-text"
                            placeholder="Berikan komentar atau catatan untuk siswa..."
                        ></v-textarea>
                    </v-form>
                </v-card-text>

                <v-card-actions class="px-4 pb-4">
                    <v-spacer></v-spacer>
                    <v-btn
                        variant="text"
                        color="grey-darken-1"
                        @click="dialogBeriNilai = false"
                    >
                        Batal
                    </v-btn>
                    <v-btn
                        color="primary"
                        variant="elevated"
                        @click="submitBeriNilai"
                        :loading="formNilai.processing"
                        prepend-icon="mdi-check"
                    >
                        Simpan Nilai
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </SupervisorsDashboardLayout>
</template>
