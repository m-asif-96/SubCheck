# Flutter Project Architecture Prompt (GetX + Layered Modules)

Build / maintain this Flutter app using the architecture below. Follow it for every new feature. Do not invent a different structure.

## Stack
- Flutter (Material)
- State management & DI: GetX (`GetMaterialApp`, `GetxController`, `Bindings`, `Obx`, `.obs`)
- Networking: Dio
- Secure storage: flutter_secure_storage
- Local prefs: shared_preferences
- Env: flutter_dotenv (`.env`)
- Responsive: responsive_sizer
- Icons: iconsax
- Assets codegen: flutter_gen (`dart run build_runner build --delete-conflicting-outputs`)
- Push: Firebase Messaging + local notifications

## Hard layering rule (non-negotiable)
For every screen/feature:
- UI file = UI only (layout, widgets composition, binding to controller getters/callbacks)
- Controller = state, business flow, navigation, API orchestration
- Widget folder = reusable UI pieces for that feature
- Util folder = pure helpers, constants, formatters, static data (no GetX side effects unless a thin open_* helper)
- Models = data classes / DTOs
- Binding = GetX DI registration for that route/feature

Never put API calls, navigation stacks, or business logic inside screens.
Never put widget trees inside controllers.
Never put UI strings/layout sizes scattered randomly — prefer constants / util.

## Root tree
```
project_root/
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
├── assets/
│   ├── fonts/
│   ├── icons/
│   ├── logo/
│   └── svgs/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── gen/                    # generated assets (flutter_gen)
│   └── src/
│       ├── core/               # app-wide shared infrastructure
│       └── modules/            # feature modules
├── test/
├── .env
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## `lib/src/core/` (shared)
```
core/
├── bindings/
│   └── initial_binding.dart          # permanent/lazy global deps
├── common/
│   ├── main_app_controller/
│   └── widgets/                      # global widgets (appbar, snackbar, error views…)
├── constants/
│   ├── app_colors.dart
│   ├── app_constants.dart            # copy / labels
│   ├── app_endpoints.dart            # API paths
│   └── app_loadings.dart
├── extensions/                       # date, country picker, pdf preview helpers…
├── routes/
│   └── app_pages.dart                # AppRoutes + AppPages GetPage registry
├── services/
│   ├── api_client/
│   │   ├── api_client.dart
│   │   ├── i_api_client.dart
│   │   ├── interceptors/
│   │   │   └── api_logger.dart
│   │   ├── models/
│   │   │   ├── api_request.dart
│   │   │   ├── api_response.dart
│   │   │   ├── api_exception.dart
│   │   │   ├── api_error_handler.dart
│   │   │   └── paginated_list_meta.dart
│   │   └── repository/
│   │       ├── i_api_repository.dart
│   │       ├── base_api_repository.dart
│   │       └── api_repository.dart   # all endpoint methods live here
│   ├── secure_storage/
│   │   └── secure_storage_service.dart
│   └── push_notification/
│       └── push_notification_service.dart
└── utils/
    ├── app_validators.dart
    ├── masks.dart
    ├── file_picker/
    ├── pdf_utils/
    └── custom_widgets/               # reusable form controls, buttons, shimmer, scaffold…
```

### Core responsibilities
- `InitialBinding`: register SecureStorage (permanent), IApiClient/IApiRepository (lazy+fenix), global ProfileController / Push service as needed.
- `AppRoutes` + `AppPages`: every navigable screen has `name`, `page`, `binding`.
- Controllers call `IApiRepository`, never Dio directly.
- Screens use named routes: `Get.toNamed` / `Get.offAllNamed` / `Get.offNamed` with bindings.

## Feature module template (copy for every feature)
```
modules/<domain>_module/<feature>_module/
├── bindings/                 # or binding/
│   └── <feature>_binding.dart
├── controller/
│   └── <feature>_controller.dart
├── models/                   # optional
│   └── <model>.dart
├── utils/                    # optional (or util/)
│   └── <helpers>.dart
├── views/                    # or view/ — screen entrypoints only
│   └── <feature>_view.dart   # GetView<FeatureController>
└── widgets/                  # or widget/
    └── <piece>_widget.dart
```

### Screen shape
```dart
class FeatureView extends GetView<FeatureController> {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // compose widgets only
      // Obx(() => ...) for reactive bits
      // onPressed: controller.submit
    );
  }
}
```

### Binding shape
```dart
class FeatureBinding extends Bindings {
  @override
  void dependencies() {
    // register FeatureController (and shared deps if needed)
    // Prefer Get.put / Get.lazyPut
    // For auth-like controllers that must survive offAllNamed: permanent: true + prepareForRoute()
  }
}
```

### Controller shape
```dart
class FeatureController extends GetxController {
  final IApiRepository _api = Get.find<IApiRepository>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  Future<void> submit() async { /* validation + API + navigation */ }

  @override
  void onClose() {
    // dispose TextEditingController / FocusNode owned here
    super.onClose();
  }
}
```

## Domain modules layout (role-based app example)
```
modules/
├── authentication_module/
│   ├── bindings/                 # AuthBinding (shared AuthController)
│   ├── controller/               # AuthController (APIs + shared auth flows)
│   ├── utils/                    # otp_validator, password_validator…
│   ├── splash/
│   │   ├── binding/
│   │   ├── controller/
│   │   ├── utils/
│   │   ├── widgets/
│   │   └── *_screen.dart
│   ├── onboarding/
│   ├── select_role/
│   ├── login/
│   ├── register/
│   ├── otp/
│   └── forgot_password/
│       ├── binding/
│       ├── controller/
│       ├── models/
│       ├── widgets/
│       └── *_screen.dart
│
├── client_side_module/
│   └── dashboard/
│       ├── bindings/
│       ├── controller/
│       ├── utils/
│       ├── views/
│       └── widget/
│
└── contractor_module/
    ├── dashboard_modules/
    ├── estimate_module/
    ├── invoices_module/
    ├── client_module/
    ├── items_module/
    ├── notification_module/
    └── more_module/
        ├── more_module_bindings/
        ├── more_module_controller/
        ├── more_module_views/
        ├── profile_module/
        ├── settings_module/
        ├── subscription_module/
        ├── report_module/
        ├── change_password_module/
        ├── delete_account_module/
        ├── quickbooks_module/
        └── widgets/
```

Nested feature screens (example under estimates):
```
estimate_module/
├── bindings/
├── controller/
├── models/
├── util/
├── widget/
└── views/
    ├── estimate_module_view.dart
    ├── create_estimate/
    │   └── widgets/
    ├── estimate_detail/
    │   └── widgets/
    └── estimate_type_selection/
```

## App bootstrap (`main.dart`)
1. `WidgetsFlutterBinding.ensureInitialized()`
2. Firebase init (if used)
3. `dependenciesInitialize()` → dotenv, system UI
4. `runApp(MyApp)`
5. `GetMaterialApp`:
   - `initialBinding: InitialBinding()`
   - `initialRoute: AppPages.initial`
   - `getPages: AppPages.pages`
   - wrap with `ResponsiveSizer` if used

## Navigation & DI rules
- Register pages in `app_pages.dart` with their Binding.
- Prefer named routes over anonymous `Get.to(() => View())` when a Binding exists.
- Use `Get.offAllNamed` for auth/logout resets.
- Controllers that own FocusNodes/TextEditingControllers must not be force-deleted then immediately reused while old widgets still mount — reuse with `prepareForRoute()` or keep permanent where required.
- Shared cross-feature services (API, storage, profile) live in InitialBinding / AuthBinding as permanent or fenix.

## API layer rules
- Endpoints only in `app_endpoints.dart`
- Repository interface (`IApiRepository`) + implementation (`ApiRepository`)
- Controllers depend on `IApiRepository`
- Log requests via interceptor/logger
- Map errors to user-facing strings in controller/util mappers

## UI rules
- Use shared widgets from `core/common/widgets` and `core/utils/custom_widgets`
- Feature-specific widgets stay in that feature’s `widgets/`
- Strings in `app_constants.dart` (or feature util if truly local)
- Colors in `app_colors.dart`
- Prefer `Obx` / `.obs` over `setState`
- Screens should look like composition of small widgets + controller callbacks

## Naming conventions
- Screens: `*_screen.dart` or `*_view.dart` (be consistent per module)
- Controllers: `*_controller.dart`
- Bindings: `*_binding.dart`
- Models: descriptive nouns
- Utils: `*_validator.dart`, `*_layout.dart`, `open_*.dart` for navigation helpers
- Package imports: `package:<app_name>/src/...`

## When adding a NEW feature, always do this checklist
1. Create module folder with binding / controller / views / widgets / utils / models as needed
2. Implement Binding + Controller + thin GetView
3. Register route in `AppRoutes` + `AppPages`
4. Add repository methods if new APIs
5. Keep UI free of logic
6. Dispose controllers/nodes in `onClose`
7. Reuse core widgets; don’t duplicate

## Do NOT
- Put business logic in widgets/screens
- Call Dio from UI
- Create controllers with `AuthController()` / `FeatureController()` manually when Get.find/binding should supply them
- Mix unrelated features in one giant view file
- Commit secrets (`.env` keys, tokens)

Use this architecture for the entire project. If something is unclear, prefer matching an existing module (login / dashboard_home / notification) over inventing a new pattern.
