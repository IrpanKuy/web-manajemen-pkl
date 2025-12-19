<script setup>
import { Link } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    mitra: Object,
    pembimbings: Array,
    siswas: Array,
});

// --- HELPERS ---
const formatDate = (date) => {
    if (!date) return "-";
    return new Date(date).toLocaleDateString("id-ID", {
        year: "numeric",
        month: "long",
        day: "numeric",
    });
};

const title = [
    {
        title: "Mitra Industri",
        disabled: false,
        href: route("mitra-industri.index"),
    },
    {
        title: "Detail",
        disabled: true,
    },
];

// Headers for siswa table
const siswaHeaders = [
    { title: "No", key: "index", align: "center", sortable: false },
    { title: "Nama Siswa", key: "name" },
    { title: "Jurusan", key: "jurusan" },
    { title: "Pembimbing", key: "pembimbing" },
    { title: "Periode PKL", key: "periode" },
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
                <Link :href="route('mitra-industri.index')">
                    <v-btn variant="text" prepend-icon="mdi-arrow-left">
                        Kembali
                    </v-btn>
                </Link>
            </div>

            <!-- MITRA INFO -->
            <v-card class="pa-6" elevation="2" rounded="lg">
                <v-card-title class="d-flex align-center gap-3">
                    <v-avatar color="primary" size="56">
                        <v-icon size="32">mdi-office-building</v-icon>
                    </v-avatar>
                    <div>
                        <h3 class="text-xl font-bold">
                            {{ props.mitra?.nama_instansi || "N/A" }}
                        </h3>
                        <div class="text-caption text-grey">
                            {{ props.mitra?.bidang_usaha || "-" }}
                        </div>
                    </div>
                </v-card-title>

                <v-card-text class="mt-4">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Info Mitra -->
                        <div>
                            <h4
                                class="text-lg font-semibold mb-4 flex items-center gap-2"
                            >
                                <v-icon color="primary">mdi-information</v-icon>
                                Informasi Mitra
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
                                            props.mitra?.nama_instansi || "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Bidang Usaha</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.mitra?.bidang_usaha || "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Kuota</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.mitra?.kuota || 0
                                        }}
                                        siswa</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Jam Masuk</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.mitra?.jam_masuk || "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Jam Pulang</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.mitra?.jam_pulang || "-"
                                        }}</span
                                    >
                                </div>
                            </div>
                        </div>

                        <!-- Alamat -->
                        <div>
                            <h4
                                class="text-lg font-semibold mb-4 flex items-center gap-2"
                            >
                                <v-icon color="success">mdi-map-marker</v-icon>
                                Alamat
                            </h4>
                            <div class="space-y-3">
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Provinsi</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.mitra?.alamat?.profinsi || "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Kabupaten</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.mitra?.alamat?.kabupaten ||
                                            "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Kecamatan</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.mitra?.alamat?.kecamatan ||
                                            "-"
                                        }}</span
                                    >
                                </div>
                                <div class="flex gap-2">
                                    <span
                                        class="text-grey"
                                        style="min-width: 120px"
                                        >Detail Alamat</span
                                    >
                                    <span class="font-weight-medium"
                                        >:
                                        {{
                                            props.mitra?.alamat
                                                ?.detail_alamat || "-"
                                        }}</span
                                    >
                                </div>
                            </div>
                        </div>
                    </div>
                </v-card-text>
            </v-card>

            <!-- SUPERVISOR & PENDAMPING -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Supervisor -->
                <v-card class="pa-6" elevation="2" rounded="lg">
                    <v-card-title class="d-flex align-center gap-3">
                        <v-avatar color="orange" size="48">
                            <v-icon size="24">mdi-account-supervisor</v-icon>
                        </v-avatar>
                        <div>
                            <h4 class="text-lg font-bold">Supervisor</h4>
                        </div>
                    </v-card-title>

                    <v-card-text class="mt-4">
                        <div class="space-y-3">
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 80px"
                                    >Nama</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.mitra?.supervisor?.name || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 80px"
                                    >Email</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.mitra?.supervisor?.email || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 80px"
                                    >No HP</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.mitra?.supervisor?.phone || "-"
                                    }}</span
                                >
                            </div>
                        </div>
                    </v-card-text>
                </v-card>

                <!-- Pendamping -->
                <v-card class="pa-6" elevation="2" rounded="lg">
                    <v-card-title class="d-flex align-center gap-3">
                        <v-avatar color="purple" size="48">
                            <v-icon size="24">mdi-school</v-icon>
                        </v-avatar>
                        <div>
                            <h4 class="text-lg font-bold">Pendamping</h4>
                        </div>
                    </v-card-title>

                    <v-card-text class="mt-4">
                        <div class="space-y-3">
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 80px"
                                    >Nama</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.mitra?.pendamping?.name || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 80px"
                                    >Email</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.mitra?.pendamping?.email || "-"
                                    }}</span
                                >
                            </div>
                            <div class="flex gap-2">
                                <span class="text-grey" style="min-width: 80px"
                                    >No HP</span
                                >
                                <span class="font-weight-medium"
                                    >:
                                    {{
                                        props.mitra?.pendamping?.phone || "-"
                                    }}</span
                                >
                            </div>
                        </div>
                    </v-card-text>
                </v-card>
            </div>

            <!-- PEMBIMBING LIST -->
            <v-card class="pa-6" elevation="2" rounded="lg">
                <v-card-title class="d-flex align-center gap-3">
                    <v-avatar color="cyan" size="48">
                        <v-icon size="24">mdi-account-tie</v-icon>
                    </v-avatar>
                    <div>
                        <h4 class="text-lg font-bold">
                            Daftar Pembimbing ({{
                                props.pembimbings?.length || 0
                            }})
                        </h4>
                    </div>
                </v-card-title>

                <v-card-text class="mt-4">
                    <div
                        v-if="props.pembimbings?.length > 0"
                        class="grid grid-cols-1 md:grid-cols-3 gap-4"
                    >
                        <v-card
                            v-for="pembimbing in props.pembimbings"
                            :key="pembimbing.id"
                            class="pa-4 border"
                            variant="outlined"
                        >
                            <div class="flex items-center gap-3">
                                <v-avatar color="cyan" size="40">
                                    <v-icon>mdi-account</v-icon>
                                </v-avatar>
                                <div>
                                    <div class="font-weight-bold">
                                        {{ pembimbing.name }}
                                    </div>
                                    <div class="text-caption text-grey">
                                        {{ pembimbing.email }}
                                    </div>
                                </div>
                            </div>
                        </v-card>
                    </div>
                    <div v-else class="text-center text-grey pa-4">
                        Belum ada pembimbing yang ditugaskan
                    </div>
                </v-card-text>
            </v-card>

            <!-- SISWA LIST -->
            <v-card class="pa-6" elevation="2" rounded="lg">
                <v-card-title class="d-flex align-center gap-3">
                    <v-avatar color="green" size="48">
                        <v-icon size="24">mdi-account-school</v-icon>
                    </v-avatar>
                    <div>
                        <h4 class="text-lg font-bold">
                            Daftar Siswa PKL ({{ props.siswas?.length || 0 }})
                        </h4>
                    </div>
                </v-card-title>

                <v-card-text class="mt-4">
                    <v-data-table
                        :headers="siswaHeaders"
                        :items="props.siswas || []"
                        class="elevation-0 border"
                        hover
                    >
                        <template v-slot:item.index="{ index }">
                            {{ index + 1 }}
                        </template>

                        <template v-slot:item.name="{ item }">
                            <div class="py-2">
                                <div class="font-weight-bold">
                                    {{ item.name }}
                                </div>
                                <div class="text-caption text-grey">
                                    {{ item.email }}
                                </div>
                            </div>
                        </template>

                        <template v-slot:item.jurusan="{ item }">
                            {{ item.jurusan }}
                        </template>

                        <template v-slot:item.pembimbing="{ item }">
                            {{ item.pembimbing }}
                        </template>

                        <template v-slot:item.periode="{ item }">
                            <div class="text-caption">
                                {{ formatDate(item.tgl_mulai) }} -
                                {{ formatDate(item.tgl_selesai) }}
                            </div>
                        </template>
                    </v-data-table>
                </v-card-text>
            </v-card>
        </div>
    </PendampingDashboardLayout>
</template>
