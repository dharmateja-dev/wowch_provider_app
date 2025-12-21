/// Demo Data Provider
/// This file provides comprehensive dummy data for all screens in the app.
/// Used for UI testing without backend.

import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart'
    as dashboard;
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart'
    as handyman;
import 'package:handyman_provider_flutter/models/notification_list_response.dart';
import 'package:handyman_provider_flutter/models/payment_list_reasponse.dart';
import 'package:handyman_provider_flutter/models/revenue_chart_data.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';

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
        onlineHandyman: ['2', '3', '5'],
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
        firstName: 'Mike',
        lastName: 'Johnson',
        email: 'mike@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '+1234567891',
        status: 1,
        displayName: 'Mike Johnson',
        profileImage: 'https://i.pravatar.cc/300?u=mike',
        designation: 'Senior Handyman',
        handymanRating: 4.8,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
      ),
      UserData(
        id: 3,
        firstName: 'David',
        lastName: 'Williams',
        email: 'david@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '+1234567892',
        status: 1,
        displayName: 'David Williams',
        profileImage: 'https://i.pravatar.cc/300?u=david',
        designation: 'Electrician',
        handymanRating: 4.6,
        isHandymanAvailable: true,
        isVerifiedHandyman: 1,
      ),
      UserData(
        id: 4,
        firstName: 'Robert',
        lastName: 'Brown',
        email: 'robert@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '+1234567893',
        status: 1,
        displayName: 'Robert Brown',
        profileImage: 'https://i.pravatar.cc/300?u=robert',
        designation: 'Plumber',
        handymanRating: 4.5,
        isHandymanAvailable: false,
        isVerifiedHandyman: 1,
      ),
      UserData(
        id: 5,
        firstName: 'James',
        lastName: 'Davis',
        email: 'james@handyman.com',
        userType: USER_TYPE_HANDYMAN,
        contactNumber: '+1234567894',
        status: 1,
        displayName: 'James Davis',
        profileImage: 'https://i.pravatar.cc/300?u=james',
        designation: 'Painter',
        handymanRating: 4.7,
        isHandymanAvailable: true,
        isVerifiedHandyman: 0,
      ),
    ];

/// Demo Bookings List - ALL BOOKING STATUSES
/// Status types: pending, accept, on_going, in_progress, hold, cancelled,
/// rejected, failed, completed, pending_approval, waiting, paid
List<BookingData> get demoBookings => [
      // 1. PENDING - New booking awaiting acceptance
      BookingData(
        id: 1001,
        serviceName: 'Home Cleaning',
        serviceId: 1,
        customerName: 'Alice Smith',
        customerId: 101,
        customerImage: 'https://i.pravatar.cc/300?u=alice',
        providerId: 1,
        providerName: 'John Provider',
        providerImage: 'https://i.pravatar.cc/300?u=provider',
        status: BOOKING_STATUS_PENDING,
        statusLabel: 'Pending',
        date: '2024-01-20 10:00:00',
        address: '123 Main Street, New York, NY 10001',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 75.00,
        totalAmount: 82.50,
        discount: 10,
        type: SERVICE_TYPE_FIXED,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 1,
        description: 'Deep cleaning of 3-bedroom apartment',
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
        ],
      ),

      // 2. ACCEPT - Booking accepted, waiting to start
      BookingData(
        id: 1002,
        serviceName: 'Electrical Repair',
        serviceId: 2,
        customerName: 'Bob Johnson',
        customerId: 102,
        customerImage: 'https://i.pravatar.cc/300?u=bob',
        providerId: 1,
        providerName: 'John Provider',
        status: BOOKING_STATUS_ACCEPT,
        statusLabel: 'Accepted',
        date: '2024-01-21 14:30:00',
        address: '456 Oak Avenue, Brooklyn, NY 11201',
        visitType: VISIT_OPTION_ON_SITE,
        amount: 100.00,
        totalAmount: 100.00,
        discount: 0,
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_STRIPE,
        quantity: 2,
        description: 'Fix electrical outlets in living room',
        handyman: [
          Handyman(
            id: 1,
            bookingId: 1002,
            handymanId: 2,
            handyman: demoHandymen[0],
          ),
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
        type: SERVICE_TYPE_HOURLY,
        paymentStatus: PENDING,
        paymentMethod: PAYMENT_METHOD_COD,
        quantity: 4,
        description: 'Building custom shelves in living room',
        startAt: '2024-01-22 11:30:00',
        handyman: [
          Handyman(
            id: 3,
            bookingId: 1006,
            handymanId: 5,
            handyman: demoHandymen[3],
          ),
        ],
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
        createdAt:
            DateTime.now().subtract(const Duration(minutes: 5)).toString(),
        data: Data(
          id: 1001,
          type: ADD_BOOKING,
          subject: 'New Booking',
          message: 'You have a new booking for Home Cleaning',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '2',
        readAt: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)).toString(),
        data: Data(
          id: 1002,
          type: ASSIGNED_BOOKING,
          subject: 'Booking Assigned',
          message:
              'Mike Johnson has been assigned to Electrical Repair booking',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '3',
        readAt: DateTime.now().subtract(const Duration(hours: 2)).toString(),
        createdAt: DateTime.now().subtract(const Duration(hours: 3)).toString(),
        data: Data(
          id: 1003,
          type: UPDATE_BOOKING_STATUS,
          subject: 'Booking Status Updated',
          message: 'Plumbing Service booking is now in progress',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '4',
        readAt: DateTime.now().subtract(const Duration(days: 1)).toString(),
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toString(),
        data: Data(
          id: 1004,
          type: PAID_FOR_BOOKING,
          subject: 'Payment Received',
          message: 'Payment of \$72.25 received for AC Repair & Service',
          notificationType: NOTIFICATION_TYPE_BOOKING,
        ),
      ),
      NotificationData(
        id: '5',
        readAt: DateTime.now().subtract(const Duration(days: 2)).toString(),
        createdAt: DateTime.now().subtract(const Duration(days: 2)).toString(),
        data: Data(
          id: 1005,
          type: CANCEL_BOOKING,
          subject: 'Booking Cancelled',
          message: 'Painting Service booking has been cancelled by customer',
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
