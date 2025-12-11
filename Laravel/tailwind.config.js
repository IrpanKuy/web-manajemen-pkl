// tailwind.config.js
export default {
    // Opsi ini membungkus semua class tailwind dengan selector ID #app
    // Contoh: .bg-red-500 menjadi #app .bg-red-500 (Specificity lebih tinggi)
    important: "#app",

    content: [
        "./resources/**/*.blade.php",
        "./resources/**/*.js",
        "./resources/**/*.vue",
    ],
    theme: {
        extend: {},
    },
    plugins: [],
};
