import "vuetify/styles";
import "./bootstrap";
import "../css/app.css";

import { createVuetify } from "vuetify";
import * as components from "vuetify/components";
import * as directives from "vuetify/directives";

import { Icon } from "@iconify/vue";
import { ZiggyVue } from "../../vendor/tightenco/ziggy";
import { createApp, h } from "vue";
import { createInertiaApp } from "@inertiajs/vue3";

const vuetify = createVuetify({
    components,
    directives,
    // atur style bawaan
    defaults: {
        VBtn: {
            color: "primary",
            variant: "flat",
            rounded: "lg",
            class: "text-none font-bold",
        },
        VTextField: {
            variant: "outlined",
            density: "compact",
            color: "primary",
        },
        VSelect: {
            variant: "outlined",
            density: "compact",
            color: "primary",
        },
        VNumberInput: {
            variant: "outlined",
            density: "compact",
            color: "primary",
        },
        VTextarea: {
            variant: "outlined",
            density: "compact",
            color: "primary",
        },
    },
    icons: {
        // default icon
        defaultSet: "iconify",

        // definisikan icon
        sets: {
            iconify: {
                component: (props) => h(Icon, { icon: props.icon, ...props }),
            },
        },
    },
});

createInertiaApp({
    resolve: (name) => {
        const pages = import.meta.glob("./Pages/**/*.vue", { eager: true });
        return pages[`./Pages/${name}.vue`];
    },
    setup({ el, App, props, plugin }) {
        // 2. Buat instance aplikasi Vue dan simpan ke variabel 'app'
        const app = createApp({ render: () => h(App, props) });

        // 3. Daftarkan plugins pada instance 'app'
        app.use(plugin); // Plugin Inertia (WAJIB)

        app.use(ZiggyVue, Ziggy);

        app.use(vuetify);

        app.component("Icon", Icon);
        // 5. Mounting
        app.mount(el);
    },

    defaults: {
        form: {
            recentlySuccessfulDuration: 5000,
        },
        prefetch: {
            cacheFor: "1m",
            hoverDelay: 150,
        },
        visitOptions: (_href, options) => {
            return {
                headers: {
                    ...options.headers,
                    "X-Custom-Header": "value",
                },
            };
        },
    },
});
