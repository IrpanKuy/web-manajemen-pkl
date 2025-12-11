<script setup>
import { useForm, usePage } from "@inertiajs/vue3";
import Swal from "sweetalert2";
import { watch } from "vue";

const form = useForm({
    email: "",
    password: "",
    remember: false,
});

const page = usePage();
watch(
    () => page.props.flash,
    (flash) => {
        if (flash?.success) {
            Swal.fire("Berhasil!", flash.success, "success");
        }
        if (flash?.error) {
            Swal.fire("Gagal Login!", flash.error, "error");
        }
    },
    { immediate: true }
);

const submit = () => {
    form.post("login", {
        onFinish: () => form.reset("password"),
    });
};
</script>

<template>
    <!-- WAJIB: Bungkus seluruh halaman dengan v-app agar komponen Vuetify bekerja -->
    <v-app>
        <div
            style="
                background-image: url('/assets/gedung.jpg');
                background-size: cover;
                background-position: center;
                background-repeat: no-repeat;
            "
            class="w-screen h-screen flex justify-center items-center bg-gray-50"
        >
            <div class="absolute inset-0 bg-black/25"></div>
            <!-- Kartu Login -->
            <!-- Saya ubah p-5 menjadi p-8 agar lebih lega -->
            <div
                class="w-full max-w-md p-8! z-10 border space-y-8! h-screen md:h-auto! border-indigo-100 md:rounded-xl bg-white shadow-lg"
            >
                <img src="/assets/logo-mutu.png" alt="logo-mutu" />

                <h2 class="text-3xl text-center font-bold text-indigo-900">
                    Login
                </h2>

                <form @submit.prevent="submit" class="flex flex-col gap-6">
                    <!-- Email -->
                    <!-- density="compact" membuat input tidak terlalu raksasa -->
                    <v-text-field
                        variant="outlined"
                        density="confort"
                        v-model="form.email"
                        label="Email"
                        placeholder="nama@email.com"
                        clearable
                    ></v-text-field>

                    <!-- Password -->
                    <v-text-field
                        v-model="form.password"
                        density="confort"
                        label="Password"
                        placeholder="********"
                        clearable
                        type="password"
                        hide-details="auto"
                    ></v-text-field>

                    <!-- Error Messages -->
                    <div
                        class="text-sm text-red-600 bg-red-50 p-2 rounded"
                        v-if="
                            form.errors && Object.keys(form.errors).length > 0
                        "
                    >
                        <ul class="list-disc pl-4">
                            <li
                                v-for="(message, index) in form.errors"
                                :key="index"
                            >
                                {{ message }}
                            </li>
                        </ul>
                    </div>

                    <!-- Remember Me -->
                    <div class="flex items-center">
                        <input
                            type="checkbox"
                            v-model="form.remember"
                            id="remember"
                            class="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                        />
                        <label
                            for="remember"
                            class="ml-2 block text-sm text-gray-900"
                        >
                            Remember Me
                        </label>
                    </div>

                    <!-- Tombol Login -->
                    <v-btn
                        type="submit"
                        :disabled="formProcessing"
                        color="indigo-darken-1"
                        block
                        size="large"
                        class="mt-2 text-none font-bold"
                        elevation="2"
                    >
                        Login
                    </v-btn>
                </form>
            </div>
        </div>
    </v-app>
</template>
