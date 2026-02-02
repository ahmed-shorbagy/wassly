import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wassly/l10n/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../drivers/domain/entities/driver_entity.dart';
import '../../../drivers/presentation/cubits/driver_cubit.dart';

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DriverEntity> _filteredDrivers = [];
  List<DriverEntity> _allDrivers = [];

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    _searchController.addListener(_filterDrivers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterDrivers);
    _searchController.dispose();
    super.dispose();
  }

  void _loadDrivers() {
    context.read<DriverCubit>().loadAllDrivers();
  }

  void _filterDrivers() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredDrivers = List.from(_allDrivers);
      } else {
        _filteredDrivers = _allDrivers.where((driver) {
          final nameMatch = driver.name.toLowerCase().contains(query);
          final emailMatch = driver.email.toLowerCase().contains(query);
          final phoneMatch = driver.phone.toLowerCase().contains(query);
          final vehicleMatch =
              driver.vehicleModel?.toLowerCase().contains(query) ?? false;
          final plateMatch =
              driver.vehiclePlateNumber?.toLowerCase().contains(query) ?? false;
          return nameMatch ||
              emailMatch ||
              phoneMatch ||
              vehicleMatch ||
              plateMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/admin');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.driverManagement),
          backgroundColor: Colors.purple,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/admin/drivers/create'),
              tooltip: l10n.addDriver,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDrivers,
              tooltip: l10n.refresh,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: StatefulBuilder(
                builder: (context, setState) => TextField(
                  controller: _searchController,
                  onChanged: (_) {
                    setState(() {});
                    _filterDrivers();
                  },
                  decoration: InputDecoration(
                    hintText: l10n.searchDriversHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                              _filterDrivers();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            // Drivers List
            Expanded(
              child: BlocConsumer<DriverCubit, DriverState>(
                listener: (context, state) {
                  if (state is DriversLoaded) {
                    setState(() {
                      _allDrivers = state.drivers;
                      _filteredDrivers = state.drivers;
                    });
                    _filterDrivers();
                  } else if (state is DriverError) {
                    context.showErrorSnackBar(state.message);
                  } else if (state is DriverDeleted) {
                    context.showSuccessSnackBar(l10n.driverDeletedSuccessfully);
                  }
                },
                builder: (context, state) {
                  if (state is DriverLoading && _allDrivers.isEmpty) {
                    return const LoadingWidget();
                  }

                  if (state is DriverError && _allDrivers.isEmpty) {
                    return ErrorDisplayWidget(
                      message: state.message,
                      onRetry: _loadDrivers,
                    );
                  }

                  if (_filteredDrivers.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadDrivers(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = _filteredDrivers[index];
                        return _buildDriverCard(context, driver);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delivery_dining,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? l10n.noDriversFound
                : l10n.noDriversYet,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          if (_searchController.text.isEmpty)
            ElevatedButton.icon(
              onPressed: () => context.push('/admin/drivers/create'),
              icon: const Icon(Icons.add),
              label: Text(l10n.addFirstDriver),
            ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(BuildContext context, DriverEntity driver) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/admin/drivers/edit/${driver.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Driver Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    driver.personalImageUrl != null &&
                        driver.personalImageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: driver.personalImageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: AppColors.surface,
                          child: const Icon(Icons.person),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: AppColors.surface,
                        child: const Icon(Icons.person),
                      ),
              ),
              const SizedBox(width: 16),
              // Driver Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      driver.phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (driver.vehicleModel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${driver.vehicleModel} • ${driver.vehiclePlateNumber ?? l10n.nA}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status Badge
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: driver.isActive
                          ? AppColors.success
                          : AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      driver.isActive ? l10n.active : l10n.inactive,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: driver.isOnline ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      driver.isOnline ? l10n.online : l10n.offline,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
