<script setup>
import { ref, watch } from "vue";
import { router } from "@inertiajs/vue3";
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

// --- DETAIL DIALOG STATE ---
const detailDialog = ref(false);
const selectedJurnal = ref(null);

// --- OPTIONS ---
const statusOptions = [
    { value: null, title: "Semua Status" },
    { value: "pending", title: "Pending" },
    { value: "disetujui", title: "Disetujui" },
    { value: "revisi", title: "Revisi" },
];

// --- HEADERS ---
const headers = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Tanggal", key: "tanggal" },
    { title: "Siswa", key: "siswa_info" },
    { title: "Judul", key: "judul" },
    { title: "Pembimbing", key: "pembimbing" },
    { title: "Status", key: "status", align: "center" },
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
        },
        { preserveState: true, replace: true }
    );
};

let searchTimeout = null;
watch(search, () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applyFilters, 500);
});

watch([filterBulan, filterStatus, filterPembimbing, filterMitra], applyFilters);

// --- DETAIL FUNCTION ---
const openDetail = (item) => {
    selectedJurnal.value = item;
    detailDialog.value = true;
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
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
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
                    v-model="filterPembimbing"
                    :items="props.pembimbings"
                    item-title="name"
                    item-value="id"
                    label="Filter Pembimbing"
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
                :items="props.jurnals?.data || []"
                class="elevation-0 border"
                hover
            >
                <template v-slot:item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <template v-slot:item.tanggal="{ item }">
                    <div style="min-width: 140px">
                        {{ formatDate(item.tanggal) }}
                    </div>
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

                <template v-slot:item.judul="{ item }">
                    <div style="min-width: 200px; max-width: 300px">
                        <span class="font-medium text-wrap">{{
                            item.judul || "-"
                        }}</span>
                    </div>
                </template>

                <template v-slot:item.pembimbing="{ item }">
                    {{ item.pembimbing?.name || "-" }}
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

                        <v-list-item v-if="selectedJurnal?.catatan_pembimbing">
                            <v-list-item-title class="font-weight-bold"
                                >Catatan Pembimbing</v-list-item-title
                            >
                            <v-list-item-subtitle class="text-wrap">{{
                                selectedJurnal.catatan_pembimbing
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
    </PendampingDashboardLayout>
</template>
