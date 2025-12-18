<script setup>
import { computed, ref } from "vue";
import { useForm, router } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";
import Swal from "sweetalert2";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    users: Object, // Data Paginator
});

// --- STATE LOKAL ---
const dialog = ref(false);
const isEditing = ref(false);

// --- DEFINISI FORM INERTIA ---
const form = useForm({
    id: null,
    name: "",
    email: "",
    phone: "",
    password: "",
    is_active: true,
});

const search = ref("");

// --- HEADER TABEL ---
const headers = [
    { title: "Nama User", key: "name" },
    { title: "Email", key: "email" },
    { title: "No HP", key: "phone" },
    { title: "Status", key: "is_active", align: "center" },
    { title: "Aksi", key: "actions", sortable: false, align: "center" },
];

// --- FUNGSI ACTIONS ---

// 1. Buka Modal Create
const openCreateModal = () => {
    isEditing.value = false;
    form.reset();
    form.clearErrors();
    form.is_active = true;
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
    form.phone = item.phone;
    form.is_active = !!item.is_active;
    form.password = "";

    dialog.value = true;
};

// 3. Simpan Data (Store / Update)
const submit = () => {
    if (isEditing.value) {
        form.put(route("manajemen-role.update", form.id), {
            onSuccess: () => {
                dialog.value = false;
                Swal.fire("Berhasil", "Data berhasil diupdate", "success");
            },
        });
    } else {
        form.post(route("manajemen-role.store"), {
            onSuccess: () => {
                dialog.value = false;
                Swal.fire("Berhasil", "Pendamping baru ditambahkan", "success");
            },
        });
    }
};

// 4. Hapus Data
const deleteItem = (id) => {
    Swal.fire({
        title: "Hapus Pendamping?",
        text: "Data tidak bisa dikembalikan!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Ya, Hapus",
    }).then((result) => {
        if (result.isConfirmed) {
            router.delete(route("manajemen-role.destroy", id), {
                onSuccess: () =>
                    Swal.fire("Terhapus!", "Pendamping dihapus.", "success"),
            });
        }
    });
};

const title = [
    {
        title: "Manajemen Pendamping",
        disabled: false,
        href: route("manajemen-role.index"),
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
                <h3 class="text-lg md:text-xl mb-2 font-bold">
                    Data Pendamping
                </h3>
            </v-card-title>

            <!-- HEADER: Search & Tombol Tambah -->
            <div class="flex justify-between gap-3 mb-4">
                <v-text-field
                    v-model="search"
                    label="Cari Nama Atau Email"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    single-line
                    density="compact"
                    style="max-width: 400px"
                ></v-text-field>
                <v-btn
                    color="primary"
                    prepend-icon="mdi-plus"
                    @click="openCreateModal"
                >
                    Tambah Pendamping
                </v-btn>
            </div>

            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :items="props.users?.data || []"
                :search="search"
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
                        isEditing ? "Edit Pendamping" : "Tambah Pendamping Baru"
                    }}</span>
                </v-card-title>

                <v-card-text class="pt-4">
                    <v-form @submit.prevent="submit">
                        <v-row>
                            <!-- NAMA -->
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.name"
                                    label="Nama Lengkap"
                                    placeholder="Masukkan nama"
                                    variant="outlined"
                                    density="compact"
                                    :error-messages="form.errors.name"
                                    :error="!!form.errors.name"
                                ></v-text-field>
                            </v-col>

                            <!-- EMAIL -->
                            <v-col cols="12" md="6">
                                <v-text-field
                                    v-model="form.email"
                                    label="Email"
                                    type="email"
                                    variant="outlined"
                                    density="compact"
                                    :error-messages="form.errors.email"
                                    :error="!!form.errors.email"
                                ></v-text-field>
                            </v-col>

                            <!-- NO HP -->
                            <v-col cols="12" md="6">
                                <v-text-field
                                    v-model="form.phone"
                                    label="Nomor HP"
                                    type="tel"
                                    variant="outlined"
                                    density="compact"
                                    :error-messages="form.errors.phone"
                                    :error="!!form.errors.phone"
                                ></v-text-field>
                            </v-col>

                            <!-- PASSWORD -->
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.password"
                                    label="Password"
                                    type="password"
                                    variant="outlined"
                                    density="compact"
                                    :hint="
                                        isEditing
                                            ? 'Kosongkan jika tidak ingin mengganti password'
                                            : 'Wajib diisi minimal 8 karakter'
                                    "
                                    persistent-hint
                                    :error-messages="form.errors.password"
                                    :error="!!form.errors.password"
                                ></v-text-field>
                            </v-col>

                            <!-- STATUS AKTIF -->
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
                        {{ isEditing ? "Simpan Perubahan" : "Simpan" }}
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </PendampingDashboardLayout>
</template>
