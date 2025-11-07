import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/route_constants.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_event.dart';
import 'package:mobile/features/auth/presentation/bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.push(RouteConstants.settings),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Refresh user data
              context.read<AuthBloc>().add(const CheckAuthStatusEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Card
                  _UserProfileCard(user: user),
                  const SizedBox(height: 24),

                  // Profile Status Card
                  _ProfileStatusCard(user: user),
                  const SizedBox(height: 24),

                  // Azure AD Information Card
                  _AzureInfoCard(user: user),
                  const SizedBox(height: 24),

                  // Health Stats Card (if profile complete)
                  if (user.isProfileComplete) ...[
                    _HealthStatsCard(user: user),
                    const SizedBox(height: 24),
                  ],

                  // Quick Actions
                  _QuickActionsSection(),
                  const SizedBox(height: 24),

                  // Logout Button
                  _LogoutButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// User Profile Card Widget
class _UserProfileCard extends StatelessWidget {
  final User user;

  const _UserProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              backgroundImage:
                  user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child:
                  user.avatarUrl == null
                      ? Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      )
                      : null,
            ),
            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user.email != null)
                    Text(
                      user.email!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (user.phoneNumber != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.phoneNumber!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),

            // Edit Button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.push(RouteConstants.editProfile),
              tooltip: 'Edit Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Status Card Widget
class _ProfileStatusCard extends StatelessWidget {
  final User user;

  const _ProfileStatusCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isComplete = user.isProfileComplete;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isComplete ? Colors.green.shade50 : Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isComplete ? Icons.check_circle : Icons.warning,
              color: isComplete ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isComplete ? 'Profile Complete' : 'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isComplete
                              ? Colors.green.shade900
                              : Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isComplete
                        ? 'All health information is up to date'
                        : 'Add your health details for better recommendations',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isComplete
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            if (!isComplete)
              TextButton(
                onPressed: () => context.push(RouteConstants.editProfile),
                child: const Text('Complete'),
              ),
          ],
        ),
      ),
    );
  }
}

// Azure AD Info Card Widget
class _AzureInfoCard extends StatelessWidget {
  final User user;

  const _AzureInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_user,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Azure AD Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.badge, label: 'User ID', value: user.id),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email ?? 'Not provided',
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Member Since',
              value: _formatDate(user.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Health Stats Card Widget
class _HealthStatsCard extends StatelessWidget {
  final User user;

  const _HealthStatsCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Health Overview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _HealthStatItem(
                    icon: Icons.cake,
                    label: 'Age',
                    value: user.age?.toString() ?? '-',
                    unit: 'years',
                  ),
                ),
                Expanded(
                  child: _HealthStatItem(
                    icon: Icons.wc,
                    label: 'Gender',
                    value: _getGenderString(user.gender),
                    unit: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _HealthStatItem(
                    icon: Icons.height,
                    label: 'Height',
                    value: user.height?.toStringAsFixed(0) ?? '-',
                    unit: 'cm',
                  ),
                ),
                Expanded(
                  child: _HealthStatItem(
                    icon: Icons.monitor_weight,
                    label: 'Weight',
                    value: user.weight?.toStringAsFixed(1) ?? '-',
                    unit: 'kg',
                  ),
                ),
              ],
            ),
            if (user.calculatedBmi != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getBmiColor(user.calculatedBmi!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: _getBmiColor(user.calculatedBmi!),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'BMI',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          user.calculatedBmi!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getBmiColor(user.calculatedBmi!),
                          ),
                        ),
                        Text(
                          user.bmiCategory ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getGenderString(Gender? gender) {
    if (gender == null) return '-';
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}

// Health Stat Item Widget
class _HealthStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _HealthStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Info Row Widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Quick Actions Section Widget
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.calendar_today,
                label: 'Appointments',
                color: Colors.blue,
                onTap: () {
                  // Navigate to appointments
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.medical_services,
                label: 'Records',
                color: Colors.green,
                onTap: () {
                  // Navigate to medical records
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Logout Button Widget
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(const LogoutEvent());
                      },
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          );
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Logout', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
