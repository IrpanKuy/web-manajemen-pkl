<script setup>
import { computed, ref, watch } from "vue";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";
import { Link, router, usePage } from "@inertiajs/vue3";
import Swal from "sweetalert2";

const props = defineProps({
    mitras: {
        type: Object,
        required: true,
    },
    listPendampings: Array,
    listSupervisors: Array,
});

const listPendampingsOptions = computed(() => {
    return [{ id: null, name: "Semua Pendamping" }, ...props.listPendampings];
});

const listSupervisorsOptions = computed(() => {
    return [{ id: null, name: "Semua Supervisors" }, ...props.listSupervisors];
});

const search = ref("");
const filterPendamping = ref(null);
const filterSupervisors = ref(null);

const filteredItems = computed(() => {
    let data = props.mitras.data;

    if (filterPendamping.value) {
        data = data.filter(
            (mitra) => mitra.pendamping_id === filterPendamping.value
        );
    }

    if (filterSupervisors.value) {
        data = data.filter(
            (mitra) => mitra.supervisors_id === filterSupervisors.value
        );
    }
    return data;
});

const page = usePage();

const deleteItem = (id) => {
    Swal.fire({
        title: "Hapus Mitra Industri?",
        text: "Data tidak bisa dikembalikan!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        cancelButtonColor: "#6b7280",
        confirmButtonText: "Ya, Hapus",
        cancelButtonText: "Batal",
    }).then((result) => {
        if (result.isConfirmed) {
            router.delete(route("mitra-industri.destroy", id), {
                preserveScroll: true,
                preserveState: true,
            });
        }
    });
};

const editItem = (id) => {
    router.get(route("mitra-industri.edit", id));
};

const viewDetail = (id) => {
    router.get(route("mitra-industri.detail", id));
};

watch(
    () => page.props.flash,
    (flash) => {
        if (flash?.success) {
            Swal.fire({
                icon: "success",
                title: "Berhasil!",
                text: flash.success,
                timer: 2000,
                showConfirmButton: false,
            });
        }
        if (flash?.error) {
            Swal.fire({
                icon: "error",
                title: "Gagal!",
                text: flash.error,
            });
        }
        if (flash?.download_qr_id) {
            window.open(
                route("mitra-industri.download-qr", flash.download_qr_id),
                "_blank"
            );
        }
    },
    { immediate: true }
);

const headers = [
    {
        title: "No",
        key: "index",
        align: "center",
        sortable: false,
        width: "60px",
    },
    { title: "Nama Instansi", key: "nama_instansi" },
    { title: "Bidang Usaha", key: "bidang_usaha" },
    { title: "Pendamping", key: "pendamping.name" },
    { title: "Supervisor", key: "supervisor.name" },
    { title: "Kuota", key: "kuota_info", align: "center" },
    { title: "Lokasi", key: "alamat.kecamatan" },
    {
        title: "Aksi",
        key: "actions",
        sortable: false,
        align: "center",
        width: "180px",
    },
];

const title = [
    {
        title: "Mitra Industri",
        disabled: false,
        href: route("mitra-industri.index"),
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
            <v-card-title
                class="d-flex justify-space-between align-center flex-wrap gap-2"
            >
                <h3 class="text-lg md:text-xl font-bold">
                    Data Mitra Industri
                </h3>
                <Link :href="route('mitra-industri.create')">
                    <v-btn color="primary" prepend-icon="mdi-plus">
                        Tambah Mitra
                    </v-btn>
                </Link>
            </v-card-title>

            <!-- FILTER -->
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mt-4 mb-4">
                <v-text-field
                    v-model="search"
                    label="Cari Nama / Bidang Usaha"
                    prepend-inner-icon="mdi-magnify"
                    class="md:col-span-2"
                    variant="outlined"
                    density="compact"
                    clearable
                    hide-details
                ></v-text-field>
                <v-select
                    v-model="filterPendamping"
                    label="Filter Pendamping"
                    :items="listPendampingsOptions"
                    item-title="name"
                    item-value="id"
                    variant="outlined"
                    density="compact"
                    hide-details
                ></v-select>
                <v-select
                    v-model="filterSupervisors"
                    label="Filter Supervisor"
                    :items="listSupervisorsOptions"
                    item-title="name"
                    item-value="id"
                    variant="outlined"
                    density="compact"
                    hide-details
                ></v-select>
            </div>

            <!-- TABLE -->
            <v-data-table
                :headers="headers"
                :items="filteredItems"
                :search="search"
                class="elevation-0 border"
                hover
            >
                <template #item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <template #item.nama_instansi="{ item }">
                    <div class="py-2" style="min-width: 150px">
                        <div class="font-weight-bold">
                            {{ item.nama_instansi }}
                        </div>
                    </div>
                </template>

                <template #item.bidang_usaha="{ item }">
                    <v-chip color="indigo" size="small" variant="flat">
                        {{ item.bidang_usaha }}
                    </v-chip>
                </template>

                <template #item.kuota_info="{ item }">
                    <div class="text-center">
                        <div class="font-weight-bold">
                            {{ item.placements_count || 0 }}/{{ item.kuota }}
                        </div>
                        <div class="text-caption text-grey">siswa</div>
                    </div>
                </template>

                <template #item.actions="{ item }">
                    <div class="d-flex gap-2 justify-center">
                        <v-tooltip text="Lihat Detail" location="top">
                            <template v-slot:activator="{ props }">
                                <v-btn
                                    v-bind="props"
                                    icon="mdi-eye"
                                    color="primary"
                                    size="small"
                                    variant="flat"
                                    @click="viewDetail(item.id)"
                                ></v-btn>
                            </template>
                        </v-tooltip>

                        <v-tooltip text="Edit" location="top">
                            <template v-slot:activator="{ props }">
                                <v-btn
                                    v-bind="props"
                                    icon="mdi-pencil"
                                    color="amber"
                                    size="small"
                                    variant="flat"
                                    @click="editItem(item.id)"
                                ></v-btn>
                            </template>
                        </v-tooltip>

                        <v-tooltip text="Hapus" location="top">
                            <template v-slot:activator="{ props }">
                                <v-btn
                                    v-bind="props"
                                    icon="mdi-delete"
                                    size="small"
                                    color="red"
                                    variant="flat"
                                    @click="deleteItem(item.id)"
                                ></v-btn>
                            </template>
                        </v-tooltip>
                    </div>
                </template>
            </v-data-table>
        </v-card>
    </PendampingDashboardLayout>
</template>
