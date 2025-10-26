import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/restaurants/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurants/domain/repositories/restaurant_repository.dart';
import '../../features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import '../../features/restaurants/domain/usecases/get_restaurant_by_id_usecase.dart';
import '../../features/restaurants/domain/usecases/get_restaurant_products_usecase.dart';
import '../../features/restaurants/presentation/cubits/restaurant_cubit.dart';
import '../network/network_info.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  late final FirebaseAuth _firebaseAuth;
  late final FirebaseFirestore _firestore;
  late final NetworkInfo _networkInfo;
  late final AuthRepository _authRepository;
  late final RestaurantRepository _restaurantRepository;

  Future<void> init() async {
    // External dependencies
    _firebaseAuth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _networkInfo = NetworkInfoImpl();

    // Repository
    _authRepository = AuthRepositoryImpl(
      firebaseAuth: _firebaseAuth,
      firestore: _firestore,
      networkInfo: _networkInfo,
    );

    _restaurantRepository = RestaurantRepositoryImpl(
      firestore: _firestore,
      networkInfo: _networkInfo,
    );
  }

  List<BlocProvider> getBlocProviders() {
    return [
      BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(
          loginUseCase: LoginUseCase(_authRepository),
          signupUseCase: SignupUseCase(_authRepository),
          logoutUseCase: LogoutUseCase(_authRepository),
          getCurrentUserUseCase: GetCurrentUserUseCase(_authRepository),
        ),
      ),
      BlocProvider<RestaurantCubit>(
        create: (_) => RestaurantCubit(
          getAllRestaurantsUseCase: GetAllRestaurantsUseCase(_restaurantRepository),
          getRestaurantByIdUseCase: GetRestaurantByIdUseCase(_restaurantRepository),
          getRestaurantProductsUseCase: GetRestaurantProductsUseCase(_restaurantRepository),
        ),
      ),
    ];
  }
}
