<script setup>
import { usePage, Link, router } from "@inertiajs/vue3";
import Swal from "sweetalert2";
import { computed, onMounted, ref, watch } from "vue";

const showSidebar = ref(window.innerWidth >= 768);
const showSiswaDropdown = ref(false);

const closeSidebar = () => {
    showSidebar.value = false;
};

const logout = () => {
    Swal.fire({
        title: "Yakin ingin logout?",
        icon: "warning",
        showCancelButton: true,
        cancelButtonText: "Batal",
    }).then((result) => {
        if (result.isConfirmed) {
            router.post(route("logout"));
        }
    });
};

const page = usePage();
watch(
    () => page.props.flash,
    (flash) => {
        if (flash?.success) {
            Swal.fire("Berhasil!", flash.success, "success");
        }
        if (flash?.error) {
            Swal.fire("Gagal!", flash.error, "error");
        }
    },
    { immediate: true }
);

const SIDEBAR_WIDTH = "16rem";
const screenWidth = ref(0);

onMounted(() => {
    screenWidth.value = window.innerWidth;
});
const dynamicStyles = computed(() => ({
    // Tentukan lebar sidebar sebagai variabel CSS
    "--sidebar-width": showSidebar.value ? SIDEBAR_WIDTH : "0px",
    transition: "margin-left 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.86)",
}));

const handleResize = () => {
    if (window.innerWidth >= 768) {
        showSidebar.value = true;
    } else {
        showSidebar.value = false;
    }
};

const currentRouteName = computed(() => page.props.currentRoute.name);

// pengkondisian route
const isLinkActive = (routeName) => {
    return currentRouteName.value === routeName;
};
</script>
<template>
    <body class="font-poppins">
        <transition name="fade">
            <div
                v-show="showSidebar"
                class="fixed z-48 inset-0 bg-black/30 md:hidden"
                @click="closeSidebar"
            ></div>
        </transition>
        <transition name="fade-slide">
            <aside v-show="showSidebar" class="h-screen z-50 fixed w-67">
                <!-- logo -->
                <div class="p-3! h-20 bg-white shadow-md">
                    <img
                        src="/assets/logo-mutu.png"
                        class="bg-cover w-52"
                        alt="logo-mutu"
                    />
                </div>

                <div
                    class="bg-linear-to-b p-5! h-full flex flex-col justify-between! from-[#1E3A8A] to-[#264AB3]"
                >
                    <div class="flex flex-col gap-4">
                        <slot name="sidebar-menu" />
                    </div>
                    <!-- logout -->
                    <div class="border-t-2 border-white">
                        <div
                            @click="logout"
                            class="text-white cursor-pointer mt-2 mb-20! hover:bg-[#4A60AA]! font-medium! transition duration-150 flex items-center gap-3 px-3 py-2 rounded-md"
                        >
                            <Icon icon="mdi:logout" width="24" />
                            <div>Logout</div>
                        </div>
                    </div>
                </div>
            </aside>
        </transition>
        <!-- header desktop -->
        <transition name="fade-slide">
            <header
                class="h-20 z-5! bg-white hidden md:inline shadow-sm fixed w-screen px-6!"
            >
                <div
                    :style="{
                        'margin-left': showSidebar ? SIDEBAR_WIDTH : '0px',
                    }"
                    class="flex justify-between items-center h-full transition-[margin-left] duration-200"
                >
                    <div class="flex items-center gap-4">
                        <v-btn
                            icon
                            variant="text"
                            @click="showSidebar = !showSidebar"
                        >
                            <Icon icon="ci:hamburger-lg" width="28" />
                        </v-btn>
                        <div
                            class="text-xl flex items-center gap-1 font-medium"
                        >
                            <slot name="headerTitle" />
                        </div>
                    </div>
                    <div class="mr-8">not</div>
                </div>
            </header>
        </transition>
        <!-- header mobile -->
        <div class="h-20 z-49 md:hidden bg-white shadow-sm fixed w-screen px-6">
            <div class="flex justify-between items-center h-full">
                <div class="flex items-center">
                    <v-btn
                        icon
                        variant="text"
                        @click="showSidebar = !showSidebar"
                    >
                        <Icon icon="ci:hamburger-lg" width="28" />
                    </v-btn>
                    <h2 class="font-bold text-xl">
                        <slot name="headerTitle" />
                    </h2>
                </div>
                <div>not</div>
            </div>
        </div>

        <!-- slot -->
        <div
            :style="{
                marginLeft:
                    showSidebar && screenWidth >= 768 ? SIDEBAR_WIDTH : '0px',
            }"
            class="pt-20! transition-[margin-left] duration-200"
        >
            <div class="p-2! md:p-8!">
                <slot name="content" />
            </div>
        </div>
    </body>
</template>

<style scoped>
.fade-slide-enter-active,
.fade-slide-leave-active {
    transition: all 0.2s cubic-bezier(0.25, 0.46, 0.45, 0.86);
}
/* Status awal saat muncul (enter-from) & status akhir saat menghilang (leave-to) */
.fade-slide-enter-from,
.fade-slide-leave-to {
    transform: translateX(-100%);
}

/* Status normal (di layar) */
.fade-slide-enter-to,
.fade-slide-leave-from {
    transform: translateX(0);
}
</style>
