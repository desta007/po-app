<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @page { margin: 5mm; size: auto; }
        html, body { font-family: 'DejaVu Sans', sans-serif; font-size: 12px; color: #000; line-height: 1.4; margin: 0; padding: 0 3mm; height: auto; overflow: hidden; }
        * { page-break-inside: avoid; }
        table { page-break-inside: auto; }
        tr { page-break-inside: avoid; }
        .text-center { text-align: center; }
        .text-right { text-align: right; }
        .text-left { text-align: left; }
        .font-bold { font-weight: bold; }
        .border-bottom { border-bottom: 1px dashed #000; padding-bottom: 5px; margin-bottom: 5px; }
        .border-top { border-top: 1px dashed #000; padding-top: 5px; margin-top: 5px; }
        
        .header { text-align: center; margin-bottom: 10px; border-bottom: 1px dashed #000; padding-bottom: 10px; }
        .header h1 { margin: 0; font-size: 18px; font-weight: bold; }
        .header p { margin: 2px 0 0; }
        .logo { max-height: 40px; max-width: 120px; margin-bottom: 5px; }
        
        .info { margin-bottom: 10px; border-bottom: 1px dashed #000; padding-bottom: 10px; }
        .info table { width: 100%; font-size: 12px; }
        .info td { vertical-align: top; padding: 1px 0; }
        .info .label { width: 35%; font-weight: bold; }
        
        table.items { width: 100%; border-collapse: collapse; margin-bottom: 10px; }
        table.items th { font-weight: bold; text-align: left; padding: 2px 0; border-bottom: 1px dashed #000; }
        table.items td { padding: 4px 0; vertical-align: top; }
        table.items .item-name { font-weight: bold; display: block; margin-bottom: 2px; }
        table.items .item-meta { color: #555; font-size: 11px; }
        
        .summary { width: 100%; margin-top: 10px; border-top: 1px dashed #000; padding-top: 5px; }
        .summary table { width: 100%; font-size: 12px; }
        .summary td { padding: 2px 0; }
        .summary .total { font-weight: bold; font-size: 14px; }
        
        .notes, .payment-info { margin-top: 10px; padding: 5px 0; border-top: 1px dashed #000; text-align: center; }
        .footer { margin-top: 8px; text-align: center; font-size: 11px; padding-top: 5px; border-top: 1px dashed #000; }
    </style>
</head>
<body>
    <div class="header">
        @if($organization->logo_url)
        <img src="{{ storage_path('app/public/' . str_replace('/storage/', '', $organization->logo_url)) }}" class="logo" alt="Logo"><br>
        @endif
        <h1>{{ $organization->name }}</h1>
        <p>{{ $organization->address }}</p>
        <p>{{ $organization->phone }}</p>
    </div>

    <div class="info">
        <div class="text-center font-bold" style="margin-bottom:5px; font-size: 14px;">INVOICE</div>
        <div class="text-center" style="margin-bottom:10px;">{{ $po->po_number }}</div>
        
        <table>
            <tr><td class="label">Tgl Order</td><td>: {{ $po->order_date->format('d M Y') }}</td></tr>
            <tr><td class="label">Tgl Kirim</td><td>: {{ $po->delivery_date->format('d M Y') }}</td></tr>
            <tr><td class="label">Kepada</td><td>: {{ $customer->name }}</td></tr>
            @if($customer->phone)<tr><td class="label">No HP</td><td>: {{ $customer->phone }}</td></tr>@endif
            @if($po->payment_method)<tr><td class="label">Pembayaran</td><td>: {{ $po->payment_method }}</td></tr>@endif
        </table>
    </div>

    <table class="items">
        <thead>
            <tr>
                <th>Item</th>
                <th class="text-right">Total</th>
            </tr>
        </thead>
        <tbody>
            @foreach($items as $item)
            <tr>
                <td colspan="2" style="padding-bottom:0;">
                    <span class="item-name">{{ $item->product_name }}</span>
                    @if($item->notes)<span class="item-meta">{{ $item->notes }}</span><br>@endif
                </td>
            </tr>
            <tr>
                <td style="padding-top:0;">{{ number_format($item->quantity, 0) }} x {{ number_format($item->unit_price, 0, ',', '.') }}</td>
                <td class="text-right" style="padding-top:0;">{{ number_format($item->subtotal, 0, ',', '.') }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="summary">
        <table>
            <tr><td>Subtotal</td><td class="text-right">{{ number_format($po->subtotal, 0, ',', '.') }}</td></tr>
            @if($po->discount > 0)<tr><td>Diskon</td><td class="text-right">-{{ number_format($po->discount, 0, ',', '.') }}</td></tr>@endif
            @if($po->tax > 0)<tr><td>Pajak</td><td class="text-right">{{ number_format($po->tax, 0, ',', '.') }}</td></tr>@endif
            @if($po->shipping_cost > 0)<tr><td>Ongkos Kirim</td><td class="text-right">{{ number_format($po->shipping_cost, 0, ',', '.') }}</td></tr>@endif
            <tr class="border-top total"><td>TOTAL</td><td class="text-right">Rp {{ number_format($po->total, 0, ',', '.') }}</td></tr>
        </table>
    </div>

    @if($po->notes)
    <div class="notes">
        <strong>Catatan:</strong><br>{{ $po->notes }}
    </div>
    @endif

    @php
        $bankInfo = $organization->settings['bank_info'] ?? null;
    @endphp
    @if($bankInfo && !empty($bankInfo['bank_name']))
    <div class="payment-info">
        Pembayaran ke rekening:<br>
        <strong>{{ $bankInfo['bank_name'] }}</strong><br>
        {{ $bankInfo['account_number'] ?? '' }} a.n {{ $bankInfo['account_name'] ?? '' }}
    </div>
    @endif

    <div class="footer">
        Terima kasih atas pesanan Anda.
    </div>
</body>
</html>
