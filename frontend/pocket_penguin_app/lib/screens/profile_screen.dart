import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';


/*
  Shows user information and logout
  Allows editing: bio, birthday, profile picture
 */

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _profilePictureController = TextEditingController();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _bioController.dispose();
    _profilePictureController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Try to get from API first, then fallback to stored data
    final result = await _authService.getCurrentUser();
    if (result['success'] == true) {
      setState(() {
        _userData = result['data'];
        _bioController.text = result['data']['bio'] ?? '';
        _profilePictureController.text =
            result['data']['profile_picture'] ?? '';

        // Parse date_of_birth if it exists
        if (result['data']['date_of_birth'] != null) {
          try {
            _selectedDate = DateTime.parse(result['data']['date_of_birth']);
          } catch (e) {
            _selectedDate = null;
          }
        }

        _isLoading = false;
      });
    } else {
      // Fallback to stored data
      final storedData = await _authService.getUserData();
      setState(() {
        _userData = storedData;
        if (storedData != null) {
          _bioController.text = storedData['bio'] ?? '';
          _profilePictureController.text = storedData['profile_picture'] ?? '';
          if (storedData['date_of_birth'] != null) {
            try {
              _selectedDate = DateTime.parse(storedData['date_of_birth']);
            } catch (e) {
              _selectedDate = null;
            }
          }
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E3A8A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Format date for API (YYYY-MM-DD)
    String? dateOfBirth;
    if (_selectedDate != null) {
      dateOfBirth = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }

    final result = await _authService.updateProfile(
      bio: _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim(),
      profilePicture: _profilePictureController.text.trim().isEmpty
          ? null
          : _profilePictureController.text.trim(),
      dateOfBirth: dateOfBirth,
    );

    setState(() {
      _isSaving = false;
    });

    if (result['success'] == true) {
      setState(() {
        _isEditing = false;
      });
      await _loadUserData(); // Reload to get updated data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        final errorMessage = result['error']?['message'] ??
            (result['error'] is Map
                ? result['error'].toString()
                : 'Failed to update profile');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Logged out successfully. You can continue using the app.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 375,
          height: 800,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE0F2FE), Color(0xFFDBEAFE)],
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.grey[800]!, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Column(
              children: [
                // Phone Notch
                Container(
                  width: 128,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    border: Border(
                      bottom: BorderSide(color: Colors.blue[100]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.asset("images/logo.png",
                                width: 32, height: 32),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (!_isEditing)
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF1E3A8A)),
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              tooltip: 'Edit Profile',
                            ),
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Color(0xFF1E3A8A)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 20),
                                // Profile Avatar
                                Center(
                                  child: GestureDetector(
                                    onTap: _isEditing
                                        ? () {
                                            // Show dialog to enter profile picture URL
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                    'Profile Picture URL'),
                                                content: TextField(
                                                  controller:
                                                      _profilePictureController,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText:
                                                        'Enter image URL (https://...)',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.url,
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('OK'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        : null,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: Colors.blue[300]!,
                                          width: 3,
                                        ),
                                      ),
                                      child: _profilePictureController
                                                  .text.isNotEmpty &&
                                              _profilePictureController.text
                                                  .startsWith('http')
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(47),
                                              child: Image.network(
                                                _profilePictureController.text,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return const Icon(
                                                    Icons.person,
                                                    size: 50,
                                                    color: Color(0xFF1E3A8A),
                                                  );
                                                },
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Color(0xFF1E3A8A),
                                            ),
                                    ),
                                  ),
                                ),
                                if (_isEditing)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Tap to add profile picture URL',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: 24),
                                // User Info Card
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow('Email',
                                          _userData?['email'] ?? 'N/A'),
                                      const Divider(),
                                      _buildInfoRow('Username',
                                          _userData?['username'] ?? 'N/A'),
                                      const Divider(),
                                      _buildInfoRow(
                                        'Verified',
                                        _userData?['is_verified'] == true
                                            ? 'Yes'
                                            : 'No',
                                      ),
                                      if (!_isEditing) ...[
                                        const Divider(),
                                        _buildInfoRow(
                                          'Birthday',
                                          _selectedDate != null
                                              ? DateFormat('MMMM d, yyyy')
                                                  .format(_selectedDate!)
                                              : 'Not set',
                                        ),
                                        if (_bioController.text.isNotEmpty) ...[
                                          const Divider(),
                                          _buildInfoRow(
                                              'Bio', _bioController.text),
                                        ],
                                      ],
                                      if (_isEditing) ...[
                                        const Divider(),
                                        // Birthday field
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Birthday',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: () =>
                                                    _selectDate(context),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            Colors.grey[300]!),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        _selectedDate != null
                                                            ? DateFormat(
                                                                    'MMMM d, yyyy')
                                                                .format(
                                                                    _selectedDate!)
                                                            : 'Select birthday',
                                                        style: TextStyle(
                                                          color:
                                                              _selectedDate !=
                                                                      null
                                                                  ? Colors.black
                                                                  : Colors.grey[
                                                                      400],
                                                        ),
                                                      ),
                                                      const Icon(
                                                          Icons.calendar_today,
                                                          size: 20),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        // Bio field
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Bio',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              TextFormField(
                                                controller: _bioController,
                                                maxLines: 4,
                                                maxLength: 700,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Tell us about yourself...',
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.all(12),
                                                ),
                                                validator: (value) {
                                                  if (value != null &&
                                                      value.length > 700) {
                                                    return 'Bio must be 700 characters or less';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Save/Cancel buttons (when editing)
                                if (_isEditing) ...[
                                  ElevatedButton(
                                    onPressed: _isSaving ? null : _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[600],
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: _isSaving
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(width: 8),
                                              Text(
                                                'Save Changes',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                    onPressed: _isSaving
                                        ? null
                                        : () {
                                            setState(() {
                                              _isEditing = false;
                                              // Reset to original values
                                              _loadUserData();
                                            });
                                          },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.grey[700],
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cancel),
                                        SizedBox(width: 8),
                                        Text(
                                          'Cancel',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                // Logout Button
                                ElevatedButton(
                                  onPressed: _isEditing ? null : _handleLogout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.logout),
                                      SizedBox(width: 8),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
