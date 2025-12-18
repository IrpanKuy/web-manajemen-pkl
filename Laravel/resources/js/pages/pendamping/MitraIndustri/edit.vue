<script setup>
import { Link, useForm } from "@inertiajs/vue3";
import PendampingDashboardLayout from "../../layouts/PendampingDashboardLayout.vue";
import { computed, nextTick, onMounted, ref, watch } from "vue";
import { VueDatePicker } from "@vuepic/vue-datepicker";
import "@vuepic/vue-datepicker/dist/main.css";
import L from "leaflet";
import "leaflet/dist/leaflet.css";
import Swal from "sweetalert2";

const step = ref(1);

// inisialisasi variabel data map
const lat = ref(-7.536064);
const lng = ref(112.238402);
const radius = ref(100); //dalam meter
let map = null;
let marker = null;
let circle = null;

const props = defineProps({
    mitra: Object,
    jurusans: Array,
    listPendampings: Array,
});

// Initialize lat/lng/radius from props
onMounted(() => {
    if (props.mitra.alamat?.latitude) {
        lat.value = props.mitra.alamat.latitude;
    }
    if (props.mitra.alamat?.longitude) {
        lng.value = props.mitra.alamat.longitude;
    }
    if (props.mitra.alamat?.radius_meter) {
        radius.value = props.mitra.alamat.radius_meter;
    }
});

watch(step, async (newValue) => {
    if (newValue === 3) {
        await nextTick();
        initMap();
    }
});

const initMap = () => {
    if (map) return;
    map = L.map("map").setView([lat.value, lng.value], 13);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        attribution:
            '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    }).addTo(map);

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
        lat.value = posisi.lat;
        lng.value = posisi.lng;

        if (typeof form !== "undefined") {
            form.latitude = lat.value;
            form.longitude = lng.value;
        }

        circle.setLatLng(posisi);
    });
};

watch([lat, lng], ([newLat, newLng]) => {
    if (map && marker && circle) {
        const newPos = [newLat, newLng];
        marker.setLatLng(newPos);
        circle.setLatLng(newPos);
        map.panTo(newPos);

        form.latitude = newLat;
        form.longitude = newLng;
    }
});

watch(radius, (newRadius) => {
    if (circle) {
        circle.setRadius(Number(newRadius));
        form.radius_meter = newRadius;
    }
});

const form = useForm({
    pendamping_id: props.mitra.pendamping_id,
    nama_instansi: props.mitra.nama_instansi,
    deskripsi: props.mitra.deskripsi,
    bidang_usaha: props.mitra.bidang_usaha,
    jam_masuk: props.mitra.jam_masuk,
    jam_pulang: props.mitra.jam_pulang,
    kuota: props.mitra.kuota,
    jurusan_ids: (() => {
        let ids = props.mitra.jurusan_ids ?? [];

        if (
            typeof ids === "string" &&
            ids.startsWith("[") &&
            ids.endsWith("]")
        ) {
            try {
                ids = JSON.parse(ids);
            } catch (e) {
                console.error("Gagal parse jurusan_ids string:", e);
                ids = [];
            }
        }

        if (Array.isArray(ids)) {
            return ids.map((id) => parseInt(id)).filter((id) => !isNaN(id));
        }

        return [];
    })(),

    tanggal_masuk: props.mitra.tanggal_masuk ?? "none",

    // Supervisor Data (for editing existing supervisor)
    supervisor_name: props.mitra.supervisor?.name ?? "",
    supervisor_email: props.mitra.supervisor?.email ?? "",
    supervisor_phone: props.mitra.supervisor?.phone ?? "",
    supervisor_password: "", // Empty for edit, only filled if changing password

    // Alamat
    profinsi: props.mitra.alamat?.profinsi ?? "",
    kabupaten: props.mitra.alamat?.kabupaten ?? "",
    kecamatan: props.mitra.alamat?.kecamatan ?? "",
    kode_pos: props.mitra.alamat?.kode_pos ?? "",
    detail_alamat: props.mitra.alamat?.detail_alamat ?? "",

    latitude: props.mitra.alamat?.latitude ?? "-7.536064",
    longitude: props.mitra.alamat?.longitude ?? "112.238402",

    radius_meter: props.mitra.alamat?.radius_meter ?? 100,
});

// kirim ke controller
const submit = (id) => {
    form.put(route("mitra-industri.update", id), {
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
</script>

<template>
    <PendampingDashboardLayout>
        <template #headerTitle>
            <Link :href="route('mitra-industri.index')">Mitra Industri</Link>
            <Icon icon="mdi:keyboard-arrow-right" width="32"></Icon>
            <span>Edit</span>
        </template>
        <form @submit.prevent="submit(props.mitra.id)">
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

                <!-- STEP 2: Supervisor (Edit) -->
                <template #item.2>
                    <v-card flat class="pa-4">
                        <h3 class="text-lg font-bold mb-4">
                            Edit Data Supervisor
                        </h3>

                        <v-alert type="info" class="mb-4" variant="tonal">
                            Edit data supervisor mitra. Kosongkan password jika
                            tidak ingin mengubah.
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
                                label="Password Supervisor (Opsional)"
                                type="password"
                                variant="outlined"
                                density="compact"
                                hint="Kosongkan jika tidak ingin mengubah password"
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
