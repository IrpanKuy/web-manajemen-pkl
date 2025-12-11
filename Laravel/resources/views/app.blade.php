<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-t">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Laravel Vue</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    @routes
    @vite('resources/js/app.js')
    @inertiaHead
    <style>
        /* ===== GLOBAL OVERRIDE SWEETALERT2 BUTTONS ===== */

        .swal2-confirm {
            color: white !important;
        }


        /* Semua tombol */
        .swal2-popup .swal2-styled {
            border: none !important;
            box-shadow: none !important;
            font-weight: 600;
            padding: 10px 20px !important;
            border-radius: 8px !important;
        }

        /* Confirm Button */
        .swal2-popup .swal2-confirm {
            background-color: #1976d2 !important;
            /* biru */
            color: #fff !important;
        }

        /* Cancel Button */
        .swal2-popup .swal2-cancel {
            background-color: #e53935 !important;
            /* merah */
            color: #fff !important;
        }

        /* Deny Button (kalau kamu pakai) */
        .swal2-popup .swal2-deny {
            background-color: #fb8c00 !important;
            /* oranye */
            color: #fff !important;
        }

        /* Hover */
        .swal2-popup .swal2-styled:hover {
            filter: brightness(0.9) !important;
        }
    </style>
</head>

<body class="font-poppins antialiased">
    {{-- <div id="app"></div> --}}
    @inertia
</body>

</html>
