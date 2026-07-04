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
        .label {
            display: block;
            width: {{ $labelWidth }}mm;
            box-sizing: border-box;
            padding: 1mm 2mm;
            overflow: hidden;
            margin: 0;
            page-break-after: always;
        }
        .label:last-child {
            page-break-after: auto;
        }
        .label-row {
            font-size: {{ $labelHeight >= 20 ? '6' : '5' }}pt;
            line-height: 1.2;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .label-row.bold {
            font-weight: bold;
        }
    </style>
</head>
<body>
    @foreach($labels as $label)
        <div class="label">
            <div class="label-row bold">{{ $label['po_number'] }}</div>
            <div class="label-row">{{ $label['delivery_date'] }}</div>
            <div class="label-row">{{ $label['customer'] }}</div>
            <div class="label-row bold">{{ $label['product'] }}</div>
        </div>
    @endforeach
</body>
</html>
