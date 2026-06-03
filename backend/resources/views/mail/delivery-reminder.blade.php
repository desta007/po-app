<!DOCTYPE html>
<html><head><meta charset="utf-8"></head>
<body style="font-family: Arial, sans-serif; background: #f4f4f4; padding: 20px;">
<div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden;">
    <div style="background: #FFC000; color: #333; padding: 20px 30px;">
        <h1 style="margin: 0; font-size: 20px;">🔔 Pengingat Pengiriman {{ $dayLabel }}</h1>
    </div>
    <div style="padding: 30px;">
        <p>Pesanan <strong>{{ $po->po_number }}</strong> untuk <strong>{{ $po->customer->name }}</strong> dijadwalkan dikirim <strong>{{ $dayLabel }}</strong>.</p>
        <table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
            <tr><td style="padding: 8px 0; color: #888;">Tanggal Kirim</td><td style="padding: 8px 0; text-align: right;"><strong>{{ $po->delivery_date->format('d M Y') }}</strong></td></tr>
            <tr><td style="padding: 8px 0; color: #888;">Total</td><td style="padding: 8px 0; text-align: right;"><strong>Rp {{ number_format($po->total, 0, ',', '.') }}</strong></td></tr>
            <tr><td style="padding: 8px 0; color: #888;">Status</td><td style="padding: 8px 0; text-align: right;">{{ $po->status->label() }}</td></tr>
        </table>
    </div>
</div>
</body></html>
