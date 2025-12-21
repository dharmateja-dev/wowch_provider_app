# Demo Mode Complete Guide

## Overview

This demo mode setup allows you to:
1. **Test with demo credentials** OR **use real credentials**
2. **See all UI screens** with realistic dummy data
3. **Explore all features** without a backend connection

---

## Sign-In Options

The sign-in screen shows both demo buttons AND accepts any credentials:

```
┌─────────────────────────────────────────────────────────────┐
│                     SIGN IN SCREEN                           │
├─────────────────────────────────────────────────────────────┤
│  Email:    [                                  ]              │
│  Password: [                                  ]              │
│                                                              │
│                    [   SIGN IN   ]                           │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐           │
│  │Demo Provider │  │Demo Handyman │  │  Reset   │           │
│  └──────────────┘  └──────────────┘  └──────────┘           │
└─────────────────────────────────────────────────────────────┘
```

---

## Demo Credentials

| User Type | Email | Password |
|-----------|-------|----------|
| **Provider** | `demo@provider.com` | `12345678` |
| **Handyman** | `demo@handyman.com` | `12345678` |

### Alternative Credentials (also work)

| User Type | Email | Password |
|-----------|-------|----------|
| **Provider** | `john.williams@servicepro.com` | `Provider@1` |
| **Handyman** | `mike.johnson@servicepro.com` | `Handyman@1` |

**Note:** Password must be 8-12 characters.

---

## User Profiles

### Provider: John Williams
- **Company:** ServicePro
- **Role:** Founder & CEO
- **Rating:** 4.9★
- **Total Bookings:** 1,247
- **Experience:** 10+ years
- **Location:** Los Angeles, CA

### Handyman: Mike Johnson
- **Role:** Senior Technician
- **Rating:** 4.8★
- **Experience:** 8+ years
- **Location:** Los Angeles, CA
- **Specialties:** Electrical, Plumbing, HVAC

---

## Demo Data Available

### Dashboard
| Provider | Handyman |
|----------|----------|
| 156 bookings | 45 bookings |
| 12 services | 3 today |
| 8 handymen | $25,000 revenue |
| $125,000 revenue | $5,000 cash |

### Bookings (All Statuses)
| Status | Count | ID Range |
|--------|-------|----------|
| Pending | 1 | 1001 |
| Accepted | 1 | 1002 |
| On Going | 1 | 1003 |
| In Progress | 1 | 1006 |
| Hold | 1 | 1007 |
| Completed | 1 | 1004 |
| Cancelled | 1 | 1005 |
| Rejected | 1 | 1008 |
| Failed | 1 | 1009 |
| Pending Approval | 1 | 1010 |
| Waiting Payment | 1 | 1011 |
| Paid | 1 | 1012 |

### Services
- Home Cleaning ($75.00)
- Electrical Repair ($50/hr)
- Plumbing Service ($45/hr)
- AC Repair & Service ($85.00)
- Painting Service ($40/hr)
- Digital Consultation ($100/hr)

### Handymen (4 employees)
- Mike Johnson - Electrical, Plumbing, Painting
- David Lee - Carpentry
- Robert Wilson - Plumbing, HVAC
- James Taylor - Painting

### Other Data
| Screen | Items |
|--------|-------|
| Notifications | 5 |
| Payments | 3 |
| Customers | 5 |
| Taxes | 3 |
| Bank Details | 2 |
| Wallet History | 5 transactions |
| Subscription Plans | 4 |
| Packages | 3 |
| Time Slots | 11 |
| Job Requests | 3 |
| Bids | 2 |
| Addon Services | 4 |
| Earnings | 2 |
| Reviews | 3 |
| Categories | 6 |
| Service Zones | 4 |
| Blogs | 2 |
| Help Desk Tickets | 2 |
| Documents | 3 |

---

## How to Use

### 1. Quick Demo Test
1. Launch the app
2. Click **"Demo Provider"** or **"Demo Handyman"**
3. Click **Sign In**
4. Explore the dashboard

### 2. Custom Credentials
1. Enter any email (with @)
2. Enter any password (8+ chars)
3. Click **Sign In**
4. App logs in as Provider by default

### 3. Switching User Types
- Login with `demo@handyman.com` → Opens Handyman Dashboard
- Login with any other email → Opens Provider Dashboard

---

## Configuration

In `lib/utils/demo_mode.dart`:

```dart
// Enable dummy data fallback when APIs fail
const bool DEMO_MODE_ENABLED = true;

// Show sign-in screen (don't auto-login)
const bool DEMO_AUTO_LOGIN = false;

// Show demo login buttons
const bool SHOW_DEMO_BUTTONS = true;
```

---

## Key Files

| File | Purpose |
|------|---------|
| `lib/utils/demo_mode.dart` | Config flags, user profiles |
| `lib/utils/demo_data.dart` | All dummy data for screens |
| `lib/networks/rest_apis.dart` | API fallback logic |
| `lib/auth/sign_in_screen.dart` | Demo login handling |

---

## Returning to Production

```dart
// In lib/utils/demo_mode.dart
const bool DEMO_MODE_ENABLED = false;
```

Restart the app to use real API calls.
