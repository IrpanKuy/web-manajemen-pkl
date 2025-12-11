<script setup>
import { Link } from "@inertiajs/vue3";
import { ref } from "vue";

const message = ref("Tombol PrimeVue bekerja!");

const showMessage = () => {
    alert(message.value);
};

defineProps({ user: Object });

// Catatan: TIDAK perlu "import Button from 'primevue/button';" di sini!
</script>

<template>
    <div>yey auth berhasil namamu {{ $page.props.auth.user.name }}</div>
    <div>yey auth berhasil emailmu {{ $page.props.auth.user.email }}</div>
    <Link :href="route('logout')" method="post" as="button">logout</Link>
</template>
