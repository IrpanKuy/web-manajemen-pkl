<script setup>
import Swal from "sweetalert2";
import SupervisorsDashboardLayout from "../layouts/SupervisorsDashboardLayout.vue";
import { watch } from "vue";
import { useForm, usePage } from "@inertiajs/vue3";
import { VueDatePicker } from "@vuepic/vue-datepicker";
import "@vuepic/vue-datepicker/dist/main.css";

const title = [
    {
        title: "Profil Instansi",
        disabled: false,
        href: "breadcrumbs_dashboard",
    },
];

const props = defineProps({
    mitra: Object,
    jurusans: Array,
});

const form = useForm({
    nama_instansi: props.mitra.nama_instansi,
    pendamping_id: props.mitra.pendamping_id,
    supervisors_id: props.mitra.supervisors_id,
    pendamping: props.mitra.pendamping.name,
    deskripsi: props.mitra.deskripsi,
    bidang_usaha: props.mitra.bidang_usaha,
    jam_masuk: props.mitra.jam_masuk,
    jam_pulang: props.mitra.jam_pulang,
    kuota: props.mitra.kuota,
    jurusan_ids: (() => {
        let ids = props.mitra.jurusan_ids ?? [];

        // Cek apakah data adalah string yang terlihat seperti JSON
        if (
            typeof ids === "string" &&
            ids.startsWith("[") &&
            ids.endsWith("]")
        ) {
            try {
                // Parse string JSON menjadi array
                ids = JSON.parse(ids);
            } catch (e) {
                console.error("Gagal parse jurusan_ids string:", e);
                ids = []; // Jika gagal, set array kosong
            }
        }

        // Pastikan semua elemen di dalamnya adalah angka (integer)
        if (Array.isArray(ids)) {
            // Konversi elemen menjadi integer, hanya ambil yang valid
            return ids.map((id) => parseInt(id)).filter((id) => !isNaN(id));
        }

        return []; // Jika bukan array, kembalikan array kosong
    })(),

    tanggal_masuk: props.mitra.tanggal_masuk ?? "none",
});

const submit = (id) => {
    form.put(route("profile-instansi.update", id), {
        preserveScroll: true,
    });
};

watch(
    () => form.errors,
    (errors) => {
        if (Object.keys(errors).length > 0) {
            onValidationError();
        }
    }
);

const onValidationError = () => {
    console.log("Ada error validasi dari useForm!", form.errors);
    // Contoh pake SweetAlert:
    Swal.fire({
        icon: "error",
        title: "Gagal terkirim",
        text: "Periksa kembali form data atau alamat mitra",
    });
};

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
</script>
<template>
    <SupervisorsDashboardLayout>
        <template #headerTitle>
            <v-breadcrumbs :items="title" class="text-base md:text-xl">
                <template v-slot:divider>
                    <v-icon icon="mdi-chevron-right"></v-icon>
                </template>
            </v-breadcrumbs>
        </template>
        <form @submit.prevent="submit(props.mitra.id)">
            <v-card class="p-3!">
                <div class="grid! grid-cols-2! md:grid-cols-4! gap-3!">
                    <div>
                        <v-text-field
                            v-model="form.pendamping"
                            readonly
                            label="Nama Pendamping"
                            :error-messages="form.errors.pendamping"
                            :error="!!form.errors.pendamping"
                        ></v-text-field>
                    </div>
                    <div>
                        <v-text-field
                            v-model="form.nama_instansi"
                            label="Nama Instansi"
                            :error-messages="form.errors.nama_instansi"
                            :error="!!form.errors.nama_instansi"
                        ></v-text-field>
                    </div>

                    <div>
                        <v-text-field
                            v-model="form.bidang_usaha"
                            label="Bidang Usaha"
                            placeholder="fashion, bengkel"
                            :error-messages="form.errors.bidang_usaha"
                            :error="!!form.errors.bidang_usaha"
                        ></v-text-field>
                    </div>

                    <div class="mb-4">
                        <VueDatePicker
                            v-model="form.tanggal_masuk"
                            model-type="yyyy-MM-dd"
                            :enable-time-picker="false"
                            teleport="body"
                            auto-apply
                        >
                            <template #trigger>
                                <v-text-field
                                    :model-value="form.tanggal_masuk"
                                    label="Tanggal Masuk"
                                    prepend-inner-icon="mdi-calendar"
                                    variant="outlined"
                                    readonly
                                    hide-details
                                    placeholder="Pilih Tanggal"
                                    class="cursor-pointer"
                                    :error-messages="form.errors.tanggal_masuk"
                                    :error="!!form.errors.tanggal_masuk"
                                ></v-text-field>
                            </template>
                        </VueDatePicker>
                    </div>

                    <div>
                        <v-number-input
                            v-model="form.kuota"
                            label="Kuota"
                            :error-messages="form.errors.kuota"
                            :error="!!form.errors.kuota"
                        ></v-number-input>
                    </div>

                    <div>
                        <v-select
                            v-model="form.jurusan_ids"
                            label="Jurusan"
                            chips
                            multiple
                            :items="jurusans"
                            item-title="nama_jurusan"
                            item-value="id"
                            :error-messages="form.errors.jurusan_ids"
                            :error="!!form.errors.jurusan_ids"
                        >
                        </v-select>
                    </div>

                    <v-textarea
                        v-model="form.deskripsi"
                        class="col-span-2!"
                        label="Deskripsi/Syarat Instansi"
                        :error-messages="form.errors.deskripsi"
                        :error="!!form.errors.deskripsi"
                    ></v-textarea>

                    <v-time-picker
                        v-model="form.jam_masuk"
                        title="Pilih Waktu Masuk PKL"
                        header="Pilih Waktu"
                        format="24hr"
                        class="col-span-2!"
                        color="primary"
                    ></v-time-picker>

                    <v-time-picker
                        v-model="form.jam_pulang"
                        title="Pilih Waktu Pulang PKL"
                        header="Pilih Waktu"
                        format="24hr"
                        class="col-span-2!"
                        color="primary"
                    ></v-time-picker>
                </div>
                <v-btn
                    type="submit"
                    color="success"
                    variant="flat"
                    :loading="form.processing"
                >
                    Update Data
                </v-btn>
            </v-card>
        </form>
    </SupervisorsDashboardLayout>
</template>
