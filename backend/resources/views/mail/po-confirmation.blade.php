<!DOCTYPE html>
<html><head><meta charset="utf-8"></head>
<body style="font-family: Arial, sans-serif; background: #f4f4f4; padding: 20px;">
<div style="max-width: 600px; margin: 0 auto; background: white; border-radius: 8px; overflow: hidden;">
    <div style="background: #1F4E79; color: white; padding: 20px 30px;">
        <h1 style="margin: 0; font-size: 20px;">Pesanan Dikonfirmasi ✓</h1>
    </div>
    <div style="padding: 30px;">
        <p>Halo <strong>{{ $po->customer->name }}</strong>,</p>
        <p>Pesanan Anda dengan nomor <strong>{{ $po->po_number }}</strong> telah dikonfirmasi.</p>
        <table style="width: 100%; margin: 20px 0; border-collapse: collapse;">
            <tr><td style="padding: 8px 0; color: #888;">Tanggal Kirim</td><td style="padding: 8px 0; text-align: right;"><strong>{{ $po->delivery_date->format('d M Y') }}</strong></td></tr>
            <tr><td style="padding: 8px 0; color: #888;">Total</td><td style="padding: 8px 0; text-align: right;"><strong>Rp {{ number_format($po->total, 0, ',', '.') }}</strong></td></tr>
        </table>
        <p style="color: #888; font-size: 12px;">Email ini dikirim otomatis oleh PO Scheduler. {{ $po->organization->name }}</p>
    </div>
</div>
</body></html>
