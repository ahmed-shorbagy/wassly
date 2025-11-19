import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/back_button_handler.dart';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, type);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_personalImage == null) {
      context.showErrorSnackBar('Please select personal image');
      return;
    }

    if (_driverLicenseImage == null) {
      context.showErrorSnackBar('Please select driver license');
      return;
    }

    if (_vehicleLicenseImage == null) {
      context.showErrorSnackBar('Please select vehicle license');
      return;
    }

    if (_vehiclePhotoImage == null) {
      context.showErrorSnackBar('Please select vehicle photo');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      context.showErrorSnackBar('Passwords do not match');
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
          title: const Text('Create Driver'),
          backgroundColor: Colors.purple,
        ),
        body: BlocConsumer<DriverCubit, DriverState>(
          listener: (context, state) {
            if (state is DriverCreated) {
              // Show credentials dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text('Driver Created Successfully'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please provide these credentials to the driver:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildCredentialRow('Email:', _emailController.text),
                      const SizedBox(height: 8),
                      _buildCredentialRow('Password:', _passwordController.text),
                      const SizedBox(height: 16),
                      const Text(
                        'Note: Driver can change password after first login.',
                        style: TextStyle(
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
                        Navigator.pop(context);
                        context.go('/admin/drivers');
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } else if (state is DriverError) {
              context.showErrorSnackBar(state.message);
            }
          },
          builder: (context, state) {
            if (state is DriverLoading) {
              return LoadingWidget(message: 'Creating driver...');
            }

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Personal Information Section
                  _buildSectionTitle('Personal Information'),
                  const SizedBox(height: 12),
                  
                  // Personal Image
                  _buildImageUploadSection(
                    'Personal Photo',
                    _personalImage,
                    (source) => _pickImage(source, 'personal'),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.isValidEmail) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
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
                        return 'Please confirm password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on,
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // License Information Section
                  _buildSectionTitle('License Information'),
                  const SizedBox(height: 12),
                  
                  // Driver License
                  _buildImageUploadSection(
                    'Driver License',
                    _driverLicenseImage,
                    (source) => _pickImage(source, 'driverLicense'),
                  ),
                  const SizedBox(height: 24),

                  // Vehicle Information Section
                  _buildSectionTitle('Vehicle Information'),
                  const SizedBox(height: 12),
                  
                  // Vehicle License
                  _buildImageUploadSection(
                    'Vehicle License',
                    _vehicleLicenseImage,
                    (source) => _pickImage(source, 'vehicleLicense'),
                  ),
                  const SizedBox(height: 16),
                  
                  // Vehicle Photo
                  _buildImageUploadSection(
                    'Vehicle Photo',
                    _vehiclePhotoImage,
                    (source) => _pickImage(source, 'vehiclePhoto'),
                  ),
                  const SizedBox(height: 16),

                  _buildDropdownField(
                    controller: _vehicleTypeController,
                    label: 'Vehicle Type',
                    icon: Icons.directions_car,
                    items: _vehicleTypes,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select vehicle type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _vehicleModelController,
                    label: 'Vehicle Model',
                    icon: Icons.directions_car,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter vehicle model';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _vehicleColorController,
                    label: 'Vehicle Color',
                    icon: Icons.color_lens,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter vehicle color';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _vehiclePlateController,
                    label: 'Vehicle Plate Number',
                    icon: Icons.confirmation_number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter vehicle plate number';
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
                      child: const Text(
                        'Create Driver',
                        style: TextStyle(
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
                            if (label == 'Personal Photo') {
                              _personalImage = null;
                            } else if (label == 'Driver License') {
                              _driverLicenseImage = null;
                            } else if (label == 'Vehicle License') {
                              _vehicleLicenseImage = null;
                            } else if (label == 'Vehicle Photo') {
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
                          if (label == 'Driver License') type = 'driverLicense';
                          if (label == 'Vehicle License') type = 'vehicleLicense';
                          if (label == 'Vehicle Photo') type = 'vehiclePhoto';
                          _showImageSourceDialog(type);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Change'),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: () {
                    String type = 'personal';
                    if (label == 'Driver License') type = 'driverLicense';
                    if (label == 'Vehicle License') type = 'vehicleLicense';
                    if (label == 'Vehicle Photo') type = 'vehiclePhoto';
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
                          'Tap to upload $label',
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
      value: controller.text.isEmpty ? null : controller.text,
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

