<script setup>
import { onMounted, ref } from "vue";
import PendampingDashboardLayout from "../layouts/PendampingDashboardLayout.vue";

// --- PROPS ---
const props = defineProps({
    summary: Object,
    absensiChart: Object,
    izinTerbaru: Array,
});

// --- CHART REF ---
const chartCanvas = ref(null);
let chartInstance = null;

// --- IZIN TABLE HEADERS ---
const izinHeaders = [
    { title: "Siswa", key: "siswa_info" },
    { title: "Tanggal", key: "tanggal" },
    { title: "Durasi", key: "durasi_hari", align: "center" },
    { title: "Keterangan", key: "keterangan" },
    { title: "Status", key: "status", align: "center" },
    { title: "Diproses Oleh", key: "approver" },
];

// --- HELPERS ---
const getStatusColor = (status) => {
    if (status === "approved") return "success";
    if (status === "rejected") return "error";
    return "warning";
};

const getStatusLabel = (status) => {
    if (status === "approved") return "Disetujui";
    if (status === "rejected") return "Ditolak";
    return "Pending";
};

const formatDate = (date) => {
    return new Date(date).toLocaleDateString("id-ID", {
        year: "numeric",
        month: "short",
        day: "numeric",
    });
};

// --- INIT CHART ---
onMounted(() => {
    if (chartCanvas.value && props.absensiChart) {
        // Load Chart.js from CDN
        const chartScript = document.createElement("script");
        chartScript.src =
            "https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js";

        // Load datalabels plugin
        const datalabelsScript = document.createElement("script");
        datalabelsScript.src =
            "https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0/dist/chartjs-plugin-datalabels.min.js";

        chartScript.onload = () => {
            document.head.appendChild(datalabelsScript);

            datalabelsScript.onload = () => {
                // Register the plugin
                Chart.register(ChartDataLabels);

                const ctx = chartCanvas.value.getContext("2d");
                chartInstance = new Chart(ctx, {
                    type: "pie",
                    data: {
                        labels: props.absensiChart.labels,
                        datasets: [
                            {
                                data: props.absensiChart.data,
                                backgroundColor: props.absensiChart.colors,
                                borderWidth: 2,
                                borderColor: "#fff",
                            },
                        ],
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: "bottom",
                                labels: {
                                    padding: 20,
                                    usePointStyle: true,
                                    generateLabels: function (chart) {
                                        const data = chart.data;
                                        return data.labels.map((label, i) => ({
                                            text: `${label}: ${data.datasets[0].data[i]}`,
                                            fillStyle:
                                                data.datasets[0]
                                                    .backgroundColor[i],
                                            strokeStyle:
                                                data.datasets[0].borderColor,
                                            lineWidth:
                                                data.datasets[0].borderWidth,
                                            hidden: false,
                                            index: i,
                                            pointStyle: "circle",
                                        }));
                                    },
                                },
                            },
                            title: {
                                display: true,
                                text: "Absensi Hari Ini",
                                font: {
                                    size: 16,
                                    weight: "bold",
                                },
                            },
                            datalabels: {
                                color: "#fff",
                                font: {
                                    weight: "bold",
                                    size: 14,
                                },
                                formatter: (value, context) => {
                                    if (value === 0) return "";
                                    return value;
                                },
                                anchor: "center",
                                align: "center",
                                textShadowColor: "rgba(0, 0, 0, 0.5)",
                                textShadowBlur: 3,
                            },
                        },
                    },
                });
            };
        };
        document.head.appendChild(chartScript);
    }
});

const title = [
    {
        title: "Dashboard",
        disabled: false,
        href: route("pendamping.dashboard"),
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

        <div class="space-y-6!">
            <!-- SUMMARY CARDS -->
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
                <!-- Total Mitra -->
                <v-card class="pa-4 border-l-4 border-blue-500" elevation="2">
                    <div class="d-flex align-center gap-3">
                        <v-avatar color="blue-lighten-4" size="48">
                            <v-icon color="blue" size="24"
                                >mdi-office-building</v-icon
                            >
                        </v-avatar>
                        <div>
                            <div class="text-caption text-grey">
                                Total Mitra
                            </div>
                            <div class="text-h5 font-weight-bold text-blue-600">
                                {{ props.summary?.total_mitra || 0 }}
                            </div>
                        </div>
                    </div>
                </v-card>

                <!-- Total Siswa -->
                <v-card class="pa-4 border-l-4 border-green-500" elevation="2">
                    <div class="d-flex align-center gap-3">
                        <v-avatar color="green-lighten-4" size="48">
                            <v-icon color="green" size="24"
                                >mdi-account-group</v-icon
                            >
                        </v-avatar>
                        <div>
                            <div class="text-caption text-grey">
                                Total Siswa
                            </div>
                            <div
                                class="text-h5 font-weight-bold text-green-600"
                            >
                                {{ props.summary?.total_siswa || 0 }}
                            </div>
                        </div>
                    </div>
                </v-card>

                <!-- Total Supervisor -->
                <v-card class="pa-4 border-l-4 border-purple-500" elevation="2">
                    <div class="d-flex align-center gap-3">
                        <v-avatar color="purple-lighten-4" size="48">
                            <v-icon color="purple" size="24"
                                >mdi-account-tie</v-icon
                            >
                        </v-avatar>
                        <div>
                            <div class="text-caption text-grey">Supervisor</div>
                            <div
                                class="text-h5 font-weight-bold text-purple-600"
                            >
                                {{ props.summary?.total_supervisor || 0 }}
                            </div>
                        </div>
                    </div>
                </v-card>

                <!-- Siswa Belum PKL -->
                <v-card class="pa-4 border-l-4 border-orange-500" elevation="2">
                    <div class="d-flex align-center gap-3">
                        <v-avatar color="orange-lighten-4" size="48">
                            <v-icon color="orange" size="24"
                                >mdi-account-question</v-icon
                            >
                        </v-avatar>
                        <div>
                            <div class="text-caption text-grey">Belum PKL</div>
                            <div
                                class="text-h5 font-weight-bold text-orange-600"
                            >
                                {{ props.summary?.siswa_belum_pkl || 0 }}
                            </div>
                        </div>
                    </div>
                </v-card>

                <!-- Pengajuan Pending -->
                <v-card class="pa-4 border-l-4 border-yellow-500" elevation="2">
                    <div class="d-flex align-center gap-3">
                        <v-avatar color="yellow-lighten-4" size="48">
                            <v-icon color="yellow-darken-2" size="24"
                                >mdi-clock-outline</v-icon
                            >
                        </v-avatar>
                        <div>
                            <div class="text-caption text-grey">Pending</div>
                            <div
                                class="text-h5 font-weight-bold text-yellow-darken-2"
                            >
                                {{ props.summary?.pengajuan_pending || 0 }}
                            </div>
                        </div>
                    </div>
                </v-card>

                <!-- Siswa Diterima -->
                <v-card class="pa-4 border-l-4 border-cyan-500" elevation="2">
                    <div class="d-flex align-center gap-3">
                        <v-avatar color="cyan-lighten-4" size="48">
                            <v-icon color="cyan" size="24"
                                >mdi-check-circle</v-icon
                            >
                        </v-avatar>
                        <div>
                            <div class="text-caption text-grey">Diterima</div>
                            <div class="text-h5 font-weight-bold text-cyan-600">
                                {{ props.summary?.siswa_diterima || 0 }}
                            </div>
                        </div>
                    </div>
                </v-card>
            </div>

            <!-- CHART & TABLE ROW -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- PIE CHART -->
                <v-card class="pa-4" elevation="2" rounded="lg">
                    <v-card-title class="text-lg font-bold">
                        <v-icon class="mr-2">mdi-chart-pie</v-icon>
                        Absensi Hari Ini
                    </v-card-title>
                    <v-card-text>
                        <div style="height: 300px">
                            <canvas ref="chartCanvas"></canvas>
                        </div>
                    </v-card-text>
                </v-card>

                <!-- IZIN TERBARU TABLE -->
                <v-card class="pa-4" elevation="2" rounded="lg">
                    <v-card-title class="text-lg font-bold">
                        <v-icon class="mr-2">mdi-file-document</v-icon>
                        Izin Terbaru
                    </v-card-title>
                    <v-card-text>
                        <v-data-table
                            :headers="izinHeaders"
                            :items="props.izinTerbaru || []"
                            class="elevation-0 border"
                            density="compact"
                            hide-default-footer
                        >
                            <template v-slot:item.siswa_info="{ item }">
                                <div class="py-1">
                                    <div class="font-weight-medium">
                                        {{ item.siswa?.user?.name || "N/A" }}
                                    </div>
                                    <div class="text-caption text-grey">
                                        {{
                                            item.siswa?.jurusan?.nama_jurusan ||
                                            "-"
                                        }}
                                    </div>
                                </div>
                            </template>

                            <template v-slot:item.tanggal="{ item }">
                                <div class="text-caption">
                                    {{ formatDate(item.tgl_mulai) }} -
                                    {{ formatDate(item.tgl_selesai) }}
                                </div>
                            </template>

                            <template v-slot:item.durasi_hari="{ item }">
                                <v-chip
                                    color="info"
                                    size="x-small"
                                    variant="flat"
                                >
                                    {{ item.durasi_hari }} hari
                                </v-chip>
                            </template>

                            <template v-slot:item.keterangan="{ item }">
                                <div
                                    style="max-width: 150px"
                                    class="text-truncate"
                                >
                                    {{ item.keterangan || "-" }}
                                </div>
                            </template>

                            <template v-slot:item.status="{ item }">
                                <v-chip
                                    :color="getStatusColor(item.status)"
                                    size="x-small"
                                >
                                    {{ getStatusLabel(item.status) }}
                                </v-chip>
                            </template>

                            <template v-slot:item.approver="{ item }">
                                <span class="text-caption">{{
                                    item.approver?.name || "-"
                                }}</span>
                            </template>

                            <template v-slot:no-data>
                                <div class="pa-4 text-center text-grey">
                                    Tidak ada data izin terbaru
                                </div>
                            </template>
                        </v-data-table>
                    </v-card-text>
                </v-card>
            </div>
        </div>
    </PendampingDashboardLayout>
</template>
