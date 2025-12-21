<script setup>
import SupervisorsDashboardLayout from "../layouts/SupervisorsDashboardLayout.vue";
import { computed, ref } from "vue";
import { router, usePage } from "@inertiajs/vue3";
import Swal from "sweetalert2";

const page = usePage();

// Props dari Controller Laravel
const props = defineProps({
    pengajuanMasukSiswa: Array,
    mitra: Array,
});

const items = computed(() => props.pengajuanMasukSiswa);

// Menghitung jumlah status secara otomatis
const statusCounts = computed(() => {
    const list = items.value || []; // Pastikan list tidak null/undefined

    return list.reduce(
        (acc, item) => {
            // Ambil status, jika null anggap sebagai 'pending' (sesuaikan logika)
            const status = item.status || "pending";

            // Jika key status belum ada di accumulator, buat 0
            if (!acc[status]) {
                acc[status] = 0;
            }

            // Tambah hitungan
            acc[status]++;

            return acc;
        },
        {
            // Default values (agar di template tidak error jika datanya 0)
            pending: 0,
            diterima: 0,
            ditolak: 0,
        }
    );
});

// Konfigurasi Header Tabel Vuetify - Hapus CV dan Deskripsi
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Siswa", key: "siswa_info" }, // Custom slot untuk gabungan Nama/NISN/Kelas
    { title: "Tanggal Ajuan", key: "tgl_ajuan" },
    { title: "Durasi", key: "durasi" },
    { title: "Status", key: "status", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
];

// --- State untuk Dialog Penolakan ---
const dialogTolak = ref(false);
const formTolak = ref({
    id: null,
    alasan: null,
});
const loading = ref(false);

// --- State untuk Dialog Detail ---
const detailDialog = ref(false);
const selectedItem = ref(null);

// --- Fungsi Aksi ---

// 1. Fungsi Buka CV
const openCv = (path) => {
    // Asumsi file disimpan di public/storage. Sesuaikan path jika berbeda.
    window.open(`/storage/${path}`, "_blank");
};

// 2. Fungsi Buka Detail
const openDetail = (item) => {
    selectedItem.value = item;
    detailDialog.value = true;
};

// 3. Fungsi Terima Pengajuan
const terimaPengajuan = (id) => {
    Swal.fire({
        title: "Terima Siswa?",
        text: "Kamu perlu persetujuan pendamping jika ingin membatalkan terima",
        icon: "warning",
        showCancelButton: true,
        cancelButtonText: "batal",
        confirmButtonText: "Ya, terima",
    }).then((result) => {
        if (result.isConfirmed) {
            router.put(route("pengajuan-masuk.update", id), {
                status: "diterima",
            });
        }
    });
};

// 4. Fungsi Persiapan Tolak (Buka Dialog)
const bukaDialogTolak = (id) => {
    formTolak.value.id = id;
    formTolak.value.alasan = "";
    dialogTolak.value = true;
};

// 5. Fungsi Submit Tolak
const submitTolak = () => {
    if (!formTolak.value.alasan) {
        return Swal.fire(
            "Gagal Menolak!",
            "Alasan penolakan wajib diisi",
            "error"
        );
    }

    Swal.fire({
        title: "Tolak Siswa?",
        text: "Kamu yakin untuk menolak siswa?",
        icon: "warning",
        showCancelButton: true,
        cancelButtonText: "batal",
        confirmButtonText: "Ya, tolak",
    }).then((result) => {
        if (result.isConfirmed) {
            router.put(route("pengajuan-masuk.update", formTolak.value.id), {
                status: "ditolak",
                alasan_penolakan: formTolak.value.alasan,
            });
        }
    });

    dialogTolak.value = false;
};

const title = [
    {
        title: "Pengajuan Masuk Siswa",
        disabled: false,
        href: route("pengajuan-masuk.index"),
    },
];

// Helper untuk warna status
const getStatusColor = (status) => {
    if (status === "diterima") return "success";
    if (status === "ditolak") return "error";
    return "warning";
};

// Format date helper
const formatDate = (date) => {
    return new Date(date).toLocaleDateString("id-ID", {
        year: "numeric",
        month: "short",
        day: "numeric",
    });
};
</script>

<template>
    <SupervisorsDashboardLayout>
        <template #headerTitle>
            <v-breadcrumbs
                :items="title"
                class="text-base md:text-xl flex-wrap"
            >
                <template v-slot:divider>
                    <v-icon icon="mdi-chevron-right"></v-icon>
                </template>
            </v-breadcrumbs>
        </template>

        <v-card class="pa-4 border border-gray-700" elevation="2" rounded="lg">
            <v-card-title>
                <h3 class="text-lg md:text-x mb-2 l font-bold text-wrap">
                    Daftar Pengajuan Masuk Siswa
                </h3>
            </v-card-title>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Kuota Siswa</div>
                    <div class="text-h4 font-weight-bold text-blue-600">
                        {{ props.mitra.kuota }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-yellow-500" elevation="2">
                    <div class="text-caption text-grey">
                        Menunggu Konfirmasi
                    </div>
                    <div class="text-h4 font-weight-bold text-yellow-600">
                        {{ statusCounts.pending }}
                    </div>
                </v-card>

                <v-card class="pa-4 border-l-4 border-green-500" elevation="2">
                    <div class="text-caption text-grey">Siswa Diterima</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ statusCounts.diterima }}
                    </div>
                </v-card>

                <v-card class="pa-4 border-l-4 border-red-500" elevation="2">
                    <div class="text-caption text-grey">Siswa Ditolak</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ statusCounts.ditolak }}
                    </div>
                </v-card>
            </div>
            <v-data-table
                :headers="headers"
                :items="items"
                :loading="loading"
                class="elevation-0 border"
            >
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <template v-slot:item.siswa_info="{ item }">
                    <div
                        class="d-flex flex-column py-2"
                        style="min-width: 180px"
                    >
                        <span class="font-weight-bold">{{
                            item.siswa.user.name || "No Name"
                        }}</span>
                        <span class="text-caption text-grey">
                            Jurusan:
                            {{ item.siswa.jurusan.nama_jurusan || "-" }}
                        </span>
                    </div>
                </template>

                <template v-slot:item.tgl_ajuan="{ item }">
                    <div style="min-width: 100px">
                        {{
                            new Date(item.tgl_ajuan).toLocaleDateString("id-ID")
                        }}
                    </div>
                </template>
                <template v-slot:item.durasi="{ item }">
                    {{ item.durasi }} Bulan
                </template>

                <template v-slot:item.status="{ item }">
                    <v-chip
                        :color="getStatusColor(item.status)"
                        size="small"
                        class="text-capitalize"
                    >
                        {{ item.status || "pending" }}
                    </v-chip>
                    <v-tooltip
                        v-if="item.status === 'ditolak'"
                        activator="parent"
                        location="bottom"
                    >
                        Alasan: {{ item.alasan_penolakan }}
                    </v-tooltip>
                </template>

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
                                v-if="item.cv_path"
                                prepend-icon="mdi-file-document"
                                title="Lihat CV"
                                @click="openCv(item.cv_path)"
                            ></v-list-item>
                            <v-divider
                                v-if="!item.status || item.status === 'pending'"
                            ></v-divider>
                            <v-list-item
                                v-if="!item.status || item.status === 'pending'"
                                prepend-icon="mdi-check"
                                title="Terima"
                                class="text-success"
                                @click="terimaPengajuan(item.id)"
                            ></v-list-item>
                            <v-list-item
                                v-if="!item.status || item.status === 'pending'"
                                prepend-icon="mdi-close"
                                title="Tolak"
                                class="text-error"
                                @click="bukaDialogTolak(item.id)"
                            ></v-list-item>
                        </v-list>
                    </v-menu>
                </template>
            </v-data-table>
        </v-card>

        <transition name="fade">
            <div
                v-if="dialogTolak"
                class="fixed inset-0 bg-black/50 flex items-center justify-center z-66 px-4"
            >
                <div
                    class="bg-white rounded-lg shadow-lg max-w-lg w-full animate-scale overflow-hidden"
                >
                    <v-card flat>
                        <v-card-title class="text-h6 bg-error text-white">
                            Tolak Pengajuan
                        </v-card-title>
                        <v-card-text class="pt-4">
                            <p class="mb-2">
                                Silakan masukkan alasan penolakan untuk siswa
                                ini:
                            </p>
                            <v-textarea
                                v-model="formTolak.alasan"
                                label="Alasan Penolakan"
                                variant="outlined"
                                rows="3"
                                auto-grow
                            ></v-textarea>
                        </v-card-text>
                        <v-card-actions class="px-4 pb-4">
                            <v-spacer></v-spacer>
                            <v-btn variant="text" @click="dialogTolak = false">
                                Batal
                            </v-btn>
                            <v-btn
                                color="error"
                                variant="elevated"
                                @click="submitTolak"
                            >
                                Kirim Penolakan
                            </v-btn>
                        </v-card-actions>
                    </v-card>
                </div>
            </div>
        </transition>

        <!-- Detail Dialog -->
        <v-dialog v-model="detailDialog" max-width="600px">
            <v-card>
                <v-card-title class="bg-primary text-white">
                    <span class="text-h6">Detail Pengajuan</span>
                </v-card-title>

                <v-card-text class="pt-4">
                    <v-list lines="two" density="compact">
                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Nama Siswa</v-list-item-title
                            >
                            <v-list-item-subtitle>{{
                                selectedItem?.siswa?.user?.name || "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Jurusan</v-list-item-title
                            >
                            <v-list-item-subtitle>{{
                                selectedItem?.siswa?.jurusan?.nama_jurusan ||
                                "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Tanggal Ajuan</v-list-item-title
                            >
                            <v-list-item-subtitle>{{
                                selectedItem?.tgl_ajuan
                                    ? formatDate(selectedItem.tgl_ajuan)
                                    : "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Durasi PKL</v-list-item-title
                            >
                            <v-list-item-subtitle
                                >{{
                                    selectedItem?.durasi || 0
                                }}
                                Bulan</v-list-item-subtitle
                            >
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Deskripsi</v-list-item-title
                            >
                            <v-list-item-subtitle class="text-wrap">{{
                                selectedItem?.deskripsi || "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Status</v-list-item-title
                            >
                            <v-list-item-subtitle>
                                <v-chip
                                    :color="
                                        getStatusColor(selectedItem?.status)
                                    "
                                    size="small"
                                    class="text-capitalize"
                                >
                                    {{ selectedItem?.status || "pending" }}
                                </v-chip>
                            </v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item v-if="selectedItem?.status === 'ditolak'">
                            <v-list-item-title
                                class="font-weight-bold text-error"
                                >Alasan Penolakan</v-list-item-title
                            >
                            <v-list-item-subtitle class="text-wrap">{{
                                selectedItem?.alasan_penolakan || "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item v-if="selectedItem?.cv_path">
                            <v-list-item-title class="font-weight-bold"
                                >CV</v-list-item-title
                            >
                            <v-list-item-subtitle>
                                <v-btn
                                    color="primary"
                                    variant="outlined"
                                    size="small"
                                    prepend-icon="mdi-file-document"
                                    @click="openCv(selectedItem.cv_path)"
                                >
                                    Lihat CV
                                </v-btn>
                            </v-list-item-subtitle>
                        </v-list-item>
                    </v-list>
                </v-card-text>

                <v-card-actions>
                    <v-spacer></v-spacer>
                    <v-btn
                        v-if="
                            !selectedItem?.status ||
                            selectedItem?.status === 'pending'
                        "
                        color="success"
                        variant="flat"
                        @click="
                            detailDialog = false;
                            terimaPengajuan(selectedItem.id);
                        "
                    >
                        Terima
                    </v-btn>
                    <v-btn
                        v-if="
                            !selectedItem?.status ||
                            selectedItem?.status === 'pending'
                        "
                        color="error"
                        variant="flat"
                        @click="
                            detailDialog = false;
                            bukaDialogTolak(selectedItem.id);
                        "
                    >
                        Tolak
                    </v-btn>
                    <v-btn
                        color="grey"
                        variant="text"
                        @click="detailDialog = false"
                    >
                        Tutup
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </SupervisorsDashboardLayout>
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
