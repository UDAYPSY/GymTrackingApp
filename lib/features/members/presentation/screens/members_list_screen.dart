import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_manager/core/constants/app_constants.dart';
import 'package:gym_manager/core/theme/app_theme.dart';
import 'package:gym_manager/core/utils/formatters.dart';
import 'package:gym_manager/features/members/models/member_model.dart';
import 'package:gym_manager/features/members/repositories/member_repository.dart';
import 'package:gym_manager/features/members/presentation/screens/add_member_screen.dart';
import 'package:gym_manager/features/members/presentation/screens/member_detail_screen.dart';

class MembersListScreen extends ConsumerStatefulWidget {
  const MembersListScreen({super.key});

  @override
  ConsumerState<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends ConsumerState<MembersListScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add Member',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMemberScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Member', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMemberScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by member name or phone...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Active'),
                _buildFilterChip('Expiring Soon'),
                _buildFilterChip('Expired'),
                _buildFilterChip('Frozen'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Members List
          Expanded(
            child: membersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (members) {
                // Apply filters
                final filtered = members.where((m) {
                  final matchesSearch = m.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      m.phone.contains(_searchQuery);

                  if (!matchesSearch) return false;

                  if (_selectedFilter == 'Active') return m.status == MemberStatus.active;
                  if (_selectedFilter == 'Expiring Soon') return m.isExpiringSoon;
                  if (_selectedFilter == 'Expired') return m.hasExpired || m.status == MemberStatus.expired;
                  if (_selectedFilter == 'Frozen') return m.isFrozen;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: Colors.grey.shade600),
                        const SizedBox(height: 12),
                        const Text(
                          'No members found',
                          style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final member = filtered[index];
                    return _buildMemberCard(context, member);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primary.withAlpha(60),
        checkmarkColor: AppTheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          setState(() => _selectedFilter = label);
        },
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, MemberModel member) {
    Color statusColor;
    String statusText;

    if (member.isFrozen) {
      statusColor = Colors.blue;
      statusText = 'FROZEN';
    } else if (member.hasExpired) {
      statusColor = AppTheme.error;
      statusText = 'EXPIRED';
    } else if (member.isExpiringSoon) {
      statusColor = AppTheme.warning;
      statusText = '${member.daysRemaining} DAYS LEFT';
    } else {
      statusColor = AppTheme.success;
      statusText = 'ACTIVE';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemberDetailScreen(member: member),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primary.withAlpha(40),
                    child: Text(
                      member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${member.memberCode} • ${member.phone}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 0.8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.planName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Expires: ${Formatters.formatDate(member.endDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (member.dueAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Due: ${Formatters.formatCurrency(member.dueAmount)}',
                        style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone, color: AppTheme.secondary),
                        iconSize: 22,
                        tooltip: 'Call Member',
                        onPressed: () => Formatters.makePhoneCall(member.phone),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat, color: AppTheme.success),
                        iconSize: 22,
                        tooltip: 'WhatsApp Reminder',
                        onPressed: () {
                          final msg =
                              'Hi ${member.name}, friendly reminder from GymManager. Your membership (${member.planName}) validity ends on ${Formatters.formatDate(member.endDate)}. ${member.dueAmount > 0 ? "Pending dues: ₹${member.dueAmount}." : ""} Please renew to continue your training!';
                          Formatters.openWhatsApp(
                            phone: member.phone,
                            message: msg,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
