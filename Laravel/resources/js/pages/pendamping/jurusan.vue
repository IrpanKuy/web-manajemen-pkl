<script setup>
import { computed, ref, watch } from "vue";
import { useForm, router } from "@inertiajs/vue3";
import Swal from "sweetalert2";
import PendampingDashboardLayout from "../layouts/PendampingDashboardLayout.vue";

// --- PROPS DARI CONTROLLER ---
const props = defineProps({
    jurusans: Array, // Data Paginator
});

// --- STATE LOKAL ---
const dialog = ref(false);
const isEditing = ref(false);

// --- DEFINISI FORM INERTIA ---
const form = useForm({
    id: null,
    nama_jurusan: "",
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

const items = computed(() => props.jurusans);

const search = ref("");

// --- HEADER TABEL ---
const headers = [
    { title: "Nama Jurusan", key: "nama_jurusan" },
    { title: "Aksi", key: "actions", sortable: false, align: "end" },
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
    form.nama_jurusan = item.nama_jurusan;

    dialog.value = true;
};

// 3. Simpan Data (Store / Update)
const submit = () => {
    if (isEditing.value) {
        form.put(route("jurusan.update", { jurusan: form.id }), {
            onSuccess: () => {
                dialog.value = false;
            },
        });
    } else {
        form.post(route("jurusan.store"), {
            onSuccess: () => {
                dialog.value = false;
            },
        });
    }
};

// 4. Hapus Data
const deleteItem = (id) => {
    Swal.fire({
        title: "Hapus Jurusan?",
        text: "Data tidak bisa dikembalikan!",
        icon: "warning",
        showCancelButton: true,
        confirmButtonText: "Ya, Hapus",
    }).then((result) => {
        if (result.isConfirmed) {
            router.delete(route("jurusan.destroy", id), {
                onSuccess: () =>
                    Swal.fire("Terhapus!", "Jurusan dihapus.", "success"),
            });
        }
    });
};
</script>

<template>
    <PendampingDashboardLayout>
        <template #headerTitle>Jurusan</template>

        <v-card class="pa-4 border border-gray-700" elevation="2" rounded="lg">
            <!-- HEADER: Tombol Tambah (Tanpa Search/Filter rumit) -->
            <div class="md:flex hidden justify-between gap-3">
                <v-text-field
                    v-model="search"
                    label="Cari Nama Jurusan"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    single-line
                ></v-text-field>
                <v-btn
                    color="primary"
                    prepend-icon="mdi-plus"
                    @click="openCreateModal"
                >
                    Tambah Jurusan
                </v-btn>
            </div>
            <div class="flex flex-col md:hidden gap-3">
                <v-btn
                    color="primary"
                    prepend-icon="mdi-plus"
                    @click="openCreateModal"
                >
                    Tambah Jurusan
                </v-btn>
                <v-text-field
                    v-model="search"
                    label="Cari Nama Jurusan"
                    prepend-inner-icon="mdi-magnify"
                    variant="outlined"
                    single-line
                ></v-text-field>
            </div>

            <!-- TABEL DATA -->
            <v-data-table
                :headers="headers"
                :search="search"
                :items="items"
                class="elevation-0 border"
                hover
            >
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

        <transition name="fade">
            <div
                v-if="dialog"
                class="fixed inset-0 bg-black/50 flex items-center justify-center z-66"
            >
                <div
                    class="bg-white rounded-lg shadow-lg max-w-lg w-full p-5 animate-scale"
                >
                    <v-card>
                        <v-card-title class="bg-indigo-darken-1 text-white">
                            <span class="text-h6">{{
                                isEditing
                                    ? "Edit Jurusan"
                                    : "Tambah Jurusan Baru"
                            }}</span>
                        </v-card-title>

                        <v-card-text class="pt-4">
                            <v-form @submit.prevent="submit">
                                <v-row>
                                    <!-- NAMA -->
                                    <v-col cols="12">
                                        <v-text-field
                                            v-model="form.nama_jurusan"
                                            label="Nama Jurusan"
                                            placeholder="Masukkan nama jurusan"
                                            variant="outlined"
                                            :error-messages="
                                                form.errors.nama_jurusan
                                            "
                                            :error="!!form.errors.nama_jurusan"
                                        ></v-text-field>
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
                                {{
                                    isEditing
                                        ? "Simpan Perubahan"
                                        : "Simpan Jurusan"
                                }}
                            </v-btn>
                        </v-card-actions>
                    </v-card>
                </div>
            </div>
        </transition>
    </PendampingDashboardLayout>
</template>
<style scoped>
.fade-enter-from,
.fade-leave-to {
    opacity: 0;
}

.fade-enter-active,
.fade-leave-active {
    transition: 0.2s;
}

.animate-scale {
    animation: scaleIn 0.2s ease;
}

@keyframes scaleIn {
    0% {
        transform: scale(0.95);
        opacity: 0;
    }
    100% {
        transform: scale(1);
        opacity: 1;
    }
}
</style>
