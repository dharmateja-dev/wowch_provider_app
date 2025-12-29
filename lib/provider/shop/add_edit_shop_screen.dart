// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/custom_image_picker.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/city_list_response.dart';
import 'package:handyman_provider_flutter/models/country_list_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/multi_language_request_model.dart';
import 'package:handyman_provider_flutter/models/shop_model.dart';
import 'package:handyman_provider_flutter/models/state_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class AddEditShopScreen extends StatefulWidget {
  final ShopModel? shop;

  const AddEditShopScreen({Key? key, this.shop}) : super(key: key);

  @override
  State<AddEditShopScreen> createState() => _AddEditShopScreenState();
}

class _AddEditShopScreenState extends State<AddEditShopScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isUpdate = false;

  bool isFirstTime = true;
  bool isLastPage = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController regNoController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController shopStartTimeController = TextEditingController();
  TextEditingController shopEndTimeController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  List<CountryListResponse> countryList = [];
  List<StateListResponse> stateList = [];
  List<CityListResponse> cityList = [];
  List<ServiceData> serviceList = [];
  CountryListResponse? selectedCountry;
  StateListResponse? selectedState;
  CityListResponse? selectedCity;
  TimeOfDay? shopStartTime;
  TimeOfDay? shopEndTime;
  List<String> selectedImages = [];

  int servicePage = 1;

  ShopModel? shopDetails;
  Country selectedCountryPicker = defaultCountry();
  FocusNode shopNameFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode stateFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode registrationNumberFocus = FocusNode();
  FocusNode latitudeFocus = FocusNode();
  FocusNode longitudeFocus = FocusNode();
  FocusNode shopStartTimeFocus = FocusNode();
  FocusNode shopEndTimeFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  ValueNotifier _valueNotifier = ValueNotifier(true);

  // Multilanguage support
  UniqueKey formWidgetKey = UniqueKey();
  Map<String, MultiLanguageRequest> translations = {};
  MultiLanguageRequest enTranslations = MultiLanguageRequest();

  String formatTime24(TimeOfDay t) =>
      t.hour.toString().padLeft(2, '0') +
      ':' +
      t.minute.toString().padLeft(2, '0');

  @override
  void initState() {
    super.initState();
    init();
    appStore.setSelectedLanguage(languageList().first);
  }

  Future<void> init() async {
    isUpdate = widget.shop != null;

    if (DEMO_MODE_ENABLED) {
      // Use demo data for service list
      serviceList = _getDemoServiceList();
      appStore.setLoading(false);
      setState(() {});
      return;
    }

    if (isUpdate) {
      await getShopDetails();
    }
    await Future.wait(
      [
        getCountries(),
        getServices(shopId: isUpdate ? widget.shop!.id : 0),
      ],
    );
  }

  /// Demo services for UI testing
  List<ServiceData> _getDemoServiceList() {
    return [
      ServiceData(id: 1, name: 'Filter Replacement', isSelected: true),
      ServiceData(id: 2, name: 'Office Cleaning', isSelected: true),
      ServiceData(id: 3, name: 'Leak Repair', isSelected: false),
      ServiceData(id: 4, name: 'Car Interior Sanitization', isSelected: false),
      ServiceData(id: 5, name: 'Filter Replacement', isSelected: false),
      ServiceData(id: 6, name: 'Full Home Sanitization', isSelected: false),
      ServiceData(id: 7, name: 'Deep Cleaning', isSelected: false),
      ServiceData(id: 8, name: 'Pest Control', isSelected: false),
      ServiceData(id: 9, name: 'AC Service', isSelected: false),
      ServiceData(id: 10, name: 'Plumbing Repair', isSelected: false),
    ];
  }

  Future<void> getCountries() async {
    appStore.setLoading(true);
    await getCountryList().then((value) async {
      countryList.clear();
      countryList.addAll(value);
      if (isUpdate && shopDetails!.countryId.validate() > 0) {
        if (countryList.isNotEmpty && selectedCountry == null && isUpdate) {
          if (countryList
              .any((element) => element.id == shopDetails!.countryId)) {
            selectedCountry = countryList
                .firstWhere((element) => element.id == shopDetails!.countryId);
            getStates(selectedCountry!.id.validate()).then(
              (value) {
                if (stateList.isNotEmpty && selectedState == null && isUpdate) {
                  if (stateList
                      .any((element) => element.id == shopDetails!.stateId)) {
                    selectedState = stateList.firstWhere(
                        (element) => element.id == shopDetails!.stateId);
                    getCities(selectedState!.id.validate()).then(
                      (value) {
                        if (cityList.isNotEmpty &&
                            selectedCity == null &&
                            isUpdate) {
                          if (cityList.any(
                              (element) => element.id == shopDetails!.cityId)) {
                            selectedCity = cityList.firstWhere(
                                (element) => element.id == shopDetails!.cityId);
                          }
                        }
                      },
                    );
                  }
                }
              },
            );
          }
        }
      }
      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    });
    appStore.setLoading(false);
  }

  Future<void> getStates(int countryId) async {
    if (countryId == 0) return;
    appStore.setLoading(true);
    await getStateList({'country_id': countryId})
        .then((value) async {
          stateList.clear();
          stateList.addAll(value);
          setState(() {});
        })
        .whenComplete(() => appStore.setLoading(false))
        .catchError((e) {
          toast('$e', print: true);
        });
  }

  Future<void> getCities(int stateId) async {
    if (stateId == 0) return;
    appStore.setLoading(true);

    await getCityList({'state_id': stateId}).then((value) async {
      cityList.clear();
      cityList.addAll(value);

      setState(() {});
    }).catchError((e) {
      toast('$e', print: true);
    }).whenComplete(() => appStore.setLoading(false));
  }

  Future<void> getServices({int shopId = 0}) async {
    appStore.setLoading(true);
    await getSearchList(
      servicePage,
      providerId: appStore.userId.validate(),
      perPage: shopId > 0 ? PER_PAGE_ITEM_ALL : 10,
      status: VISIT_OPTION_SHOP,
      services: serviceList,
      shopId: shopId > 0 ? shopId.toString() : '',
      lastPageCallback: (isLast) {
        isLastPage = isLast;
      },
    ).then(
      (value) {
        if (isUpdate && shopId > 0) {
          final Set<String> selectedIds =
              shopDetails?.services.map((e) => e.id.toString()).toSet() ?? {};
          for (var s in serviceList) {
            if (selectedIds.contains(s.id.toString())) {
              s.isSelected = true;
            }
          }
        }

        setState(() {});
      },
    ).catchError((e) {
      toast('$e', print: true);
    }).whenComplete(() => appStore.setLoading(false));

    // Ensure at least 5 services available initially in edit mode by fetching
    // additional unselected services from the general list (without shopId)
    // if the first fetch returned only a few selected items.
    if (isUpdate && shopId > 0 && servicePage == 1 && serviceList.length < 5) {
      appStore.setLoading(true);
      await getSearchList(
        servicePage,
        providerId: appStore.userId.validate(),
        perPage: 10,
        status: VISIT_OPTION_SHOP,
        services: serviceList,
        shopId: '',
        lastPageCallback: (isLast) {
          isLastPage = isLast;
        },
      ).then((value) {
        // Re-apply selection flags based on shop details (robust string compare)
        final Set<String> selectedIds =
            shopDetails?.services.map((e) => e.id.toString()).toSet() ?? {};
        for (var s in serviceList) {
          s.isSelected = selectedIds.contains(s.id.toString());
        }

        // Deduplicate by id while preserving order
        final Map<int?, ServiceData> byId = {};
        final List<ServiceData> deduped = [];
        for (final s in serviceList) {
          if (!byId.containsKey(s.id)) {
            byId[s.id] = s;
            deduped.add(s);
          }
        }
        serviceList
          ..clear()
          ..addAll(deduped);

        setState(() {});
      }).catchError((e) {
        toast('$e', print: true);
      }).whenComplete(() => appStore.setLoading(false));
    }
  }

  Future<void> getShopDetails() async {
    appStore.setLoading(true);

    await getShopDetail(widget.shop!.id)
        .then(
          (value) async {
            shopDetails = value.shopDetail;

            // Load translations if available
            if (shopDetails!.translations?.isNotEmpty ?? false) {
              translations = Map.from(shopDetails!.translations!);
              if (translations.containsKey(DEFAULT_LANGUAGE)) {
                enTranslations = translations[DEFAULT_LANGUAGE]!;
                translations.remove(DEFAULT_LANGUAGE);
              }
            }

            // Use translated name if available, otherwise use default name
            nameController.text = enTranslations.name.validate().isNotEmpty
                ? enTranslations.name.validate()
                : shopDetails!.name;

            addressController.text = shopDetails!.address;
            regNoController.text = shopDetails!.registrationNumber;
            latitudeController.text =
                shopDetails!.latitude.validate().toString();
            longitudeController.text =
                shopDetails!.longitude.validate().toString();
            emailController.text = shopDetails!.email;
            mobileController.text = shopDetails!.contactNumber;
            try {
              final phoneData =
                  shopDetails!.contactNumber.extractPhoneCodeAndNumber;
              mobileController.text = phoneData.$2;
              final phoneCode = phoneData.$1;
              if (phoneCode.isNotEmpty && phoneCode != "0") {
                try {
                  selectedCountryPicker =
                      CountryParser.parsePhoneCode(phoneCode);
                } catch (parseError) {
                  final countries = CountryService().getAll();
                  final matchingCountries =
                      countries.where((c) => c.phoneCode == phoneCode).toList();

                  if (matchingCountries.isNotEmpty) {
                    matchingCountries
                        .sort((a, b) => a.name.length.compareTo(b.name.length));
                    selectedCountryPicker = matchingCountries.first;
                  } else {
                    log("No country found for phone code: $phoneCode");
                  }
                }
              } else {
                log("Invalid phone code: $phoneCode");
              }
            } catch (e) {
              selectedCountryPicker =
                  Country.from(json: defaultCountry().toJson());
              mobileController.text = shopDetails!.contactNumber.trim();
            }

            selectedImages = List<String>.from(shopDetails!.shopImage);
            if (shopDetails!.shopStartTime.validate().isNotEmpty) {
              shopStartTime =
                  parseTimeOfDay(shopDetails!.shopStartTime.validate());
              shopStartTimeController.text = formatTime24(shopStartTime!);
            }

            if (shopDetails!.shopEndTime.validate().isNotEmpty) {
              shopEndTime = parseTimeOfDay(shopDetails!.shopEndTime.validate());
              shopEndTimeController.text = formatTime24(shopEndTime!);
            }

            setState(() {});
          },
        )
        .whenComplete(() => appStore.setLoading(false))
        .catchError((e) {
          toast('$e', print: true);
        });
  }

  Future<void> onNextPage() async {
    if (appStore.isLoading) return;
    if (!isLastPage) {
      servicePage++;
      await getServices();
    }
  }

  Future<void> onBackToFirstPage() async {
    if (appStore.isLoading) return;
    setState(() {
      servicePage = 1;
      isLastPage = false;
    });
    await getServices(shopId: isUpdate ? widget.shop!.id : 0);
  }

  Future<void> saveShop() async {
    if (appStore.isLoading) return;

    if (_formKey.currentState!.validate()) {
      hideKeyboard(context);
      _formKey.currentState!.save();
      if (!serviceList.any((element) => element.isSelected.validate())) {
        toast(languages.pleaseSelectService);
        return;
      }

      // Save current translation before submitting
      updateTranslation();
      removeEnTranslations();

      appStore.setLoading(true);

      final Map<String, dynamic> fields = {
        ShopKeys.providerId: appStore.userId.toString(),
        ShopKeys.shopName: enTranslations.name.validate().isNotEmpty
            ? enTranslations.name.validate()
            : nameController.text.trim(),
        ShopKeys.countryId: selectedCountry?.id.toString() ?? '',
        ShopKeys.stateId: selectedState?.id.toString() ?? '',
        ShopKeys.cityId: selectedCity?.id.toString() ?? '',
        ShopKeys.address: addressController.text.trim(),
        ShopKeys.latitude: latitudeController.text.trim(),
        ShopKeys.longitude: longitudeController.text.trim(),
        ShopKeys.registrationNumber: regNoController.text.trim(),
        ShopKeys.shopStartTime: formatTime24(shopStartTime!),
        ShopKeys.shopEndTime: formatTime24(shopEndTime!),
        ShopKeys.contactNumber: buildMobileNumber(),
        ShopKeys.email: emailController.text.trim(),
      };

      // Add translations if available
      if (translations.isNotEmpty) {
        fields[ShopKeys.translations] = jsonEncode(translations);
      }

      if (serviceList.any((element) => element.isSelected.validate())) {
        serviceList
            .where((element) => element.isSelected.validate())
            .forEachIndexed((element, index) {
          fields['${ShopKeys.serviceIds}[$index]'] = element.id;
        });
      }

      if (isUpdate) {
        List<String> existingImages = widget.shop!.shopImage
            .validate()
            .where((path) => path.startsWith('http'))
            .toList();
        if (existingImages.isNotEmpty) {
          fields[ShopKeys.existingImages] = existingImages.join(',');
        }
      }

      final images = selectedImages
          .where((path) => !path.startsWith('http'))
          .map((e) => File(e))
          .toList();

      await addEditShopMultiPart(
        data: fields,
        images: images,
        shopId: isUpdate ? widget.shop!.id : 0,
      ).then(
        (value) {
          finish(context, true);
        },
      ).catchError((e) {
        toast(e.toString());
      }).whenComplete(() => appStore.setLoading(false));
    } else {
      isFirstTime = false;
      setState(() {});
    }
  }

  //region Validation Methods

  String? validateRegNo() {
    final value = regNoController.text;
    if (value.trim().isEmpty) {
      return languages.hintRequired;
    } else if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(value.trim())) {
      return languages.invalidInput;
    } else {
      return null;
    }
  }

  String? validateLatitude() {
    final value = latitudeController.text;
    if (value.trim().isEmpty) {
      return languages.latitudeIsRequired;
    } else {
      final lat = double.tryParse(value.trim());
      if (lat == null || lat < -90 || lat > 90) {
        return languages.latitudeRange;
      } else {
        return null;
      }
    }
  }

  String? validateLongitude() {
    final value = longitudeController.text;
    if (value.isEmpty) {
      return languages.longitudeIsRequired;
    }

    final double? longitude = double.tryParse(value);

    if (longitude.validate() < -180 || longitude.validate() > 180) {
      return languages.longitudeRange;
    }

    return null;
  }

  //endregion

  TimeOfDay parseTimeOfDay(String time) {
    if (time.isEmpty) return TimeOfDay.now();

    if (time.contains('T')) {
      final dt = DateTime.tryParse(time);
      if (dt != null) {
        return TimeOfDay(hour: dt.hour, minute: dt.minute);
      }
    }

    try {
      final parts = time.split(":");
      if (parts.length < 2) return TimeOfDay.now();

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1].split(" ")[0]) ?? 0;
      final isPM = time.toLowerCase().contains("pm");
      return TimeOfDay(
          hour: isPM ? (hour % 12) + 12 : hour % 12, minute: minute);
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    if (mounted) {
      nameController.dispose();
      addressController.dispose();
      regNoController.dispose();
      latitudeController.dispose();
      longitudeController.dispose();
      contactController.dispose();
      emailController.dispose();
      mobileController.dispose();
    }
    appStore.setLoading(false);
    super.dispose();
  }

  Future<void> fetchCurrentLocation() async {
    appStore.setLoading(true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          latitudeController.text = position.latitude.toString();
          longitudeController.text = position.longitude.toString();
        });
      }
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks.first;
          String address = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.postalCode,
            place.country
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          setState(() {
            addressController.text = address;
          });
        }
      } catch (e) {
        toast(e.toString());
      }
    } catch (e) {
      if (mounted) {
        toast(e.toString());
      }
    } finally {
      appStore.setLoading(false);
    }
  }

  //----------------------------- Helper Functions----------------------------//
  // Change country code function...
  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(0),
        bottomSheetHeight: 600,
        textStyle: context.primaryTextStyle(),
        searchTextStyle: context.primaryTextStyle(
          color: context.searchTextColor,
        ),
        backgroundColor: context.bottomSheetBackgroundColor,
        inputDecoration: InputDecoration(
          fillColor: context.searchFillColor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          hintText: languages.search,
          hintStyle: context.primaryTextStyle(
            size: 14,
            color: context.searchHintColor,
          ),
          prefixIcon: Icon(Icons.search, color: context.searchHintColor),
        ),
      ),
      showPhoneCode: true,
      // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountryPicker = country;
        _valueNotifier.value = !_valueNotifier.value;
      },
    );
  }

  // Build mobile number with phone code and number
  String buildMobileNumber() {
    if (mobileController.text.isEmpty) {
      return '';
    } else {
      return '+${selectedCountryPicker.phoneCode} ${mobileController.text.trim()}';
    }
  }

  //region Multilanguage Support Methods

  /// Updates the translations map with current form values
  void updateTranslation() {
    appStore.setLoading(true);
    final languageCode = appStore.selectedLanguage.languageCode.validate();
    if (nameController.text.isEmpty) {
      translations.remove(languageCode);
    } else {
      if (languageCode != DEFAULT_LANGUAGE) {
        translations[languageCode] = translations[languageCode]?.copyWith(
              name: nameController.text.validate(),
            ) ??
            MultiLanguageRequest(
              name: nameController.text.validate(),
            );
      } else {
        enTranslations = enTranslations.copyWith(
          name: nameController.text.validate(),
        );
      }
    }
    appStore.setLoading(false);
    log("Updated Translations: ${jsonEncode(translations.map((key, value) => MapEntry(key, value.toJson())))}");
  }

  /// Retrieves translations for the currently selected language
  void getTranslation() {
    final languageCode = appStore.selectedLanguage.languageCode;
    if (languageCode == DEFAULT_LANGUAGE) {
      nameController.text = enTranslations.name.validate();
    } else {
      final translation = translations[languageCode] ?? MultiLanguageRequest();
      nameController.text = translation.name.validate();
    }
    setState(() {});
  }

  /// Clears translation-related text fields when switching languages
  void disposeAllTextFieldsController() {
    nameController.clear();
    setState(() {});
  }

  /// Returns true if validation is required (only for default language)
  bool checkValidationLanguage() {
    log("language Code ==> ${appStore.selectedLanguage.languageCode}");
    if (appStore.selectedLanguage.languageCode == DEFAULT_LANGUAGE) {
      return true;
    } else {
      return false;
    }
  }

  /// Handles language change from MultiLanguageWidget
  Future<void> handleLanguageChange(LanguageDataModel code) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      hideKeyboard(context);
      updateTranslation();

      appStore.setSelectedLanguage(code);
      disposeAllTextFieldsController();
      getTranslation();
      await checkValidationLanguage();
      setState(() => formWidgetKey = UniqueKey());
    }
  }

  /// Removes English translations before submission (they're sent separately)
  void removeEnTranslations() {
    if (translations.containsKey(DEFAULT_LANGUAGE)) {
      translations.remove(DEFAULT_LANGUAGE);
    }
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // Order services with selected first
    final List<ServiceData> _selectedServices =
        serviceList.where((s) => s.isSelected.validate()).toList();
    final List<ServiceData> _unselectedServices =
        serviceList.where((s) => !s.isSelected.validate()).toList();
    final List<ServiceData> _fullSortedServices = [
      ..._selectedServices,
      ..._unselectedServices
    ];

    // First page should show up to 5: selected first, then unselected
    final List<ServiceData> _initialDisplayServices = () {
      const int minCount = 5;
      if (_selectedServices.length >= minCount) return _selectedServices;
      final int need = minCount - _selectedServices.length;
      return [..._selectedServices, ..._unselectedServices.take(need)];
    }();

    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.primary,
        leading: BackWidget(color: context.onPrimary),
        title: Text(
          isUpdate ? languages.editShop : languages.addNewShop,
          style: context.boldTextStyle(color: context.onPrimary, size: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              8.height,
              MultiLanguageWidget(onTap: (LanguageDataModel code) {
                handleLanguageChange(code);
              }),
              8.height,
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 90),
                child: Form(
                  key: _formKey,
                  autovalidateMode: isFirstTime
                      ? AutovalidateMode.disabled
                      : AutovalidateMode.onUserInteraction,
                  child: Column(
                    key: formWidgetKey,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker
                      CustomImagePicker(
                        isMultipleImages: true,
                        key: ValueKey(selectedImages.length),
                        selectedImages: selectedImages,
                        height: 140,
                        width: double.infinity,
                        onFileSelected: (files) {
                          if (mounted) {
                            setState(() {
                              selectedImages =
                                  files.map((f) => f.path).toList();
                            });
                          }
                        },
                        onRemoveClick: (path) {
                          if (mounted) {
                            showConfirmDialogCustom(
                              context,
                              height: 80,
                              width: 290,
                              shape: appDialogShape(8),
                              dialogType: DialogType.DELETE,
                              title: languages.lblDoYouWantToDelete,
                              titleColor: context.dialogTitleColor,
                              backgroundColor: context.dialogBackgroundColor,
                              primaryColor: context.error,
                              customCenterWidget: Image.asset(
                                ic_warning,
                                color: context.dialogIconColor,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                              positiveText: languages.lblDelete,
                              positiveTextColor: context.onPrimary,
                              negativeText: languages.lblCancel,
                              negativeTextColor: context.dialogCancelColor,
                              onAccept: (p0) {
                                if (mounted) {
                                  setState(() {
                                    selectedImages.remove(path);
                                  });
                                }
                              },
                            );
                          }
                        },
                      ),

                      24.height,

                      // Shop Name
                      Text(languages.shop, style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: nameController,
                        focus: shopNameFocus,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.shop,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: Icon(Icons.storefront_outlined,
                                  size: 20, color: context.iconMuted)
                              .paddingAll(14),
                        ),
                        nextFocus: registrationNumberFocus,
                        isValidationRequired: true,
                        errorThisFieldRequired: languages.hintRequired,
                      ),

                      16.height,

                      // Registration Number
                      Text(languages.registrationNumber,
                          style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: TextFieldType.NAME,
                        controller: regNoController,
                        focus: registrationNumberFocus,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.registrationNumber,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: Icon(Icons.badge_outlined,
                                  size: 20, color: context.iconMuted)
                              .paddingAll(14),
                        ),
                        isValidationRequired: true,
                        errorThisFieldRequired: languages.hintRequired,
                        nextFocus: countryFocus,
                      ),

                      16.height,

                      // Country & State Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(languages.selectCountry,
                                    style: context.boldTextStyle()),
                                8.height,
                                DropdownButtonFormField<CountryListResponse>(
                                  decoration: inputDecoration(
                                    context,
                                    hintText: languages.selectCountry,
                                    fillColor: context.profileInputFillColor,
                                    borderRadius: 8,
                                  ),
                                  isExpanded: true,
                                  menuMaxHeight: 300,
                                  value: countryList.any((item) =>
                                          item.id == selectedCountry?.id)
                                      ? selectedCountry
                                      : null,
                                  dropdownColor: context.cardSecondary,
                                  icon: Icon(Icons.keyboard_arrow_down,
                                      color: context.icon),
                                  validator: (value) {
                                    if (value == null)
                                      return languages.hintRequired;
                                    return null;
                                  },
                                  items:
                                      countryList.map((CountryListResponse e) {
                                    return DropdownMenuItem<
                                        CountryListResponse>(
                                      value: e,
                                      child: Text(e.name.validate(),
                                          style: context.primaryTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged:
                                      (CountryListResponse? value) async {
                                    selectedCountry = value;
                                    selectedState = null;
                                    selectedCity = null;
                                    await getStates(selectedCountry!.id!);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          16.width,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(languages.selectState,
                                    style: context.boldTextStyle()),
                                8.height,
                                DropdownButtonFormField<StateListResponse>(
                                  decoration: inputDecoration(
                                    context,
                                    hintText: languages.selectState,
                                    fillColor: context.profileInputFillColor,
                                    borderRadius: 8,
                                  ),
                                  isExpanded: true,
                                  dropdownColor: context.cardSecondary,
                                  menuMaxHeight: 300,
                                  icon: Icon(Icons.keyboard_arrow_down,
                                      color: context.icon),
                                  value: (stateList.isNotEmpty &&
                                          selectedState != null &&
                                          stateList.any((item) =>
                                              item.id == selectedState?.id))
                                      ? selectedState
                                      : null,
                                  validator: (value) {
                                    if (value == null)
                                      return languages.hintRequired;
                                    return null;
                                  },
                                  items: stateList.map((StateListResponse e) {
                                    return DropdownMenuItem<StateListResponse>(
                                      value: e,
                                      child: Text(e.name!,
                                          style: context.primaryTextStyle(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (StateListResponse? value) async {
                                    selectedState = value;
                                    selectedCity = null;
                                    await getCities(selectedState!.id!);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      16.height,

                      // City
                      Text(languages.selectCity,
                          style: context.boldTextStyle()),
                      8.height,
                      DropdownButtonFormField<CityListResponse>(
                        decoration: inputDecoration(
                          context,
                          hintText: languages.selectCity,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                        ),
                        isExpanded: true,
                        value:
                            cityList.any((item) => item.id == selectedCity?.id)
                                ? selectedCity
                                : null,
                        dropdownColor: context.cardSecondary,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: context.icon),
                        validator: (value) {
                          if (value == null) return languages.hintRequired;
                          return null;
                        },
                        items: cityList.map(
                          (CityListResponse e) {
                            return DropdownMenuItem<CityListResponse>(
                              value: e,
                              child: Text(e.name!,
                                  style: context.primaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            );
                          },
                        ).toList(),
                        onChanged: (CityListResponse? value) async {
                          selectedCity = value;
                          setState(() {});
                        },
                      ),

                      16.height,

                      // Address
                      Text(languages.hintAddress,
                          style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: TextFieldType.MULTILINE,
                        controller: addressController,
                        focus: addressFocus,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.hintAddress,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: Icon(Icons.location_on_outlined,
                                  size: 20, color: context.iconMuted)
                              .paddingAll(14),
                        ),
                        nextFocus: latitudeFocus,
                        isValidationRequired: true,
                        errorThisFieldRequired: languages.hintRequired,
                      ),

                      16.height,

                      // Latitude
                      Text(languages.latitude, style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: TextFieldType.NUMBER,
                        controller: latitudeController,
                        focus: latitudeFocus,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.latitude,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: Icon(Icons.map_outlined,
                                  size: 20, color: context.iconMuted)
                              .paddingAll(14),
                        ),
                        nextFocus: longitudeFocus,
                      ),

                      16.height,

                      // Longitude
                      Text(languages.longitude, style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: TextFieldType.NUMBER,
                        controller: longitudeController,
                        focus: longitudeFocus,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.longitude,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: Icon(Icons.map_outlined,
                                  size: 20, color: context.iconMuted)
                              .paddingAll(14),
                        ),
                        isValidationRequired: true,
                        errorThisFieldRequired: languages.hintRequired,
                        nextFocus: shopStartTimeFocus,
                      ),

                      8.height,

                      // Use Current Location
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: fetchCurrentLocation,
                          icon: Icon(Icons.my_location,
                              color: context.primary, size: 16),
                          label: Text(
                            languages.useCurrentLocation,
                            style: context.boldTextStyle(
                                size: 12, color: context.primary),
                          ),
                        ),
                      ),

                      8.height,

                      // Shop Start Time
                      Text(languages.shopStartTime,
                          style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: TextFieldType.OTHER,
                        controller: shopStartTimeController,
                        focus: shopStartTimeFocus,
                        nextFocus: shopEndTimeFocus,
                        isValidationRequired: true,
                        readOnly: true,
                        errorThisFieldRequired: languages.hintRequired,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.shopStartTime,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: Icon(Icons.access_time,
                                  size: 20, color: context.iconMuted)
                              .paddingAll(14),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime:
                                shopStartTime ?? TimeOfDay(hour: 9, minute: 0),
                          );
                          if (picked != null) {
                            shopStartTime = picked;
                            shopStartTimeController.text = formatTime24(picked);
                            setState(() {});
                          }
                        },
                      ),

                      16.height,

                      // Shop End Time
                      Text(languages.shopEndTime,
                          style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: TextFieldType.OTHER,
                        controller: shopEndTimeController,
                        focus: shopEndTimeFocus,
                        nextFocus: contactNumberFocus,
                        isValidationRequired: true,
                        readOnly: true,
                        errorThisFieldRequired: languages.hintRequired,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.shopEndTime,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: Icon(Icons.access_time,
                                  size: 20, color: context.iconMuted)
                              .paddingAll(14),
                        ),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: shopEndTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) {
                            shopEndTime = picked;
                            shopEndTimeController.text = formatTime24(picked);
                            setState(() {});
                          }
                        },
                      ),
                      16.height,

                      // Email
                      Text(languages.hintEmailAddressTxt,
                          style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: TextFieldType.EMAIL_ENHANCED,
                        controller: emailController,
                        focus: emailFocus,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.hintEmailAddressTxt,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: Icon(Icons.email_outlined,
                                  size: 20, color: context.iconMuted)
                              .paddingAll(14),
                        ),
                        isValidationRequired: true,
                        errorThisFieldRequired: languages.hintRequired,
                        errorInvalidEmail: languages.enterValidEmail,
                      ),

                      16.height,
                      // Phone Number
                      Text(languages.hintContactNumberTxt,
                          style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        textFieldType: isAndroid
                            ? TextFieldType.PHONE
                            : TextFieldType.NAME,
                        controller: mobileController,
                        focus: contactNumberFocus,
                        nextFocus: emailFocus,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.addYourPhoneNumber,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                          prefixIcon: GestureDetector(
                            onTap: () => changeCountry(),
                            child: ValueListenableBuilder(
                              valueListenable: _valueNotifier,
                              builder: (context, value, child) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "+${selectedCountryPicker.phoneCode}",
                                    style: context.boldTextStyle(size: 14),
                                  ),
                                  2.width,
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: context.icon,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ).paddingAll(14),
                        ),
                        maxLength: 15,
                        buildCounter: (context,
                                {required currentLength,
                                required isFocused,
                                maxLength}) =>
                            null,
                      ),

                      24.height,

                      // Select Service Section
                      Container(
                        width: context.width(),
                        decoration: BoxDecoration(
                          color: context.cardSecondary,
                          borderRadius: radius(12),
                          border:
                              Border.all(color: context.cardSecondaryBorder),
                        ),
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              languages.selectService,
                              style: context.boldTextStyle(),
                            ),
                            16.height,
                            if (serviceList.isEmpty)
                              Text(
                                languages.noServiceFound,
                                style: context.secondaryTextStyle(),
                              ).center(),
                            if (serviceList.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    color: context.selectServiceContainerColor,
                                    borderRadius: radius(8),
                                    border: Border.all(
                                        color: context.cardSecondaryBorder)),
                                child: Column(
                                  children: [
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: servicePage == 1
                                          ? _initialDisplayServices.length
                                          : _fullSortedServices.length,
                                      separatorBuilder: (context, index) =>
                                          8.height,
                                      itemBuilder: (context, index) {
                                        final List<ServiceData> _displayList =
                                            servicePage == 1
                                                ? _initialDisplayServices
                                                : _fullSortedServices;
                                        ServiceData service =
                                            _displayList[index];
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              service.isSelected = !service
                                                  .isSelected
                                                  .validate();
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  service.name.validate(),
                                                  style:
                                                      context.primaryTextStyle(
                                                          size: 14),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              8.width,
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  color: service.isSelected
                                                          .validate()
                                                      ? context.primary
                                                      : Colors.transparent,
                                                  borderRadius: radius(4),
                                                  border: Border.all(
                                                    color: service.isSelected
                                                            .validate()
                                                        ? context.primary
                                                        : context.iconMuted,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: service.isSelected
                                                        .validate()
                                                    ? Icon(
                                                        Icons.check,
                                                        size: 14,
                                                        color:
                                                            context.onPrimary,
                                                      )
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    if (serviceList.length > 5)
                                      Padding(
                                        padding: EdgeInsets.only(top: 12),
                                        child: GestureDetector(
                                          onTap: isLastPage
                                              ? onBackToFirstPage
                                              : onNextPage,
                                          child: Text(
                                            isLastPage
                                                ? languages.viewLess
                                                : languages.viewMore,
                                            style: context.primaryTextStyle(
                                                color: context.primary,
                                                size: 12),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      100.height,
                    ],
                  ),
                ),
              ).expand(),
            ],
          ),
          // Save Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Observer(
              builder: (_) => AppButton(
                text: languages.btnSave,
                color: context.primary,
                textStyle: context.boldTextStyle(color: context.onPrimary),
                width: context.width(),
                onTap: appStore.isLoading ? null : saveShop,
              ),
            ),
          ),

          // Loader
          Observer(
              builder: (_) =>
                  LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
