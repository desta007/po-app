<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @page { margin: 15mm 18mm; size: A4; }
        html, body {
            font-family: 'DejaVu Sans', sans-serif;
            font-size: 11px;
            color: #1a1a1a;
            line-height: 1.5;
            margin: 0;
            padding: 0;
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
        .logo { max-height: 45px; max-width: 140px; margin-bottom: 5px; }
        .org-name { font-size: 13px; font-weight: bold; color: #1a1a1a; }
        .org-phone { font-size: 11px; color: #555; }

        /* Invoice title */
        .invoice-title {
            font-size: 22px;
            font-weight: bold;
            color: #1a5276;
            margin: 0 0 3px 0;
        }
        .po-number {
            font-size: 11px;
            color: #555;
            margin-bottom: 15px;
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

        /* Footer / Thank you */
        .thank-you {
            margin-top: 20px;
            text-align: center;
            font-size: 10px;
            color: #999;
        }

        /* Payment info */
        .payment-section {
            margin-top: 20px;
            padding: 12px 15px;
            background-color: #eef3f7;
            border-radius: 4px;
        }
        .payment-section strong {
            display: block;
            font-size: 11px;
            color: #1a1a1a;
            margin-bottom: 3px;
        }
        .payment-section .payment-detail {
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
            @if($organization->logo_url)
            <img src="{{ storage_path('app/public/' . str_replace('/storage/', '', $organization->logo_url)) }}" class="logo" alt="Logo"><br>
            @endif
            <div class="invoice-title">INVOICE</div>
            <div class="po-number">{{ $po->po_number }}</div>
        </div>
        <div class="header-right">
            <div class="org-name">{{ $organization->name }}</div>
            @if($organization->phone)
            <div class="org-phone">{{ $organization->phone }}</div>
            @endif
        </div>
    </div>

    {{-- Customer & Order Info --}}
    <div class="info-section">
        <div class="info-left">
            <div class="info-label">Kepada</div>
            <div class="info-value" style="font-weight:bold;">{{ $customer->name }}</div>
            @if($customer->phone)
            <div class="info-value">{{ $customer->phone }}</div>
            @endif
        </div>
        <div class="info-right">
            <div class="info-label">Tanggal Order</div>
            <div class="info-value">{{ $po->order_date->format('d M Y') }}</div>
            <div class="info-label" style="margin-top:5px;">Tanggal Kirim</div>
            <div class="info-value">{{ $po->delivery_date->format('d M Y') }}</div>
            @php
                $statusLabels = [
                    'draft' => 'Draft',
                    'confirmed' => 'Dikonfirmasi',
                    'in_progress' => 'Dalam Proses',
                    'completed' => 'Selesai',
                    'cancelled' => 'Dibatalkan',
                ];
            @endphp
            <div class="info-label" style="margin-top:5px;">Status</div>
            <div class="info-value">{{ $statusLabels[$po->status] ?? ucfirst($po->status) }}</div>
        </div>
    </div>

    {{-- Items Table --}}
    <table class="items">
        <thead>
            <tr>
                <th style="width:30px;">No</th>
                <th>Produk</th>
                <th class="text-center" style="width:55px;">Qty</th>
                <th class="text-right" style="width:100px;">Harga Satuan</th>
                <th class="text-right" style="width:100px;">Subtotal</th>
            </tr>
        </thead>
        <tbody>
            @foreach($items as $index => $item)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>
                    {{ $item->product_name }}
                    @if($item->notes)
                    <br><span style="font-size:10px;color:#777;">{{ $item->notes }}</span>
                    @endif
                </td>
                <td class="text-center">{{ number_format($item->quantity, 0) }}</td>
                <td class="text-right">Rp {{ number_format($item->unit_price, 0, ',', '.') }}</td>
                <td class="text-right">Rp {{ number_format($item->subtotal, 0, ',', '.') }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    {{-- Summary --}}
    <div class="summary-section">
        <div class="summary-spacer"></div>
        <div class="summary-content">
            <table>
                <tr>
                    <td class="summary-label">Subtotal</td>
                    <td class="summary-value">Rp {{ number_format($po->subtotal, 0, ',', '.') }}</td>
                </tr>
                @if($po->discount > 0)
                <tr>
                    <td class="summary-label">Diskon</td>
                    <td class="summary-value">-Rp {{ number_format($po->discount, 0, ',', '.') }}</td>
                </tr>
                @endif
                @if($po->tax > 0)
                <tr>
                    <td class="summary-label">Pajak</td>
                    <td class="summary-value">Rp {{ number_format($po->tax, 0, ',', '.') }}</td>
                </tr>
                @endif
                @if($po->shipping_cost > 0)
                <tr>
                    <td class="summary-label">Ongkos Kirim</td>
                    <td class="summary-value">Rp {{ number_format($po->shipping_cost, 0, ',', '.') }}</td>
                </tr>
                @endif
                <tr class="total-row">
                    <td class="summary-label" style="font-weight:bold;">Total</td>
                    <td class="summary-value" style="font-weight:bold;">Rp {{ number_format($po->total, 0, ',', '.') }}</td>
                </tr>
            </table>
        </div>
    </div>

    {{-- Notes --}}
    @if($po->notes)
    <div class="notes-section">
        <div class="notes-label">Catatan:</div>
        <div class="notes-text">{{ $po->notes }}</div>
    </div>
    @endif

    {{-- Thank you --}}
    <div class="thank-you">
        Terima kasih atas pesanan Anda — {{ $organization->name }}
    </div>

    {{-- Payment info --}}
    @php
        $bankInfo = $organization->settings['bank_info'] ?? null;
    @endphp
    @if($bankInfo && !empty($bankInfo['bank_name']))
    <div class="payment-section">
        <strong>Pembayaran dapat di transfer ke rekening :</strong>
        <div class="payment-detail">
            {{ $bankInfo['bank_name'] }}<br>
            {{ $bankInfo['account_name'] ?? '' }}<br>
            {{ $bankInfo['account_number'] ?? '' }}
        </div>
    </div>
    @endif
</body>
</html>
