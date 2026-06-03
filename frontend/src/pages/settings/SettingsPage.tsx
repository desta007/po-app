import { useState } from 'react';
import { useAuth } from '@/contexts/auth-context';
import { settingsApi } from '@/api/settings';
import { PageHeader } from '@/components/layout/page-header';
import { Card } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';

export default function SettingsPage() {
  const { user, refreshUser } = useAuth();
  const queryClient = useQueryClient();

  const [profileForm, setProfileForm] = useState({
    full_name: user?.full_name || '',
    phone: user?.phone || '',
  });

  const { data: orgData } = useQuery({
    queryKey: ['settings', 'org'],
    queryFn: () => settingsApi.getOrganization(),
  });

  const [orgForm, setOrgForm] = useState({ name: '', phone: '', address: '' });
  const org = orgData?.data?.data;
  if (org && !orgForm.name) {
    setOrgForm({ name: org.name, phone: org.phone || '', address: org.address || '' });
  }

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

  return (
    <div>
      <PageHeader title="Pengaturan" description="Kelola profil dan organisasi Anda" />

      <div className="space-y-5 max-w-2xl">
        {/* Profile */}
        <Card>
          <h3 className="text-[14px] font-bold text-gray-900 mb-4">👤 Profil Saya</h3>
          <form onSubmit={(e) => { e.preventDefault(); updateProfile.mutate(profileForm); }} className="space-y-3">
            <Input label="Nama Lengkap" value={profileForm.full_name} onChange={(e) => setProfileForm({...profileForm, full_name: e.target.value})} />
            <Input label="No. HP" value={profileForm.phone} onChange={(e) => setProfileForm({...profileForm, phone: e.target.value})} />
            <Input label="Email" value={user?.email || ''} disabled />
            <Button type="submit" loading={updateProfile.isPending}>Simpan Profil</Button>
          </form>
        </Card>

        {/* Organization */}
        <Card>
          <h3 className="text-[14px] font-bold text-gray-900 mb-4">🏢 Organisasi / Bisnis</h3>
          <form onSubmit={(e) => { e.preventDefault(); updateOrg.mutate(orgForm); }} className="space-y-3">
            <Input label="Nama Bisnis" value={orgForm.name} onChange={(e) => setOrgForm({...orgForm, name: e.target.value})} />
            <Input label="No. Telepon" value={orgForm.phone} onChange={(e) => setOrgForm({...orgForm, phone: e.target.value})} />
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1.5">Alamat</label>
              <textarea className="w-full border border-gray-300 rounded-[6px] px-3 py-2.5 text-[14px] min-h-[80px] focus:outline-none focus:border-primary focus:ring-3 focus:ring-primary-50" value={orgForm.address} onChange={(e) => setOrgForm({...orgForm, address: e.target.value})} />
            </div>
            <Button type="submit" loading={updateOrg.isPending}>Simpan Organisasi</Button>
          </form>
        </Card>
      </div>
    </div>
  );
}
