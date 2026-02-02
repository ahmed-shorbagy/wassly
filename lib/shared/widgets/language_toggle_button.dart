import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/locale_cubit.dart';

class LanguageToggleButton extends StatelessWidget {
  final Color? color;
  const LanguageToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        final isArabic = state.locale.languageCode == 'ar';
        return IconButton(
          tooltip: isArabic ? 'English' : 'العربية',
          icon: Text(
            isArabic ? 'En' : 'ع',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          onPressed: () => context.read<LocaleCubit>().toggle(),
        );
      },
    );
  }
}
