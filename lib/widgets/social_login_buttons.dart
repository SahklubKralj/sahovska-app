import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SocialLoginButtons extends StatelessWidget {
  final bool isSignUp;

  const SocialLoginButtons({
    Key? key,
    this.isSignUp = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "ili"
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ili',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 16),
        
        // Google Sign In Button
        GoogleSignInButton(isSignUp: isSignUp),
        
        SizedBox(height: 12),
        
        // Apple Sign In Button (placeholder for future)
        AppleSignInButton(isSignUp: isSignUp),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final bool isSignUp;

  const GoogleSignInButton({
    Key? key,
    required this.isSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: authProvider.isLoading ? null : () async {
              final success = await authProvider.signUpWithGoogle();
              if (success) {
                // Navigation will be handled by GoRouter redirect
              }
            },
            icon: _GoogleIcon(),
            label: Text(
              isSignUp ? 'Registruj se sa Google' : 'Prijavi se sa Google',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class AppleSignInButton extends StatelessWidget {
  final bool isSignUp;

  const AppleSignInButton({
    Key? key,
    required this.isSignUp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          // Show not implemented dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Nije implementirano'),
              content: Text('Apple Sign In će biti dostupan u budućoj verziji.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        },
        icon: Icon(
          Icons.apple,
          color: Colors.black,
          size: 24,
        ),
        label: Text(
          isSignUp ? 'Registruj se sa Apple' : 'Prijavi se sa Apple',
          style: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Simple Google-like icon using Flutter icons
    // In production, use the official Google logo
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}

class EmailVerificationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null || authProvider.isEmailVerified) {
          return SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            border: Border.all(color: AppColors.warning),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Email nije verifikovan',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Molimo verifikujte svoj email da biste imali potpunu funkcionalnost.',
                style: AppTextStyles.bodySmall,
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final success = await authProvider.sendEmailVerification();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Verifikacioni email je poslat'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    child: Text('Pošalji ponovo'),
                  ),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await authProvider.reloadUser();
                    },
                    child: Text('Proveri status'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}