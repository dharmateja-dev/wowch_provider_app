/// Demo Data Provider
/// This file provides comprehensive dummy data for all screens in the app.
/// Used for UI testing without backend.

import 'dart:convert';

import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart'
    as dashboard;
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart'
    as handyman;
import 'package:handyman_provider_flutter/models/notification_list_response.dart';
import 'package:handyman_provider_flutter/models/payment_list_reasponse.dart';
import 'package:handyman_provider_flutter/models/revenue_chart_data.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/shop_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/provider_info_model.dart';
import 'package:handyman_provider_flutter/utils/common.dart';

/// Demo Dashboard Data for Provider
class DemoDashboardData {
  /// Generate demo provider dashboard response
  static dashboard.DashboardResponse get providerDashboard =>
      dashboard.DashboardResponse(
        status: true,
        totalBooking: 156,
        totalService: 12,
        todayCashAmount: 2450.00,
        totalCashInHand: 15680.50,
        totalActiveHandyman: 8,
        totalRevenue: 125000.00,
        isEmailVerified: 1,
        notificationUnreadCount: 5,
        remainingPayout: 8500.00,
        service: demoServices,
        handyman: demoHandymen,
        upcomingBookings: demoBookings,
        commission: dashboard.Commission(
          id: 1,
          name: 'Standard Commission',
          commission: 15,
          type: COMMISSION_TYPE_PERCENT,
          status: 1,
          createdAt: '2023-01-01 00:00:00',
          updatedAt: '2023-06-15 10:30:00',
        ),
        providerWallet: dashboard.ProviderWallet(
          1,
          'Provider Wallet',
          1,
          15680.50,
          1,
          '2023-01-15 10:30:00',
          '2024-01-10 14:20:00',
        ),
        onlineHandyman: [
          'https://i.pravatar.cc/300?u=mike',
          'https://i.pravatar.cc/300?u=david',
          'https://i.pravatar.cc/300?u=james',
        ],
      );

  /// Generate demo handyman dashboard response
  static handyman.HandymanDashBoardResponse get handymanDashboard =>
      handyman.HandymanDashBoardResponse(
        status: true,
        totalBooking: 45,
        todayBooking: 3,
        totalRevenue: 25000.00,
        todayCashAmount: 350.00,
        totalCashInHand: 5000.00,
        isHandymanAvailable: 1,
        completedBooking: 42,
        isEmailVerified: 1,
        notificationUnreadCount: 3,
        upcomingBookings: demoBookings.take(3).toList(),
        commission: handyman.Commission(
          id: 1,
          name: 'Handyman Commission',
          commission: 10,
          type: COMMISSION_TYPE_PERCENT,
          status: 1,
        ),
      );

  /// Demo Revenue Chart Data
  static List<RevenueChartData> get revenueChartData => [
        RevenueChartData(month: 'Jan', revenue: 12500),
        RevenueChartData(month: 'Feb', revenue: 15000),
        RevenueChartData(month: 'Mar', revenue: 11800),
        RevenueChartData(month: 'Apr', revenue: 18200),
        RevenueChartData(month: 'May', revenue: 16500),
        RevenueChartData(month: 'Jun', revenue: 21000),
        RevenueChartData(month: 'Jul', revenue: 19500),
        RevenueChartData(month: 'Aug', revenue: 22000),
        RevenueChartData(month: 'Sep', revenue: 17800),
        RevenueChartData(month: 'Oct', revenue: 20500),
        RevenueChartData(month: 'Nov', revenue: 23000),
        RevenueChartData(month: 'Dec', revenue: 25000),
      ];
}

/// Demo Handyman Data
class DemoHandymanData {
  /// Generate demo handyman info response
  static HandymanInfoResponse get handymanInfoResponse => HandymanInfoResponse(
        handymanData: UserData(
          id: 1,
          firstName: 'Michael',
          lastName: 'Smith',
          displayName: 'Michael Smith',
          email: 'michael.handyman@demo.com',
          contactNumber: '+1 555-0123',
          profileImage: 'https://i.pravatar.cc/300?u=michael',
          designation: 'Senior Electrician & Handyman',
          description:
              'Expert handyman with over 10 years of experience in residential electrical wiring, repair, and general home maintenance.',
          address: '456 Handyman St, Tech City, NY',
          createdAt:
              DateTime.now().subtract(const Duration(days: 730)).toString(),
          totalBooking: 456,
          handymanRating: 4,
          knownLanguages: jsonEncode(['English', 'Spanish', 'German']),
          skills:
              jsonEncode(['Electrical Wiring', 'Appliance Repair', 'Plumbing']),
        ),
        service: demoServices.take(2).toList(),
        handymanRatingReview: [
          RatingData(
            id: 1,
            rating: 5,
            review:
                'Professional and quick service. Michael even fixed a loose outlet for free!',
            customerName: 'Alice Johnson',
            customerProfileImage: 'https://i.pravatar.cc/300?u=alice',
            createdAt: '2024-03-15 10:30:00',
          ),
          RatingData(
            id: 2,
            rating: 4,
            review:
                'Very knowledgeable. Arrived on time and solved the issue efficiently.',
            customerName: 'Bob Williams',
            customerProfileImage: 'https://i.pravatar.cc/300?u=bob',
            createdAt: '2024-03-10 14:20:00',
          ),
        ],
      );
}

/// Demo Shops List for testing shop filters
List<ShopModel> get demoShops => [
      ShopModel(
        id: 1,
        name: 'Ayush Home Services',
        address: '65A, Indrapuri, Bhopal, M.P.',
        shopStartTime: '9:00 AM',
        shopEndTime: '6:00 PM',
        cityName: 'Bhopal',
        stateName: 'Madhya Pradesh',
        countryName: 'India',
        shopImage: [],
        providerId: 1,
        providerName: 'John Williams',
        services: [],
      ),
      ShopModel(
        id: 2,
        name: 'Prime Home Services',
        address: '123 Main Street, Downtown',
        shopStartTime: '8:00 AM',
        shopEndTime: '8:00 PM',
        cityName: 'Mumbai',
        stateName: 'Maharashtra',
        countryName: 'India',
        shopImage: [],
        providerId: 1,
        providerName: 'John Williams',
        services: [],
      ),
      ShopModel(
        id: 3,
        name: 'Quick Fix Station',
        address: '456 Oak Avenue, Residency',
        shopStartTime: '10:00 AM',
        shopEndTime: '7:00 PM',
        cityName: 'Delhi',
        stateName: 'Delhi',
        countryName: 'India',
        shopImage: [],
        providerId: 1,
        providerName: 'John Williams',
        services: [],
      ),
    ];

/// Demo Services List
List<ServiceData> get demoServices => [
      ServiceData(
        id: 1,
        name: 'Home Cleaning',
        categoryId: 1,
        categoryName: 'Cleaning',
        providerId: 1,
        providerName: 'John Provider',
        price: 75.00,
        type: SERVICE_TYPE_FIXED,
        discount: 10,
        duration: '02:00',
        status: 1,
        description:
            'Professional home cleaning service including dusting, mopping, and sanitization.',
        isFeatured: 1,
        totalReview: 45,
        totalRating: 4.8,
        visitType: VISIT_OPTION_ON_SITE,
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
      ),
      ServiceData(
        id: 2,
        name: 'Electrical Repair',
        categoryId: 2,
        categoryName: 'Electrical',
        providerId: 1,
        providerName: 'John Provider',
        price: 50.00,
        type: SERVICE_TYPE_HOURLY,
        discount: 0,
        duration: '01:00',
        status: 1,
        description:
            'Expert electrical repair services for all household needs.',
        isFeatured: 1,
        totalReview: 32,
        totalRating: 4.6,
        visitType: VISIT_OPTION_ON_SITE,
        imageAttachments: [
          'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400',
        ],
      ),
      ServiceData(
        id: 3,
        name: 'Plumbing Service',
        categoryId: 3,
        categoryName: 'Plumbing',
        providerId: 1,
        providerName: 'John Provider',
        price: 60.00,
        type: SERVICE_TYPE_HOURLY,
        discount: 5,
        duration: '01:30',
        status: 1,
        description:
            'Professional plumbing services including leak repair, pipe fitting, and drainage.',
        isFeatured: 0,
        totalReview: 28,
        totalRating: 4.5,
        visitType: VISIT_OPTION_ON_SITE,
        imageAttachments: [
          'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=400',
        ],
      ),
      ServiceData(
        id: 4,
        name: 'AC Repair & Service',
        categoryId: 4,
        categoryName: 'Appliance',
        providerId: 1,
        providerName: 'John Provider',
        price: 85.00,
        type: SERVICE_TYPE_FIXED,
        discount: 15,
        duration: '02:30',
        status: 1,
        description:
            'Complete AC repair and maintenance service including gas refill and cleaning.',
        isFeatured: 1,
        totalReview: 56,
        totalRating: 4.9,
        visitType: VISIT_OPTION_ON_SITE,
        imageAttachments: [
          'https://images.unsplash.com/photo-1631545806609-10d45f7a8532?w=400',
        ],
      ),
      ServiceData(
        id: 5,
        name: 'Painting Service',
        categoryId: 5,
        categoryName: 'Painting',
        providerId: 1,
        providerName: 'John Provider',
        price: 40.00,
        type: SERVICE_TYPE_HOURLY,
        discount: 0,
        duration: '04:00',
        status: 1,
        description:
            'Interior and exterior painting services with premium quality paints.',
        isFeatured: 0,
        totalReview: 19,
        totalRating: 4.4,
        visitType: VISIT_OPTION_ON_SITE,
        imageAttachments: [
          'https://images.unsplash.com/photo-1562259929-b4e1fd3aef09?w=400',
        ],
      ),
      ServiceData(
        id: 6,
        name: 'Online Consultation',
        categoryId: 6,
        categoryName: 'Consulting',
        providerId: 1,
        providerName: 'John Provider',
        price: 25.00,
        type: SERVICE_TYPE_FIXED,
        discount: 0,
        duration: '00:30',
        status: 1,
        description:
            'Get expert advice online for your home improvement projects.',
        isFeatured: 0,
        totalReview: 12,
        totalRating: 4.7,
        visitType: VISIT_OPTION_ONLINE,
        imageAttachments: [
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
        ],
      ),
    ];

/// Demo Handymen List
List<UserData> get demoHandymen => [
      UserData(
        id: 2,
        firstName: 'John',
        lastName: 'Doe',
        username: 'johnd',
        email: 'john@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '91-9876543210',
        status: 1,
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/300?u=john1',
        handymanRating: 4.8,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
        handymanType: 'Company',
        handymanCommission: '60%',
        createdAt: '2023-06-15 10:30:00',
        emailVerifiedAt: '2023-06-15 11:00:00',
      ),
      UserData(
        id: 3,
        firstName: 'John',
        lastName: 'Doe',
        username: 'johnd2',
        email: 'john2@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '91-9876543211',
        status: 1,
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/300?u=john2',
        handymanRating: 4.6,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
        handymanType: 'Company',
        handymanCommission: '60%',
        createdAt: '2023-07-20 09:15:00',
        emailVerifiedAt: '2023-07-20 09:45:00',
      ),
      UserData(
        id: 4,
        firstName: 'John',
        lastName: 'Doe',
        username: 'johnd3',
        email: 'john3@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '91-9876543212',
        status: 1,
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/300?u=john3',
        handymanRating: 4.5,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
        handymanType: 'Company',
        handymanCommission: '60%',
        createdAt: '2023-08-10 14:20:00',
        emailVerifiedAt: '2023-08-10 15:00:00',
      ),
      UserData(
        id: 5,
        firstName: 'John',
        lastName: 'Doe',
        username: 'johnd4',
        email: 'john4@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '91-9876543213',
        status: 1,
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/300?u=john4',
        handymanRating: 4.7,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
        handymanType: 'Company',
        handymanCommission: '60%',
        createdAt: '2023-09-05 11:45:00',
        emailVerifiedAt: '2023-09-05 12:00:00',
      ),
      UserData(
        id: 6,
        firstName: 'John',
        lastName: 'Doe',
        username: 'johnd5',
        email: 'john5@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '91-9876543214',
        status: 1,
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/300?u=john5',
        handymanRating: 4.9,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
        handymanType: 'Company',
        handymanCommission: '60%',
        createdAt: '2023-10-01 08:00:00',
        emailVerifiedAt: '2023-10-01 09:00:00',
      ),
      UserData(
        id: 7,
        firstName: 'John',
        lastName: 'Doe',
        username: 'johnd6',
        email: 'john6@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '91-9876543215',
        status: 1,
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/300?u=john6',
        handymanRating: 4.4,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
        handymanType: 'Company',
        handymanCommission: '60%',
        createdAt: '2023-11-15 10:30:00',
        emailVerifiedAt: '2023-11-15 11:00:00',
      ),
      UserData(
        id: 8,
        firstName: 'John',
        lastName: 'Doe',
        username: 'johnd7',
        email: 'john7@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '91-9876543216',
        status: 1,
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/300?u=john7',
        handymanRating: 4.3,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
        handymanType: 'Company',
        handymanCommission: '60%',
        createdAt: '2023-12-01 14:00:00',
        emailVerifiedAt: '2023-12-01 15:00:00',
      ),
      UserData(
        id: 9,
        firstName: 'John',
        lastName: 'Doe',
        username: 'johnd8',
        email: 'john8@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '91-9876543217',
        status: 1,
        displayName: 'John Doe',
        profileImage: 'https://i.pravatar.cc/300?u=john8',
        handymanRating: 4.6,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
        handymanType: 'Company',
        handymanCommission: '60%',
        createdAt: '2023-12-15 09:00:00',
        emailVerifiedAt: '2023-12-15 10:00:00',
      ),
    ];

/// Demo Bookings List - ALL BOOKING STATUSES
/// Status types: pending, accept, on_going, in_progress, hold, cancelled,
/// rejected, failed, completed, pending_approval, waiting, paid
List<BookingData> get demoBookings => [
      // 1. ACCEPTED - Booking ID #1 (matching screenshot with Call + Chat for handyman)
      BookingData(
        id: 1,
        serviceName: 'Transmission Repair',
        serviceId: 1,
        customerName: 'Pedro Norris',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=pedro',
        providerId: 1,
        providerName: 'Pedro Norris',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_ACCEPT,
        statusLabel: 'Accepted',
        date: '2025-12-12 08:25:00',
        address: 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 42.00,
        totalAmount: 30.25,
        discount: 2,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Transmission repair service',
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
        handyman: [
          Handyman(
            id: 1,
            bookingId: 1,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
        shopInfo: demoShops[0], // Ayush Home Services
      ),

      // 2. ACCEPTED - Booking ID #2 (matching screenshot with Chat only for handyman)
      BookingData(
        id: 2,
        serviceName: 'VIP Escort Protection',
        serviceId: 2,
        customerName: 'Pedro Norris',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=pedro',
        providerId: 1,
        providerName: 'Pedro Norris',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_ACCEPT,
        statusLabel: 'Accepted',
        date: '2025-12-12 08:25:00',
        address: 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 42.00,
        totalAmount: 30.25,
        discount: 2,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'VIP escort protection service',
        startAt: '2025-12-12 08:30:00',
        endAt: '2025-12-12 10:30:00',
        totalRating: 5,
        totalReview: 1,
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
        handyman: [
          Handyman(
            id: 2,
            bookingId: 2,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
        shopInfo: demoShops[1], // Prime Home Services
      ),

      // 3. PENDING - Booking ID #3 (matching screenshot with Date & Time top section)
      BookingData(
        id: 3,
        serviceName: 'VIP Escort Protection',
        serviceId: 2,
        customerName: 'Pedro Norris',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=pedro',
        providerId: 1,
        providerName: 'Pedro Norris',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_PENDING,
        statusLabel: 'Pending',
        date: '2025-12-12 08:25:00',
        address: 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 41.00,
        totalAmount: 41.00,
        discount: 0,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'VIP escort protection service',
        startAt: '2025-12-12 08:30:00',
        endAt: '2025-12-12 10:30:00',
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
        // No handyman assigned for pending
        handyman: [],
        shopInfo: demoShops[2], // Quick Fix Station
      ),

      // 4. CANCELLED - Booking ID #5 (matching screenshot with red banner and reviews)
      BookingData(
        id: 5,
        serviceName: 'VIP Escort Protection',
        serviceId: 1,
        customerName: 'Pedro Norris',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=pedro',
        providerId: 1,
        providerName: 'Pedro Norris',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_CANCELLED,
        statusLabel: 'Cancelled',
        date: '2025-12-12 08:25:00',
        address: 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 42.00,
        totalAmount: 30.25,
        discount: 2,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        reason: 'Customer requested cancellation',
        description: 'VIP escort protection service',
        totalRating: 5,
        totalReview: 1,
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
        handyman: [
          Handyman(
            id: 3,
            bookingId: 5,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
        shopInfo: demoShops[0], // Ayush Home Services
      ),

      // 4. COMPLETED - Booking ID #5 (matching screenshot with Payment Detail, History, Reviews)
      BookingData(
        id: 1005,
        serviceName: 'VIP Escort Protection',
        serviceId: 1,
        customerName: 'Pedro Norris',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=pedro',
        providerId: 1,
        providerName: 'Pedro Norris',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_COMPLETED,
        statusLabel: 'Completed',
        date: '2025-12-12 08:26:00',
        address: 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 42.00,
        totalAmount: 30.25,
        discount: 2,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PAID,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'VIP escort protection service',
        startAt: '2025-12-12 08:30:00',
        endAt: '2025-12-12 10:30:00',
        totalRating: 5,
        totalReview: 2,
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
        handyman: [
          Handyman(
            id: 4,
            bookingId: 1005,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
        shopInfo: demoShops[1], // Prime Home Services
      ),

      // 5. ON_GOING - Service in progress (Waiting for response)
      BookingData(
        id: 1006,
        serviceName: 'VIP Escort Protection',
        serviceId: 1,
        customerName: 'Pedro Norris',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=pedro',
        providerId: 1,
        providerName: 'Pedro Norris',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_ON_GOING,
        statusLabel: 'On Going',
        date: '2025-12-12 08:26:00',
        address: 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 42.00,
        totalAmount: 30.25,
        discount: 2,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'VIP escort protection service',
        startAt: '2025-12-12 08:30:00',
        totalRating: 5,
        totalReview: 1,
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
        handyman: [
          Handyman(
            id: 5,
            bookingId: 1006,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
      ),

      // 6. PENDING_APPROVAL - With Complete/Add Extra Changes buttons
      BookingData(
        id: 1007,
        serviceName: 'VIP Escort Protection',
        serviceId: 1,
        customerName: 'Pedro Norris',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=pedro',
        providerId: 1,
        providerName: 'Pedro Norris',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_PENDING_APPROVAL,
        statusLabel: 'Pending Approval',
        date: '2025-12-12 08:26:00',
        address: 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 42.00,
        totalAmount: 30.25,
        discount: 2,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'VIP escort protection service',
        startAt: '2025-12-12 08:30:00',
        endAt: '2025-12-12 10:30:00',
        totalRating: 5,
        totalReview: 1,
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
        handyman: [
          Handyman(
            id: 6,
            bookingId: 1007,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
      ),

      // 7. PENDING - New booking with Decline/Accept buttons
      BookingData(
        id: 1008,
        serviceName: 'Home Cleaning',
        serviceId: 2,
        customerName: 'Pedro Norris',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=pedro',
        providerId: 1,
        providerName: 'Pedro Norris',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_PENDING,
        statusLabel: 'Pending',
        date: '2025-12-12 08:25:00',
        address: 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 42.00,
        totalAmount: 30.25,
        discount: 2,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Deep cleaning of apartment',
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
      ),

      // 3. ON_GOING - Service in progress
      BookingData(
        id: 1003,
        serviceName: 'Plumbing Service',
        serviceId: 3,
        customerName: 'Carol White',
        customerId: 103,
        customerImage: 'https://i.pravatar.cc/300?u=carol',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_ON_GOING,
        statusLabel: 'On Going',
        date: '2024-01-19 09:00:00',
        address: '789 Pine Street, Queens, NY 11375',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 90.00,
        totalAmount: 85.50,
        discount: 5,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Fix kitchen sink leak',
        startAt: '2024-01-19 09:15:00',
        handyman: [
          Handyman(
            id: 2,
            bookingId: 1003,
            handymanId: 4,
            handyman: demoHandymen[2],
          ),
        ],
      ),

      // 4. IN_PROGRESS - Additional work being done
      BookingData(
        id: 1006,
        serviceName: 'Carpentry Work',
        serviceId: 7,
        customerName: 'Frank Wilson',
        customerId: 106,
        customerImage: 'https://i.pravatar.cc/300?u=frank',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_IN_PROGRESS,
        statusLabel: 'In Progress',
        date: '2024-01-22 11:00:00',
        address: '111 Cedar Lane, Staten Island, NY 10301',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 200.00,
        totalAmount: 200.00,
        discount: 0,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Custom shelf installation',
        startAt: '2024-01-22 11:30:00',
        handyman: [
          Handyman(
            id: 7,
            bookingId: 1006,
            handymanId: 3,
            handyman: demoHandymen[1],
          ),
        ],
      ),

      // 8. HOLD - Booking on hold
      BookingData(
        id: 1010,
        serviceName: 'Painting Service',
        serviceId: 8,
        customerName: 'Alice Green',
        customerId: 110,
        customerImage: 'https://i.pravatar.cc/300?u=alice',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_HOLD,
        statusLabel: 'Hold',
        date: '2024-01-25 10:00:00',
        address: '456 Oak Avenue, Bronx, NY 10453',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 150.00,
        totalAmount: 150.00,
        discount: 0,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Living room painting - Awaiting paint selection',
        reason: 'Customer evaluating color options',
        startAt: '2024-01-25 10:15:00',
        handyman: [
          Handyman(
            id: 8,
            bookingId: 1010,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
      ),

      // 9. REJECTED - Booking rejected
      BookingData(
        id: 1011,
        serviceName: 'Electrical Wiring',
        serviceId: 9,
        customerName: 'Bob Brown',
        customerId: 111,
        customerImage: 'https://i.pravatar.cc/300?u=bob',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_REJECTED,
        statusLabel: 'Rejected',
        date: '2024-01-26 14:00:00',
        address: '789 Maple Drive, Brooklyn, NY 11201',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 80.00,
        totalAmount: 80.00,
        discount: 0,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Rewiring old outlet',
        reason: 'Service area out of range',
      ),

      // 10. FAILED - Booking failed
      BookingData(
        id: 1012,
        serviceName: 'AC Repair',
        serviceId: 10,
        customerName: 'Charlie Black',
        customerId: 112,
        customerImage: 'https://i.pravatar.cc/300?u=charlie',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_FAILED,
        statusLabel: 'Failed',
        date: '2024-01-27 16:00:00',
        address: '321 Elm Street, Manhattan, NY 10001',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 60.00,
        totalAmount: 60.00,
        discount: 0,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: 'failed',
        paymentMethod: PAYMENT_METHOD_STRIPE,
        quantity: 1,
        description: 'AC not cooling',
        reason: 'Payment failed multiple times',
      ),

      // 11. WAITING - Booking waiting for provider
      BookingData(
        id: 1013,
        serviceName: 'Gardening',
        serviceId: 11,
        customerName: 'David Blue',
        customerId: 113,
        customerImage: 'https://i.pravatar.cc/300?u=david',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_WAITING_ADVANCED_PAYMENT,
        statusLabel: 'Waiting',
        date: '2024-01-28 09:00:00',
        address: '654 Birch Road, Queens, NY 11375',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 50.00,
        totalAmount: 50.00,
        discount: 0,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Lawn mowing and trimming',
      ),

      // 5. HOLD - Service temporarily paused
      BookingData(
        id: 1007,
        serviceName: 'Painting Service',
        serviceId: 5,
        customerName: 'Grace Lee',
        customerId: 107,
        customerImage: 'https://i.pravatar.cc/300?u=grace',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_HOLD,
        statusLabel: 'On Hold',
        date: '2024-01-17 08:00:00',
        address: '222 Birch Road, Manhattan, NY 10022',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 350.00,
        totalAmount: 350.00,
        discount: 0,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_STRIPE,
        quantity: 1,
        description: 'Interior painting - waiting for paint delivery',
        startAt: '2024-01-17 08:30:00',
        reason: 'Waiting for special paint color to be delivered',
        handyman: [
          Handyman(
            id: 4,
            bookingId: 1007,
            handymanId: 5,
            handyman: demoHandymen[3],
          ),
        ],
      ),

      // 6. COMPLETED - Service finished successfully
      BookingData(
        id: 1004,
        serviceName: 'AC Repair & Service',
        serviceId: 4,
        customerName: 'Daniel Green',
        customerId: 104,
        customerImage: 'https://i.pravatar.cc/300?u=daniel',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_COMPLETED,
        statusLabel: 'Completed',
        date: '2024-01-15 11:00:00',
        address: '321 Elm Road, Manhattan, NY 10016',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 85.00,
        totalAmount: 72.25,
        discount: 15,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PAID,
        paymentMethod: PAYMENT_METHOD_STRIPE,
        quantity: 1,
        description: 'Annual AC maintenance and gas refill',
        startAt: '2024-01-15 11:15:00',
        endAt: '2024-01-15 13:30:00',
        totalRating: 5,
        totalReview: 1,
        handyman: [
          Handyman(
            id: 5,
            bookingId: 1004,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
      ),

      // 7. CANCELLED - Booking cancelled by customer
      BookingData(
        id: 1005,
        serviceName: 'Painting Service',
        serviceId: 5,
        customerName: 'Eva Martinez',
        customerId: 105,
        customerImage: 'https://i.pravatar.cc/300?u=eva',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_CANCELLED,
        statusLabel: 'Cancelled',
        date: '2024-01-18 08:00:00',
        address: '654 Maple Drive, Bronx, NY 10451',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 160.00,
        totalAmount: 160.00,
        discount: 0,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 4,
        description: 'Paint living room and bedroom',
        reason: 'Customer requested cancellation due to schedule conflict',
        isCancelled: 1,
      ),

      // 8. REJECTED - Booking rejected by provider
      BookingData(
        id: 1008,
        serviceName: 'Home Cleaning',
        serviceId: 1,
        customerName: 'Henry Brown',
        customerId: 108,
        customerImage: 'https://i.pravatar.cc/300?u=henry',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_REJECTED,
        statusLabel: 'Rejected',
        date: '2024-01-16 09:00:00',
        address: '333 Walnut Street, Brooklyn, NY 11205',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 75.00,
        totalAmount: 75.00,
        discount: 0,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Weekly cleaning service',
        reason: 'Service area too far from our coverage zone',
      ),

      // 9. FAILED - Service could not be completed
      BookingData(
        id: 1009,
        serviceName: 'Electrical Repair',
        serviceId: 2,
        customerName: 'Irene Clark',
        customerId: 109,
        customerImage: 'https://i.pravatar.cc/300?u=irene',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_FAILED,
        statusLabel: 'Failed',
        date: '2024-01-14 14:00:00',
        address: '444 Spruce Avenue, Queens, NY 11355',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 150.00,
        totalAmount: 150.00,
        discount: 0,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_STRIPE,
        quantity: 3,
        description: 'Rewiring old electrical system',
        startAt: '2024-01-14 14:30:00',
        reason:
            'Property requires permit - work cannot proceed without city approval',
        handyman: [
          Handyman(
            id: 6,
            bookingId: 1009,
            handymanId: 3,
            handyman: demoHandymen[1],
          ),
        ],
      ),

      // 10. PENDING_APPROVAL - Waiting for admin/customer approval
      BookingData(
        id: 1010,
        serviceName: 'AC Repair & Service',
        serviceId: 4,
        customerName: 'Jack Davis',
        customerId: 110,
        customerImage: 'https://i.pravatar.cc/300?u=jack',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_PENDING_APPROVAL,
        statusLabel: 'Pending Approval',
        date: '2024-01-23 10:00:00',
        address: '555 Oak Court, Manhattan, NY 10028',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 120.00,
        totalAmount: 120.00,
        discount: 0,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_STRIPE,
        quantity: 1,
        description: 'AC installation - awaiting customer confirmation',
        startAt: '2024-01-23 10:30:00',
        endAt: '2024-01-23 14:00:00',
        handyman: [
          Handyman(
            id: 7,
            bookingId: 1010,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
        ],
      ),

      // 11. WAITING (Advance Payment) - Waiting for customer to pay advance
      BookingData(
        id: 1011,
        serviceName: 'Home Renovation',
        serviceId: 8,
        customerName: 'Karen Miller',
        customerId: 111,
        customerImage: 'https://i.pravatar.cc/300?u=karen',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_WAITING_ADVANCED_PAYMENT,
        statusLabel: 'Waiting for Payment',
        date: '2024-01-25 09:00:00',
        address: '666 Pine Court, Brooklyn, NY 11215',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 500.00,
        totalAmount: 500.00,
        discount: 0,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_STRIPE,
        quantity: 1,
        description: 'Kitchen renovation - 50% advance payment required',
      ),

      // 12. PAID - Fully paid booking
      BookingData(
        id: 1012,
        serviceName: 'Plumbing Service',
        serviceId: 3,
        customerName: 'Larry Thompson',
        customerId: 112,
        customerImage: 'https://i.pravatar.cc/300?u=larry',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_PAID,
        statusLabel: 'Paid',
        date: '2024-01-12 15:00:00',
        address: '777 Elm Court, Staten Island, NY 10304',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 180.00,
        totalAmount: 180.00,
        discount: 0,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PAID,
        paymentMethod: PAYMENT_METHOD_STRIPE,
        quantity: 1,
        description: 'Complete bathroom plumbing upgrade',
        startAt: '2024-01-12 15:30:00',
        endAt: '2024-01-12 19:00:00',
        totalRating: 4,
        totalReview: 1,
        handyman: [
          Handyman(
            id: 8,
            bookingId: 1012,
            handymanId: 4,
            handyman: demoHandymen[2],
          ),
        ],
      ),
    ];

/// Demo Notifications List
List<NotificationData> get demoNotifications => [
      NotificationData(
        id: '1',
        readAt: null,
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=pedro',
        data: Data(
          id: 1001,
          type: 'new_booking_received',
          subject: 'New Booking',
          message:
              'New booking #4 - Pedro Norris has booked Customized Facials.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '2',
        readAt: null,
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=sarah',
        data: Data(
          id: 1002,
          type: 'new_booking_received',
          subject: 'New Booking',
          message: 'New booking #5 - Sarah Johnson has booked Home Cleaning.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '3',
        readAt: null,
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=michael',
        data: Data(
          id: 1003,
          type: 'new_booking_received',
          subject: 'New Booking',
          message:
              'New booking #6 - Michael Brown has booked Electrical Repair.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '4',
        readAt: null,
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=emma',
        data: Data(
          id: 1004,
          type: 'new_booking_received',
          subject: 'New Booking',
          message:
              'New booking #7 - Emma Wilson has booked AC Repair & Service.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '5',
        readAt: null,
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=david',
        data: Data(
          id: 1005,
          type: 'new_booking_received',
          subject: 'New Booking',
          message:
              'New booking #8 - David Martinez has booked Plumbing Service.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '6',
        readAt: null,
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=lisa',
        data: Data(
          id: 1006,
          type: 'new_booking_received',
          subject: 'New Booking',
          message:
              'New booking #9 - Lisa Anderson has booked Painting Service.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '7',
        readAt: '2024-01-19 10:00:00',
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=john',
        data: Data(
          id: 1007,
          type: 'new_booking_received',
          subject: 'New Booking',
          message: 'New booking #10 - John Smith has booked Carpet Cleaning.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '8',
        readAt: '2024-01-18 14:30:00',
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=olivia',
        data: Data(
          id: 1008,
          type: 'new_booking_received',
          subject: 'New Booking',
          message: 'New booking #11 - Olivia Davis has booked Window Cleaning.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '9',
        readAt: '2024-01-17 09:15:00',
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=william',
        data: Data(
          id: 1009,
          type: 'new_booking_received',
          subject: 'New Booking',
          message: 'New booking #12 - William Taylor has booked Pest Control.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '10',
        readAt: '2024-01-16 11:45:00',
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=sophia',
        data: Data(
          id: 1010,
          type: 'new_booking_received',
          subject: 'New Booking',
          message:
              'New booking #13 - Sophia Garcia has booked Garden Maintenance.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '11',
        readAt: '2024-01-15 16:20:00',
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=james',
        data: Data(
          id: 1011,
          type: 'new_booking_received',
          subject: 'New Booking',
          message:
              'New booking #14 - James Miller has booked Appliance Repair.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '12',
        readAt: '2024-01-14 08:30:00',
        createdAt: '2 hours ago',
        profileImage: 'https://i.pravatar.cc/300?u=ava',
        data: Data(
          id: 1012,
          type: 'new_booking_received',
          subject: 'New Booking',
          message: 'New booking #15 - Ava Thomas has booked Moving Services.',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
    ];

/// Demo Payments List
List<PaymentData> get demoPayments => [
      PaymentData(
        id: 2001,
        bookingId: 1004,
        customerId: 104,
        customerName: 'Daniel Green',
        paymentMethod: PAYMENT_METHOD_STRIPE,
        paymentStatus: PAID,
        txnId: 'TXN_20240115_001',
        totalAmount: 72.25,
        date: '2024-01-15 13:45:00',
      ),
      PaymentData(
        id: 2002,
        bookingId: 1001,
        customerId: 101,
        customerName: 'Alice Smith',
        paymentMethod: PAYMENT_METHOD_COD,
        paymentStatus: PENDING,
        totalAmount: 82.50,
        date: '2024-01-20 10:00:00',
      ),
      PaymentData(
        id: 2003,
        bookingId: 1002,
        customerId: 102,
        customerName: 'Bob Johnson',
        paymentMethod: PAYMENT_METHOD_STRIPE,
        paymentStatus: PENDING,
        totalAmount: 100.00,
        date: '2024-01-21 14:30:00',
      ),
    ];

/// Demo Customers List
List<UserData> get demoCustomers => [
      UserData(
        id: 101,
        firstName: 'Alice',
        lastName: 'Smith',
        email: 'alice@customer.com',
        userType: IS_USER,
        contactNumber: '+1555000101',
        status: 1,
        displayName: 'Alice Smith',
        profileImage: 'https://i.pravatar.cc/300?u=alice',
        address: '123 Main Street, New York, NY 10001',
        totalBooking: 5,
      ),
      UserData(
        id: 102,
        firstName: 'Bob',
        lastName: 'Johnson',
        email: 'bob@customer.com',
        userType: IS_USER,
        contactNumber: '+1555000102',
        status: 1,
        displayName: 'Bob Johnson',
        profileImage: 'https://i.pravatar.cc/300?u=bob',
        address: '456 Oak Avenue, Brooklyn, NY 11201',
        totalBooking: 3,
      ),
      UserData(
        id: 103,
        firstName: 'Carol',
        lastName: 'White',
        email: 'carol@customer.com',
        userType: IS_USER,
        contactNumber: '+1555000103',
        status: 1,
        displayName: 'Carol White',
        profileImage: 'https://i.pravatar.cc/300?u=carol',
        address: '789 Pine Street, Queens, NY 11375',
        totalBooking: 8,
      ),
      UserData(
        id: 104,
        firstName: 'Daniel',
        lastName: 'Green',
        email: 'daniel@customer.com',
        userType: IS_USER,
        contactNumber: '+1555000104',
        status: 1,
        displayName: 'Daniel Green',
        profileImage: 'https://i.pravatar.cc/300?u=daniel',
        address: '321 Elm Road, Manhattan, NY 10016',
        totalBooking: 12,
      ),
      UserData(
        id: 105,
        firstName: 'Eva',
        lastName: 'Martinez',
        email: 'eva@customer.com',
        userType: IS_USER,
        contactNumber: '+1555000105',
        status: 1,
        displayName: 'Eva Martinez',
        profileImage: 'https://i.pravatar.cc/300?u=eva',
        address: '654 Maple Drive, Bronx, NY 10451',
        totalBooking: 2,
      ),
    ];

//=============================================================================
// ADDITIONAL DEMO DATA FOR ALL SCREENS
//=============================================================================

/// Demo Taxes List
List<Map<String, dynamic>> get demoTaxes => [
      {
        'id': 1,
        'title': 'State Tax',
        'type': 'percent',
        'value': 8.5,
        'status': 1,
        'provider_id': 1,
        'created_at': '2023-01-15 10:00:00',
        'updated_at': '2024-01-10 12:00:00',
      },
      {
        'id': 2,
        'title': 'City Tax',
        'type': 'percent',
        'value': 2.5,
        'status': 1,
        'provider_id': 1,
        'created_at': '2023-01-15 10:00:00',
        'updated_at': '2024-01-10 12:00:00',
      },
      {
        'id': 3,
        'title': 'Service Fee',
        'type': 'fixed',
        'value': 5.00,
        'status': 1,
        'provider_id': 1,
        'created_at': '2023-03-01 09:00:00',
        'updated_at': '2024-01-10 12:00:00',
      },
    ];

/// Demo Bank Details List
List<Map<String, dynamic>> get demoBankDetails => [
      {
        'id': 1,
        'user_id': 1,
        'bank_name': 'Chase Bank',
        'branch_name': 'Downtown LA Branch',
        'account_no': '****4567',
        'ifsc_no': 'CHASUS33',
        'mobile_no': '+1 (555) 123-4567',
        'aadhar_no': '',
        'pan_no': '',
        'is_default': 1,
        'status': 1,
        'created_at': '2023-06-15 14:30:00',
        'updated_at': '2024-01-05 10:00:00',
      },
      {
        'id': 2,
        'user_id': 1,
        'bank_name': 'Bank of America',
        'branch_name': 'West Hollywood',
        'account_no': '****8901',
        'ifsc_no': 'BOFAUS3N',
        'mobile_no': '+1 (555) 123-4567',
        'aadhar_no': '',
        'pan_no': '',
        'is_default': 0,
        'status': 1,
        'created_at': '2023-09-20 11:00:00',
        'updated_at': '2024-01-05 10:00:00',
      },
    ];

/// Demo Wallet History
List<Map<String, dynamic>> get demoWalletHistory => [
      {
        'id': 1,
        'title': 'Withdrawal to Chase Bank',
        'user_id': 1,
        'transaction_type': 'debit',
        'amount': 500.00,
        'balance': 15180.50,
        'datetime': '2024-01-18 09:30:00',
        'status': 1,
        'activity_message': 'Withdrawal successful',
      },
      {
        'id': 2,
        'title': 'Payment Received - Booking #1004',
        'user_id': 1,
        'transaction_type': 'credit',
        'amount': 72.25,
        'balance': 15680.50,
        'datetime': '2024-01-15 14:00:00',
        'status': 1,
        'activity_message': 'Payment from Daniel Green',
      },
      {
        'id': 3,
        'title': 'Payment Received - Booking #1012',
        'user_id': 1,
        'transaction_type': 'credit',
        'amount': 180.00,
        'balance': 15608.25,
        'datetime': '2024-01-12 19:30:00',
        'status': 1,
        'activity_message': 'Payment from Larry Thompson',
      },
      {
        'id': 4,
        'title': 'Commission Deduction',
        'user_id': 1,
        'transaction_type': 'debit',
        'amount': 27.00,
        'balance': 15428.25,
        'datetime': '2024-01-12 19:30:00',
        'status': 1,
        'activity_message': '15% commission on booking #1012',
      },
      {
        'id': 5,
        'title': 'Wallet Top-up',
        'user_id': 1,
        'transaction_type': 'credit',
        'amount': 1000.00,
        'balance': 15455.25,
        'datetime': '2024-01-10 10:00:00',
        'status': 1,
        'activity_message': 'Added via Stripe',
      },
    ];

/// Demo Subscription Plans
List<Map<String, dynamic>> get demoSubscriptionPlans => [
      {
        'id': 1,
        'title': 'Free Plan',
        'identifier': 'free_plan',
        'amount': 0.00,
        'status': 1,
        'type': 'monthly',
        'plan_type': 'free',
        'plan_limitation': {
          'service': 5,
          'handyman': 2,
          'featured_service': 0,
        },
        'description': 'Perfect for getting started. Basic features included.',
      },
      {
        'id': 2,
        'title': 'Starter Plan',
        'identifier': 'starter_plan',
        'amount': 29.99,
        'status': 1,
        'type': 'monthly',
        'plan_type': 'limited',
        'plan_limitation': {
          'service': 20,
          'handyman': 5,
          'featured_service': 3,
        },
        'description':
            'Great for small businesses. More services and handymen.',
      },
      {
        'id': 3,
        'title': 'Professional Plan',
        'identifier': 'professional_plan',
        'amount': 79.99,
        'status': 1,
        'type': 'monthly',
        'plan_type': 'limited',
        'plan_limitation': {
          'service': 50,
          'handyman': 15,
          'featured_service': 10,
        },
        'description': 'For growing businesses. Priority support included.',
      },
      {
        'id': 4,
        'title': 'Enterprise Plan',
        'identifier': 'enterprise_plan',
        'amount': 199.99,
        'status': 1,
        'type': 'monthly',
        'plan_type': 'unlimited',
        'plan_limitation': {
          'service': -1,
          'handyman': -1,
          'featured_service': -1,
        },
        'description': 'Unlimited everything. Dedicated account manager.',
      },
    ];

/// Demo Subscription History
List<Map<String, dynamic>> get demoSubscriptionHistory => [
      {
        'id': 1,
        'plan_id': 1,
        'user_id': 1,
        'title': 'Free Plan',
        'identifier': 'free_plan',
        'amount': 0.00,
        'status': 1,
        'start_at': '2024-01-01',
        'end_at': '2024-02-01',
        'payment_type': 'wallet',
        'payment_status': 'paid',
        'created_at': '2024-01-01 00:00:00',
      },
    ];

/// Demo Packages List
List<Map<String, dynamic>> get demoPackages => [
      {
        'id': 1,
        'name': 'Home Maintenance Bundle',
        'category_id': 1,
        'subcategory_id': null,
        'description':
            'Complete home maintenance package including cleaning, plumbing check, and electrical inspection.',
        'price': 299.99,
        'start_at': '2024-01-01',
        'end_at': '2024-12-31',
        'status': 1,
        'is_featured': 1,
        'provider_id': 1,
        'attchments': [
          'https://images.unsplash.com/photo-1558036117-15d82a90b9b1?w=600'
        ],
        'services': [1, 2, 3],
        'created_at': '2023-12-15 10:00:00',
      },
      {
        'id': 2,
        'name': 'AC Care Package',
        'category_id': 4,
        'subcategory_id': null,
        'description':
            'Annual AC maintenance with 2 service visits, filter replacement, and gas refill.',
        'price': 149.99,
        'start_at': '2024-01-01',
        'end_at': '2024-12-31',
        'status': 1,
        'is_featured': 0,
        'provider_id': 1,
        'attchments': [
          'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600'
        ],
        'services': [4],
        'created_at': '2023-12-20 14:00:00',
      },
      {
        'id': 3,
        'name': 'Premium Renovation Pack',
        'category_id': 5,
        'subcategory_id': null,
        'description':
            'Full room renovation including painting, flooring, and lighting upgrade.',
        'price': 1999.99,
        'start_at': '2024-01-01',
        'end_at': '2024-06-30',
        'status': 1,
        'is_featured': 1,
        'provider_id': 1,
        'attchments': [
          'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=600'
        ],
        'services': [5],
        'created_at': '2024-01-05 09:00:00',
      },
    ];

/// Demo Time Slots
List<Map<String, dynamic>> get demoTimeSlots => [
      {
        'id': 1,
        'day': 'monday',
        'start_at': '09:00',
        'end_at': '12:00',
        'status': 1
      },
      {
        'id': 2,
        'day': 'monday',
        'start_at': '14:00',
        'end_at': '18:00',
        'status': 1
      },
      {
        'id': 3,
        'day': 'tuesday',
        'start_at': '09:00',
        'end_at': '12:00',
        'status': 1
      },
      {
        'id': 4,
        'day': 'tuesday',
        'start_at': '14:00',
        'end_at': '18:00',
        'status': 1
      },
      {
        'id': 5,
        'day': 'wednesday',
        'start_at': '09:00',
        'end_at': '12:00',
        'status': 1
      },
      {
        'id': 6,
        'day': 'wednesday',
        'start_at': '14:00',
        'end_at': '18:00',
        'status': 1
      },
      {
        'id': 7,
        'day': 'thursday',
        'start_at': '09:00',
        'end_at': '12:00',
        'status': 1
      },
      {
        'id': 8,
        'day': 'thursday',
        'start_at': '14:00',
        'end_at': '18:00',
        'status': 1
      },
      {
        'id': 9,
        'day': 'friday',
        'start_at': '09:00',
        'end_at': '12:00',
        'status': 1
      },
      {
        'id': 10,
        'day': 'friday',
        'start_at': '14:00',
        'end_at': '17:00',
        'status': 1
      },
      {
        'id': 11,
        'day': 'saturday',
        'start_at': '10:00',
        'end_at': '14:00',
        'status': 1
      },
    ];

/// Demo Job Requests / Post Jobs
List<Map<String, dynamic>> get demoJobRequests => [
      {
        'id': 1,
        'title': 'Need Kitchen Faucet Replacement',
        'description':
            'Looking for a plumber to replace my kitchen faucet. The current one is leaking badly.',
        'price': 75.00,
        'status': 'requested',
        'customer_id': 103,
        'customer_name': 'Carol White',
        'customer_profile': 'https://i.pravatar.cc/300?u=carol',
        'service_id': 3,
        'address': '789 Pine Street, Queens, NY 11375',
        'created_at': '2024-01-19 08:30:00',
      },
      {
        'id': 2,
        'title': 'Emergency AC Repair',
        'description':
            'AC not cooling. Need urgent repair as its very hot. Prefer same day service.',
        'price': 120.00,
        'status': 'requested',
        'customer_id': 104,
        'customer_name': 'Daniel Green',
        'customer_profile': 'https://i.pravatar.cc/300?u=daniel',
        'service_id': 4,
        'address': '321 Elm Road, Manhattan, NY 10016',
        'created_at': '2024-01-20 11:00:00',
      },
      {
        'id': 3,
        'title': 'Full House Painting',
        'description':
            'Need to repaint entire 3BHK apartment. Walls and ceiling. White color preferred.',
        'price': 2500.00,
        'status': 'assigned',
        'customer_id': 101,
        'customer_name': 'Alice Smith',
        'customer_profile': 'https://i.pravatar.cc/300?u=alice',
        'service_id': 5,
        'address': '123 Main Street, New York, NY 10001',
        'created_at': '2024-01-18 15:00:00',
      },
    ];

/// Demo Bids
List<Map<String, dynamic>> get demoBids => [
      {
        'id': 1,
        'post_request_id': 1,
        'provider_id': 1,
        'price': 65.00,
        'proposal':
            'I can replace the faucet with a premium quality fixture. Available tomorrow.',
        'status': 'pending',
        'created_at': '2024-01-19 10:00:00',
      },
      {
        'id': 2,
        'post_request_id': 2,
        'provider_id': 1,
        'price': 100.00,
        'proposal': 'Experienced AC technician. Can come today within 2 hours.',
        'status': 'accepted',
        'created_at': '2024-01-20 11:30:00',
      },
    ];

/// Demo Addon Services
List<Map<String, dynamic>> get demoAddons => [
      {
        'id': 1,
        'name': 'Express Service',
        'service_id': 1,
        'price': 25.00,
        'status': 1,
        'image':
            'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=400',
      },
      {
        'id': 2,
        'name': 'Premium Cleaning Products',
        'service_id': 1,
        'price': 15.00,
        'status': 1,
        'image':
            'https://images.unsplash.com/photo-1563453392212-326f5e854473?w=400',
      },
      {
        'id': 3,
        'name': 'Same Day Service',
        'service_id': 2,
        'price': 50.00,
        'status': 1,
        'image':
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      },
      {
        'id': 4,
        'name': 'Extended Warranty',
        'service_id': 4,
        'price': 35.00,
        'status': 1,
        'image':
            'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=400',
      },
    ];

/// Demo Earnings Data
List<Map<String, dynamic>> get demoEarnings => [
      {
        'id': 1,
        'provider_id': 1,
        'booking_id': 1004,
        'payment_id': 2001,
        'commission': 10.84,
        'provider_commission': 61.41,
        'created_at': '2024-01-15',
        'service_name': 'AC Repair & Service',
        'customer_name': 'Daniel Green',
      },
      {
        'id': 2,
        'provider_id': 1,
        'booking_id': 1012,
        'payment_id': null,
        'commission': 27.00,
        'provider_commission': 153.00,
        'created_at': '2024-01-12',
        'service_name': 'Plumbing Service',
        'customer_name': 'Larry Thompson',
      },
    ];

/// Demo Handyman Earnings
List<Map<String, dynamic>> get demoHandymanEarnings => [
      {
        'id': 1,
        'handyman_id': 2,
        'booking_id': 1003,
        'commission': 8.55,
        'payment_date': '2024-01-19',
        'service_name': 'Plumbing Service',
        'customer_name': 'Carol White',
      },
      {
        'id': 2,
        'handyman_id': 2,
        'booking_id': 1002,
        'commission': 10.00,
        'payment_date': '2024-01-21',
        'service_name': 'Electrical Repair',
        'customer_name': 'Bob Johnson',
      },
    ];

/// Demo Documents
List<Map<String, dynamic>> get demoDocuments => [
      {
        'id': 1,
        'document_name': 'Business License',
        'is_required': 1,
        'status': 1,
      },
      {
        'id': 2,
        'document_name': 'Insurance Certificate',
        'is_required': 1,
        'status': 1,
      },
      {
        'id': 3,
        'document_name': 'Professional Certification',
        'is_required': 0,
        'status': 1,
      },
    ];

/// Demo Provider Documents (uploaded)
List<Map<String, dynamic>> get demoProviderDocuments => [
      {
        'id': 1,
        'provider_id': 1,
        'document_id': 1,
        'is_verified': 1,
        'provider_document': 'https://example.com/docs/license.pdf',
        'document': {
          'id': 1,
          'document_name': 'Business License',
          'is_required': 1,
          'status': 1,
        },
      },
      {
        'id': 2,
        'provider_id': 1,
        'document_id': 2,
        'is_verified': 1,
        'provider_document': 'https://example.com/docs/insurance.pdf',
        'document': {
          'id': 2,
          'document_name': 'Insurance Certificate',
          'is_required': 1,
          'status': 1,
        },
      },
    ];

/// Demo Reviews
List<Map<String, dynamic>> get demoReviews => [
      {
        'id': 1,
        'service_id': 4,
        'rating': 5.0,
        'review':
            'Excellent service! The technician was very professional and fixed my AC quickly.',
        'customer_id': 104,
        'customer_name': 'Daniel Green',
        'customer_profile_image': 'https://i.pravatar.cc/300?u=daniel',
        'created_at': '2024-01-15 14:00:00',
      },
      {
        'id': 2,
        'service_id': 3,
        'rating': 4.5,
        'review':
            'Good plumbing work. Arrived on time and completed the job efficiently.',
        'customer_id': 112,
        'customer_name': 'Larry Thompson',
        'customer_profile_image': 'https://i.pravatar.cc/300?u=larry',
        'created_at': '2024-01-12 19:30:00',
      },
      {
        'id': 3,
        'service_id': 1,
        'rating': 5.0,
        'review':
            'My house has never been this clean! Will definitely book again.',
        'customer_id': 101,
        'customer_name': 'Alice Smith',
        'customer_profile_image': 'https://i.pravatar.cc/300?u=alice',
        'created_at': '2024-01-10 12:00:00',
      },
    ];

/// Demo Categories
List<Map<String, dynamic>> get demoCategories => [
      {
        'id': 1,
        'name': 'Cleaning',
        'color': '#4CAF50',
        'status': 1,
        'category_image':
            'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        'services_count': 3,
      },
      {
        'id': 2,
        'name': 'Electrical',
        'color': '#2196F3',
        'status': 1,
        'category_image':
            'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=400',
        'services_count': 4,
      },
      {
        'id': 3,
        'name': 'Plumbing',
        'color': '#03A9F4',
        'status': 1,
        'category_image':
            'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=400',
        'services_count': 3,
      },
      {
        'id': 4,
        'name': 'HVAC',
        'color': '#FF9800',
        'status': 1,
        'category_image':
            'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=400',
        'services_count': 2,
      },
      {
        'id': 5,
        'name': 'Painting',
        'color': '#9C27B0',
        'status': 1,
        'category_image':
            'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400',
        'services_count': 2,
      },
      {
        'id': 6,
        'name': 'Consulting',
        'color': '#607D8B',
        'status': 1,
        'category_image':
            'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=400',
        'services_count': 1,
      },
    ];

/// Demo Zones / Service Areas
List<Map<String, dynamic>> get demoZones => [
      {
        'id': 1,
        'name': 'Downtown Los Angeles',
        'status': 1,
        'address': 'Downtown, Los Angeles, CA',
      },
      {
        'id': 2,
        'name': 'West Hollywood',
        'status': 1,
        'address': 'West Hollywood, Los Angeles, CA',
      },
      {
        'id': 3,
        'name': 'Santa Monica',
        'status': 1,
        'address': 'Santa Monica, Los Angeles, CA',
      },
      {
        'id': 4,
        'name': 'Beverly Hills',
        'status': 1,
        'address': 'Beverly Hills, Los Angeles, CA',
      },
    ];

/// Demo Blogs
List<Map<String, dynamic>> get demoBlogs => [
      {
        'id': 1,
        'title': '10 Tips for Maintaining Your AC System',
        'description':
            'Learn how to keep your air conditioning system running efficiently year-round with these expert tips...',
        'author_id': 1,
        'is_featured': 1,
        'status': 1,
        'created_at': '2024-01-10 09:00:00',
        'attchments': [
          'https://images.unsplash.com/photo-1504280390367-361c6d9f38f4?w=600'
        ],
      },
      {
        'id': 2,
        'title': 'DIY vs Professional: When to Call an Expert',
        'description':
            'Some home repairs you can handle yourself, but others require professional expertise. Here is how to decide...',
        'author_id': 1,
        'is_featured': 0,
        'status': 1,
        'created_at': '2024-01-15 14:00:00',
        'attchments': [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600'
        ],
      },
    ];

/// Demo Help Desk Tickets
List<Map<String, dynamic>> get demoHelpDeskTickets => [
      {
        'id': 1,
        'subject': 'Payment not received',
        'description':
            'I completed booking #1003 but haven\'t received payment yet.',
        'mode': 'open',
        'user_id': 1,
        'created_at': '2024-01-19 10:00:00',
      },
      {
        'id': 2,
        'subject': 'How to add new service',
        'description':
            'I want to add a new electrical service category. How do I do that?',
        'mode': 'closed',
        'user_id': 1,
        'created_at': '2024-01-15 08:00:00',
      },
    ];

/// Demo Cash Management Data
class DemoCashData {
  /// Total cash in hand for demo
  static num get totalCashInHand => 15680.50;

  /// Today's cash for demo
  static num get todayCash => 2450.00;

  /// Demo payment history list
  static List<Map<String, dynamic>> get paymentHistoryJson => [
        {
          'id': 1,
          'payment_id': 101,
          'booking_id': 1001,
          'action': 'handyman_approved_cash',
          'text': 'Cash collected for Home Cleaning service',
          'type': 'cash',
          'status': 'approved_by_handyman',
          'sender_id': 2,
          'receiver_id': 1,
          'parent_id': null,
          'txn_id': 'TXN_20240122_001',
          'other_transaction_detail': null,
          'datetime': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          'total_amount': 750.00,
        },
        {
          'id': 2,
          'payment_id': 102,
          'booking_id': 1002,
          'action': 'handyman_send_provider',
          'text': 'Cash sent to provider for Electrical Repair',
          'type': 'cash',
          'status': 'send_to_provider',
          'sender_id': 3,
          'receiver_id': 1,
          'parent_id': null,
          'txn_id': 'TXN_20240122_002',
          'other_transaction_detail': null,
          'datetime': DateTime.now()
              .subtract(const Duration(hours: 5))
              .toIso8601String(),
          'total_amount': 450.00,
        },
        {
          'id': 3,
          'payment_id': 103,
          'booking_id': 1003,
          'action': 'provider_approved_cash',
          'text': 'Provider approved cash for Plumbing Service',
          'type': 'cash',
          'status': 'approved_by_provider',
          'sender_id': 1,
          'receiver_id': 0,
          'parent_id': 2,
          'txn_id': 'TXN_20240121_001',
          'other_transaction_detail': null,
          'datetime': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'total_amount': 320.00,
        },
        {
          'id': 4,
          'payment_id': 104,
          'booking_id': 1004,
          'action': 'provider_send_admin',
          'text': 'Cash sent to admin for AC Repair',
          'type': 'bank',
          'status': 'send_to_admin',
          'sender_id': 1,
          'receiver_id': 0,
          'parent_id': null,
          'txn_id': 'TXN_20240120_001',
          'other_transaction_detail': 'Bank transfer: Chase Bank ***4521',
          'datetime': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'total_amount': 580.00,
        },
        {
          'id': 5,
          'payment_id': 105,
          'booking_id': 1005,
          'action': 'admin_approved_cash',
          'text': 'Admin approved payment for Painting Service',
          'type': 'bank',
          'status': 'approved_by_admin',
          'sender_id': 0,
          'receiver_id': 1,
          'parent_id': 4,
          'txn_id': 'TXN_20240119_001',
          'other_transaction_detail': 'Processed via admin portal',
          'datetime': DateTime.now()
              .subtract(const Duration(days: 3))
              .toIso8601String(),
          'total_amount': 850.00,
        },
        {
          'id': 6,
          'payment_id': 106,
          'booking_id': 1006,
          'action': 'handyman_approved_cash',
          'text': 'Cash collected for Carpentry Work',
          'type': 'cash',
          'status': 'pending_by_provider',
          'sender_id': 4,
          'receiver_id': 1,
          'parent_id': null,
          'txn_id': 'TXN_20240118_001',
          'other_transaction_detail': null,
          'datetime': DateTime.now()
              .subtract(const Duration(days: 4))
              .toIso8601String(),
          'total_amount': 420.00,
        },
        {
          'id': 7,
          'payment_id': 107,
          'booking_id': 1007,
          'action': 'provider_send_admin',
          'text': 'Payment pending with admin',
          'type': 'bank',
          'status': 'pending_by_admin',
          'sender_id': 1,
          'receiver_id': 0,
          'parent_id': null,
          'txn_id': 'TXN_20240117_001',
          'other_transaction_detail': 'Bank transfer pending approval',
          'datetime': DateTime.now()
              .subtract(const Duration(days: 5))
              .toIso8601String(),
          'total_amount': 1200.00,
        },
        {
          'id': 8,
          'payment_id': 108,
          'booking_id': 1008,
          'action': 'handyman_approved_cash',
          'text': 'Cash collected for Deep Cleaning',
          'type': 'cash',
          'status': 'approved_by_handyman',
          'sender_id': 2,
          'receiver_id': 1,
          'parent_id': null,
          'txn_id': 'TXN_20240116_001',
          'other_transaction_detail': null,
          'datetime': DateTime.now()
              .subtract(const Duration(days: 6))
              .toIso8601String(),
          'total_amount': 280.00,
        },
      ];
}

/// Demo Booking Detail Data
class DemoBookingDetailData {
  /// Helper to format date in expected format
  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  /// Get booking activity based on status
  static List<Map<String, dynamic>> _getBookingActivity(int bookingId,
      String status, String? startAt, String? endAt, String? reason) {
    List<Map<String, dynamic>> activities = [
      {
        'id': 1,
        'booking_id': bookingId,
        'datetime':
            _formatDate(DateTime.now().subtract(const Duration(hours: 5))),
        'activity_type': 'add_booking',
        'activity_message': 'Booking created by customer',
        'created_at':
            _formatDate(DateTime.now().subtract(const Duration(hours: 5))),
      },
    ];

    switch (status) {
      case 'pending':
        // Just created, no additional activity
        break;
      case 'accept':
        activities.add({
          'id': 2,
          'booking_id': bookingId,
          'datetime':
              _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
          'activity_type': 'update_booking_status',
          'activity_message': 'Booking accepted by provider',
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
        });
        activities.add({
          'id': 3,
          'booking_id': bookingId,
          'datetime':
              _formatDate(DateTime.now().subtract(const Duration(hours: 3))),
          'activity_type': 'assigned_booking',
          'activity_message': 'Handyman assigned to booking',
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(hours: 3))),
        });
        break;
      case 'on_going':
        activities.addAll([
          {
            'id': 2,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Booking accepted by provider',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
          },
          {
            'id': 3,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(hours: 3))),
            'activity_type': 'assigned_booking',
            'activity_message': 'Handyman assigned to booking',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(hours: 3))),
          },
          {
            'id': 4,
            'booking_id': bookingId,
            'datetime': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 1))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Service started',
            'created_at': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 1))),
          },
        ]);
        break;
      case 'in_progress':
        activities.addAll([
          {
            'id': 2,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Booking accepted by provider',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
          },
          {
            'id': 3,
            'booking_id': bookingId,
            'datetime': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Service in progress',
            'created_at': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
          },
        ]);
        break;
      case 'hold':
        activities.addAll([
          {
            'id': 2,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Booking accepted by provider',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
          },
          {
            'id': 3,
            'booking_id': bookingId,
            'datetime': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Service started',
            'created_at': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
          },
          {
            'id': 4,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(hours: 1))),
            'activity_type': 'update_booking_status',
            'activity_message':
                'Service put on hold${reason != null ? ": $reason" : ""}',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(hours: 1))),
          },
        ]);
        break;
      case 'completed':
      case 'paid':
        activities.addAll([
          {
            'id': 2,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(days: 2))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Booking accepted by provider',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(days: 2))),
          },
          {
            'id': 3,
            'booking_id': bookingId,
            'datetime': startAt ??
                _formatDate(
                    DateTime.now().subtract(const Duration(days: 1, hours: 2))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Service started',
            'created_at': startAt ??
                _formatDate(
                    DateTime.now().subtract(const Duration(days: 1, hours: 2))),
          },
          {
            'id': 4,
            'booking_id': bookingId,
            'datetime': endAt ??
                _formatDate(DateTime.now().subtract(const Duration(days: 1))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Service completed successfully',
            'created_at': endAt ??
                _formatDate(DateTime.now().subtract(const Duration(days: 1))),
          },
        ]);
        if (status == 'paid') {
          activities.add({
            'id': 5,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(hours: 12))),
            'activity_type': 'payment_message_status',
            'activity_message': 'Payment received',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(hours: 12))),
          });
        }
        break;
      case 'cancelled':
        activities.add({
          'id': 2,
          'booking_id': bookingId,
          'datetime':
              _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
          'activity_type': 'update_booking_status',
          'activity_message':
              'Booking cancelled${reason != null ? ": $reason" : ""}',
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
        });
        break;
      case 'rejected':
        activities.add({
          'id': 2,
          'booking_id': bookingId,
          'datetime':
              _formatDate(DateTime.now().subtract(const Duration(hours: 3))),
          'activity_type': 'update_booking_status',
          'activity_message':
              'Booking rejected by provider${reason != null ? ": $reason" : ""}',
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(hours: 3))),
        });
        break;
      case 'failed':
        activities.addAll([
          {
            'id': 2,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(days: 1))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Booking accepted by provider',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(days: 1))),
          },
          {
            'id': 3,
            'booking_id': bookingId,
            'datetime': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Service started',
            'created_at': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 4))),
          },
          {
            'id': 4,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
            'activity_type': 'update_booking_status',
            'activity_message':
                'Service failed${reason != null ? ": $reason" : ""}',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
          },
        ]);
        break;
      case 'pending_approval':
        activities.addAll([
          {
            'id': 2,
            'booking_id': bookingId,
            'datetime':
                _formatDate(DateTime.now().subtract(const Duration(hours: 3))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Booking accepted by provider',
            'created_at':
                _formatDate(DateTime.now().subtract(const Duration(hours: 3))),
          },
          {
            'id': 3,
            'booking_id': bookingId,
            'datetime': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
            'activity_type': 'update_booking_status',
            'activity_message': 'Service completed, pending customer approval',
            'created_at': startAt ??
                _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
          },
        ]);
        break;
      case 'waiting':
        activities.add({
          'id': 2,
          'booking_id': bookingId,
          'datetime':
              _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
          'activity_type': 'update_booking_status',
          'activity_message': 'Waiting for advance payment from customer',
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(hours: 2))),
        });
        break;
    }

    return activities;
  }

  /// Get demo booking detail JSON for a specific booking ID
  static Map<String, dynamic> getBookingDetailJson(int bookingId) {
    // Find the booking from demoBookings
    final booking = demoBookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => demoBookings.first,
    );

    // Get handyman data if available
    // For proper isMe detection, set handyman ID based on user type:
    // - If Handyman user: use appStore.userId (they are the handyman)
    // - If Provider user doing work themselves: use appStore.userId
    // - If Provider managing another handyman: use a different ID
    Map<String, dynamic>? handymanData;
    if (booking.handyman != null && booking.handyman!.isNotEmpty) {
      final h = booking.handyman!.first.handyman;
      if (h != null) {
        // Use current user's ID for handyman to ensure proper UI display
        // This makes isMe == true for handyman users and Provider doing own work
        final handymanId = isUserTypeHandyman
            ? appStore.userId
            : (isUserTypeProvider ? appStore.userId : h.id);

        handymanData = {
          'id': handymanId,
          'first_name': h.firstName ?? 'Pedro',
          'last_name': h.lastName ?? 'Norris',
          'display_name': h.displayName ?? 'Pedro Norris',
          'email': h.email ?? 'demo@user.com',
          'contact_number': h.contactNumber ?? '+1 (555) 987-6543',
          'address': 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
          'profile_image':
              h.profileImage ?? 'https://i.pravatar.cc/300?u=pedro',
          'user_type': 'handyman',
          'status': 1,
          'is_verified_handyman': h.isVerifiedHandyman ?? 1,
          'designation': h.designation ?? 'Senior Technician',
          'handyman_rating': h.handymanRating ?? 4.8,
        };
      }
    }

    // Calculate pricing to match screenshot:
    // Price: $42.00
    // Discount (2% Off): -$0.84
    // Coupon (JER5T6P): -$4.00
    // Sub Total: $25.00
    // Tax (5%): $5.25 (based on sub total + some adjustments)
    // Total Amount: $30.25
    final price = booking.amount ?? 42.00;
    final discountPercent = booking.discount ?? 2;
    final discountAmount = 0.84; // Fixed to match screenshot
    final couponDiscount = 4.00;
    final subTotal = 25.00; // Fixed to match screenshot
    final taxPercent = 5;
    final taxAmount = 5.25; // Fixed to match screenshot
    final totalAmount = 30.25; // Fixed to match screenshot

    // Generate taxes array
    final taxes = [
      {
        'id': 1,
        'title': 'Service Tax ($taxPercent%)',
        'type': 'percent',
        'value': taxPercent,
        'amount': taxAmount.toString(),
      },
    ];

    // Generate coupon data
    Map<String, dynamic>? couponData = {
      'id': 1,
      'code': 'JER5T6P',
      'discount': discountPercent,
      'discount_type': 'percent',
      'discount_amount': couponDiscount,
      'status': 1,
    };

    // Generate payment history for completed/paid bookings
    List<Map<String, dynamic>> paymentHistory = [];
    if (booking.status == 'completed' || booking.status == 'paid') {
      paymentHistory = [
        {
          'id': 1,
          'booking_id': booking.id,
          'sender_id': booking.customerId,
          'receiver_id': booking.providerId,
          'payment_method': booking.paymentMethod ?? 'cash',
          'payment_status': 'approved',
          'total_amount': totalAmount,
          'txn_id': '#11',
          'datetime':
              _formatDate(DateTime.now().subtract(const Duration(hours: 12))),
          'activity_message': 'Handyman: Approve Cash',
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(hours: 12))),
        },
      ];
    }

    // Generate rating data
    List<Map<String, dynamic>> ratingData = [];
    if (booking.status == 'completed' ||
        booking.status == 'paid' ||
        booking.status == 'cancelled' ||
        booking.status == 'on_going' ||
        booking.status == 'pending_approval') {
      ratingData = [
        {
          'id': 1,
          'rating': 5.0,
          'review': 'Very Good',
          'service_id': booking.serviceId ?? 1,
          'booking_id': booking.id,
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(days: 6))),
          'customer_name': booking.customerName ?? 'Customer',
          'customer_profile_image':
              booking.customerImage ?? 'https://i.pravatar.cc/300?u=customer',
          'service_name': booking.serviceName ?? 'Service',
          'handyman_id': handymanData?['id'],
          'handyman_name': handymanData?['display_name'],
        },
      ];

      // Add second review for completed bookings (matches screenshot showing Reviews (2))
      if (booking.status == 'completed' || booking.status == 'paid') {
        ratingData.add({
          'id': 2,
          'rating': 5.0,
          'review': 'Very Good',
          'service_id': booking.serviceId ?? 1,
          'booking_id': booking.id,
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(days: 1))),
          'customer_name': booking.customerName ?? 'Pedro Norris',
          'customer_profile_image':
              booking.customerImage ?? 'https://i.pravatar.cc/300?u=pedro2',
          'service_name': booking.serviceName ?? 'Service',
          'handyman_id': handymanData?['id'],
          'handyman_name': handymanData?['display_name'],
        });
      }
    }

    return {
      'booking_detail': {
        'id': booking.id,
        'customer_id': booking.customerId,
        'service_id': booking.serviceId,
        'provider_id': booking.providerId,
        'quantity': booking.quantity ?? 1,
        'price': price,
        'type': booking.type ?? 'hourly',
        'discount': discountPercent,
        'status': booking.status,
        'status_label': booking.statusLabel ??
            booking.status?.replaceAll('_', ' ').toUpperCase(),
        'description':
            booking.description ?? 'Professional service as requested.',
        'provider_name': booking.providerName ?? 'John Provider',
        'customer_name': booking.customerName ?? 'Pedro Norris',
        'service_name': booking.serviceName ?? 'VIP Escort Protection',
        'payment_status': booking.paymentStatus ?? 'pending',
        'payment_method': booking.paymentMethod ?? 'cash',
        'payment_id': (booking.paymentStatus == PAID ||
                booking.status == BOOKING_STATUS_COMPLETED)
            ? 2
            : null,
        'txn_id': (booking.paymentStatus == PAID ||
                booking.status == BOOKING_STATUS_COMPLETED)
            ? '#11'
            : null,
        'total_amount': totalAmount,
        'amount': price,
        'final_total_service_price': totalAmount,
        'sub_total': subTotal,
        'date': booking.date ??
            _formatDate(DateTime.now().add(const Duration(days: 1))),
        'booking_slot': '08:25:00',
        'duration_diff': booking.durationDiff ?? '60',
        'address': booking.address ??
            'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        'booking_address_id': booking.bookingAddressId ?? 1,
        'taxes': taxes,
        'start_at': booking.startAt,
        'end_at': booking.endAt,
        'reason': booking.reason,
        'is_cancelled': booking.isCancelled ?? 0,
        'created_at':
            _formatDate(DateTime.now().subtract(const Duration(hours: 5))),
        'updated_at': _formatDate(DateTime.now()),
        'service_attchments': booking.imageAttachments ??
            [
              'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400'
            ],
        'total_review': booking.totalReview ?? (ratingData.length),
        'total_rating': booking.totalRating ?? 5.0,
        'is_service_hourly': booking.type == 'hourly',
        'is_package_booking': false,
        'booking_type': 'service',
        'visit_type': booking.visitType ?? 'customer_location',
        'final_discount_amount': discountAmount,
        'final_coupon_discount_amount': couponDiscount,
        'final_total_tax': taxAmount,
        'final_sub_total': subTotal,
      },
      'service': {
        'id': booking.serviceId ?? 1,
        'name': booking.serviceName ?? 'VIP Escort Protection',
        'description': 'Professional service provided by our experienced team.',
        'category_id': 1,
        'category_name': 'General',
        'subcategory_id': null,
        'provider_id': booking.providerId ?? 1,
        'price': price,
        'price_format': '\$$price/hr',
        'type': booking.type ?? 'hourly',
        'discount': discountPercent,
        'duration': '2 Hours',
        'status': 1,
        'is_featured': 1,
        'total_rating': booking.totalRating ?? 5.0,
        'total_review': booking.totalReview ?? 10,
        'attchments': booking.imageAttachments ??
            [
              'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400'
            ],
        'attchments_array': [
          {
            'id': 1,
            'url': (booking.imageAttachments?.isNotEmpty == true)
                ? booking.imageAttachments!.first
                : 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400'
          }
        ],
        'image_attchments': booking.imageAttachments ??
            [
              'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400'
            ],
      },
      'customer': {
        'id': booking.customerId ?? 101,
        'first_name': booking.customerName?.split(' ').first ?? 'Pedro',
        'last_name': booking.customerName?.split(' ').length == 2
            ? booking.customerName!.split(' ').last
            : 'Norris',
        'display_name': booking.customerName ?? 'Pedro Norris',
        'email': 'demo@user.com',
        'contact_number': '+1 (555) 234-5678',
        'address': booking.address ??
            'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        'profile_image':
            booking.customerImage ?? 'https://i.pravatar.cc/300?u=pedro',
        'user_type': 'user',
        'status': 1,
      },
      'provider_data': {
        'id': booking.providerId ?? 1,
        'first_name': 'Pedro',
        'last_name': 'Norris',
        'display_name': booking.providerName ?? 'Pedro Norris',
        'email': 'provider@servicepro.com',
        'contact_number': '+1 (555) 123-4567',
        'address': 'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
        'profile_image':
            booking.providerImage ?? 'https://i.pravatar.cc/300?u=provider',
        'user_type': 'provider',
        'status': 1,
      },
      'handyman_data': handymanData != null
          ? [handymanData]
          : [
              {
                'id': 2,
                'first_name': 'Pedro',
                'last_name': 'Norris',
                'display_name': 'Pedro Norris',
                'email': 'demo@user.com',
                'contact_number': '+1 (555) 987-6543',
                'address':
                    'Vistar yojna, Lucknow, Uttar Pradesh, 226031, India',
                'profile_image': 'https://i.pravatar.cc/300?u=pedro',
                'user_type': 'handyman',
                'status': 1,
                'is_verified_handyman': 1,
                'designation': 'Senior Technician',
                'handyman_rating': 4.8,
              }
            ],
      'booking_activity': _getBookingActivity(
        booking.id ?? bookingId,
        booking.status ?? 'pending',
        booking.startAt,
        booking.endAt,
        booking.reason,
      ),
      'rating_data': ratingData,
      'payment_history': paymentHistory,
      'service_proof': [],
      'coupon_data': couponData,
      'extra_charges_list': [],
    };
  }
}

/// Demo Review Data
class DemoReviewData {
  /// Helper to format date in ISO 8601 format for DateTime.parse compatibility
  static String _formatDate(DateTime dt) {
    return dt.toIso8601String();
  }

  /// Get demo reviews list
  static List<Map<String, dynamic>> get reviewsJson => [
        {
          'id': 1,
          'rating': 5,
          'review':
              'Excellent service! The handyman was very professional and completed the work quickly. Highly recommended for anyone looking for quality home services.',
          'service_id': 1,
          'booking_id': 1001,
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(days: 2))),
          'customer_name': 'Alice Smith',
          'customer_profile_image': 'https://i.pravatar.cc/300?u=alice',
          'service_name': 'Home Cleaning',
          'handyman_id': 2,
          'handyman_name': 'Mike Johnson',
        },
        {
          'id': 2,
          'rating': 4,
          'review':
              'Great job! Very punctual and efficient. The cleaning was thorough and the prices were reasonable.',
          'service_id': 2,
          'booking_id': 1002,
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(days: 5))),
          'customer_name': 'Bob Johnson',
          'customer_profile_image': 'https://i.pravatar.cc/300?u=bob',
          'service_name': 'Electrical Repair',
          'handyman_id': 2,
          'handyman_name': 'Mike Johnson',
        },
        {
          'id': 3,
          'rating': 5,
          'review':
              'Amazing work on my plumbing issue. Fixed the leak in no time and gave me tips on maintenance. Will definitely hire again!',
          'service_id': 3,
          'booking_id': 1003,
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(days: 7))),
          'customer_name': 'Carol White',
          'customer_profile_image': 'https://i.pravatar.cc/300?u=carol',
          'service_name': 'Plumbing Service',
          'handyman_id': 2,
          'handyman_name': 'Mike Johnson',
        },
        {
          'id': 4,
          'rating': 4,
          'review':
              'Good experience overall. AC is working perfectly now. A bit late on arrival but made up for it with quality work.',
          'service_id': 4,
          'booking_id': 1004,
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(days: 10))),
          'customer_name': 'Daniel Green',
          'customer_profile_image': 'https://i.pravatar.cc/300?u=daniel',
          'service_name': 'AC Repair & Service',
          'handyman_id': 2,
          'handyman_name': 'Mike Johnson',
        },
        {
          'id': 5,
          'rating': 5,
          'review':
              'Best painting service I have ever used! Clean work, no mess left behind, and the colors look exactly as I wanted.',
          'service_id': 5,
          'booking_id': 1012,
          'created_at':
              _formatDate(DateTime.now().subtract(const Duration(days: 14))),
          'customer_name': 'Eva Martinez',
          'customer_profile_image': 'https://i.pravatar.cc/300?u=eva',
          'service_name': 'Painting Service',
          'handyman_id': 2,
          'handyman_name': 'Mike Johnson',
        },
      ];
}

/// Demo Chat Data for Chat UI testing
class DemoChatData {
  /// Demo chat contacts list
  static List<UserData> get chatContacts => [
        UserData(
          id: 201,
          uid: 'demo_pedro_001',
          firstName: 'Pedro',
          lastName: 'Norris',
          email: 'pedro@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=pedro',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 202,
          uid: 'demo_parsa_002',
          firstName: 'Parsa',
          lastName: 'Evana',
          email: 'parsa@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=parsa',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 203,
          uid: 'demo_sarah_003',
          firstName: 'Sarah',
          lastName: 'Johnson',
          email: 'sarah@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=sarah',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 204,
          uid: 'demo_michael_004',
          firstName: 'Michael',
          lastName: 'Brown',
          email: 'michael@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=michael',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 205,
          uid: 'demo_emma_005',
          firstName: 'Emma',
          lastName: 'Wilson',
          email: 'emma@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=emma',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 206,
          uid: 'demo_david_006',
          firstName: 'David',
          lastName: 'Martinez',
          email: 'david@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=david',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 207,
          uid: 'demo_lisa_007',
          firstName: 'Lisa',
          lastName: 'Anderson',
          email: 'lisa@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=lisa',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 208,
          uid: 'demo_john_008',
          firstName: 'John',
          lastName: 'Smith',
          email: 'john@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=john',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 209,
          uid: 'demo_olivia_009',
          firstName: 'Olivia',
          lastName: 'Davis',
          email: 'olivia@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=olivia',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 210,
          uid: 'demo_william_010',
          firstName: 'William',
          lastName: 'Taylor',
          email: 'william@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=william',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 211,
          uid: 'demo_sophia_011',
          firstName: 'Sophia',
          lastName: 'Garcia',
          email: 'sophia@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=sophia',
          userType: 'user',
          status: 1,
        ),
        UserData(
          id: 212,
          uid: 'demo_james_012',
          firstName: 'James',
          lastName: 'Miller',
          email: 'james@demo.com',
          profileImage: 'https://i.pravatar.cc/300?u=james',
          userType: 'user',
          status: 1,
        ),
      ];

  /// Get demo last messages for each contact
  static Map<String, String> get lastMessages => {
        'demo_pedro_001': 'Hi',
        'demo_parsa_002': 'Hi',
        'demo_sarah_003': 'When can you come?',
        'demo_michael_004': 'Thanks for the service!',
        'demo_emma_005': 'Hi',
        'demo_david_006': 'Is the plumber available?',
        'demo_lisa_007': 'Great work!',
        'demo_john_008': 'Hi',
        'demo_olivia_009': 'Can you send a quote?',
        'demo_william_010': 'Hi',
        'demo_sophia_011': 'Perfect, see you tomorrow',
        'demo_james_012': 'Hi',
      };

  /// Get demo last message time
  static String get lastMessageTime => '7:38 AM';
}
