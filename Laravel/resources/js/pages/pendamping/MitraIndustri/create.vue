<script setup>
import { Link, useForm } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";
import { computed, nextTick, onMounted, ref, watch } from "vue";
import { VueDatePicker } from "@vuepic/vue-datepicker";
import "@vuepic/vue-datepicker/dist/main.css";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import Swal from "sweetalert2";

const tempDate = ref("");
const step = ref(1);

// inisialisasi variabel data map
const lat = ref(-7.536064);
const lng = ref(112.238402);
const radius = ref(100); //dalam meter
let map = null;
let marker = null;
let circle = null;

watch(step, async (newValue) => {
    if (newValue === 3) {
        // PENTING: Tunggu Vue selesai merender elemen <div id="map">
        await nextTick();

        // Jalankan init map
        initMap();
    }
});

const initMap = () => {
    // 1. Inisialisasi Map
    map = L.map("map").setView([lat.value, lng.value], 13);

    // 2. Tambahkan Tile Layer (Peta Dasarnya)
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution:
            '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

    // 3. Tambahkan Marker (Opsional)
    marker = L.marker([lat.value, lng.value], { draggable: true })
        .addTo(map)
        .bindPopup("Lokasi Mitra")
        .openPopup();

    circle = L.circle([lat.value, lng.value], {
        color: "red",
        fillColor: "#f03",
        fillOpacity: 0.5,
        radius: radius.value,
    }).addTo(map);
    marker.on("dragend", (event) => {
        const posisi = event.target.getLatLng();

        // Update variabel reaktif
        lat.value = posisi.lat;
        lng.value = posisi.lng;

        // Update Form Inertia (jika pakai)
        if (typeof form !== "undefined") {
            form.latitude = lat.value;
            form.longitude = lng.value;
        }

        circle.setLatLng(posisi);

        console.log("Updated:", posisi);
    });
};

// A. Jika Lat/Lng berubah (misal user ketik manual di input), update Marker & Circle
watch([lat, lng], ([newLat, newLng]) => {
    if (map && marker && circle) {
        const newPos = [newLat, newLng];
        marker.setLatLng(newPos); // Pindah marker
        circle.setLatLng(newPos); // Pindah lingkaran
        map.panTo(newPos); // Geser kamera map ke tengah

        form.latitude = newLat;
        form.longitude = newLng;
    }
});

// B. Jika Radius berubah, update ukuran Circle
watch(radius, (newRadius) => {
    if (circle) {
        circle.setRadius(Number(newRadius));
        form.radius_meter = newRadius;
    }
});

watch(tempDate, (d) => {
    if (!d) return;
    form.tanggal_masuk = d.toString().split("T")[0];
});

const form = useForm({
    // --- DATA MITRA INDUSTRI ---
    pendamping_id: null,
    nama_instansi: "",
    deskripsi: "",
    bidang_usaha: "",
    jam_masuk: "",
    jam_pulang: "",
    kuota: 0,
    jurusan_ids: [],
    tanggal_masuk: "",

    // --- SUPERVISOR DATA (Always create new) ---
    supervisor_name: "",
    supervisor_email: "",
    supervisor_phone: "",
    supervisor_password: "",

    // --- DATA ALAMAT ---
    profinsi: "",
    kabupaten: "",
    kecamatan: "",
    kode_pos: "",
    detail_alamat: "",

    // kolom 'location'
    latitude: -7.536064,
    longitude: 112.238402,

    radius_meter: 100,
});

// kirim ke controller
const submit = () => {
    form.post(route("mitra-industri.store"), {
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
    console.log("Ada error validasi dari useForm!");
    Swal.fire({
        icon: "error",
        title: "Gagal terkirim",
        text: "Periksa kembali form data atau alamat mitra",
    });
};

Object.keys(form.data()).forEach((field) => {
    watch(
        () => form[field],
        (newVal) => {
            if (form.errors[field]) {
                form.clearErrors(field);
            }
            console.log(`User mengubah ${field} menjadi ${newVal}`);
        },
        500
    );
});

// Computed Property: Mengubah "2025-12-03" menjadi "03 Desember 2025" untuk tampilan
const displayDate = computed(() => {
    if (!tempDate.value) return "";

    const date = new Date(tempDate.value);
    return new Intl.DateTimeFormat("id-ID", {
        day: "2-digit",
        month: "long",
        year: "numeric",
    }).format(date);
});

const props = defineProps({
    listPendampings: Array,
    jurusans: Array,
});
</script>

<template>
    <PendampingDashboardLayout>
        <template #headerTitle>
            <Link :href="route('mitra-industri.index')">Mitra Industri</Link>
            <Icon icon="mdi:keyboard-arrow-right" width="32"></Icon>
            <Link :href="route('mitra-industri.create')">Create</Link>
        </template>
        <form @submit.prevent="submit">
            <v-stepper
                v-model="step"
                hide-actions
                :items="['Data Mitra', 'Supervisor', 'Alamat Mitra']"
            >
                <!-- STEP 1: Data Mitra -->
                <template #item.1>
                    <v-card flat class="p-3!">
                        <div class="grid! grid-cols-2! md:grid-cols-4! gap-3!">
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

                            <div>
                                <v-select
                                    v-model="form.pendamping_id"
                                    label="Pilih Pendamping Mitra"
                                    :items="listPendampings"
                                    item-title="name"
                                    item-value="id"
                                    :error-messages="form.errors.pendamping_id"
                                    :error="!!form.errors.pendamping_id"
                                ></v-select>
                            </div>

                            <div class="mb-4">
                                <VueDatePicker
                                    v-model="tempDate"
                                    model-type="yyyy-MM-dd"
                                    :enable-time-picker="false"
                                    teleport="body"
                                    auto-apply
                                >
                                    <template #trigger>
                                        <v-text-field
                                            :model-value="displayDate"
                                            label="Tanggal Masuk"
                                            prepend-inner-icon="mdi-calendar"
                                            variant="outlined"
                                            readonly
                                            hide-details
                                            placeholder="Pilih Tanggal"
                                            class="cursor-pointer"
                                            :error-messages="
                                                form.errors.tanggal_masuk
                                            "
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
                                    chips
                                    multiple
                                    label="Pilih Jurusan Mitra"
                                    :items="jurusans"
                                    item-title="nama_jurusan"
                                    item-value="id"
                                    :error-messages="form.errors.jurusan_ids"
                                    :error="!!form.errors.jurusan_ids"
                                ></v-select>
                            </div>

                            <v-textarea
                                v-model="form.deskripsi"
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

                        <template #actions>
                            <v-btn color="grey" variant="text" @click="step = 1"
                                >Batal</v-btn
                            >
                            <v-btn
                                color="primary"
                                variant="elevated"
                                @click="step = 2"
                                >Lanjut 🚀</v-btn
                            >
                        </template>
                    </v-card>
                </template>

                <!-- STEP 2: Supervisor (Create Only) -->
                <template #item.2>
                    <v-card flat class="pa-4">
                        <h3 class="text-lg font-bold mb-4">
                            Data Supervisor Mitra
                        </h3>

                        <v-alert type="info" class="mb-4" variant="tonal">
                            Buat akun supervisor baru untuk mitra ini.
                            Supervisor akan otomatis dibuat saat mitra disimpan.
                        </v-alert>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <v-text-field
                                v-model="form.supervisor_name"
                                label="Nama Supervisor"
                                variant="outlined"
                                density="compact"
                                :error-messages="form.errors.supervisor_name"
                                :error="!!form.errors.supervisor_name"
                            ></v-text-field>

                            <v-text-field
                                v-model="form.supervisor_email"
                                label="Email Supervisor"
                                type="email"
                                variant="outlined"
                                density="compact"
                                :error-messages="form.errors.supervisor_email"
                                :error="!!form.errors.supervisor_email"
                            ></v-text-field>

                            <v-text-field
                                v-model="form.supervisor_phone"
                                label="No HP Supervisor"
                                variant="outlined"
                                density="compact"
                                :error-messages="form.errors.supervisor_phone"
                                :error="!!form.errors.supervisor_phone"
                            ></v-text-field>

                            <v-text-field
                                v-model="form.supervisor_password"
                                label="Password Supervisor"
                                type="password"
                                variant="outlined"
                                density="compact"
                                hint="Minimal 8 karakter"
                                persistent-hint
                                :error-messages="
                                    form.errors.supervisor_password
                                "
                                :error="!!form.errors.supervisor_password"
                            ></v-text-field>
                        </div>

                        <template #actions>
                            <v-btn
                                color="grey"
                                variant="tonal"
                                @click="step = 1"
                            >
                                Kembali
                            </v-btn>

                            <v-btn
                                color="primary"
                                variant="flat"
                                @click="step = 3"
                            >
                                Lanjut 🚀
                            </v-btn>
                        </template>
                    </v-card>
                </template>

                <!-- STEP 3: Alamat Mitra -->
                <template #item.3>
                    <v-card flat class="pa-1">
                        <div class="flex! flex-col! gap-3!">
                            <div id="map"></div>
                            <div class="grid! grid-cols-2! gap-3!">
                                <v-text-field
                                    v-model="lat"
                                    label="Latitude"
                                    :error-messages="form.errors.latitude"
                                    :error="!!form.errors.latitude"
                                ></v-text-field>

                                <v-text-field
                                    v-model="lng"
                                    label="Longitude"
                                    :error-messages="form.errors.longitude"
                                    :error="!!form.errors.longitude"
                                ></v-text-field>

                                <v-text-field
                                    v-model="radius"
                                    label="Radius(dalam meter)"
                                    :error-messages="form.errors.radius_meter"
                                    :error="!!form.errors.radius_meter"
                                ></v-text-field>

                                <v-text-field
                                    v-model="form.profinsi"
                                    label="Provinsi"
                                    :error-messages="form.errors.profinsi"
                                    :error="!!form.errors.profinsi"
                                ></v-text-field>

                                <v-text-field
                                    v-model="form.kabupaten"
                                    label="Kabupaten"
                                    :error-messages="form.errors.kabupaten"
                                    :error="!!form.errors.kabupaten"
                                ></v-text-field>

                                <v-text-field
                                    v-model="form.kecamatan"
                                    label="Kecamatan"
                                    :error-messages="form.errors.kecamatan"
                                    :error="!!form.errors.kecamatan"
                                ></v-text-field>

                                <v-text-field
                                    style="align-self: start"
                                    v-model="form.kode_pos"
                                    label="Kode Pos"
                                    :error-messages="form.errors.kode_pos"
                                    :error="!!form.errors.kode_pos"
                                ></v-text-field>

                                <v-textarea
                                    v-model="form.detail_alamat"
                                    label="Detail Alamat"
                                    :error-messages="form.errors.detail_alamat"
                                    :error="!!form.errors.detail_alamat"
                                ></v-textarea>
                            </div>
                        </div>

                        <template #actions>
                            <v-btn
                                color="grey"
                                variant="tonal"
                                @click="step = 2"
                            >
                                Kembali
                            </v-btn>

                            <v-btn
                                type="submit"
                                color="success"
                                variant="flat"
                                :loading="form.processing"
                            >
                                Selesai ✔
                            </v-btn>
                        </template>
                    </v-card>
                </template>
            </v-stepper>
        </form>
    </PendampingDashboardLayout>
</template>
<style scoped>
.cursor-pointer :deep(.v-field) {
    cursor: pointer;
}

#map {
    height: 400px;
    width: 100%;
    z-index: 1;
}
</style>
