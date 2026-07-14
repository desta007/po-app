import { useState } from 'react';
import { useAuth } from '@/contexts/auth-context';
import { settingsApi } from '@/api/settings';
import { PageHeader } from '@/components/layout/page-header';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { storageUrl } from '@/lib/utils';
import { toast } from 'sonner';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Users, UserPlus, Trash2, Shield, Crown, Eye, Briefcase, Upload, Image as ImageIcon, Plus, Pencil, CreditCard } from 'lucide-react';
import { useQuota } from '@/hooks/use-quota';
import { useRef } from 'react';
import type { MemberRole, TeamMember } from '@/types/auth';
import { OnlineStoreTab } from '@/components/settings/online-store-tab';

interface PaymentMethod {
  name: string;
  is_active: boolean;
}

const TABS = [
  { id: 'profile', label: '👤 Profil', roles: ['owner', 'admin', 'staff', 'viewer'] as string[] },
  { id: 'organization', label: '🏢 Organisasi', roles: ['owner', 'admin', 'staff', 'viewer'] as string[] },
  { id: 'payment-methods', label: '💳 Metode Bayar', roles: ['owner', 'admin'] as string[] },
  { id: 'online-store', label: '🛒 Toko Online', roles: ['owner', 'admin'] as string[] },
  { id: 'team', label: '👥 Anggota Tim', roles: ['owner', 'admin'] as string[] },
];

const ROLE_CONFIG: Record<string, { label: string; color: string; bgColor: string; icon: typeof Crown }> = {
  owner: { label: 'Owner', color: '#1F4E79', bgColor: '#DBEAFE', icon: Crown },
  admin: { label: 'Admin', color: '#D97706', bgColor: '#FEF3C7', icon: Shield },
  staff: { label: 'Staff', color: '#6B7280', bgColor: '#F3F4F6', icon: Briefcase },
  viewer: { label: 'Viewer', color: '#9CA3AF', bgColor: '#F9FAFB', icon: Eye },
};

const INVITE_ROLES = [
  { value: 'admin', label: 'Admin — Kelola semua data & anggota' },
  { value: 'staff', label: 'Staff — Kelola PO, customer, produk' },
  { value: 'viewer', label: 'Viewer — Hanya melihat data' },
];

function getInitials(name: string) {
  return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
}

export default function SettingsPage() {
  const { user, role, refreshUser } = useAuth();
  const queryClient = useQueryClient();
  const { teamUsage, isPremiumOrAdmin } = useQuota();
  const [activeTab, setActiveTab] = useState('profile');

  // Profile form
  const [profileForm, setProfileForm] = useState({
    full_name: user?.full_name || '',
    phone: user?.phone || '',
  });

  // Organization
  const { data: orgData } = useQuery({
    queryKey: ['settings', 'org'],
    queryFn: () => settingsApi.getOrganization(),
  });

  const [orgForm, setOrgForm] = useState({ 
    name: '', 
    phone: '', 
    address: '',
    settings: {
      bank_info: {
        bank_name: '',
        account_number: '',
        account_name: ''
      }
    }
  });
  const org = orgData?.data?.data;
  const orgSettings = org?.settings as { bank_info?: { bank_name?: string; account_number?: string; account_name?: string } } | undefined;
  if (org && !orgForm.name) {
    setOrgForm({
      name: org.name,
      phone: org.phone || '',
      address: org.address || '',
      settings: {
        bank_info: {
          bank_name: orgSettings?.bank_info?.bank_name || '',
          account_number: orgSettings?.bank_info?.account_number || '',
          account_name: orgSettings?.bank_info?.account_name || ''
        }
      }
    });
  }

  const fileInputRef = useRef<HTMLInputElement>(null);
  const [uploadingLogo, setUploadingLogo] = useState(false);

  // Team
  const { data: teamData, isLoading: teamLoading } = useQuery({
    queryKey: ['team-members'],
    queryFn: () => settingsApi.listTeamMembers(),
    enabled: role === 'owner' || role === 'admin',
  });

  const [inviteOpen, setInviteOpen] = useState(false);
  const [inviteForm, setInviteForm] = useState({ email: '', role: 'staff' as MemberRole });

  // Payment Methods
  const { data: paymentMethodsData, isLoading: pmLoading } = useQuery({
    queryKey: ['payment-methods'],
    queryFn: () => settingsApi.getPaymentMethods(),
    enabled: role === 'owner' || role === 'admin',
  });

  const [pmEditOpen, setPmEditOpen] = useState(false);
  const [pmEditIndex, setPmEditIndex] = useState<number | null>(null);
  const [pmForm, setPmForm] = useState({ name: '', is_active: true });

  const paymentMethods: PaymentMethod[] = paymentMethodsData?.data?.data || [];

  const updatePaymentMethods = useMutation({
    mutationFn: (methods: PaymentMethod[]) => settingsApi.updatePaymentMethods(methods),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['payment-methods'] });
      toast.success('Metode pembayaran berhasil diperbarui.');
    },
    onError: () => toast.error('Gagal memperbarui metode pembayaran.'),
  });

  const handleAddPaymentMethod = () => {
    setPmEditIndex(null);
    setPmForm({ name: '', is_active: true });
    setPmEditOpen(true);
  };

  const handleEditPaymentMethod = (index: number) => {
    const method = paymentMethods[index];
    if (!method) return;
    setPmEditIndex(index);
    setPmForm({ name: method.name, is_active: method.is_active });
    setPmEditOpen(true);
  };

  const handleSavePaymentMethod = () => {
    if (!pmForm.name.trim()) {
      toast.error('Nama metode bayar tidak boleh kosong.');
      return;
    }
    const updated: PaymentMethod[] = [...paymentMethods];
    if (pmEditIndex !== null) {
      updated[pmEditIndex] = { name: pmForm.name, is_active: pmForm.is_active };
    } else {
      updated.push({ name: pmForm.name, is_active: pmForm.is_active });
    }
    updatePaymentMethods.mutate(updated);
    setPmEditOpen(false);
  };

  const handleDeletePaymentMethod = (index: number) => {
    const method = paymentMethods[index];
    if (!method || !window.confirm(`Hapus metode "${method.name}"?`)) return;
    const updated = paymentMethods.filter((_, i) => i !== index);
    updatePaymentMethods.mutate(updated);
  };

  const handleTogglePaymentMethod = (index: number) => {
    const updated: PaymentMethod[] = paymentMethods.map((m, i) =>
      i === index ? { name: m.name, is_active: !m.is_active } : m
    );
    updatePaymentMethods.mutate(updated);
  };

  const handleMovePaymentMethod = (index: number, direction: 'up' | 'down') => {
    const updated: PaymentMethod[] = [...paymentMethods];
    const targetIndex = direction === 'up' ? index - 1 : index + 1;
    if (targetIndex < 0 || targetIndex >= updated.length) return;
    const temp = updated[index]!;
    updated[index] = updated[targetIndex]!;
    updated[targetIndex] = temp;
    updatePaymentMethods.mutate(updated);
  };

  // Mutations
  const updateProfile = useMutation({
    mutationFn: (data: any) => settingsApi.updateProfile(data),
    onSuccess: () => { refreshUser(); toast.success('Profil berhasil diperbarui.'); },
    onError: () => toast.error('Gagal memperbarui profil.'),
  });

  const updateOrg = useMutation({
    mutationFn: (data: any) => settingsApi.updateOrganization(data),
    onSuccess: () => { queryClient.invalidateQueries({ queryKey: ['settings'] }); toast.success('Organisasi berhasil diperbarui.'); },
    onError: () => toast.error('Gagal memperbarui organisasi.'),
  });

  const handleLogoUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    
    setUploadingLogo(true);
    try {
      await settingsApi.uploadLogo(file);
      queryClient.invalidateQueries({ queryKey: ['settings', 'org'] });
      toast.success('Logo berhasil diupload.');
    } catch (err: any) {
      toast.error(err.response?.data?.message || 'Gagal upload logo.');
    } finally {
      setUploadingLogo(false);
      if (fileInputRef.current) fileInputRef.current.value = '';
    }
  };

  const deleteLogo = useMutation({
    mutationFn: () => settingsApi.deleteLogo(),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings', 'org'] });
      toast.success('Logo berhasil dihapus.');
    },
    onError: () => toast.error('Gagal menghapus logo.'),
  });

  const inviteMember = useMutation({
    mutationFn: (data: { email: string; role: MemberRole }) => settingsApi.inviteTeamMember(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['team-members'] });
      queryClient.invalidateQueries({ queryKey: ['quota-usage'] });
      setInviteOpen(false);
      setInviteForm({ email: '', role: 'staff' });
      toast.success('Anggota berhasil ditambahkan.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menambahkan anggota.'),
  });

  const updateRole = useMutation({
    mutationFn: ({ id, role }: { id: string; role: MemberRole }) => settingsApi.updateMemberRole(id, role),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['team-members'] });
      toast.success(`Role berhasil diubah.`);
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal mengubah role.'),
  });

  const removeMember = useMutation({
    mutationFn: (id: string) => settingsApi.removeMember(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['team-members'] });
      toast.success('Anggota berhasil dihapus.');
    },
    onError: (err: any) => toast.error(err.response?.data?.message || 'Gagal menghapus anggota.'),
  });

  const members: TeamMember[] = teamData?.data?.data || [];
  const visibleTabs = TABS.filter(t => !role || t.roles.includes(role));

  return (
    <div>
      <PageHeader title="Pengaturan" description="Kelola profil, organisasi, dan tim Anda" />

      {/* Tab Bar */}
      <div className="flex gap-1 mb-6 bg-gray-100 p-1 rounded-[10px] max-w-fit">
        {visibleTabs.map(tab => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`px-4 py-2 rounded-[8px] text-[13px] font-semibold transition-all ${
              activeTab === tab.id
                ? 'bg-white text-gray-900 shadow-sm'
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <div className="max-w-2xl">
        {/* Profile Tab */}
        {activeTab === 'profile' && (
          <div className="space-y-5">
            <Card>
              <h3 className="text-[14px] font-bold text-gray-900 mb-4">Informasi Profil</h3>
              <form onSubmit={(e) => { e.preventDefault(); updateProfile.mutate(profileForm); }} className="space-y-3">
                <Input label="Nama Lengkap" value={profileForm.full_name} onChange={(e) => setProfileForm({...profileForm, full_name: e.target.value})} />
                <Input label="No. HP" value={profileForm.phone} onChange={(e) => setProfileForm({...profileForm, phone: e.target.value})} />
                <Input label="Email" value={user?.email || ''} disabled />
                <Button type="submit" loading={updateProfile.isPending}>Simpan Profil</Button>
              </form>
            </Card>
          </div>
        )}

        {/* Organization Tab */}
        {activeTab === 'organization' && (
          <div className="space-y-4">
            <Card>
              <h3 className="text-[14px] font-bold text-gray-900 mb-1">🔗 Link Katalog Publik</h3>
              <p className="text-[12px] text-gray-500 mb-3.5">Bagikan link ini kepada pelanggan Anda agar mereka dapat melihat daftar produk aktif Anda secara online.</p>
              <div className="flex items-center gap-2 bg-gray-55 border border-gray-200 rounded-[10px] p-2">
                <span className="text-[13px] text-gray-600 font-mono select-all truncate flex-1 pl-2">
                  {org?.slug ? `${window.location.origin}/katalog/${org.slug}` : 'Generating link...'}
                </span>
                <Button 
                  type="button" 
                  variant="secondary" 
                  size="sm"
                  onClick={() => {
                    if (org?.slug) {
                      navigator.clipboard.writeText(`${window.location.origin}/katalog/${org.slug}`);
                      toast.success('Link katalog disalin ke clipboard!');
                    }
                  }}
                >
                  Salin Link
                </Button>
                <a 
                  href={org?.slug ? `/katalog/${org.slug}` : '#'} 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="inline-flex items-center justify-center h-9 px-4 border border-gray-200 rounded-[8px] text-[13px] font-semibold text-gray-700 bg-white hover:bg-gray-50 transition-colors"
                >
                  Buka
                </a>
              </div>
            </Card>

            <Card>
              <h3 className="text-[14px] font-bold text-gray-900 mb-4">Informasi Organisasi / Bisnis</h3>
              <form onSubmit={(e) => { e.preventDefault(); updateOrg.mutate(orgForm); }} className="space-y-4">
                
                <div className="space-y-1.5 border-b border-gray-100 pb-4 mb-4">
                  <label className="block text-xs font-semibold text-gray-700">Logo Bisnis (Tampil di Katalog & Invoice)</label>
                  <div className="flex items-center gap-4 mt-2">
                    {org?.logo_url ? (
                      <div className="relative group">
                        <img src={storageUrl(org.logo_url)} alt="Logo" className="w-16 h-16 rounded-[6px] object-contain border border-gray-200 bg-white" />
                        <button 
                          type="button" 
                          className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full p-1 opacity-0 group-hover:opacity-100 transition-opacity"
                          onClick={() => { if(window.confirm('Hapus logo?')) deleteLogo.mutate(); }}
                        >
                          <Trash2 size={12} />
                        </button>
                      </div>
                    ) : (
                      <div className="w-16 h-16 rounded-[6px] bg-gray-50 border border-gray-200 flex items-center justify-center text-gray-400">
                        <ImageIcon size={24} />
                      </div>
                    )}
                    <div>
                      <input 
                        type="file" 
                        accept="image/png, image/jpeg, image/webp" 
                        className="hidden" 
                        ref={fileInputRef}
                        onChange={handleLogoUpload}
                      />
                      <Button 
                        type="button" 
                        variant="secondary" 
                        size="sm" 
                        onClick={() => fileInputRef.current?.click()}
                        loading={uploadingLogo}
                      >
                        <Upload size={14} className="mr-1.5" /> {org?.logo_url ? 'Ganti Logo' : 'Upload Logo'}
                      </Button>
                      <p className="text-[11px] text-gray-500 mt-1">Maks. 1MB. Format: JPG, PNG, WEBP.</p>
                    </div>
                  </div>
                </div>

                <div className="space-y-3">
                  <Input label="Nama Bisnis" value={orgForm.name} onChange={(e) => setOrgForm({...orgForm, name: e.target.value})} required />
                  <Input label="No. Telepon" value={orgForm.phone} onChange={(e) => setOrgForm({...orgForm, phone: e.target.value})} />
                  <div>
                    <label className="block text-xs font-semibold text-gray-700 mb-1.5">Alamat</label>
                    <textarea className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] min-h-[80px] focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50" value={orgForm.address} onChange={(e) => setOrgForm({...orgForm, address: e.target.value})} />
                  </div>
                </div>

                <div className="pt-4 border-t border-gray-100">
                  <h4 className="text-[13px] font-bold text-gray-900 mb-3">Informasi Rekening Bank (Tampil di Invoice)</h4>
                  <div className="grid sm:grid-cols-2 gap-3 mb-3">
                    <Input 
                      label="Nama Bank" 
                      placeholder="Cth: BCA"
                      value={orgForm.settings.bank_info.bank_name} 
                      onChange={(e) => setOrgForm({...orgForm, settings: {...orgForm.settings, bank_info: {...orgForm.settings.bank_info, bank_name: e.target.value}}})} 
                    />
                    <Input 
                      label="Nomor Rekening" 
                      value={orgForm.settings.bank_info.account_number} 
                      onChange={(e) => setOrgForm({...orgForm, settings: {...orgForm.settings, bank_info: {...orgForm.settings.bank_info, account_number: e.target.value}}})} 
                    />
                  </div>
                  <Input 
                    label="Atas Nama (A/N)" 
                    value={orgForm.settings.bank_info.account_name} 
                    onChange={(e) => setOrgForm({...orgForm, settings: {...orgForm.settings, bank_info: {...orgForm.settings.bank_info, account_name: e.target.value}}})} 
                  />
                </div>

                <Button type="submit" loading={updateOrg.isPending}>Simpan Pengaturan Organisasi</Button>
              </form>
            </Card>
          </div>
        )}

        {/* Payment Methods Tab */}
        {activeTab === 'payment-methods' && (role === 'owner' || role === 'admin') && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-[16px] font-bold text-gray-900">Metode Pembayaran</h3>
                <p className="text-[13px] text-gray-500 mt-0.5">Kelola daftar metode pembayaran yang tampil saat update status pembayaran PO</p>
              </div>
              <Button onClick={handleAddPaymentMethod}>
                <Plus size={15} /> Tambah Metode
              </Button>
            </div>

            {pmLoading ? (
              <Card><div className="animate-pulse space-y-3">{[1,2,3].map(i => <div key={i} className="h-14 bg-gray-100 rounded-lg" />)}</div></Card>
            ) : paymentMethods.length === 0 ? (
              <Card>
                <div className="text-center py-8 text-gray-500">
                  <CreditCard size={40} className="mx-auto mb-2 opacity-50" />
                  <p className="font-semibold">Belum ada metode pembayaran</p>
                  <p className="text-[13px] mt-1">Tambahkan metode bayar seperti Transfer BCA, QRIS, Cash, dll.</p>
                  <Button className="mt-4" onClick={handleAddPaymentMethod}>
                    <Plus size={15} /> Tambah Metode Pertama
                  </Button>
                </div>
              </Card>
            ) : (
              <Card padding="none">
                <div className="divide-y divide-gray-100">
                  {paymentMethods.map((method, index) => (
                    <div key={index} className="flex items-center gap-3 px-5 py-4 hover:bg-gray-50 transition-colors">
                      {/* Reorder */}
                      <div className="flex flex-col gap-0.5">
                        <button
                          onClick={() => handleMovePaymentMethod(index, 'up')}
                          disabled={index === 0}
                          className="p-0.5 rounded text-gray-400 hover:text-gray-600 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                          title="Pindah ke atas"
                        >
                          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M6 3L10 7H2L6 3Z" fill="currentColor"/></svg>
                        </button>
                        <button
                          onClick={() => handleMovePaymentMethod(index, 'down')}
                          disabled={index === paymentMethods.length - 1}
                          className="p-0.5 rounded text-gray-400 hover:text-gray-600 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
                          title="Pindah ke bawah"
                        >
                          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M6 9L2 5H10L6 9Z" fill="currentColor"/></svg>
                        </button>
                      </div>

                      {/* Icon */}
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 ${
                        method.is_active ? 'bg-emerald-100 text-emerald-600' : 'bg-gray-100 text-gray-400'
                      }`}>
                        <CreditCard size={18} />
                      </div>

                      {/* Name */}
                      <div className="flex-1 min-w-0">
                        <span className={`font-semibold text-[14px] ${method.is_active ? 'text-gray-900' : 'text-gray-400 line-through'}`}>{method.name}</span>
                      </div>

                      {/* Active Toggle */}
                      <button
                        onClick={() => handleTogglePaymentMethod(index)}
                        className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none ${
                          method.is_active ? 'bg-emerald-500' : 'bg-gray-300'
                        }`}
                        title={method.is_active ? 'Nonaktifkan' : 'Aktifkan'}
                      >
                        <span className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform shadow-sm ${
                          method.is_active ? 'translate-x-6' : 'translate-x-1'
                        }`} />
                      </button>

                      {/* Edit */}
                      <button
                        onClick={() => handleEditPaymentMethod(index)}
                        className="p-1.5 rounded-lg text-gray-400 hover:text-primary hover:bg-primary/5 transition-colors"
                        title="Edit"
                      >
                        <Pencil size={15} />
                      </button>

                      {/* Delete */}
                      <button
                        onClick={() => handleDeletePaymentMethod(index)}
                        className="p-1.5 rounded-lg text-gray-400 hover:text-red-500 hover:bg-red-50 transition-colors"
                        title="Hapus"
                      >
                        <Trash2 size={15} />
                      </button>
                    </div>
                  ))}
                </div>
              </Card>
            )}

            <Card>
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="7" stroke="#3B82F6" strokeWidth="1.5"/><path d="M8 5v4M8 11h.01" stroke="#3B82F6" strokeWidth="1.5" strokeLinecap="round"/></svg>
                </div>
                <div>
                  <p className="text-[13px] font-semibold text-gray-900">Tips</p>
                  <p className="text-[12px] text-gray-500 mt-0.5">Metode bayar yang aktif akan muncul sebagai pilihan di dialog "Update Status Pembayaran" pada detail PO. Anda tetap bisa mengetik metode lain secara manual.</p>
                </div>
              </div>
            </Card>
          </div>
        )}

        {/* Online Store Tab */}
        {activeTab === 'online-store' && (role === 'owner' || role === 'admin') && (
          <OnlineStoreTab />
        )}

        {/* Team Tab */}
        {activeTab === 'team' && (role === 'owner' || role === 'admin') && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="text-[16px] font-bold text-gray-900">Anggota Tim</h3>
                <p className="text-[13px] text-gray-500 mt-0.5">{members.length} anggota di organisasi ini</p>
              </div>
              <Button onClick={() => setInviteOpen(true)}>
                <UserPlus size={15} /> Tambah Anggota
              </Button>
            </div>

            {/* Quota banner for free users */}
            {!isPremiumOrAdmin && teamUsage && (
              <div className="flex items-center justify-between bg-amber-50 border border-amber-200 rounded-xl px-4 py-2.5">
                <span className="text-sm text-amber-800">
                  Anggota tim: <strong>{teamUsage.current}/{teamUsage.limit}</strong>
                </span>
                {teamUsage.current >= (teamUsage.limit ?? Infinity) && (
                  <span className="inline-flex items-center gap-1 text-xs font-semibold text-primary">
                    <Crown size={12} /> Upgrade Premium
                  </span>
                )}
              </div>
            )}

            {teamLoading ? (
              <Card><div className="animate-pulse space-y-3">{[1,2,3].map(i => <div key={i} className="h-14 bg-gray-100 rounded-lg" />)}</div></Card>
            ) : members.length === 0 ? (
              <Card>
                <div className="text-center py-8 text-gray-500">
                  <Users size={40} className="mx-auto mb-2 opacity-50" />
                  <p className="font-semibold">Belum ada anggota</p>
                  <p className="text-[13px] mt-1">Tambahkan anggota tim untuk berkolaborasi</p>
                </div>
              </Card>
            ) : (
              <Card padding="none">
                <div className="divide-y divide-gray-100">
                  {members.map((member) => {
                    const config = ROLE_CONFIG[member.role] ?? { label: 'Viewer', color: '#9CA3AF', bgColor: '#F9FAFB', icon: Eye };
                    const isCurrentUser = member.user_id === user?.id?.toString();
                    const RoleIcon = config.icon;

                    return (
                      <div key={member.id} className="flex items-center gap-3 px-5 py-4 hover:bg-gray-50 transition-colors">
                        {/* Avatar */}
                        <div className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold text-sm flex-shrink-0" style={{ backgroundColor: config.color }}>
                          {getInitials(member.user_name)}
                        </div>

                        {/* Info */}
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2">
                            <span className="font-semibold text-[14px] text-gray-900 truncate">{member.user_name}</span>
                            {isCurrentUser && <span className="text-[10px] text-gray-400 font-medium">(Anda)</span>}
                          </div>
                          <div className="text-[12px] text-gray-500 truncate">{member.user_email}</div>
                        </div>

                        {/* Role Badge */}
                        <span
                          className="inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-[11px] font-semibold"
                          style={{ backgroundColor: config.bgColor, color: config.color }}
                        >
                          <RoleIcon size={12} />
                          {config.label}
                        </span>

                        {/* Role Selector (for owner/admin to change others' roles) */}
                        {!isCurrentUser && role === 'owner' && (
                          <select
                            value={member.role}
                            onChange={(e) => updateRole.mutate({ id: member.id, role: e.target.value as MemberRole })}
                            className="text-[12px] border border-gray-200 rounded-md px-2 py-1 bg-white text-gray-700 focus:outline-none focus:border-primary"
                          >
                            <option value="owner">Owner</option>
                            <option value="admin">Admin</option>
                            <option value="staff">Staff</option>
                            <option value="viewer">Viewer</option>
                          </select>
                        )}

                        {/* Remove Button */}
                        {!isCurrentUser && (role === 'owner' || (role === 'admin' && member.role !== 'owner')) && (
                          <button
                            onClick={() => {
                              if (window.confirm(`Hapus ${member.user_name} dari organisasi?`)) {
                                removeMember.mutate(member.id);
                              }
                            }}
                            className="p-1.5 rounded-lg text-gray-400 hover:text-red-500 hover:bg-red-50 transition-colors"
                            title="Hapus anggota"
                          >
                            <Trash2 size={15} />
                          </button>
                        )}
                      </div>
                    );
                  })}
                </div>
              </Card>
            )}
          </div>
        )}
      </div>

      {/* Invite Dialog */}
      <Dialog open={inviteOpen} onOpenChange={setInviteOpen}>
        <DialogContent>
          <DialogHeader><DialogTitle>Tambah Anggota Tim</DialogTitle></DialogHeader>
          <form onSubmit={(e) => { e.preventDefault(); inviteMember.mutate(inviteForm); }} className="space-y-4">
            <Input
              label="Email"
              type="email"
              placeholder="email@contoh.com"
              value={inviteForm.email}
              onChange={(e) => setInviteForm({ ...inviteForm, email: e.target.value })}
              required
            />
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-2">Pilih Role</label>
              <div className="space-y-2">
                {INVITE_ROLES.map(r => (
                  <label
                    key={r.value}
                    className={`flex items-center gap-3 p-3 rounded-lg border cursor-pointer transition-all ${
                      inviteForm.role === r.value
                        ? 'border-primary bg-primary-50'
                        : 'border-gray-200 hover:border-gray-300'
                    }`}
                  >
                    <input
                      type="radio"
                      name="role"
                      value={r.value}
                      checked={inviteForm.role === r.value}
                      onChange={() => setInviteForm({ ...inviteForm, role: r.value as MemberRole })}
                      className="accent-primary"
                    />
                    <span className="text-[13px] text-gray-700">{r.label}</span>
                  </label>
                ))}
              </div>
            </div>
            <p className="text-[11px] text-gray-400">
              User harus sudah terdaftar di PO Scheduler. Jika belum, minta mereka register terlebih dahulu.
            </p>
            <div className="flex justify-end gap-2 pt-2">
              <Button variant="secondary" type="button" onClick={() => setInviteOpen(false)}>Batal</Button>
              <Button type="submit" loading={inviteMember.isPending}>Tambahkan</Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>

      {/* Payment Method Edit Dialog */}
      <Dialog open={pmEditOpen} onOpenChange={setPmEditOpen}>
        <DialogContent>
          <DialogHeader><DialogTitle>{pmEditIndex !== null ? 'Edit Metode Bayar' : 'Tambah Metode Bayar'}</DialogTitle></DialogHeader>
          <form onSubmit={(e) => { e.preventDefault(); handleSavePaymentMethod(); }} className="space-y-4">
            <Input
              label="Nama Metode Bayar"
              placeholder="Cth: Transfer BCA, QRIS, Cash, GoPay"
              value={pmForm.name}
              onChange={(e) => setPmForm({ ...pmForm, name: e.target.value })}
              required
            />
            <label className="flex items-center gap-3 p-3 rounded-lg border border-gray-200 cursor-pointer hover:border-gray-300 transition-colors">
              <input
                type="checkbox"
                checked={pmForm.is_active}
                onChange={(e) => setPmForm({ ...pmForm, is_active: e.target.checked })}
                className="accent-primary w-4 h-4"
              />
              <div>
                <span className="text-[13px] font-semibold text-gray-700">Aktif</span>
                <p className="text-[11px] text-gray-500">Metode ini akan muncul di pilihan saat update pembayaran PO</p>
              </div>
            </label>
            <div className="flex justify-end gap-2 pt-2">
              <Button variant="secondary" type="button" onClick={() => setPmEditOpen(false)}>Batal</Button>
              <Button type="submit" loading={updatePaymentMethods.isPending}>
                {pmEditIndex !== null ? 'Simpan Perubahan' : 'Tambah Metode'}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
