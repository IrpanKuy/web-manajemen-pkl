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
        </div>
    </PendampingDashboardLayout>
</template>
