<script setup>
import { Link } from "@inertiajs/vue3";
import PembimbingDashboardLayout from "../layouts/pembimbingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    placement: Object,
});

// --- HELPER ---
const formatDate = (date) => {
    if (!date) return "-";
    return new Date(date).toLocaleDateString("id-ID", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
    });
};

const getStatusColor = (status) => {
    if (status === "berjalan") return "success";
    if (status === "selesai") return "info";
    if (status === "gagal") return "error";
    return "warning";
};

const title = [
    {
        title: "Siswa Bimbingan",
        disabled: false,
        href: route("siswa-bimbingan.index"),
    },
    {
        title: props.placement?.siswa?.user?.name || "Detail Siswa",
        disabled: true,
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

        <div class="space-y-6!">
            <!-- BACK BUTTON -->
            <div>
                <Link :href="route('siswa-bimbingan.index')">
                    <v-btn
                        variant="text"
                        color="primary"
                        prepend-icon="mdi-arrow-left"
                    >
                        Kembali
                    </v-btn>
                </Link>
            </div>

            <!-- STUDENT INFO CARD -->
            <v-card
                class="pa-6 border border-gray-200"
                elevation="2"
                rounded="lg"
            >
                <div class="flex items-center gap-4 mb-6">
                    <v-avatar size="80" color="primary">
                        <v-icon size="48">mdi-account</v-icon>
                    </v-avatar>
                    <div>
                        <h2 class="text-2xl font-bold">
                            {{ props.placement?.siswa?.user?.name || "N/A" }}
                        </h2>
                        <p class="text-grey">
                            NISN: {{ props.placement?.siswa?.nisn || "-" }}
                        </p>
                        <v-chip
                            :color="getStatusColor(props.placement?.status)"
                            size="small"
                            class="mt-2 text-capitalize"
                        >
                            {{ props.placement?.status || "pending" }}
                        </v-chip>
                    </div>
                </div>

                <v-divider class="mb-6"></v-divider>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- DATA SISWA -->
                    <div>
                        <h3
                            class="text-lg font-bold mb-4 flex items-center gap-2"
                        >
                            <v-icon color="primary">mdi-account-school</v-icon>
                            Data Siswa
                        </h3>
                        <div class="space-y-3">
                            <div class="flex">
                                <span class="text-grey w-32">Nama</span>
                                <span class="font-medium"
                                    >:
                                    {{
                                        props.placement?.siswa?.user?.name ||
                                        "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex">
                                <span class="text-grey w-32">Email</span>
                                <span class="font-medium"
                                    >:
                                    {{
                                        props.placement?.siswa?.user?.email ||
                                        "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex">
                                <span class="text-grey w-32">No HP</span>
                                <span class="font-medium"
                                    >:
                                    {{
                                        props.placement?.siswa?.user?.phone ||
                                        "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex">
                                <span class="text-grey w-32">NISN</span>
                                <span class="font-medium"
                                    >:
                                    {{
                                        props.placement?.siswa?.nisn || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex">
                                <span class="text-grey w-32">Jurusan</span>
                                <span class="font-medium"
                                    >:
                                    {{
                                        props.placement?.siswa?.jurusan
                                            ?.nama_jurusan || "-"
                                    }}</span
                                >
                            </div>
                        </div>
                    </div>

                    <!-- DATA PKL -->
                    <div>
                        <h3
                            class="text-lg font-bold mb-4 flex items-center gap-2"
                        >
                            <v-icon color="primary">mdi-briefcase</v-icon>
                            Data PKL
                        </h3>
                        <div class="space-y-3">
                            <div class="flex">
                                <span class="text-grey w-32">Instansi</span>
                                <span class="font-medium"
                                    >:
                                    {{
                                        props.placement?.mitra?.nama_instansi ||
                                        "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex">
                                <span class="text-grey w-32">Alamat</span>
                                <span class="font-medium"
                                    >:
                                    {{
                                        props.placement?.mitra?.alamat
                                            ?.kecamatan || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex">
                                <span class="text-grey w-32"
                                    >Tanggal Mulai</span
                                >
                                <span class="font-medium"
                                    >:
                                    {{
                                        formatDate(props.placement?.tgl_mulai)
                                    }}</span
                                >
                            </div>
                            <div class="flex">
                                <span class="text-grey w-32"
                                    >Tanggal Selesai</span
                                >
                                <span class="font-medium"
                                    >:
                                    {{
                                        formatDate(props.placement?.tgl_selesai)
                                    }}</span
                                >
                            </div>
                            <div class="flex">
                                <span class="text-grey w-32">Status</span>
                                <span class="font-medium"
                                    >:
                                    <v-chip
                                        :color="
                                            getStatusColor(
                                                props.placement?.status
                                            )
                                        "
                                        size="x-small"
                                        class="ml-1 text-capitalize"
                                    >
                                        {{
                                            props.placement?.status || "pending"
                                        }}
                                    </v-chip>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </v-card>

            <!-- QUICK ACTIONS -->
            <v-card
                class="pa-6 border border-gray-200"
                elevation="2"
                rounded="lg"
            >
                <h3 class="text-lg font-bold mb-4 flex items-center gap-2">
                    <v-icon color="primary">mdi-lightning-bolt</v-icon>
                    Aksi Cepat
                </h3>
                <div class="flex flex-wrap gap-3">
                    <Link :href="route('jurnal-siswa.index')">
                        <v-btn
                            color="primary"
                            variant="outlined"
                            prepend-icon="mdi-notebook"
                        >
                            Lihat Jurnal
                        </v-btn>
                    </Link>
                    <Link :href="route('absensi-harian.index')">
                        <v-btn
                            color="success"
                            variant="outlined"
                            prepend-icon="mdi-clock-check"
                        >
                            Lihat Absensi
                        </v-btn>
                    </Link>
                    <Link :href="route('pengajuan-izin.index')">
                        <v-btn
                            color="warning"
                            variant="outlined"
                            prepend-icon="mdi-file-document"
                        >
                            Pengajuan Izin
                        </v-btn>
                    </Link>
                </div>
            </v-card>
        </div>
    </PembimbingDashboardLayout>
</template>
