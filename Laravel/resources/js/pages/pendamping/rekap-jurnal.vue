<script setup>
import { ref, watch } from "vue";
import { router, useForm } from "@inertiajs/vue3";
import Swal from "sweetalert2";
import PendampingDashboardLayout from "../layouts/PendampingDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    jurnals: Object,
    summary: Object,
    bulan: String,
    filters: Object,
    pembimbings: Array,
    mitras: Array,
});

// --- STATE ---
const search = ref(props.filters?.search || "");
const filterBulan = ref(props.filters?.bulan || props.bulan || "");
const filterStatus = ref(props.filters?.status || null);
const filterPembimbing = ref(props.filters?.pembimbing_id || null);
const filterMitra = ref(props.filters?.mitra_id || null);
const filterKomentar = ref(props.filters?.has_komentar || null);

// --- DETAIL DIALOG STATE ---
const detailDialog = ref(false);
const selectedJurnal = ref(null);

// --- KOMENTAR DIALOG STATE ---
const komentarDialog = ref(false);
const komentarForm = useForm({
    komentar_pendamping: "",
});

// --- OPTIONS ---
const statusOptions = [
    { value: null, title: "Semua Status" },
    { value: "pending", title: "Pending" },
    { value: "disetujui", title: "Disetujui" },
    { value: "revisi", title: "Revisi" },
];

const komentarOptions = [
    { value: null, title: "Semua Komentar" },
    { value: "1", title: "Sudah Dikomentar" },
    { value: "0", title: "Belum Dikomentar" },
];

// --- HEADERS ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Tanggal", key: "tanggal" },
    { title: "Siswa", key: "siswa_info" },
    { title: "Mitra", key: "mitra_name" },
    { title: "Judul", key: "judul" },
    { title: "Status", key: "status", align: "center" },
    { title: "Komentar", key: "has_komentar", align: "center" },
    { title: "Aksi", key: "actions", align: "center", sortable: false },
];

// --- FILTER ---
const applyFilters = () => {
    router.get(
        route("rekap-jurnal.index"),
        {
            search: search.value || undefined,
            bulan: filterBulan.value || undefined,
            status: filterStatus.value || undefined,
            pembimbing_id: filterPembimbing.value || undefined,
            mitra_id: filterMitra.value || undefined,
            has_komentar: filterKomentar.value || undefined,
        },
        { preserveState: true, replace: true }
    );
};

let searchTimeout = null;
watch(search, () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applyFilters, 500);
});

watch(
    [filterBulan, filterStatus, filterPembimbing, filterMitra, filterKomentar],
    applyFilters
);

// --- DETAIL FUNCTION ---
const openDetail = (item) => {
    selectedJurnal.value = item;
    detailDialog.value = true;
};

// --- KOMENTAR FUNCTION ---
const openKomentarDialog = (item) => {
    selectedJurnal.value = item;
    komentarForm.komentar_pendamping = item.komentar_pendamping || "";
    komentarDialog.value = true;
};

const submitKomentar = () => {
    if (!komentarForm.komentar_pendamping.trim()) {
        return Swal.fire("Gagal!", "Komentar wajib diisi", "error");
    }

    komentarForm.post(
        route("rekap-jurnal.beri-komentar", selectedJurnal.value.id),
        {
            onSuccess: () => {
                komentarDialog.value = false;
                komentarForm.reset();
            },
        }
    );
};

// --- HELPERS ---
const getStatusColor = (status) => {
    if (status === "disetujui") return "success";
    if (status === "revisi") return "error";
    return "warning";
};

const formatDate = (date) => {
    return new Date(date).toLocaleDateString("id-ID", {
        weekday: "short",
        year: "numeric",
        month: "short",
        day: "numeric",
    });
};

const formatBulan = (bulan) => {
    if (!bulan) return "-";
    const date = new Date(bulan + "-01");
    return date.toLocaleDateString("id-ID", {
        year: "numeric",
        month: "long",
    });
};

const title = [
    {
        title: "Rekap Jurnal",
        disabled: false,
        href: route("rekap-jurnal.index"),
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
                    Rekap Jurnal Siswa - {{ formatBulan(props.bulan) }}
                </h3>
            </v-card-title>

            <!-- SUMMARY -->
            <div class="grid grid-cols-2 md:grid-cols-5 gap-4 mb-6">
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="text-caption text-grey">Total Jurnal</div>
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
                    <div class="text-caption text-grey">Disetujui</div>
                    <div class="text-h4 font-weight-bold text-green-600">
                        {{ props.summary?.disetujui || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-red-500" elevation="2">
                    <div class="text-caption text-grey">Revisi</div>
                    <div class="text-h4 font-weight-bold text-red-600">
                        {{ props.summary?.revisi || 0 }}
                    </div>
                </v-card>
                <v-card class="pa-4 border-l-4 border-purple-500" elevation="2">
                    <div class="text-caption text-grey">Sudah Dikomentar</div>
                    <div class="text-h4 font-weight-bold text-purple-600">
                        {{ props.summary?.dengan_komentar || 0 }}
                    </div>
                </v-card>
            </div>

            <!-- FILTER -->
            <div class="grid grid-cols-1 md:grid-cols-6 gap-4 mb-4">
                <v-text-field
                    v-model="search"
                    label="Cari Siswa / Judul"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-text-field>
                <v-text-field
                    v-model="filterBulan"
                    label="Pilih Bulan"
                    type="month"
                    variant="outlined"
                    density="compact"
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
                <v-select
                    v-model="filterKomentar"
                    :items="komentarOptions"
                    item-title="title"
                    item-value="value"
                    label="Filter Komentar"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-select>
            </div>

            <!-- TABLE -->
            <v-data-table
                :headers="headers"
                :items="props.jurnals?.data || []"
                class="elevation-0 border"
                hover
            >
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <template v-slot:item.tanggal="{ item }">
                    <div style="min-width: 120px">
                        {{ formatDate(item.tanggal) }}
                    </div>
                </template>

                <template v-slot:item.siswa_info="{ item }">
                    <div class="py-2" style="min-width: 150px">
                        <div class="font-weight-bold">
                            {{ item.siswa?.user?.name || "N/A" }}
                        </div>
                        <div class="text-caption text-grey">
                            {{ item.siswa?.jurusan?.nama_jurusan || "-" }}
                        </div>
                    </div>
                </template>

                <template v-slot:item.mitra_name="{ item }">
                    <div style="min-width: 120px">
                        {{ item.mitra?.nama_instansi || "-" }}
                    </div>
                </template>

                <template v-slot:item.judul="{ item }">
                    <div style="min-width: 150px; max-width: 250px">
                        <span class="font-medium text-wrap">{{
                            item.judul || "-"
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

                <template v-slot:item.has_komentar="{ item }">
                    <v-chip
                        :color="item.komentar_pendamping ? 'success' : 'grey'"
                        size="small"
                        variant="outlined"
                    >
                        {{ item.komentar_pendamping ? "Sudah" : "Belum" }}
                    </v-chip>
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
                            <v-divider></v-divider>
                            <v-list-item
                                prepend-icon="mdi-comment-text"
                                :title="
                                    item.komentar_pendamping
                                        ? 'Edit Komentar'
                                        : 'Beri Komentar'
                                "
                                class="text-purple"
                                @click="openKomentarDialog(item)"
                            ></v-list-item>
                        </v-list>
                    </v-menu>
                </template>
            </v-data-table>
        </v-card>

        <!-- DETAIL DIALOG -->
        <v-dialog v-model="detailDialog" max-width="600px">
            <v-card>
                <v-card-title class="bg-primary text-white">
                    <span class="text-h6">Detail Jurnal</span>
                </v-card-title>

                <v-card-text class="pt-4">
                    <v-list lines="two" density="compact">
                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Tanggal</v-list-item-title
                            >
                            <v-list-item-subtitle>{{
                                selectedJurnal?.tanggal
                                    ? formatDate(selectedJurnal.tanggal)
                                    : "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Siswa</v-list-item-title
                            >
                            <v-list-item-subtitle
                                >{{
                                    selectedJurnal?.siswa?.user?.name || "-"
                                }}
                                ({{
                                    selectedJurnal?.siswa?.jurusan
                                        ?.nama_jurusan || "-"
                                }})</v-list-item-subtitle
                            >
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Mitra Industri</v-list-item-title
                            >
                            <v-list-item-subtitle>{{
                                selectedJurnal?.mitra?.nama_instansi || "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Judul</v-list-item-title
                            >
                            <v-list-item-subtitle>{{
                                selectedJurnal?.judul || "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Deskripsi</v-list-item-title
                            >
                            <v-list-item-subtitle class="text-wrap">{{
                                selectedJurnal?.deskripsi || "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Pembimbing</v-list-item-title
                            >
                            <v-list-item-subtitle>{{
                                selectedJurnal?.pembimbing?.name || "-"
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item>
                            <v-list-item-title class="font-weight-bold"
                                >Status</v-list-item-title
                            >
                            <v-list-item-subtitle>
                                <v-chip
                                    :color="
                                        getStatusColor(selectedJurnal?.status)
                                    "
                                    size="small"
                                    class="text-capitalize"
                                >
                                    {{ selectedJurnal?.status || "pending" }}
                                </v-chip>
                            </v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item v-if="selectedJurnal?.komentar">
                            <v-list-item-title class="font-weight-bold"
                                >Catatan Pembimbing</v-list-item-title
                            >
                            <v-list-item-subtitle class="text-wrap">{{
                                selectedJurnal.komentar
                            }}</v-list-item-subtitle>
                        </v-list-item>

                        <v-list-item v-if="selectedJurnal?.komentar_pendamping">
                            <v-list-item-title
                                class="font-weight-bold text-purple"
                                >Komentar Pendamping</v-list-item-title
                            >
                            <v-list-item-subtitle class="text-wrap">{{
                                selectedJurnal.komentar_pendamping
                            }}</v-list-item-subtitle>
                        </v-list-item>
                    </v-list>
                </v-card-text>

                <v-card-actions>
                    <v-btn
                        color="purple"
                        variant="flat"
                        prepend-icon="mdi-comment-text"
                        @click="
                            detailDialog = false;
                            openKomentarDialog(selectedJurnal);
                        "
                    >
                        {{
                            selectedJurnal?.komentar_pendamping
                                ? "Edit Komentar"
                                : "Beri Komentar"
                        }}
                    </v-btn>
                    <v-spacer></v-spacer>
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

        <!-- KOMENTAR DIALOG -->
        <v-dialog v-model="komentarDialog" max-width="500px" persistent>
            <v-card>
                <v-card-title class="bg-purple text-white">
                    <span class="text-h6">{{
                        selectedJurnal?.komentar_pendamping
                            ? "Edit Komentar"
                            : "Beri Komentar"
                    }}</span>
                </v-card-title>

                <v-card-text class="pt-4">
                    <p class="mb-3 text-grey-darken-1">
                        Jurnal: <strong>{{ selectedJurnal?.judul }}</strong
                        ><br />
                        Siswa:
                        <strong>{{ selectedJurnal?.siswa?.user?.name }}</strong>
                    </p>
                    <v-textarea
                        v-model="komentarForm.komentar_pendamping"
                        label="Komentar Pendamping"
                        variant="outlined"
                        rows="4"
                        auto-grow
                        placeholder="Berikan komentar untuk jurnal ini..."
                        :error-messages="
                            komentarForm.errors.komentar_pendamping
                        "
                    ></v-textarea>
                </v-card-text>

                <v-card-actions class="px-4 pb-4">
                    <v-spacer></v-spacer>
                    <v-btn
                        variant="text"
                        @click="
                            komentarDialog = false;
                            komentarForm.reset();
                        "
                    >
                        Batal
                    </v-btn>
                    <v-btn
                        color="purple"
                        variant="flat"
                        :loading="komentarForm.processing"
                        @click="submitKomentar"
                    >
                        Simpan Komentar
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </PendampingDashboardLayout>
</template>
