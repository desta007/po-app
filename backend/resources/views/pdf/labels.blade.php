<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @page {
            margin: 0;
            size: {{ $paperWidth }}mm {{ $paperHeight }}mm;
        }
        html, body {
            font-family: 'DejaVu Sans', sans-serif;
            margin: 0;
            padding: 0;
            color: #000;
        }
        .labels-strip {
            width: 100%;
        }
        .label {
            display: block;
            width: {{ $labelWidth }}mm;
            height: {{ $labelHeight }}mm;
            border-bottom: 0.3px dashed #ccc;
            box-sizing: border-box;
            padding: 1mm 2mm;
            overflow: hidden;
            margin: 0;
            page-break-inside: avoid;
        }
        .label:last-child {
            border-bottom: none;
        }
        .label-row {
            font-size: 6pt;
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
    <div class="labels-strip">
        @foreach($labels as $label)
            <div class="label">
                <div class="label-row bold">{{ $label['po_number'] }}</div>
                <div class="label-row">{{ $label['order_date'] }}</div>
                <div class="label-row">{{ $label['customer'] }}</div>
                <div class="label-row bold">{{ $label['product'] }}</div>
            </div>
        @endforeach
    </div>
</body>
</html>
