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

console.log(filteredItems);

// watch([filterPendamping, filterKota], () => {});
const page = usePage();

const deleteItem = (id) => {
    router.delete(route("mitra-industri.destroy", id), {
        preserveScroll: true,
        preserveState: true,
    });
};

const editItem = (id) => {
    router.get(route("mitra-industri.edit", id));
};
watch(
    () => page.props.flash,
    (flash) => {
        if (flash?.success) {
            Swal.fire({
                icon: "success",
                title: flash.success,
            });
        }
        if (flash?.error) {
            Swal.fire({
                icon: "error",
                title: flash.error,
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
    { title: "Nama Instansi", key: "nama_instansi" },
    { title: "Bidang Usaha", key: "bidang_usaha" },
    { title: "Pendamping", key: "pendamping.name" },
    { title: "Supervisors", key: "supervisor.name" },
    { title: "Kuota", key: "kuota" },
    { title: "Lokasi", key: "alamat.kecamatan" },
    { title: "Aksi", key: "actions", sortable: false, align: "center" },
];

const title = [
    {
        title: "Mitra Industri",
        disabled: false,
        href: "breadcrumbs_dashboard",
    },
    {
        title: "Edit",
        disabled: true,
        href: "breadcrumbs_dashboard",
    },
];
</script>

<template>
    <PendampingDashboardLayout>
        <template #headerTitle
            ><v-breadcrumbs :items="title" class="text-base md:text-xl">
                <template v-slot:divider>
                    <v-icon icon="mdi-chevron-right"></v-icon>
                </template>
            </v-breadcrumbs>
        </template>
        <v-card class="pa-3 z-20! space-y-5! border border-gray-700">
            <div class="d-flex justify-end align-center">
                <Link :href="route('mitra-industri.create')">
                    <v-btn
                        prepend-icon="mdi:plus"
                        text="Tambah Mitra Industri"
                    />
                </Link>
            </div>
            <div class="grid! grid-cols-4! gap-3">
                <v-text-field
                    v-model="search"
                    label="Cari Nama Atau Bidang Usaha"
                    prepend-inner-icon="mdi-magnify"
                    class="col-span-2"
                    variant="outlined"
                    single-line
                ></v-text-field>
                <v-select
                    v-model="filterPendamping"
                    label="Pilih Pendamping"
                    :items="listPendampingsOptions"
                    item-title="name"
                    item-value="id"
                ></v-select>
                <v-select
                    v-model="filterSupervisors"
                    label="Pilih Supervisors"
                    :items="listSupervisorsOptions"
                    item-title="name"
                    item-value="id"
                ></v-select>
            </div>
            <v-data-table
                :headers="headers"
                :items="filteredItems"
                :search="search"
                class="border bg-gray-300 z-0!"
                hover
            >
                <template #item.actions="{ item }">
                    <div class="d-flex ga-2 justify-end">
                        <v-btn
                            icon="mdi-pencil"
                            color="amber"
                            size="small"
                            @click="editItem(item.id)"
                        ></v-btn>

                        <v-btn
                            icon="mdi-delete"
                            size="small"
                            color="red"
                            @click="deleteItem(item.id)"
                        ></v-btn>
                    </div>
                </template>
            </v-data-table>
        </v-card>
    </PendampingDashboardLayout>
</template>
