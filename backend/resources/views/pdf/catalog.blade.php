<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: DejaVu Sans, sans-serif; color: #1f2937; font-size: 11px; }

        @page { margin: 18mm 12mm 16mm 12mm; }

        .header { border-bottom: 2px solid #111827; padding-bottom: 10px; margin-bottom: 14px; }
        .header table { width: 100%; }
        .header .logo { max-height: 46px; max-width: 130px; }
        .header .org-name { font-size: 18px; font-weight: bold; color: #111827; }
        .header .org-meta { font-size: 10px; color: #6b7280; margin-top: 2px; }
        .header .title-cell { text-align: right; vertical-align: top; }
        .header .doc-title { font-size: 13px; font-weight: bold; color: #111827; }
        .header .doc-date { font-size: 10px; color: #6b7280; margin-top: 2px; }

        .category { margin-top: 8px; margin-bottom: 6px; }
        .category-name {
            font-size: 12px; font-weight: bold; color: #111827;
            background: #f3f4f6; padding: 5px 8px; border-radius: 4px;
        }

        .grid { width: 100%; border-collapse: separate; border-spacing: 6px; }
        .cell { width: 33%; vertical-align: top; }

        .card {
            border: 1px solid #e5e7eb; border-radius: 6px; padding: 8px; height: 100%;
        }
        .thumb {
            width: 100%; height: 110px; text-align: center; background: #f9fafb;
            border-radius: 4px; margin-bottom: 6px; overflow: hidden;
        }
        .thumb img { max-width: 100%; max-height: 110px; }
        .thumb .no-img { color: #9ca3af; font-size: 9px; padding-top: 46px; display: block; }

        .p-name { font-size: 11px; font-weight: bold; color: #111827; margin-bottom: 2px; }
        .p-price { font-size: 12px; font-weight: bold; color: #059669; }
        .p-unit { font-size: 9px; color: #6b7280; }
        .p-desc { font-size: 9px; color: #6b7280; margin-top: 3px; line-height: 1.3; }
        .p-oos { font-size: 9px; color: #dc2626; font-weight: bold; margin-top: 2px; }

        .footer {
            position: fixed; bottom: -10mm; left: 0; right: 0;
            text-align: center; font-size: 9px; color: #9ca3af;
        }
        .empty { text-align: center; color: #9ca3af; padding: 40px 0; font-size: 12px; }
    </style>
</head>
<body>
    <div class="header">
        <table>
            <tr>
                <td style="vertical-align: top;">
                    @if($logoPath)
                        <img src="{{ $logoPath }}" class="logo" alt="Logo"><br>
                    @endif
                    <span class="org-name">{{ $organization->name }}</span>
                    <div class="org-meta">
                        @if($organization->address){{ $organization->address }}@endif
                        @if($organization->phone) &middot; {{ $organization->phone }}@endif
                    </div>
                </td>
                <td class="title-cell">
                    <span class="doc-title">Katalog Produk</span>
                    <div class="doc-date">{{ $generatedAt }}</div>
                </td>
            </tr>
        </table>
    </div>

    @if(count($groups) === 0)
        <div class="empty">Belum ada produk yang ditampilkan di katalog.</div>
    @endif

    @foreach($groups as $categoryName => $products)
        <div class="category">
            <span class="category-name">{{ $categoryName }}</span>
        </div>
        @foreach(array_chunk($products, 3) as $rowItems)
            <table class="grid">
                <tr>
                    @foreach($rowItems as $p)
                        <td class="cell">
                            <div class="card">
                                <div class="thumb">
                                    @if($p['image_path'])
                                        <img src="{{ $p['image_path'] }}" alt="{{ $p['name'] }}">
                                    @else
                                        <span class="no-img">Tanpa Foto</span>
                                    @endif
                                </div>
                                <div class="p-name">{{ $p['name'] }}</div>
                                <span class="p-price">Rp{{ number_format($p['price'], 0, ',', '.') }}</span>
                                <span class="p-unit">/ {{ $p['unit'] }}</span>
                                @if($p['out_of_stock'])
                                    <div class="p-oos">Stok Habis</div>
                                @endif
                                @if($p['description'])
                                    <div class="p-desc">{{ \Illuminate\Support\Str::limit($p['description'], 90) }}</div>
                                @endif
                            </div>
                        </td>
                    @endforeach
                    {{-- Fill remaining columns so cards keep a consistent width --}}
                    @for($i = count($rowItems); $i < 3; $i++)
                        <td class="cell"></td>
                    @endfor
                </tr>
            </table>
        @endforeach
    @endforeach

    <div class="footer">
        Katalog didukung oleh POScheduler
    </div>
</body>
</html>
