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
import '../../features/orders/presentation/cubits/cart_cubit.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/create_order_usecase.dart';
import '../../features/orders/domain/usecases/get_customer_orders_usecase.dart';
import '../../features/orders/domain/usecases/get_active_orders_usecase.dart';
import '../../features/orders/domain/usecases/get_order_by_id_usecase.dart';
import '../../features/orders/domain/usecases/cancel_order_usecase.dart';
import '../../features/orders/presentation/cubits/order_cubit.dart';
import '../../features/partner/presentation/cubits/product_management_cubit.dart';
import '../../features/partner/presentation/cubits/restaurant_onboarding_cubit.dart';
import '../../features/admin/presentation/cubits/admin_cubit.dart';
import '../../features/admin/presentation/cubits/admin_product_cubit.dart';
import '../../features/restaurants/domain/repositories/restaurant_owner_repository.dart';
import '../../features/restaurants/data/repositories/restaurant_owner_repository_impl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../network/network_info.dart';
import '../network/supabase_service.dart';
import '../utils/image_upload_helper.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  late final FirebaseAuth _firebaseAuth;
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _firebaseStorage;
  late final NetworkInfo _networkInfo;
  late final SupabaseService _supabaseService;
  late final ImageUploadHelper _imageUploadHelper;
  late final AuthRepository _authRepository;
  late final RestaurantRepository _restaurantRepository;
  late final OrderRepository _orderRepository;
  late final RestaurantOwnerRepository _restaurantOwnerRepository;

  Future<void> init() async {
    // External dependencies
    _firebaseAuth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _firebaseStorage = FirebaseStorage.instance;
    _networkInfo = NetworkInfoImpl();
    
    // Supabase services
    _supabaseService = SupabaseService();
    _imageUploadHelper = ImageUploadHelper(supabaseService: _supabaseService);

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

    _orderRepository = OrderRepositoryImpl(
      firestore: _firestore,
    );

    _restaurantOwnerRepository = RestaurantOwnerRepositoryImpl(
      firestore: _firestore,
      storage: _firebaseStorage,
      supabaseService: _supabaseService,
    );
  }
  
  // Getters for accessing services from other parts of the app
  SupabaseService get supabaseService => _supabaseService;
  ImageUploadHelper get imageUploadHelper => _imageUploadHelper;

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
          getAllRestaurantsUseCase: GetAllRestaurantsUseCase(
            _restaurantRepository,
          ),
          getRestaurantByIdUseCase: GetRestaurantByIdUseCase(
            _restaurantRepository,
          ),
          getRestaurantProductsUseCase: GetRestaurantProductsUseCase(
            _restaurantRepository,
          ),
        ),
      ),
      BlocProvider<CartCubit>(create: (_) => CartCubit()),
      BlocProvider<OrderCubit>(
        create: (_) => OrderCubit(
          createOrderUseCase: CreateOrderUseCase(_orderRepository),
          getCustomerOrdersUseCase: GetCustomerOrdersUseCase(_orderRepository),
          getActiveOrdersUseCase: GetActiveOrdersUseCase(_orderRepository),
          getOrderByIdUseCase: GetOrderByIdUseCase(_orderRepository),
          cancelOrderUseCase: CancelOrderUseCase(_orderRepository),
          repository: _orderRepository,
        ),
      ),
      BlocProvider<ProductManagementCubit>(
        create: (_) => ProductManagementCubit(
          repository: _restaurantOwnerRepository,
        ),
      ),
      BlocProvider<RestaurantOnboardingCubit>(
        create: (_) => RestaurantOnboardingCubit(
          repository: _restaurantOwnerRepository,
        ),
      ),
      BlocProvider<AdminCubit>(
        create: (_) => AdminCubit(
          repository: _restaurantOwnerRepository,
        ),
      ),
      BlocProvider<AdminProductCubit>(
        create: (_) => AdminProductCubit(
          repository: _restaurantOwnerRepository,
        ),
      ),
    ];
  }
}
