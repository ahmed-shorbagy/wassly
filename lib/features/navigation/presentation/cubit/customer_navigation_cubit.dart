import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

/// Cubit responsible for bottom navigation state in the customer app.
class CustomerNavigationCubit extends Cubit<CustomerNavigationState> {
  CustomerNavigationCubit({int initialIndex = 0})
      : super(
          CustomerNavigationState(
            index: initialIndex,
            resetToInitialLocation: false,
            changeId: 0,
          ),
        );

  /// Selects a tab by index and indicates whether we should reset
  /// the branch stack when tapping the already selected tab.
  void selectTab(int newIndex) {
    emit(
      CustomerNavigationState(
        index: newIndex,
        resetToInitialLocation: newIndex == state.index,
        changeId: state.changeId + 1,
      ),
    );
  }
}

class CustomerNavigationState extends Equatable {
  final int index;
  final bool resetToInitialLocation;
  final int changeId;

  const CustomerNavigationState({
    required this.index,
    required this.resetToInitialLocation,
    required this.changeId,
  });

  @override
  List<Object?> get props => [index, resetToInitialLocation, changeId];
}

