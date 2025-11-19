import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/restaurants/data/repositories/restaurant_repository_impl.dart';
import '../../features/restaurants/domain/repositories/restaurant_repository.dart';
import '../../features/restaurants/domain/repositories/favorites_repository.dart';
import '../../features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import '../../features/restaurants/domain/usecases/get_restaurant_by_id_usecase.dart';
import '../../features/restaurants/domain/usecases/get_restaurant_products_usecase.dart';
import '../../features/restaurants/presentation/cubits/restaurant_cubit.dart';
import '../../features/restaurants/presentation/cubits/favorites_cubit.dart';
import '../../features/restaurants/data/repositories/favorites_repository_impl.dart';
import '../../features/orders/presentation/cubits/cart_cubit.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/repositories/cart_repository.dart';
import '../../features/orders/data/repositories/cart_repository_impl.dart';
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
import '../../features/restaurants/domain/repositories/food_category_repository.dart';
import '../../features/restaurants/data/repositories/food_category_repository_impl.dart';
import '../../features/restaurants/presentation/cubits/food_category_cubit.dart';
import '../../features/market_products/domain/repositories/market_product_repository.dart';
import '../../features/market_products/data/repositories/market_product_repository_impl.dart';
import '../../features/market_products/presentation/cubits/market_product_cubit.dart';
import '../../features/market_products/presentation/cubits/market_product_customer_cubit.dart';
import '../../features/ads/domain/repositories/ad_repository.dart';
import '../../features/ads/data/repositories/ad_repository_impl.dart';
import '../../features/admin/presentation/cubits/ad_management_cubit.dart';
import '../../features/ads/presentation/cubits/startup_ad_customer_cubit.dart';
import '../../features/drivers/domain/repositories/driver_repository.dart';
import '../../features/drivers/data/repositories/driver_repository_impl.dart';
import '../../features/drivers/presentation/cubits/driver_cubit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../network/network_info.dart';
import '../network/supabase_service.dart';
import '../utils/image_upload_helper.dart';
import '../localization/locale_cubit.dart';

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
  late final FavoritesRepository _favoritesRepository;
  late final CartRepository _cartRepository;
  late final MarketProductRepository _marketProductRepository;
  late final AdRepository _adRepository;
  late final FoodCategoryRepository _foodCategoryRepository;
  late final DriverRepository _driverRepository;

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

    _favoritesRepository = FavoritesRepositoryImpl(
      firestore: _firestore,
    );

    _cartRepository = CartRepositoryImpl(
      firestore: _firestore,
    );

    _marketProductRepository = MarketProductRepositoryImpl(
      firestore: _firestore,
      imageUploadHelper: _imageUploadHelper,
    );

    _adRepository = AdRepositoryImpl(
      firestore: _firestore,
      imageUploadHelper: _imageUploadHelper,
    );

    _foodCategoryRepository = FoodCategoryRepositoryImpl(
      firestore: _firestore,
      networkInfo: _networkInfo,
    );

    _driverRepository = DriverRepositoryImpl(
      firestore: _firestore,
      networkInfo: _networkInfo,
      supabaseService: _supabaseService,
    );
  }
  
  // Getters for accessing services from other parts of the app
  SupabaseService get supabaseService => _supabaseService;
  ImageUploadHelper get imageUploadHelper => _imageUploadHelper;

  List<BlocProvider> getBlocProviders() {
    return [
      BlocProvider<LocaleCubit>(
        create: (_) => LocaleCubit()..load(),
      ),
      BlocProvider<AuthCubit>(
        create: (_) => AuthCubit(
          loginUseCase: LoginUseCase(_authRepository),
          signupUseCase: SignupUseCase(_authRepository),
          logoutUseCase: LogoutUseCase(_authRepository),
          getCurrentUserUseCase: GetCurrentUserUseCase(_authRepository),
          resetPasswordUseCase: ResetPasswordUseCase(_authRepository),
          repository: _authRepository,
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
          restaurantOwnerRepository: _restaurantOwnerRepository,
        ),
      ),
      BlocProvider<CartCubit>(
        create: (_) => CartCubit(
          repository: _cartRepository,
          firebaseAuth: _firebaseAuth,
        ),
      ),
      BlocProvider<FavoritesCubit>(
        create: (_) => FavoritesCubit(
          repository: _favoritesRepository,
          firebaseAuth: _firebaseAuth,
        ),
      ),
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
      BlocProvider<MarketProductCubit>(
        create: (_) => MarketProductCubit(
          repository: _marketProductRepository,
        ),
      ),
      BlocProvider<MarketProductCustomerCubit>(
        create: (_) => MarketProductCustomerCubit(
          repository: _marketProductRepository,
        ),
      ),
      BlocProvider<AdManagementCubit>(
        create: (_) => AdManagementCubit(
          repository: _adRepository,
        ),
      ),
      BlocProvider<StartupAdCustomerCubit>(
        create: (_) => StartupAdCustomerCubit(
          repository: _adRepository,
        ),
      ),
      BlocProvider<FoodCategoryCubit>(
        create: (_) => FoodCategoryCubit(
          repository: _foodCategoryRepository,
        ),
      ),
      BlocProvider<DriverCubit>(
        create: (_) => DriverCubit(
          driverRepository: _driverRepository,
          authRepository: _authRepository,
        ),
      ),
    ];
  }
}
