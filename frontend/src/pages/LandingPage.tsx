import { useState } from 'react';
import { Link } from 'react-router-dom';
import { ROUTES } from '@/lib/constants';
import {
  ClipboardList,
  Calendar,
  Store,
  Package,
  TrendingUp,
  Users,
  Check,
  ArrowRight,
  Menu,
  X,
  ShoppingCart,
  MessageCircle,
  Sparkles,
  Crown,
  ChevronDown,
} from 'lucide-react';

const FEATURES = [
  {
    icon: ClipboardList,
    title: 'Manajemen Purchase Order',
    desc: 'Buat, lacak, dan kelola setiap pesanan dari draft hingga selesai. Status pembayaran & pengiriman selalu terpantau.',
  },
  {
    icon: Calendar,
    title: 'Kalender Pesanan',
    desc: 'Lihat semua jadwal pengiriman dan deadline dalam satu tampilan kalender. Tidak ada lagi pesanan yang terlewat.',
  },
  {
    icon: Store,
    title: 'Katalog Online + WhatsApp',
    desc: 'Bagikan link katalog produk Anda. Pelanggan pesan sendiri, pesanan masuk otomatis lewat WhatsApp.',
  },
  {
    icon: Package,
    title: 'Produk & Stok',
    desc: 'Kelola produk, harga, kategori, hingga banyak foto per produk. Stok habis otomatis tampil di katalog.',
  },
  {
    icon: TrendingUp,
    title: 'Laporan Laba Rugi',
    desc: 'Pantau omzet, biaya pokok, dan keuntungan secara otomatis. Ambil keputusan berdasarkan data.',
  },
  {
    icon: Users,
    title: 'Pelanggan & Tim',
    desc: 'Simpan database pelanggan dan ajak tim berkolaborasi mengelola pesanan bersama-sama.',
  },
];

const STEPS = [
  {
    no: '1',
    title: 'Daftar & atur toko',
    desc: 'Buat akun gratis dalam hitungan menit, lalu tambahkan produk beserta harga dan fotonya.',
  },
  {
    no: '2',
    title: 'Bagikan katalog',
    desc: 'Sebar link katalog online ke pelanggan lewat WhatsApp, Instagram, atau media sosial lainnya.',
  },
  {
    no: '3',
    title: 'Kelola pesanan',
    desc: 'Pesanan pelanggan otomatis menjadi PO. Lacak, jadwalkan, dan selesaikan dari satu dashboard.',
  },
];

const FREE_FEATURES = [
  '20 Purchase Order / bulan',
  '10 produk',
  '2 anggota tim',
  'Katalog online + checkout WhatsApp',
  'Laporan dasar',
];

const PREMIUM_FEATURES = [
  'Purchase Order tanpa batas',
  'Produk tanpa batas',
  'Anggota tim tanpa batas',
  'Semua fitur laporan & laba rugi',
  'Prioritas dukungan',
];

const FAQS = [
  {
    q: 'Apakah PO Scheduler benar-benar gratis?',
    a: 'Ya. Paket Gratis bisa dipakai selamanya dengan 20 Purchase Order per bulan, 10 produk, dan 2 anggota tim — tanpa kartu kredit. Upgrade ke Premium hanya saat bisnismu butuh kapasitas lebih.',
  },
  {
    q: 'Apakah saya perlu instalasi atau website sendiri?',
    a: 'Tidak. PO Scheduler berjalan langsung di browser. Katalog online juga otomatis tersedia lewat satu link yang bisa langsung kamu bagikan ke pelanggan.',
  },
  {
    q: 'Bagaimana cara pelanggan memesan?',
    a: 'Kamu cukup membagikan link katalog. Pelanggan memilih produk sendiri, lalu checkout langsung terkirim ke WhatsApp-mu dan otomatis tercatat sebagai Purchase Order.',
  },
  {
    q: 'Jenis bisnis apa yang cocok memakai aplikasi ini?',
    a: 'Cocok untuk berbagai UMKM yang menerima pesanan — seperti toko kue, katering, frozen food, snack box, hingga bisnis produksi berbasis pesanan (pre-order).',
  },
  {
    q: 'Bagaimana cara upgrade ke Premium?',
    a: 'Setelah mendaftar, buka menu langganan di dalam aplikasi, lakukan pembayaran, dan kirim bukti. Tim kami memverifikasi lalu akun Premium langsung aktif.',
  },
];

function Logo({ className = '' }: { className?: string }) {
  return (
    <Link to="/" className={`flex items-center gap-2 ${className}`} aria-label="PO Scheduler — beranda">
      <div className="w-9 h-9 rounded-[10px] bg-primary text-white flex items-center justify-center text-lg shadow-sm">
        📋
      </div>
      <span className="font-extrabold text-[18px] text-gray-900 tracking-tight">
        PO Scheduler
      </span>
    </Link>
  );
}

export default function LandingPage() {
  const [menuOpen, setMenuOpen] = useState(false);
  const [openFaq, setOpenFaq] = useState<number | null>(0);

  return (
    <div className="min-h-screen bg-white text-gray-900">
      {/* ===== Navbar ===== */}
      <header className="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b border-gray-100">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <Logo />

            <nav className="hidden md:flex items-center gap-8">
              <a href="#fitur" className="text-[14px] font-medium text-gray-600 hover:text-primary transition-colors">Fitur</a>
              <a href="#cara-kerja" className="text-[14px] font-medium text-gray-600 hover:text-primary transition-colors">Cara Kerja</a>
              <a href="#harga" className="text-[14px] font-medium text-gray-600 hover:text-primary transition-colors">Harga</a>
            </nav>

            <div className="hidden md:flex items-center gap-2">
              <Link
                to={ROUTES.LOGIN}
                className="px-4 py-2 rounded-[10px] text-[14px] font-semibold text-gray-700 hover:bg-gray-100 transition-colors"
              >
                Masuk
              </Link>
              <Link
                to={ROUTES.REGISTER}
                className="px-4 py-2 rounded-[10px] text-[14px] font-semibold bg-primary text-white hover:bg-primary-dark transition-colors shadow-sm"
              >
                Daftar Gratis
              </Link>
            </div>

            <button
              className="md:hidden p-2 text-gray-600"
              onClick={() => setMenuOpen(v => !v)}
              aria-label="Menu"
            >
              {menuOpen ? <X size={22} /> : <Menu size={22} />}
            </button>
          </div>
        </div>

        {/* Mobile menu */}
        {menuOpen && (
          <div className="md:hidden border-t border-gray-100 bg-white px-4 py-4 space-y-1">
            <a href="#fitur" onClick={() => setMenuOpen(false)} className="block px-3 py-2.5 rounded-lg text-[14px] font-medium text-gray-700 hover:bg-gray-50">Fitur</a>
            <a href="#cara-kerja" onClick={() => setMenuOpen(false)} className="block px-3 py-2.5 rounded-lg text-[14px] font-medium text-gray-700 hover:bg-gray-50">Cara Kerja</a>
            <a href="#harga" onClick={() => setMenuOpen(false)} className="block px-3 py-2.5 rounded-lg text-[14px] font-medium text-gray-700 hover:bg-gray-50">Harga</a>
            <div className="pt-2 flex flex-col gap-2">
              <Link to={ROUTES.LOGIN} className="w-full text-center px-4 py-2.5 rounded-[10px] text-[14px] font-semibold text-gray-700 border border-gray-200">Masuk</Link>
              <Link to={ROUTES.REGISTER} className="w-full text-center px-4 py-2.5 rounded-[10px] text-[14px] font-semibold bg-primary text-white">Daftar Gratis</Link>
            </div>
          </div>
        )}
      </header>

      {/* ===== Hero ===== */}
      <section className="relative overflow-hidden">
        {/* soft background accents */}
        <div className="absolute inset-0 -z-10">
          <div className="absolute -top-24 -right-24 w-96 h-96 rounded-full bg-primary-50 blur-3xl opacity-70" />
          <div className="absolute top-40 -left-24 w-80 h-80 rounded-full bg-accent-light blur-3xl opacity-60" />
        </div>

        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 pt-16 pb-20 sm:pt-24 sm:pb-28">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            {/* copy */}
            <div className="text-center lg:text-left">
              <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-primary-50 text-primary text-[12px] font-semibold mb-5">
                <Sparkles size={13} /> Kelola pesanan lebih rapi & profesional
              </span>
              <h1 className="text-4xl sm:text-5xl font-extrabold tracking-tight leading-[1.1] text-gray-900">
                Atur pesanan bisnismu, <span className="text-primary">tanpa ribet</span>
              </h1>
              <p className="mt-5 text-[16px] sm:text-[17px] text-gray-500 leading-relaxed max-w-xl mx-auto lg:mx-0">
                PO Scheduler membantu UMKM mengelola purchase order, katalog online,
                stok, dan laporan keuangan — semuanya dalam satu aplikasi sederhana.
              </p>
              <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center lg:justify-start">
                <Link
                  to={ROUTES.REGISTER}
                  className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-[12px] text-[15px] font-bold bg-primary text-white hover:bg-primary-dark transition-colors shadow-lg shadow-primary/20"
                >
                  Mulai Gratis Sekarang <ArrowRight size={18} />
                </Link>
                <a
                  href="#fitur"
                  className="inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-[12px] text-[15px] font-bold text-gray-700 bg-white border border-gray-200 hover:bg-gray-50 transition-colors"
                >
                  Lihat Fitur
                </a>
              </div>
              <p className="mt-4 text-[13px] text-gray-400">
                Gratis selamanya · Tanpa kartu kredit
              </p>
            </div>

            {/* app mockup */}
            <div className="relative">
              <div className="relative bg-white rounded-2xl shadow-2xl border border-gray-100 p-5 rotate-1 hover:rotate-0 transition-transform duration-500">
                {/* mock header */}
                <div className="flex items-center justify-between mb-4">
                  <div>
                    <div className="text-[11px] text-gray-400 font-medium">Dashboard</div>
                    <div className="text-[15px] font-bold text-gray-900">Halo, Toko Kue Melati 👋</div>
                  </div>
                  <div className="w-9 h-9 rounded-full bg-primary-50 flex items-center justify-center text-primary font-bold text-[13px]">TM</div>
                </div>

                {/* mock stat cards */}
                <div className="grid grid-cols-3 gap-2.5 mb-4">
                  {[
                    { label: 'Pesanan', value: '128', color: 'bg-primary-50 text-primary' },
                    { label: 'Omzet', value: '24jt', color: 'bg-accent-light text-accent' },
                    { label: 'Selesai', value: '96%', color: 'bg-primary-50 text-primary' },
                  ].map((s) => (
                    <div key={s.label} className="rounded-xl border border-gray-100 p-3">
                      <div className={`w-7 h-7 rounded-lg ${s.color} flex items-center justify-center text-[11px] font-bold mb-2`}>
                        {s.label[0]}
                      </div>
                      <div className="text-[16px] font-extrabold text-gray-900 leading-none">{s.value}</div>
                      <div className="text-[10px] text-gray-400 mt-1">{s.label}</div>
                    </div>
                  ))}
                </div>

                {/* mock order rows */}
                <div className="space-y-2">
                  {[
                    { name: 'Kue Ultah Coklat', status: 'Diproses', color: 'text-amber-600 bg-amber-50' },
                    { name: 'Nasi Box 50 pcs', status: 'Selesai', color: 'text-accent bg-accent-light' },
                    { name: 'Snack Box Meeting', status: 'Dikonfirmasi', color: 'text-primary bg-primary-50' },
                  ].map((o, i) => (
                    <div key={i} className="flex items-center justify-between rounded-xl border border-gray-100 px-3 py-2.5">
                      <div className="flex items-center gap-2.5">
                        <div className="w-8 h-8 rounded-lg bg-gray-100 flex items-center justify-center text-[13px]">🧁</div>
                        <div>
                          <div className="text-[12px] font-semibold text-gray-800">{o.name}</div>
                          <div className="text-[10px] text-gray-400">PO-2026-0{i + 1}</div>
                        </div>
                      </div>
                      <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-full ${o.color}`}>{o.status}</span>
                    </div>
                  ))}
                </div>
              </div>

              {/* floating WA badge */}
              <div className="absolute -bottom-4 -left-4 bg-white rounded-xl shadow-xl border border-gray-100 px-3.5 py-2.5 flex items-center gap-2.5 -rotate-2">
                <div className="w-9 h-9 rounded-full bg-green-500 text-white flex items-center justify-center">
                  <MessageCircle size={18} />
                </div>
                <div>
                  <div className="text-[11px] font-bold text-gray-900">Pesanan baru!</div>
                  <div className="text-[10px] text-gray-400">via katalog WhatsApp</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ===== Stats strip ===== */}
      <section className="border-y border-gray-100 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
            {[
              { value: 'Semua', label: 'Jenis UMKM' },
              { value: '< 5 mnt', label: 'Langsung jalan' },
              { value: '1 Link', label: 'Katalog online' },
              { value: 'Realtime', label: 'Laporan keuangan' },
            ].map((s) => (
              <div key={s.label}>
                <div className="text-2xl font-extrabold text-primary">{s.value}</div>
                <div className="text-[13px] text-gray-500 mt-1">{s.label}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ===== Features ===== */}
      <section id="fitur" className="py-20 sm:py-24 scroll-mt-20">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="text-[13px] font-bold text-accent uppercase tracking-wider">Fitur Lengkap</span>
            <h2 className="mt-2 text-3xl sm:text-4xl font-extrabold tracking-tight text-gray-900">
              Semua yang bisnismu butuhkan
            </h2>
            <p className="mt-4 text-[16px] text-gray-500">
              Dari terima pesanan sampai laporan keuntungan — dikerjakan dari satu tempat.
            </p>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {FEATURES.map((f) => (
              <div
                key={f.title}
                className="group rounded-2xl border border-gray-100 bg-white p-6 hover:shadow-lg hover:border-primary-100 transition-all"
              >
                <div className="w-12 h-12 rounded-xl bg-primary-50 text-primary flex items-center justify-center mb-4 group-hover:bg-primary group-hover:text-white transition-colors">
                  <f.icon size={22} />
                </div>
                <h3 className="text-[16px] font-bold text-gray-900 mb-1.5">{f.title}</h3>
                <p className="text-[14px] text-gray-500 leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ===== Katalog highlight ===== */}
      <section className="py-16 bg-gradient-to-br from-primary-dark via-primary to-primary-light">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid lg:grid-cols-2 gap-10 items-center">
            <div className="text-white">
              <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/15 text-white text-[12px] font-semibold mb-4">
                <ShoppingCart size={13} /> Katalog Online
              </span>
              <h2 className="text-3xl sm:text-4xl font-extrabold tracking-tight leading-tight">
                Toko online instan, pesanan langsung ke WhatsApp
              </h2>
              <p className="mt-4 text-[16px] text-white/80 leading-relaxed">
                Bagikan satu link katalog. Pelanggan memilih produk sendiri, dan pesanan
                otomatis tercatat sebagai Purchase Order lengkap dengan data pelanggan.
              </p>
              <ul className="mt-6 space-y-3">
                {['Tanpa perlu bikin website', 'Checkout langsung via WhatsApp', 'Stok habis otomatis tampil'].map((t) => (
                  <li key={t} className="flex items-center gap-2.5 text-[15px] text-white/90">
                    <span className="w-5 h-5 rounded-full bg-white/20 flex items-center justify-center flex-shrink-0">
                      <Check size={12} />
                    </span>
                    {t}
                  </li>
                ))}
              </ul>
              <Link
                to={ROUTES.REGISTER}
                className="mt-8 inline-flex items-center gap-2 px-6 py-3 rounded-[12px] text-[15px] font-bold bg-white text-primary hover:bg-gray-50 transition-colors shadow-lg"
              >
                Buat Katalog Gratis <ArrowRight size={18} />
              </Link>
            </div>

            {/* mock catalog card */}
            <div className="bg-white rounded-2xl shadow-2xl p-4 max-w-sm mx-auto w-full">
              <div className="grid grid-cols-2 gap-3">
                {[
                  { emoji: '🎂', name: 'Kue Tart Ulang Tahun', price: 'Rp 250.000' },
                  { emoji: '🍪', name: 'Cookies Premium', price: 'Rp 85.000' },
                  { emoji: '🥐', name: 'Croissant Butter', price: 'Rp 18.000' },
                  { emoji: '🧁', name: 'Cupcake Box', price: 'Rp 120.000' },
                ].map((p) => (
                  <div key={p.name} className="rounded-xl border border-gray-100 overflow-hidden">
                    <div className="aspect-square bg-gray-50 flex items-center justify-center text-4xl">{p.emoji}</div>
                    <div className="p-2.5">
                      <div className="text-[12px] font-semibold text-gray-800 leading-tight">{p.name}</div>
                      <div className="text-[13px] font-extrabold text-primary mt-1">{p.price}</div>
                    </div>
                  </div>
                ))}
              </div>
              <button className="mt-3 w-full rounded-xl bg-green-500 text-white text-[13px] font-bold py-2.5 flex items-center justify-center gap-2">
                <ShoppingCart size={16} /> Checkout via WhatsApp
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* ===== How it works ===== */}
      <section id="cara-kerja" className="py-20 sm:py-24 scroll-mt-20">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="text-[13px] font-bold text-accent uppercase tracking-wider">Cara Kerja</span>
            <h2 className="mt-2 text-3xl sm:text-4xl font-extrabold tracking-tight text-gray-900">
              Siap dalam 3 langkah
            </h2>
          </div>

          <div className="grid md:grid-cols-3 gap-6">
            {STEPS.map((s, i) => (
              <div key={s.no} className="relative">
                <div className="rounded-2xl border border-gray-100 bg-white p-7 h-full">
                  <div className="w-11 h-11 rounded-xl bg-primary text-white flex items-center justify-center text-lg font-extrabold mb-4">
                    {s.no}
                  </div>
                  <h3 className="text-[17px] font-bold text-gray-900 mb-2">{s.title}</h3>
                  <p className="text-[14px] text-gray-500 leading-relaxed">{s.desc}</p>
                </div>
                {i < STEPS.length - 1 && (
                  <div className="hidden md:block absolute top-1/2 -right-3 text-gray-300 z-10">
                    <ArrowRight size={22} />
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ===== Pricing ===== */}
      <section id="harga" className="py-20 sm:py-24 bg-gray-50 border-y border-gray-100 scroll-mt-20">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="text-[13px] font-bold text-accent uppercase tracking-wider">Harga</span>
            <h2 className="mt-2 text-3xl sm:text-4xl font-extrabold tracking-tight text-gray-900">
              Mulai gratis, upgrade saat berkembang
            </h2>
            <p className="mt-4 text-[16px] text-gray-500">
              Tidak ada biaya tersembunyi. Batalkan kapan saja.
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-6 max-w-3xl mx-auto">
            {/* Free */}
            <div className="rounded-2xl border border-gray-200 bg-white p-8">
              <h3 className="text-[15px] font-bold text-gray-500">Gratis</h3>
              <div className="mt-3 flex items-baseline gap-1">
                <span className="text-4xl font-extrabold text-gray-900">Rp 0</span>
                <span className="text-[14px] text-gray-400">/selamanya</span>
              </div>
              <p className="mt-2 text-[14px] text-gray-500">Cocok untuk memulai dan mencoba semua fitur inti.</p>
              <ul className="mt-6 space-y-3">
                {FREE_FEATURES.map((f) => (
                  <li key={f} className="flex items-start gap-2.5 text-[14px] text-gray-700">
                    <Check size={18} className="text-accent flex-shrink-0 mt-0.5" /> {f}
                  </li>
                ))}
              </ul>
              <Link
                to={ROUTES.REGISTER}
                className="mt-8 block w-full text-center px-5 py-3 rounded-[12px] text-[15px] font-bold text-primary bg-primary-50 hover:bg-primary-100 transition-colors"
              >
                Mulai Gratis
              </Link>
            </div>

            {/* Premium */}
            <div className="relative rounded-2xl border-2 border-primary bg-white p-8 shadow-xl">
              <span className="absolute -top-3 left-1/2 -translate-x-1/2 inline-flex items-center gap-1 px-3 py-1 rounded-full bg-primary text-white text-[11px] font-bold">
                <Crown size={12} /> Paling Populer
              </span>
              <h3 className="text-[15px] font-bold text-primary">Premium</h3>
              <div className="mt-3 flex items-baseline gap-1">
                <span className="text-4xl font-extrabold text-gray-900">Rp 35.000</span>
                <span className="text-[14px] text-gray-400">/bulan</span>
              </div>
              <p className="mt-2 text-[14px] text-gray-500">Untuk bisnis yang siap tumbuh tanpa batasan.</p>
              <ul className="mt-6 space-y-3">
                {PREMIUM_FEATURES.map((f) => (
                  <li key={f} className="flex items-start gap-2.5 text-[14px] text-gray-700">
                    <Check size={18} className="text-primary flex-shrink-0 mt-0.5" /> {f}
                  </li>
                ))}
              </ul>
              <Link
                to={ROUTES.REGISTER}
                className="mt-8 block w-full text-center px-5 py-3 rounded-[12px] text-[15px] font-bold text-white bg-primary hover:bg-primary-dark transition-colors shadow-lg shadow-primary/20"
              >
                Coba Premium
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* ===== FAQ ===== */}
      <section id="faq" className="py-20 sm:py-24 scroll-mt-20">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <span className="text-[13px] font-bold text-accent uppercase tracking-wider">FAQ</span>
            <h2 className="mt-2 text-3xl sm:text-4xl font-extrabold tracking-tight text-gray-900">
              Pertanyaan yang sering ditanyakan
            </h2>
          </div>

          <div className="space-y-3">
            {FAQS.map((item, i) => {
              const isOpen = openFaq === i;
              return (
                <div key={i} className="rounded-2xl border border-gray-100 bg-white overflow-hidden">
                  <button
                    onClick={() => setOpenFaq(isOpen ? null : i)}
                    className="w-full flex items-center justify-between gap-4 px-5 py-4 text-left"
                    aria-expanded={isOpen}
                  >
                    <span className="text-[15px] font-semibold text-gray-900">{item.q}</span>
                    <ChevronDown
                      size={20}
                      className={`flex-shrink-0 text-gray-400 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`}
                    />
                  </button>
                  <div
                    className={`grid transition-all duration-200 ease-in-out ${isOpen ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'}`}
                  >
                    <div className="overflow-hidden">
                      <p className="px-5 pb-4 text-[14px] text-gray-500 leading-relaxed">{item.a}</p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* ===== CTA ===== */}
      <section className="py-20 sm:py-24">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="rounded-3xl bg-primary text-white text-center px-6 py-14 sm:py-16 relative overflow-hidden">
            <div className="absolute -top-16 -right-16 w-64 h-64 rounded-full bg-white/10 blur-2xl" />
            <div className="absolute -bottom-16 -left-16 w-64 h-64 rounded-full bg-white/10 blur-2xl" />
            <div className="relative">
              <h2 className="text-3xl sm:text-4xl font-extrabold tracking-tight">
                Siap bikin bisnismu lebih rapi?
              </h2>
              <p className="mt-4 text-[16px] text-white/80 max-w-xl mx-auto">
                Bergabung sekarang dan kelola pesanan, katalog, dan laporan bisnismu tanpa ribet.
              </p>
              <Link
                to={ROUTES.REGISTER}
                className="mt-8 inline-flex items-center gap-2 px-7 py-3.5 rounded-[12px] text-[15px] font-bold bg-white text-primary hover:bg-gray-50 transition-colors shadow-lg"
              >
                Daftar Gratis Sekarang <ArrowRight size={18} />
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* ===== Footer ===== */}
      <footer className="border-t border-gray-100 py-12 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col items-center text-center gap-4">
            <Logo />
            <p className="text-[14px] text-gray-500 max-w-md leading-relaxed">
              Aplikasi manajemen pesanan, katalog online, dan laporan keuangan
              yang dirancang sederhana untuk UMKM Indonesia.
            </p>
            <Link
              to={ROUTES.REGISTER}
              className="inline-flex items-center gap-2 px-5 py-2.5 rounded-[10px] text-[14px] font-semibold bg-primary text-white hover:bg-primary-dark transition-colors"
            >
              Mulai Gratis <ArrowRight size={16} />
            </Link>
          </div>
          <div className="mt-8 pt-6 border-t border-gray-200 text-center text-[13px] text-gray-400">
            © {new Date().getFullYear()} PO Scheduler. Dibuat untuk UMKM Indonesia.
          </div>
        </div>
      </footer>
    </div>
  );
}
