<script setup>
import { Link } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    placement: Object,
});

// --- HELPERS ---
const getStatusColor = (status) => {
    if (status === "berjalan") return "success";
    if (status === "selesai") return "info";
    if (status === "gagal") return "error";
    return "warning";
};

const formatDate = (date) => {
    if (!date) return "-";
    return new Date(date).toLocaleDateString("id-ID", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
    });
};

// Helper untuk menghitung grade dari nilai
const calculateGrade = (nilai) => {
    if (!nilai && nilai !== 0) return "-";
    if (nilai >= 90) return "A";
    if (nilai >= 80) return "B";
    if (nilai >= 70) return "C";
    if (nilai >= 60) return "D";
    return "E";
};

// Helper untuk warna grade
const getGradeColor = (nilai) => {
    if (!nilai && nilai !== 0) return "grey";
    if (nilai >= 90) return "success";
    if (nilai >= 80) return "primary";
    if (nilai >= 70) return "info";
    if (nilai >= 60) return "warning";
    return "error";
};

const title = [
    {
        title: "Penempatan Siswa",
        disabled: false,
        href: route("penempatan-siswa.index"),
    },
    {
        title: "Detail",
        disabled: true,
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

        <div class="space-y-6!">
            <!-- HEADER -->
            <div class="flex items-center justify-between">
                <Link :href="route('penempatan-siswa.index')">
                    <v-btn variant="text" prepend-icon="mdi-arrow-left">
                        Kembali
                    </v-btn>
                </Link>
                <v-chip
                    :color="getStatusColor(props.placement?.status)"
                    size="large"
                    class="text-capitalize"
                >
                    {{ props.placement?.status || "pending" }}
                </v-chip>
            </div>

            <!-- SISWA INFO -->
            <v-card class="pa-6" elevation="2" rounded="lg">
                <v-card-title class="d-flex align-center gap-3">
                    <v-avatar color="primary" size="56">
                        <v-icon size="32">mdi-account-school</v-icon>
                    </v-avatar>
                    <div>
                        <h3 class="text-xl font-bold">
                            {{ props.placement?.siswa?.user?.name || "N/A" }}
                        </h3>
                        <div class="text-caption text-grey">Siswa PKL</div>
                    </div>
                </v-card-title>

                <v-card-text class="mt-4">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Informasi Siswa -->
                        <div>
                            <h4
                                class="text-lg font-semibold mb-4 flex items-center gap-2"
                            >
                                <v-icon color="primary">mdi-account</v-icon>
                                Informasi Siswa
                            </h4>
                            <div class="space-y-3">
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Nama</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.placement?.siswa?.user
                                                ?.name || "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >NISN</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.placement?.siswa?.nisn || "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Email</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.placement?.siswa?.user
                                                ?.email || "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >No HP</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.placement?.siswa?.user
                                                ?.phone || "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Jurusan</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.placement?.siswa?.jurusan
                                                ?.nama_jurusan || "-"
                                        }}</span
                                    >
                                </div>
                            </div>
                        </div>

                        <!-- Periode PKL -->
                        <div>
                            <h4
                                class="text-lg font-semibold mb-4 flex items-center gap-2"
                            >
                                <v-icon color="success">mdi-calendar</v-icon>
                                Periode PKL
                            </h4>
                            <div class="space-y-3">
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Tanggal Mulai</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            formatDate(
                                                props.placement?.tgl_mulai
                                            )
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Tanggal Selesai</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            formatDate(
                                                props.placement?.tgl_selesai
                                            )
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Status</span
                                    >
                                    <span
                                        >:
                                        <v-chip
                                            :color="
                                                getStatusColor(
                                                    props.placement?.status
                                                )
                                            "
                                            size="small"
                                            class="text-capitalize"
                                        >
                                            {{
                                                props.placement?.status ||
                                                "pending"
                                            }}
                                        </v-chip>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </v-card-text>
            </v-card>

            <!-- MITRA & PEMBIMBING -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Mitra Industri -->
                <v-card class="pa-6" elevation="2" rounded="lg">
                    <v-card-title class="d-flex align-center gap-3">
                        <v-avatar color="orange" size="48">
                            <v-icon size="24">mdi-office-building</v-icon>
                        </v-avatar>
                        <div>
                            <h4 class="text-lg font-bold">Mitra Industri</h4>
                        </div>
                    </v-card-title>

                    <v-card-text class="mt-4">
                        <div class="space-y-3">
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 100px"
                                    >Nama</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.placement?.mitra?.nama_instansi ||
                                        "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 100px"
                                    >Kota</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.placement?.mitra?.alamat
                                            ?.kecamatan || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 100px"
                                    >No Telepon</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.placement?.mitra?.supervisor
                                            ?.phone || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 100px"
                                    >Supervisor</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.placement?.mitra?.supervisor
                                            .name || "-"
                                    }}</span
                                >
                            </div>
                        </div>
                    </v-card-text>
                </v-card>

                <!-- Pembimbing -->
                <v-card class="pa-6" elevation="2" rounded="lg">
                    <v-card-title class="d-flex align-center gap-3">
                        <v-avatar color="purple" size="48">
                            <v-icon size="24">mdi-account-tie</v-icon>
                        </v-avatar>
                        <div>
                            <h4 class="text-lg font-bold">Pembimbing</h4>
                        </div>
                    </v-card-title>

                    <v-card-text class="mt-4">
                        <div class="space-y-3">
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 100px"
                                    >Nama</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.placement?.pembimbing?.name || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 100px"
                                    >Email</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.placement?.pembimbing?.email ||
                                        "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 100px"
                                    >No HP</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.placement?.pembimbing?.phone ||
                                        "-"
                                    }}</span
                                >
                            </div>
                        </div>
                    </v-card-text>
                </v-card>
            </div>

            <!-- NILAI PKL (hanya tampil jika status selesai) -->
            <v-card
                v-if="props.placement?.status === 'selesai'"
                class="pa-6"
                elevation="2"
                rounded="lg"
            >
                <v-card-title class="d-flex align-center gap-3">
                    <v-avatar color="teal" size="48">
                        <v-icon size="24">mdi-trophy</v-icon>
                    </v-avatar>
                    <div>
                        <h4 class="text-lg font-bold">Nilai PKL</h4>
                        <div class="text-caption text-grey">
                            Hasil evaluasi PKL siswa
                        </div>
                    </div>
                </v-card-title>

                <v-card-text class="mt-4">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <!-- Nilai Akhir -->
                        <v-card
                            :color="getGradeColor(props.placement?.nilai)"
                            class="pa-6 text-center text-white"
                            elevation="3"
                        >
                            <div class="text-h2 font-bold">
                                {{ props.placement?.nilai ?? "-" }}
                            </div>
                            <div class="text-subtitle-1 mt-2">Nilai Akhir</div>
                        </v-card>

                        <!-- Grade -->
                        <v-card
                            class="pa-6 text-center border-2"
                            :class="`border-${getGradeColor(
                                props.placement?.nilai
                            )}`"
                            elevation="1"
                        >
                            <div
                                class="text-h2 font-bold"
                                :class="`text-${getGradeColor(
                                    props.placement?.nilai
                                )}`"
                            >
                                {{ calculateGrade(props.placement?.nilai) }}
                            </div>
                            <div class="text-subtitle-1 mt-2 text-grey">
                                Grade
                            </div>
                        </v-card>

                        <!-- Keterangan Grade -->
                        <v-card class="pa-6" elevation="1">
                            <div class="text-subtitle-2 text-grey mb-2">
                                Keterangan Grade
                            </div>
                            <v-chip
                                v-if="props.placement?.nilai >= 90"
                                color="success"
                                class="mb-1"
                                >A: Sangat Baik (90-100)</v-chip
                            >
                            <v-chip
                                v-else-if="props.placement?.nilai >= 80"
                                color="primary"
                                class="mb-1"
                                >B: Baik (80-89)</v-chip
                            >
                            <v-chip
                                v-else-if="props.placement?.nilai >= 70"
                                color="info"
                                class="mb-1"
                                >C: Cukup (70-79)</v-chip
                            >
                            <v-chip
                                v-else-if="props.placement?.nilai >= 60"
                                color="warning"
                                class="mb-1"
                                >D: Kurang (60-69)</v-chip
                            >
                            <v-chip
                                v-else-if="props.placement?.nilai"
                                color="error"
                                class="mb-1"
                                >E: Sangat Kurang (&lt;60)</v-chip
                            >
                            <v-chip v-else color="grey" class="mb-1"
                                >Belum ada nilai</v-chip
                            >
                        </v-card>
                    </div>

                    <!-- Komentar Supervisor -->
                    <div
                        v-if="props.placement?.komentar_supervisor"
                        class="mt-6"
                    >
                        <h5
                            class="text-lg font-semibold mb-3 flex items-center gap-2"
                        >
                            <v-icon color="teal">mdi-comment-text</v-icon>
                            Komentar Supervisor
                        </h5>
                        <v-card class="pa-4 bg-grey-lighten-4" elevation="0">
                            <p class="text-body-1 text-wrap">
                                {{ props.placement?.komentar_supervisor }}
                            </p>
                        </v-card>
                    </div>
                </v-card-text>
            </v-card>
        </div>
    </PendampingDashboardLayout>
</template>
