import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/locale_cubit.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final isArabic = state.locale.languageCode == 'ar';
        return IconButton(
          tooltip: isArabic ? 'English' : 'العربية',
          icon: Text(
            isArabic ? 'En' : 'ع',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => context.read<LocaleCubit>().toggle(),
        );
      },
    );
  }
}


