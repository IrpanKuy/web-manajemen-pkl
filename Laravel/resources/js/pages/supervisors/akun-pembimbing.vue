<script setup>
import { computed, ref } from "vue";
import { useForm, router } from "@inertiajs/vue3";
import SupervisorsDashboardLayout from "../layouts/SupervisorsDashboardLayout.vue";

import Swal from "sweetalert2";

// --- PROPS ---
const props = defineProps({
    pembimbings: Array, // Menerima Array lengkap dari Controller (tanpa paginator)
});

// --- STATE ---
const dialog = ref(false);
const isEditing = ref(false);
const search = ref("");

// --- FORM INERTIA ---
const form = useForm({
    id: null,
    name: "",
    email: "",
    phone: "",
    password: "",
    is_active: true,
    // Role tidak diperlukan di frontend karena di-handle backend
});

// --- TABLE HEADERS ---
const headers = [
    { title: "Nama Pembimbing", key: "name" },
    { title: "Email", key: "email" },
    { title: "No HP", key: "phone" },
    { title: "Status", key: "is_active", align: "center" },
    { title: "Aksi", key: "actions", sortable: false, align: "center" },
];

// --- LOGIC FILTER CLIENT-SIDE ---
const filteredItems = computed(() => {
    // Jika search kosong, tampilkan semua data
    if (!search.value) {
        return props.pembimbings;
    }

    // Logic pencarian sederhana (case-insensitive)
    const query = search.value.toLowerCase();

    return props.pembimbings.filter((item) => {
        return (
            (item.name && item.name.toLowerCase().includes(query)) ||
            (item.email && item.email.toLowerCase().includes(query)) ||
            (item.phone && item.phone.toLowerCase().includes(query))
        );
    });
});

// --- ACTIONS ---

const openCreateModal = () => {
    isEditing.value = false;
    form.reset();
    form.clearErrors();
    form.is_active = true;
    dialog.value = true;
};

const openEditModal = (item) => {
    isEditing.value = true;
    form.clearErrors();

    // Load data ke form
    form.id = item.id;
    form.name = item.name;
    form.email = item.email;
    form.phone = item.phone;
    form.is_active = !!item.is_active;
    form.password = ""; // Reset password agar tidak terisi hash

    dialog.value = true;
};

const submit = () => {
    if (isEditing.value) {
        // UPDATE -> route: akun-pembimbing.update
        form.put(route("akun-pembimbing.update", form.id), {
            onSuccess: () => {
                dialog.value = false;
                Swal.fire(
                    "Berhasil",
                    "Data pembimbing berhasil diperbarui",
                    "success"
                );
            },
        });
    } else {
        // CREATE -> route: akun-pembimbing.store
        form.post(route("akun-pembimbing.store"), {
            onSuccess: () => {
                dialog.value = false;
                Swal.fire("Berhasil", "Pembimbing baru ditambahkan", "success");
            },
        });
    }
};

const deleteItem = (id) => {
    Swal.fire({
        title: "Hapus Pembimbing?",
        text: "Data yang dihapus tidak dapat dikembalikan!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#d33",
        cancelButtonColor: "#3085d6",
        confirmButtonText: "Ya, Hapus",
        cancelButtonText: "Batal",
    }).then((result) => {
        if (result.isConfirmed) {
            router.delete(route("akun-pembimbing.destroy", id), {
                onSuccess: () =>
                    Swal.fire("Terhapus!", "Data berhasil dihapus.", "success"),
            });
        }
    });
};

const title = [
    {
        title: "Akun Pembimbing",
        disabled: false,
        href: route("akun-pembimbing.index"),
    },
];
</script>

<template>
    <SupervisorsDashboardLayout>
        <template #headerTitle
            ><v-breadcrumbs :items="title" class="text-base md:text-xl">
                <template v-slot:divider>
                    <v-icon icon="mdi-chevron-right"></v-icon>
                </template>
            </v-breadcrumbs>
        </template>

        <v-card class="pa-4 border border-gray-700" elevation="2" rounded="lg">
            <!-- HEADER TOOLBAR -->
            <div class="flex flex-col md:flex-row justify-between gap-3 mb-4">
                <!-- Search Input (Client Side) -->
                <div class="w-full md:w-1/3">
                    <v-text-field
                        v-model="search"
                        label="Cari Nama / Email / HP"
                        prepend-inner-icon="mdi-magnify"
                        variant="outlined"
                        density="compact"
                        hide-details
                        single-line
                        clearable
                    ></v-text-field>
                </div>

                <!-- Tombol Tambah -->
                <div>
                    <v-btn
                        color="primary"
                        prepend-icon="mdi-plus"
                        @click="openCreateModal"
                        elevation="2"
                    >
                        Tambah Pembimbing
                    </v-btn>
                </div>
            </div>

            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :items="filteredItems"
                class="elevation-0 border"
                hover
            >
                <template #item.index="{ index }">
                    {{ index + 1 }}
                </template>

                <template #item.phone="{ item }">
                    {{ item.phone || "-" }}
                </template>

                <!-- Status Chip -->
                <template #item.is_active="{ item }">
                    <v-chip
                        :color="item.is_active ? 'success' : 'error'"
                        size="small"
                        class="font-weight-bold"
                        variant="flat"
                    >
                        {{ item.is_active ? "Aktif" : "Non-Aktif" }}
                    </v-chip>
                </template>

                <!-- Action Buttons -->
                <template #item.actions="{ item }">
                    <div class="d-flex ga-2 justify-center">
                        <v-btn
                            icon="mdi-pencil"
                            color="amber"
                            size="small"
                            @click="openEditModal(item)"
                        ></v-btn>
                        <v-btn
                            icon="mdi-delete"
                            color="red"
                            size="small"
                            @click="deleteItem(item.id)"
                        ></v-btn>
                    </div>
                </template>

                <!-- State Kosong -->
                <template #no-data>
                    <div class="pa-4 text-center text-grey">
                        Tidak ada data pembimbing ditemukan
                    </div>
                </template>
            </v-data-table>
        </v-card>

        <!-- MODAL FORM (DIALOG) -->
        <v-dialog v-model="dialog" max-width="500px" persistent>
            <v-card>
                <v-card-title
                    class="bg-primary text-white d-flex justify-space-between align-center"
                >
                    <span class="text-h6">{{
                        isEditing ? "Edit Pembimbing" : "Tambah Pembimbing"
                    }}</span>
                    <v-btn
                        icon="mdi-close"
                        variant="text"
                        density="compact"
                        color="white"
                        @click="dialog = false"
                    ></v-btn>
                </v-card-title>

                <v-card-text class="pt-4">
                    <v-form @submit.prevent="submit">
                        <v-row dense>
                            <!-- Nama -->
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.name"
                                    label="Nama Lengkap"
                                    variant="outlined"
                                    density="compact"
                                    :error-messages="form.errors.name"
                                    prepend-inner-icon="mdi-account"
                                ></v-text-field>
                            </v-col>

                            <!-- Email -->
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.email"
                                    label="Email"
                                    type="email"
                                    variant="outlined"
                                    density="compact"
                                    :error-messages="form.errors.email"
                                    prepend-inner-icon="mdi-email"
                                ></v-text-field>
                            </v-col>

                            <!-- No HP -->
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.phone"
                                    label="Nomor HP"
                                    type="tel"
                                    variant="outlined"
                                    density="compact"
                                    :error-messages="form.errors.phone"
                                    prepend-inner-icon="mdi-phone"
                                ></v-text-field>
                            </v-col>

                            <!-- Password -->
                            <v-col cols="12">
                                <v-text-field
                                    v-model="form.password"
                                    label="Password"
                                    type="password"
                                    variant="outlined"
                                    density="compact"
                                    :hint="
                                        isEditing
                                            ? 'Biarkan kosong jika tidak ingin mengganti'
                                            : 'Wajib diisi'
                                    "
                                    persistent-hint
                                    :error-messages="form.errors.password"
                                    prepend-inner-icon="mdi-lock"
                                ></v-text-field>
                            </v-col>

                            <!-- Status Switch -->
                            <v-col cols="12">
                                <v-switch
                                    v-model="form.is_active"
                                    label="Status Akun Aktif"
                                    color="success"
                                    hide-details
                                    density="compact"
                                    class="ml-2"
                                ></v-switch>
                            </v-col>
                        </v-row>
                    </v-form>
                </v-card-text>

                <v-card-actions class="px-4 pb-4">
                    <v-spacer></v-spacer>
                    <v-btn
                        variant="text"
                        color="grey-darken-1"
                        @click="dialog = false"
                        >Batal</v-btn
                    >
                    <v-btn
                        color="primary"
                        variant="elevated"
                        @click="submit"
                        :loading="form.processing"
                        prepend-icon="mdi-content-save"
                    >
                        Simpan
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>
    </SupervisorsDashboardLayout>
</template>
