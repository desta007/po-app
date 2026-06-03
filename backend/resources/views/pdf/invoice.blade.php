<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: 'DejaVu Sans', sans-serif; font-size: 12px; color: #333; }
        .header { display: flex; justify-content: space-between; margin-bottom: 30px; border-bottom: 3px solid #1F4E79; padding-bottom: 15px; }
        .header h1 { color: #1F4E79; margin: 0; font-size: 24px; }
        .header .org-info { text-align: right; font-size: 11px; color: #666; }
        .info-grid { display: table; width: 100%; margin-bottom: 20px; }
        .info-col { display: table-cell; width: 50%; vertical-align: top; }
        .info-label { font-weight: bold; color: #1F4E79; font-size: 10px; text-transform: uppercase; }
        .info-value { margin-bottom: 5px; }
        table.items { width: 100%; border-collapse: collapse; margin: 20px 0; }
        table.items th { background: #1F4E79; color: white; padding: 8px 10px; text-align: left; font-size: 11px; }
        table.items td { padding: 8px 10px; border-bottom: 1px solid #e0e0e0; }
        table.items tr:nth-child(even) { background: #f8f9fa; }
        .text-right { text-align: right; }
        .summary { width: 300px; float: right; margin-top: 10px; }
        .summary table { width: 100%; }
        .summary td { padding: 5px 10px; }
        .summary .total { font-size: 16px; font-weight: bold; color: #1F4E79; border-top: 2px solid #1F4E79; }
        .footer { margin-top: 40px; text-align: center; color: #888; font-size: 10px; border-top: 1px solid #e0e0e0; padding-top: 10px; }
        .notes { background: #f8f9fa; padding: 10px; border-radius: 4px; margin-top: 20px; font-size: 11px; }
    </style>
</head>
<body>
    <div class="header">
        <div>
            <h1>INVOICE</h1>
            <p style="color: #666; margin: 5px 0 0;">{{ $po->po_number }}</p>
        </div>
        <div class="org-info">
            <strong>{{ $organization->name }}</strong><br>
            {{ $organization->address }}<br>
            {{ $organization->phone }}
        </div>
    </div>

    <div class="info-grid">
        <div class="info-col">
            <p class="info-label">Kepada</p>
            <p class="info-value"><strong>{{ $customer->name }}</strong></p>
            @if($customer->address)<p class="info-value">{{ $customer->address }}</p>@endif
            @if($customer->phone)<p class="info-value">{{ $customer->phone }}</p>@endif
            @if($customer->email)<p class="info-value">{{ $customer->email }}</p>@endif
        </div>
        <div class="info-col" style="text-align: right;">
            <p class="info-label">Tanggal Order</p>
            <p class="info-value">{{ $po->order_date->format('d M Y') }}</p>
            <p class="info-label">Tanggal Kirim</p>
            <p class="info-value">{{ $po->delivery_date->format('d M Y') }}</p>
            <p class="info-label">Status</p>
            <p class="info-value">{{ $po->status->label() }}</p>
        </div>
    </div>

    <table class="items">
        <thead>
            <tr>
                <th style="width: 30px;">No</th>
                <th>Produk</th>
                <th class="text-right" style="width: 60px;">Qty</th>
                <th class="text-right" style="width: 120px;">Harga Satuan</th>
                <th class="text-right" style="width: 120px;">Subtotal</th>
            </tr>
        </thead>
        <tbody>
            @foreach($items as $index => $item)
            <tr>
                <td>{{ $index + 1 }}</td>
                <td>{{ $item->product_name }}@if($item->notes) <br><small style="color:#888">{{ $item->notes }}</small>@endif</td>
                <td class="text-right">{{ number_format($item->quantity, 0) }}</td>
                <td class="text-right">Rp {{ number_format($item->unit_price, 0, ',', '.') }}</td>
                <td class="text-right">Rp {{ number_format($item->subtotal, 0, ',', '.') }}</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <div class="summary">
        <table>
            <tr><td>Subtotal</td><td class="text-right">Rp {{ number_format($po->subtotal, 0, ',', '.') }}</td></tr>
            @if($po->discount > 0)<tr><td>Diskon</td><td class="text-right">- Rp {{ number_format($po->discount, 0, ',', '.') }}</td></tr>@endif
            @if($po->tax > 0)<tr><td>Pajak</td><td class="text-right">Rp {{ number_format($po->tax, 0, ',', '.') }}</td></tr>@endif
            <tr class="total"><td><strong>Total</strong></td><td class="text-right"><strong>Rp {{ number_format($po->total, 0, ',', '.') }}</strong></td></tr>
        </table>
    </div>

    <div style="clear: both;"></div>

    @if($po->notes)
    <div class="notes">
        <strong>Catatan:</strong><br>{{ $po->notes }}
    </div>
    @endif

    <div class="footer">
        Terima kasih atas pesanan Anda &mdash; {{ $organization->name }}
    </div>
</body>
</html>
