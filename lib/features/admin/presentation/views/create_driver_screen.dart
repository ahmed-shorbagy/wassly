import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/back_button_handler.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../drivers/presentation/cubits/driver_cubit.dart';

class CreateDriverScreen extends StatefulWidget {
  const CreateDriverScreen({super.key});

  @override
  State<CreateDriverScreen> createState() => _CreateDriverScreenState();
}

class _CreateDriverScreenState extends State<CreateDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _vehiclePlateController = TextEditingController();

  File? _personalImage;
  File? _driverLicenseImage;
  File? _vehicleLicenseImage;
  File? _vehiclePhotoImage;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _vehicleTypes = ['motorcycle', 'car', 'truck', 'van'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _vehicleTypeController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          switch (type) {
            case 'personal':
              _personalImage = File(image.path);
              break;
            case 'driverLicense':
              _driverLicenseImage = File(image.path);
              break;
            case 'vehicleLicense':
              _vehicleLicenseImage = File(image.path);
              break;
            case 'vehiclePhoto':
              _vehiclePhotoImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      context.showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog(String type) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectImageSource),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickImage(ImageSource.camera, type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
              onTap: () {
                Navigator.pop(dialogContext);
                _pickImage(ImageSource.gallery, type);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_personalImage == null) {
      context.showErrorSnackBar(l10n.pleaseSelectPersonalImage);
      return;
    }

    if (_driverLicenseImage == null) {
      context.showErrorSnackBar(l10n.pleaseSelectDriverLicense);
      return;
    }

    if (_vehicleLicenseImage == null) {
      context.showErrorSnackBar(l10n.pleaseSelectVehicleLicense);
      return;
    }

    if (_vehiclePhotoImage == null) {
      context.showErrorSnackBar(l10n.pleaseSelectVehiclePhoto);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      context.showErrorSnackBar(l10n.passwordsDoNotMatch);
      return;
    }

    context.read<DriverCubit>().createDriver(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      vehicleType: _vehicleTypeController.text.trim(),
      vehicleModel: _vehicleModelController.text.trim(),
      vehicleColor: _vehicleColorController.text.trim(),
      vehiclePlateNumber: _vehiclePlateController.text.trim(),
      personalImageFile: _personalImage!,
      driverLicenseFile: _driverLicenseImage!,
      vehicleLicenseFile: _vehicleLicenseImage!,
      vehiclePhotoFile: _vehiclePhotoImage!,
    );
  }

  bool get _hasUnsavedChanges {
    return _nameController.text.isNotEmpty ||
        _emailController.text.isNotEmpty ||
        _passwordController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty ||
        _addressController.text.isNotEmpty ||
        _personalImage != null ||
        _driverLicenseImage != null ||
        _vehicleLicenseImage != null ||
        _vehiclePhotoImage != null;
  }

  @override
  Widget build(BuildContext context) {
    return UnsavedChangesHandler(
      hasUnsavedChanges: _hasUnsavedChanges,
      child: Scaffold(
        appBar: AppBar(
          title: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(l10n.createDriver);
            },
          ),
          backgroundColor: Colors.purple,
        ),
        body: BlocConsumer<DriverCubit, DriverState>(
          listener: (context, state) {
            if (state is DriverCreated) {
              // Show credentials dialog
              final l10n = AppLocalizations.of(context)!;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.driverCreatedSuccessfully),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pleaseProvideTheseCredentials,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildCredentialRow(
                        '${l10n.email}:',
                        _emailController.text,
                      ),
                      const SizedBox(height: 8),
                      _buildCredentialRow(
                        '${l10n.password}:',
                        _passwordController.text,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noteDriverCanChangePassword,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        context.read<DriverCubit>().resetState();
                        context.go('/admin/drivers');
                      },
                      child: Text(l10n.ok),
                    ),
                  ],
                ),
              );
            } else if (state is DriverError) {
              context.showErrorSnackBar(state.message);
            }
          },
          builder: (context, state) {
            final l10n = AppLocalizations.of(context)!;

            if (state is DriverLoading) {
              return LoadingWidget(message: l10n.creatingDriver);
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Personal Information Section
                  _buildSectionTitle(l10n.personalInformation),
                  const SizedBox(height: 12),

                  // Personal Image
                  _buildImageUploadSection(
                    l10n.personalPhoto,
                    _personalImage,
                    (source) => _pickImage(source, 'personal'),
                    l10n,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _nameController,
                    label: l10n.fullName,
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterFullName;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: l10n.email,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterEmail;
                      }
                      if (!value.isValidEmail) {
                        return l10n.pleaseEnterValidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: l10n.password,
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterPassword;
                      }
                      if (value.length < 6) {
                        return l10n.passwordMustBeAtLeast6Characters;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: l10n.confirmPassword,
                    icon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseConfirmPassword;
                      }
                      if (value != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: l10n.phoneNumber,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterPhoneNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: l10n.address,
                    icon: Icons.location_on,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterAddress;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // License Information Section
                  _buildSectionTitle(l10n.licenseInformation),
                  const SizedBox(height: 12),

                  // Driver License
                  _buildImageUploadSection(
                    l10n.driverLicense,
                    _driverLicenseImage,
                    (source) => _pickImage(source, 'driverLicense'),
                    l10n,
                  ),
                  const SizedBox(height: 24),

                  // Vehicle Information Section
                  _buildSectionTitle(l10n.vehicleInformation),
                  const SizedBox(height: 12),

                  // Vehicle License
                  _buildImageUploadSection(
                    l10n.vehicleLicense,
                    _vehicleLicenseImage,
                    (source) => _pickImage(source, 'vehicleLicense'),
                    l10n,
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Photo
                  _buildImageUploadSection(
                    l10n.vehiclePhoto,
                    _vehiclePhotoImage,
                    (source) => _pickImage(source, 'vehiclePhoto'),
                    l10n,
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    controller: _vehicleTypeController,
                    label: l10n.vehicleType,
                    icon: Icons.directions_car,
                    items: _vehicleTypes,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseSelectVehicleType;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _vehicleModelController,
                    label: l10n.vehicleModel,
                    icon: Icons.directions_car,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterVehicleModel;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _vehicleColorController,
                    label: l10n.vehicleColor,
                    icon: Icons.color_lens,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterVehicleColor;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _vehiclePlateController,
                    label: l10n.vehiclePlateNumber,
                    icon: Icons.confirmation_number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.pleaseEnterVehiclePlateNumber;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        l10n.createDriver,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildImageUploadSection(
    String label,
    File? image,
    Function(ImageSource) onPickImage,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: image != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        image,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            if (label == l10n.personalPhoto) {
                              _personalImage = null;
                            } else if (label == l10n.driverLicense) {
                              _driverLicenseImage = null;
                            } else if (label == l10n.vehicleLicense) {
                              _vehicleLicenseImage = null;
                            } else if (label == l10n.vehiclePhoto) {
                              _vehiclePhotoImage = null;
                            }
                          });
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          String type = 'personal';
                          if (label == l10n.driverLicense) {
                            type = 'driverLicense';
                          }
                          if (label == l10n.vehicleLicense) {
                            type = 'vehicleLicense';
                          }
                          if (label == l10n.vehiclePhoto) type = 'vehiclePhoto';
                          _showImageSourceDialog(type);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.change),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: () {
                    String type = 'personal';
                    if (label == l10n.driverLicense) type = 'driverLicense';
                    if (label == l10n.vehicleLicense) type = 'vehicleLicense';
                    if (label == l10n.vehiclePhoto) type = 'vehiclePhoto';
                    _showImageSourceDialog(type);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tapToUploadImage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> items,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item[0].toUpperCase() + item.substring(1)),
        );
      }).toList(),
      onChanged: (value) {
        controller.text = value ?? '';
      },
      validator: validator,
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
