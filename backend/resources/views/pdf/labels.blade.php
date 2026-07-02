<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        @page {
            margin: 5mm;
            size: A4 portrait;
        }
        html, body {
            font-family: 'DejaVu Sans', sans-serif;
            margin: 0;
            padding: 0;
            color: #000;
        }
        .labels-grid {
            width: 100%;
        }
        .label {
            display: inline-block;
            vertical-align: top;
            width: {{ $labelWidth }}mm;
            height: {{ $labelHeight }}mm;
            border: 0.3px solid #ccc;
            box-sizing: border-box;
            padding: 1.5mm 2mm;
            overflow: hidden;
            margin: 0;
            page-break-inside: avoid;
        }
        .label-po {
            font-size: 6px;
            font-weight: bold;
            line-height: 1.2;
            letter-spacing: 0.3px;
        }
        .label-date {
            font-size: 5.5px;
            line-height: 1.2;
            color: #333;
        }
        .label-customer {
            font-size: 5.5px;
            line-height: 1.2;
            color: #333;
        }
        .label-product {
            font-size: 6.5px;
            font-weight: bold;
            line-height: 1.2;
            margin-top: 0.5mm;
        }
    </style>
</head>
<body>
    <div class="labels-grid">
        @foreach($labels as $label)
            <div class="label">
                <div class="label-po">{{ $label['po_number'] }}</div>
                <div class="label-date">{{ $label['order_date'] }}</div>
                <div class="label-customer">{{ $label['customer'] }}</div>
                <div class="label-product">{{ $label['product'] }}</div>
            </div>
        @endforeach
    </div>
</body>
</html>
