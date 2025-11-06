'use client';

import { AuthGuard } from '@/components/auth/AuthGuard';
import { DashboardLayout } from '@/components/dashboard/DashboardLayout';

export default function DashboardPage() {
  return (
    <AuthGuard>
      <DashboardLayout>
        <div className="mt-8">
          {/* Additional dashboard content can be added here */}
        </div>
      </DashboardLayout>
    </AuthGuard>
  );
}