import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../cubits/partner_signup_cubit.dart';
import '../cubits/partner_signup_state.dart';

class PartnerSignupScreen extends StatefulWidget {
  const PartnerSignupScreen({super.key});

  @override
  State<PartnerSignupScreen> createState() => _PartnerSignupScreenState();
}

class _PartnerSignupScreenState extends State<PartnerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Partner Type
  String _selectedPartnerType = AppConstants.userTypeRestaurant;

  // Restaurant/Market Specific
  File? _restaurantImage;
  File? _commercialRegistration;
  LatLng? _selectedLocation;

  // Driver Specific
  String _vehicleType = 'motorcycle';
  final _vehiclePlateController = TextEditingController();
  File? _personalImage;
  File? _driverLicense;
  File? _vehicleLicense;
  File? _vehiclePhoto;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      context.showErrorSnackBar(context.l10n.failedToPickImage(e.toString()));
    }
    return null;
  }

  Future<void> _showImageSourceSelection(Function(File) onImageSelected) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.l10n.camera ?? 'Camera'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _pickImage(ImageSource.camera);
                if (file != null) onImageSelected(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.l10n.gallery ?? 'Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final file = await _pickImage(ImageSource.gallery);
                if (file != null) onImageSelected(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _signup() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<PartnerSignupCubit>();

    if (_selectedPartnerType == AppConstants.userTypeDriver) {
      if (_personalImage == null ||
          _driverLicense == null ||
          _vehicleLicense == null ||
          _vehiclePhoto == null) {
        context.showErrorSnackBar(context.l10n.pleaseUploadAllDriverDocuments);
        return;
      }
      cubit.signupDriver(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        vehicleType: _vehicleType,
        vehiclePlate: _vehiclePlateController.text.trim(),
        personalImageFile: _personalImage!,
        driverLicenseFile: _driverLicense!,
        vehicleLicenseFile: _vehicleLicense!,
        vehiclePhotoFile: _vehiclePhoto!,
      );
    } else {
      // Restaurant or Market
      if (_commercialRegistration == null) {
        context.showErrorSnackBar(
          context.l10n.pleaseUploadCommercialRegistration,
        );
        return;
      }

      // For simplicity in signup, we use some defaults or placeholder values for restaurant specific fields
      // In a real app, you'd add more fields or a second step
      cubit.signupRestaurantOrMarket(
        name: _nameController.text.trim(),
        description: context.l10n.newPartnerType(_selectedPartnerType),
        address: context.l10n.signupAddress,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        categoryIds: [], // To be managed by admin later
        location: _selectedLocation ?? const LatLng(30.0444, 31.2357),
        imageFile: _restaurantImage,
        deliveryFee: 10.0,
        minOrderAmount: 50.0,
        estimatedDeliveryTime: 30,
        commercialRegistrationPhotoFile: _commercialRegistration,
        userType: _selectedPartnerType,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF27AE60),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<PartnerSignupCubit, PartnerSignupState>(
            listener: (context, state) {
              if (state is PartnerSignupSuccess) {
                context.showSuccessSnackBar(state.message);
                context.pushReplacement('/login');
              } else if (state is PartnerSignupError) {
                context.showErrorSnackBar(state.message);
              }
            },
            builder: (context, state) {
              if (state is PartnerSignupLoading) {
                return LoadingWidget(
                  message: state.message ?? context.l10n.loading,
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 20),

                      // Selection of Partner Type
                      _buildPartnerTypeSelection(),
                      const SizedBox(height: 20),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildCommonFields(),
                            const Divider(height: 32),
                            if (_selectedPartnerType ==
                                AppConstants.userTypeDriver)
                              _buildDriverFields()
                            else
                              _buildRestaurantMarketFields(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF27AE60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          context.l10n.signUpAsPartner,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildFooter(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/logo.jpeg',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          context.l10n.joinAsPartner,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          context.l10n.startGrowingWithWassly,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPartnerTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTypeOption(
            context.l10n.restaurant,
            AppConstants.userTypeRestaurant,
          ),
          _buildTypeOption(context.l10n.driver, AppConstants.userTypeDriver),
          _buildTypeOption(context.l10n.market, AppConstants.userTypeMarket),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String label, String value) {
    bool isSelected = _selectedPartnerType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPartnerType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF27AE60) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          validator: Validators.validateName,
          decoration: InputDecoration(
            labelText: context.l10n.fullNameStoreName,
            prefixIcon: Icon(Icons.person_outlined),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          decoration: InputDecoration(
            labelText: context.l10n.email,
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        IntlPhoneField(
          initialCountryCode: 'EG',
          decoration: InputDecoration(
            labelText: context.l10n.phoneNumber,
            prefixIcon: const Icon(Icons.phone_outlined),
            counterText: '',
          ),
          onChanged: (phone) => _phoneController.text = phone.completeNumber,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: Validators.validatePassword,
          decoration: InputDecoration(
            labelText: context.l10n.password,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _passwordController.text,
          ),
          decoration: InputDecoration(
            labelText: context.l10n.confirmPassword,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantMarketFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.businessDocuments,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildImagePicker(
          label: context.l10n.commercialRegistrationPhoto,
          file: _commercialRegistration,
          onTap: () => _showImageSourceSelection((file) {
            setState(() => _commercialRegistration = file);
          }),
        ),
        const SizedBox(height: 16),
        _buildImagePicker(
          label: context.l10n.storeLogoOptional,
          file: _restaurantImage,
          onTap: () => _showImageSourceSelection((file) {
            setState(() => _restaurantImage = file);
          }),
        ),
      ],
    );
  }

  Widget _buildDriverFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.vehicleInfo,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _vehicleType,
          items: [
            DropdownMenuItem(
              value: 'motorcycle',
              child: Text(context.l10n.motorcycle),
            ),
            DropdownMenuItem(value: 'car', child: Text(context.l10n.car)),
            DropdownMenuItem(
              value: 'bicycle',
              child: Text(context.l10n.bicycle),
            ),
          ],
          onChanged: (val) => setState(() => _vehicleType = val!),
          decoration: InputDecoration(
            labelText: context.l10n.vehicleType,
            prefixIcon: Icon(Icons.directions_bike),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _vehiclePlateController,
          decoration: InputDecoration(
            labelText: context.l10n.vehiclePlateNumber,
            prefixIcon: Icon(Icons.pin_outlined),
          ),
          validator: (val) =>
              (val == null || val.isEmpty) ? context.l10n.fieldRequired : null,
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.driverDocuments,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildImagePicker(
          label: context.l10n.personalPhoto,
          file: _personalImage,
          onTap: () => _showImageSourceSelection((file) {
            setState(() => _personalImage = file);
          }),
        ),
        const SizedBox(height: 12),
        _buildImagePicker(
          label: context.l10n.driverLicense,
          file: _driverLicense,
          onTap: () => _showImageSourceSelection((file) {
            setState(() => _driverLicense = file);
          }),
        ),
        const SizedBox(height: 12),
        _buildImagePicker(
          label: context.l10n.vehicleLicense,
          file: _vehicleLicense,
          onTap: () => _showImageSourceSelection((file) {
            setState(() => _vehicleLicense = file);
          }),
        ),
        const SizedBox(height: 12),
        _buildImagePicker(
          label: context.l10n.vehiclePhoto,
          file: _vehiclePhoto,
          onTap: () => _showImageSourceSelection((file) {
            setState(() => _vehiclePhoto = file);
          }),
        ),
      ],
    );
  }

  Widget _buildImagePicker({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file != null ? context.l10n.photoAttached : label,
                style: TextStyle(
                  color: file != null ? Colors.green : Colors.grey,
                ),
              ),
            ),
            if (file != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  file,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10n.alreadyHaveAccount,
            style: TextStyle(color: Colors.white),
          ),
          TextButton(
            onPressed: () => context.push('/login'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(
              context.l10n.login,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
