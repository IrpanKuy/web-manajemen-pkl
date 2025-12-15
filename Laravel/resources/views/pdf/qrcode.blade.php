<!DOCTYPE html>
<html>

<head>
    <title>QR Code Mitra Industri</title>
    <style>
        body {
            font-family: sans-serif;
            text-align: center;
            padding: 50px;
        }

        .container {
            border: 2px solid #333;
            padding: 30px;
            display: inline-block;
            border-radius: 10px;
        }

        .qr-code {
            margin: 20px 0;
        }

        .instansi-name {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .footer {
            margin-top: 20px;
            font-size: 12px;
            color: #666;
        }
    </style>
</head>

<body>
    <div class="container">
        <div class="instansi-name">{{ $mitra->nama_instansi }}</div>
        <div class="qr-code">
            <img src="data:image/svg+xml;base64, {{ $qrCode }}" alt="QR Code">
        </div>
        <div>
            Scan QR Code ini untuk absensi
        </div>
        <div class="footer">
            {{ $mitra->bidang_usaha }}
        </div>
    </div>
</body>

</html>
