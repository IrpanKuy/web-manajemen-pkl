<script setup>
import { computed, ref, watch } from "vue";
import { useForm, router } from "@inertiajs/vue3";
import Swal from "sweetalert2";
import PendampingDashboardLayout from "../layouts/PendampingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    siswas: Object,
    jurusans: Array, // Data Paginator
});
console.log(props.siswas);
console.log(props.jurusans);

// --- STATE LOKAL ---
const dialog = ref(false);
const isEditing = ref(false);

// --- DEFINISI FORM INERTIA ---
const form = useForm({
    id: null,
    name: "",
    email: "",
    password: "",
    phone: "",
    nisn: "",
    kelas: "",
    jurusan_id: null,
    is_active: true,
});

Object.keys(form.data()).forEach((field) => {
    // Kita buat watch untuk setiap field
    watch(
        () => form[field],
        (newVal) => {
            // Cek: Jika field ini punya error, hapus errornya saat user mengetik
            if (form.errors[field]) {
                form.clearErrors(field);
            }
        },
        500
    );
});

const search = ref("");
const filterJurusan = ref(null);

const filterJurusanOption = computed(() => {
    return [{ id: null, nama_jurusan: "Semua Jurusan" }, ...props.jurusans];
});

const filteredItems = computed(() => {
    let data = props.siswas.data;
    if (filterJurusan.value) {
        data = data.filter(
            (siswa) => siswa.siswas.jurusan_id === filterJurusan.value
        );
    }
    console.log(props.siswas.data);

    return data;
});

// --- HEADER TABEL ---
const headers = [
    { title: "Nama Siswa", key: "name" },
    { title: "Email", key: "email" },
    { title: "No Hp", key: "phone" },
    { title: "Nisn", key: "siswas.nisn" },
    { title: "Jurusan", key: "siswas.jurusan.nama_jurusan" },
    { title: "Status", key: "is_active", align: "center" },
    { title: "Aksi", key: "actions", sortable: false, align: "center" },
];

// --- FUNGSI ACTIONS ---

// 1. Buka Modal Create
const openCreateModal = () => {
    isEditing.value = false;
    form.reset();
    form.clearErrors();
    dialog.value = true;
};

// 2. Buka Modal Edit
const openEditModal = (item) => {
    isEditing.value = true;
    form.clearErrors();

    // Load data item ke form
    form.id = item.id;
    form.name = item.name;
    form.email = item.email;
    form.password = item.password;
    form.phone = item.phone;
    form.nisn = item.siswas.nisn;
    form.jurusan_id = item.siswas.jurusan_id;
    form.is_active = !!item.is_active;

    dialog.value = true;
};

// 3. Simpan Data (Store / Update)
const submit = () => {
    if (isEditing.value) {
        form.put(route("data-siswa.update", { data_siswa: form.id }), {
            onSuccess: () => {
                dialog.value = false;
            },
        });
    } else {
        form.post(route("data-siswa.store"), {
            onSuccess: () => {
                dialog.value = false;
            },
        });
    }
};

const title = [
    {
        title: "Pengajuan Masuk Siswa",
        disabled: false,
        href: route("data-siswa.index"),
    },
];

// 4. Hapus Data
const deleteItem = (id) => {
    Swal.fire({
        title: "Hapus Siswa?",
        text: "Data tidak bisa dikembalikan!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Ya, Hapus",
    }).then((result) => {
        if (result.isConfirmed) {
            router.delete(route("data-siswa.destroy", id), {
                onSuccess: () =>
                    Swal.fire("Terhapus!", "Siswa dihapus.", "success"),
            });
        }
    });
};
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

        <v-card
            class="pa-4 space-y-5! border border-gray-700"
            elevation="2"
            rounded="lg"
        >
            <!-- HEADER: Tombol Tambah (Tanpa Search/Filter rumit) -->
            <div class="flex justify-end gap-3">
                <v-btn color="green">Import</v-btn>
                <v-btn color="green">Export Excel</v-btn>
                <v-btn
                    color="primary"
                    prepend-icon="mdi-plus"
                    @click="openCreateModal"
                >
                    Tambah Siswa
                </v-btn>
            </div>
            <div class="grid grid-cols-2 w-full gap-3">
                <v-text-field
                    v-model="search"
                    label="Cari Siswa"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    single-line
                ></v-text-field>
                <v-select
                    :items="filterJurusanOption"
                    v-model="filterJurusan"
                    label="Jurusan"
                    item-title="nama_jurusan"
                    item-value="id"
                ></v-select>
            </div>
            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :search="search"
                :items="filteredItems"
                class="elevation-0 border"
                hover
            >
                <!-- Kustomisasi Kolom Status -->
                <template #item.is_active="{ item }">
                    <v-icon :color="item.is_active ? 'green' : 'red'">
                        {{
                            item.is_active
                                ? "mdi-check-circle"
                                : "mdi-close-circle"
                        }}
                    </v-icon>
                </template>

                <!-- Kustomisasi Kolom Aksi -->
                <template #item.actions="{ item }">
                    <div class="d-flex ga-2 justify-end">
                        <v-btn
                            icon="mdi-pencil"
                            color="amber"
                            size="small"
                            @click="openEditModal(item)"
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

        <!-- ================= MODAL FORM (DIALOG) ================= -->
        <v-dialog v-model="dialog" max-width="600px" persistent>
            <v-card>
                <v-card-title class="bg-indigo-darken-1 text-white">
                    <span class="text-h6">{{
                        isEditing ? "Edit Siswa" : "Tambah Siswa Baru"
                    }}</span>
                </v-card-title>

                <v-card-text class="pt-4">
                    <v-form @submit.prevent="submit">
                        <v-row>
                            <!-- NAMA -->
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.name"
                                    label="Nama Siswa"
                                    placeholder="Masukkan nama Siswa"
                                    variant="outlined"
                                    :error-messages="form.errors.name"
                                    :error="!!form.errors.name"
                                ></v-text-field>
                            </v-col>
                            <v-col cols="6">
                                <v-text-field
                                    v-model="form.email"
                                    label="Email"
                                    placeholder="Masukkan Email"
                                    variant="outlined"
                                    :error-messages="form.errors.email"
                                    :error="!!form.errors.email"
                                ></v-text-field>
                            </v-col>
                            <v-col cols="6">
                                <v-text-field
                                    v-model="form.password"
                                    label="Password"
                                    placeholder="*********"
                                    variant="outlined"
                                    type="password"
                                    hide-details="auto"
                                    :error-messages="form.errors.password"
                                    :error="!!form.errors.password"
                                ></v-text-field>
                            </v-col>
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.phone"
                                    label="No Hp"
                                    placeholder="Masukkan No Hp"
                                    variant="outlined"
                                    :error-messages="form.errors.phone"
                                    :error="!!form.errors.phone"
                                ></v-text-field>
                            </v-col>
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.nisn"
                                    label="Nisn"
                                    placeholder="Masukkan Nisn"
                                    variant="outlined"
                                    :error-messages="form.errors.nisn"
                                    :error="!!form.errors.nisn"
                                ></v-text-field>
                            </v-col>
                            <v-col cols="12">
                                <v-select
                                    :items="props.jurusans"
                                    item-title="nama_jurusan"
                                    item-value="id"
                                    v-model="form.jurusan_id"
                                    label="Jurusan"
                                    placeholder="Masukkan Jurusan"
                                    variant="outlined"
                                    :error-messages="form.errors.jurusan_id"
                                    :error="!!form.errors.jurusan_id"
                                ></v-select>
                            </v-col>
                            <v-col cols="12">
                                <v-switch
                                    v-model="form.is_active"
                                    label="Akun Aktif?"
                                    color="primary"
                                    hide-details
                                ></v-switch>
                            </v-col>
                        </v-row>
                    </v-form>
                </v-card-text>

                <v-card-actions class="pb-4 px-4">
                    <v-spacer></v-spacer>
                    <v-btn
                        color="grey-darken-1"
                        variant="text"
                        @click="dialog = false"
                    >
                        Batal
                    </v-btn>
                    <v-btn
                        color="primary"
                        variant="flat"
                        :loading="form.processing"
                        @click="submit"
                    >
                        {{ isEditing ? "Simpan Perubahan" : "Simpan Siswa" }}
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </PendampingDashboardLayout>
</template>
