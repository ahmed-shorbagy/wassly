import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/extensions.dart';
import '../cubits/admin_cubit.dart';
import '../widgets/partner_request_card.dart';
import 'admin_partner_detail_screen.dart';

class AdminPendingPartnersScreen extends StatefulWidget {
  const AdminPendingPartnersScreen({super.key});

  @override
  State<AdminPendingPartnersScreen> createState() =>
      _AdminPendingPartnersScreenState();
}

class _AdminPendingPartnersScreenState
    extends State<AdminPendingPartnersScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AdminCubit>().getPendingPartners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is PartnerApprovedSuccess) {
            context.showSuccessSnackBar('Request processed successfully!');
            _loadData(); // Refresh list
          } else if (state is AdminError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingPartnersLoaded) {
            if (state.pendingPartners.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All caught up!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('No pending partner registrations.'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.pendingPartners.length,
                itemBuilder: (context, index) {
                  final partner = state.pendingPartners[index];
                  return PartnerRequestCard(
                    partner: partner,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminPartnerDetailScreen(partner: partner),
                        ),
                      ).then((_) {
                        // Refresh when coming back, in case action was taken
                        // Although BlocListener handles it if action was taken IN this screen
                        // But if action was taken in DetailScreen, we might need to refresh
                        // Actually, DetailScreen calls cubit methods which emit new states.
                        // So the BlocConsumer here will rebuild.
                        // But we should ensuring data is fresh.
                        _loadData();
                      });
                    },
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
