<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @page { margin: 20mm 35mm; size: A4; }
        html, body {
            font-family: 'DejaVu Sans', sans-serif;
            font-size: 11px;
            color: #1a1a1a;
            line-height: 1.5;
            margin: 0;
            padding: 0 3mm;
        }

        /* Header */
        .header {
            display: table;
            width: 100%;
            margin-bottom: 5px;
        }
        .header-left {
            display: table-cell;
            vertical-align: top;
            width: 50%;
        }
        .header-right {
            display: table-cell;
            vertical-align: top;
            width: 50%;
            text-align: right;
        }
        .invoice-title {
            font-size: 22px;
            font-weight: bold;
            color: #1a5276;
            margin: 0 0 3px 0;
        }
        .invoice-number {
            font-size: 11px;
            color: #555;
            margin-bottom: 15px;
        }
        .app-name {
            font-size: 13px;
            font-weight: bold;
            color: #1a1a1a;
        }
        .app-detail {
            font-size: 11px;
            color: #555;
        }

        /* Info section */
        .info-section {
            display: table;
            width: 100%;
            margin-bottom: 18px;
            border-top: 1px solid #ddd;
            padding-top: 12px;
        }
        .info-left {
            display: table-cell;
            vertical-align: top;
            width: 55%;
        }
        .info-right {
            display: table-cell;
            vertical-align: top;
            width: 45%;
            text-align: right;
        }
        .info-label {
            font-size: 10px;
            font-weight: bold;
            color: #1a5276;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .info-value {
            font-size: 11px;
            color: #333;
            margin-bottom: 3px;
        }

        /* Items table */
        table.items {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 10px;
        }
        table.items thead tr {
            background-color: #1a5276;
        }
        table.items th {
            color: #fff;
            font-weight: bold;
            font-size: 10px;
            text-transform: uppercase;
            padding: 8px 10px;
            text-align: left;
            letter-spacing: 0.3px;
        }
        table.items th.text-center { text-align: center; }
        table.items th.text-right { text-align: right; }
        table.items td {
            padding: 8px 10px;
            vertical-align: top;
            font-size: 11px;
            border-bottom: 1px solid #eee;
        }
        table.items td.text-center { text-align: center; }
        table.items td.text-right { text-align: right; }
        table.items tbody tr:last-child td {
            border-bottom: 2px solid #1a5276;
        }

        /* Summary */
        .summary-section {
            display: table;
            width: 100%;
            margin-top: 5px;
        }
        .summary-spacer {
            display: table-cell;
            width: 55%;
        }
        .summary-content {
            display: table-cell;
            width: 45%;
        }
        .summary-content table {
            width: 100%;
        }
        .summary-content td {
            padding: 3px 10px;
            font-size: 11px;
        }
        .summary-content .summary-label { text-align: right; }
        .summary-content .summary-value { text-align: right; font-weight: normal; }
        .summary-content .total-row td {
            font-weight: bold;
            font-size: 14px;
            color: #1a5276;
            padding-top: 6px;
            border-top: 1px solid #ddd;
        }

        /* Status badge */
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .status-paid {
            background-color: #d1fae5;
            color: #065f46;
        }

        /* Notes */
        .notes-section {
            margin-top: 20px;
            padding: 10px 12px;
            background-color: #f7f9fa;
            border-left: 3px solid #1a5276;
        }
        .notes-label {
            font-size: 10px;
            font-weight: bold;
            color: #555;
            margin-bottom: 3px;
        }
        .notes-text {
            font-size: 11px;
            color: #333;
        }

        /* Footer */
        .thank-you {
            margin-top: 30px;
            text-align: center;
            font-size: 10px;
            color: #999;
        }

        .approval-section {
            margin-top: 20px;
            padding: 12px 15px;
            background-color: #eef3f7;
            border-radius: 4px;
        }
        .approval-section strong {
            display: block;
            font-size: 11px;
            color: #1a1a1a;
            margin-bottom: 3px;
        }
        .approval-section .approval-detail {
            font-size: 11px;
            color: #333;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    {{-- Header --}}
    <div class="header">
        <div class="header-left">
            <div class="invoice-title">INVOICE SUBSCRIPTION</div>
            <div class="invoice-number">{{ $invoiceNumber }}</div>
        </div>
        <div class="header-right">
            <div class="app-name">PO App</div>
            <div class="app-detail">Sistem Manajemen Purchase Order</div>
        </div>
    </div>

    {{-- Info Section --}}
    <div class="info-section">
        <div class="info-left">
            <div class="info-label">Ditagihkan Kepada</div>
            <div class="info-value" style="font-weight:bold;">{{ $subscription->organization->name }}</div>
            <div class="info-value">{{ $subscription->requester->full_name }}</div>
            <div class="info-value">{{ $subscription->requester->email }}</div>
            @if($subscription->requester->phone)
            <div class="info-value">{{ $subscription->requester->phone }}</div>
            @endif
        </div>
        <div class="info-right">
            <div class="info-label">Tanggal Invoice</div>
            <div class="info-value">{{ $subscription->responded_at->format('d M Y') }}</div>
            <div class="info-label" style="margin-top:5px;">Periode Langganan</div>
            <div class="info-value">{{ $subscription->starts_at->format('d M Y') }} - {{ $subscription->expires_at->format('d M Y') }}</div>
            <div class="info-label" style="margin-top:5px;">Status Pembayaran</div>
            <div class="info-value">
                <span class="status-badge status-paid">LUNAS</span>
            </div>
        </div>
    </div>

    {{-- Items Table --}}
    <table class="items">
        <thead>
            <tr>
                <th style="width:30px;">No</th>
                <th>Deskripsi</th>
                <th class="text-center" style="width:55px;">Qty</th>
                <th class="text-right" style="width:100px;">Harga</th>
                <th class="text-right" style="width:100px;">Subtotal</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>1</td>
                <td>
                    Langganan {{ $subscription->plan->label() }} — 30 Hari
                    <br><span style="font-size:10px;color:#777;">Periode: {{ $subscription->starts_at->format('d M Y') }} s/d {{ $subscription->expires_at->format('d M Y') }}</span>
                </td>
                <td class="text-center">1</td>
                <td class="text-right">Rp {{ number_format($subscription->amount, 0, ',', '.') }}</td>
                <td class="text-right">Rp {{ number_format($subscription->amount, 0, ',', '.') }}</td>
            </tr>
        </tbody>
    </table>

    {{-- Summary --}}
    <div class="summary-section">
        <div class="summary-spacer"></div>
        <div class="summary-content">
            <table>
                <tr>
                    <td class="summary-label">Subtotal</td>
                    <td class="summary-value">Rp {{ number_format($subscription->amount, 0, ',', '.') }}</td>
                </tr>
                <tr class="total-row">
                    <td class="summary-label" style="font-weight:bold;">Total</td>
                    <td class="summary-value" style="font-weight:bold;">Rp {{ number_format($subscription->amount, 0, ',', '.') }}</td>
                </tr>
            </table>
        </div>
    </div>

    {{-- Payment Note --}}
    @if($subscription->payment_proof_note)
    <div class="notes-section">
        <div class="notes-label">Catatan Pembayaran:</div>
        <div class="notes-text">{{ $subscription->payment_proof_note }}</div>
    </div>
    @endif

    {{-- Approval Info --}}
    <div class="approval-section">
        <strong>Informasi Persetujuan:</strong>
        <div class="approval-detail">
            Disetujui oleh: {{ $subscription->approver->full_name ?? '-' }}<br>
            Tanggal persetujuan: {{ $subscription->responded_at->format('d M Y, H:i') }}
        </div>
    </div>

    {{-- Footer --}}
    <div class="thank-you">
        Terima kasih telah berlangganan Premium — PO App
    </div>
</body>
</html>
