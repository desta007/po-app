@php
    // Font scale by label size. Small 80x50 labels need tighter type.
    $isSmall = $labelHeight < 80;
    $baseFs = $isSmall ? 7 : 10;
    $nameFs = $isSmall ? 10 : 15;
    $labelFs = $isSmall ? 6 : 8;
    $pad = $isSmall ? 2 : 4; // mm
@endphp
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @page {
            margin: 0;
            size: {{ $labelWidth }}mm {{ $labelHeight }}mm;
        }
        html, body {
            font-family: 'DejaVu Sans', sans-serif;
            margin: 0;
            padding: 0;
            color: #000;
        }
        /* IMPORTANT: DomPDF does NOT support box-sizing: border-box, so padding on
           .label would be ADDED to width/height (making it 108x157mm) — spilling
           past the page horizontally (clipped text) and vertically (blank page).
           So .label keeps the exact page dimensions with no padding, and the inner
           .label-content carries the padding instead (matches pdf/labels.blade.php).
           Page breaks are set per-label from the Blade loop (page-break-before on
           every label except the first) — never page-break-after, which leaves a
           trailing blank page in DomPDF. */
        .label {
            position: relative;
            display: block;
            width: {{ $labelWidth }}mm;
            height: {{ $labelHeight - 1 }}mm;
            overflow: hidden;
            margin: 0;
            padding: 0;
        }
        .label.break {
            page-break-before: always;
        }
        .label-content {
            padding: {{ $pad }}mm {{ $pad }}mm 0 {{ $pad }}mm;
        }
        .section-label {
            font-size: {{ $labelFs }}pt;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5pt;
            color: #333;
        }
        .sender {
            font-size: {{ $baseFs - 1 }}pt;
            line-height: 1.2;
            padding-bottom: {{ $isSmall ? '1mm' : '2mm' }};
            border-bottom: 1px solid #000;
            margin-bottom: {{ $isSmall ? '1.5mm' : '3mm' }};
        }
        .recipient-name {
            font-size: {{ $nameFs }}pt;
            font-weight: bold;
            line-height: 1.1;
            margin: {{ $isSmall ? '0.5mm' : '1mm' }} 0;
        }
        .recipient-phone {
            font-size: {{ $baseFs }}pt;
            line-height: 1.2;
        }
        .recipient-address {
            font-size: {{ $baseFs }}pt;
            line-height: 1.25;
            margin-top: {{ $isSmall ? '0.5mm' : '1.5mm' }};
            word-wrap: break-word;
        }
        /* PO reference pinned to the bottom of the label. left/right match the
           content padding so it aligns with the text above. */
        .po-ref {
            position: absolute;
            left: {{ $pad }}mm;
            right: {{ $pad }}mm;
            bottom: {{ $isSmall ? '1.5mm' : '3mm' }};
            font-size: {{ $labelFs }}pt;
            border-top: 1px solid #999;
            padding-top: {{ $isSmall ? '0.8mm' : '1.5mm' }};
        }
        .po-ref .num {
            font-weight: bold;
        }
    </style>
</head>
<body>
    @foreach($labels as $label)
        <div class="label{{ $loop->first ? '' : ' break' }}">
            <div class="label-content">
                @if($label['sender_name'] !== '-' || $label['sender_phone'])
                    <div class="sender">
                        <span class="section-label">Pengirim:</span>
                        <strong>{{ $label['sender_name'] }}</strong>@if($label['sender_phone']) &middot; {{ $label['sender_phone'] }}@endif
                        @if($label['sender_address'] && !$isSmall)<br>{{ $label['sender_address'] }}@endif
                    </div>
                @endif

                <div class="section-label">Penerima:</div>
                <div class="recipient-name">{{ $label['recipient_name'] }}</div>
                @if($label['recipient_phone'])
                    <div class="recipient-phone">{{ $label['recipient_phone'] }}</div>
                @endif
                <div class="recipient-address">{{ $label['recipient_address'] ?: '-' }}</div>
            </div>

            <div class="po-ref">
                <span class="num">{{ $label['po_number'] }}</span> &middot; Kirim: {{ $label['delivery_date'] }}
            </div>
        </div>
    @endforeach
</body>
</html>
