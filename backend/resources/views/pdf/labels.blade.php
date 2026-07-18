@php
    $fs = $labelHeight >= 30 ? 9 : ($labelHeight >= 20 ? 6 : 5);
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
        /* Fixed height strictly smaller than the page (no padding here, to avoid
           DomPDF border-box quirks) so each label fits on exactly one page with
           no blank page spilling after it. */
        .label {
            position: relative;
            display: block;
            width: {{ $labelWidth }}mm;
            height: {{ $labelHeight - 1 }}mm;
            overflow: hidden;
            margin: 0;
            page-break-after: always;
        }
        .label:last-child {
            page-break-after: auto;
        }
        .label-content {
            padding: 1mm 2mm 0 2mm;
        }
        .label-row {
            font-size: {{ $fs }}pt;
            line-height: 0.95;
            white-space: nowrap;
            overflow: hidden;
        }
        .label-row.bold {
            font-weight: bold;
        }
        /* Product name may be long: allow it to wrap instead of being cut off. */
        .label-row.product {
            white-space: normal;
        }
        /* Pinned to the bottom-right corner of the label. */
        .label-page {
            position: absolute;
            right: 2mm;
            bottom: 0.8mm;
            font-size: {{ $fs }}pt;
            line-height: 1;
            white-space: nowrap;
        }
    </style>
</head>
<body>
    @foreach($labels as $label)
        <div class="label">
            <div class="label-content">
                <div class="label-row bold">{{ $label['po_number'] }}</div>
                <div class="label-row">{{ $label['delivery_date'] }}</div>
                <div class="label-row">{{ $label['customer'] }}</div>
                <div class="label-row product bold">{{ $label['product'] }}</div>
            </div>
            @if($label['page_total'] > 1)
                <div class="label-page">{{ $label['page_index'] }}/{{ $label['page_total'] }}</div>
            @endif
        </div>
    @endforeach
</body>
</html>
