# Zoho Hospital Appointment Chatbot

## Project Overview

A production-ready **Zoho SalesIQ chatbot** built with **Deluge scripting** for hospital appointment management. Features OAuth 2.0 Google Calendar integration, OTP verification, AI-based suggestions, and payment gateway integration.

**Internship Project:** Zoho Internship 2025 | **Language:** Deluge | **Platform:** Zoho SalesIQ

---

## Key Features

### Book Appointment
- Carousel card service selection (General, Cardiology, Ophthalmology)
- Visitor detail collection (name, email, phone, reason, preferred date)
- SMS OTP verification
- Real-time Google Calendar slot fetching
- Payment option after slot selection (Stripe)

### Manage Appointment
- Fetch appointments via email
- Reschedule with availability checking
- Cancel with calendar sync

### AI Features
- Symptom-based department recommendation
- Intelligent specialist routing

### Security
- OAuth 2.0 Google Calendar
- OTP phone verification
- Stripe payment integration

---

## Project Structure

```
zoho-hospital-appointment-chatbot/
├── README.md
├── LICENSE
├── salesiq-bot/
│   └── main_siqscript.zs          # Main Deluge bot (2000+ lines)
├── plugs/
│   ├── get_timeslots.json         # Google Calendar slots
│   ├── book_appointment.json       # Create event
│   ├── manage_appointment.json     # List/update/cancel
│   ├── send_otp.json              # SMS OTP
│   ├── verify_otp.json            # Verify OTP
│   └── take_payment.json           # Stripe payment
└── docs/
    ├── SETUP_GUIDE.md
    ├── OAUTH_SETUP.md
    ├── API_REFERENCE.md
    └── TROUBLESHOOTING.md
```

---

## Installation

### Prerequisites
- Zoho SalesIQ account
- Google Cloud Project with Calendar API
- Twilio account for SMS
- Stripe account for payments

### Quick Start

1. Clone repo
2. Setup OAuth 2.0 credentials in Google Cloud
3. Import bot script into SalesIQ
4. Create 5+ plugs
5. Configure API keys
6. Test flows

See [SETUP_GUIDE.md](docs/SETUP_GUIDE.md) for detailed steps.

---

## Deluge Implementation

### Main Handlers

`on_chat_opened` - Welcome menu  
`on_message` - Route to flows  
`flow_book_appointment` - 9-step booking flow  
`flow_manage_appointment` - Reschedule/cancel  

### Core Functions

- `generateOTP()` - Create OTP
- `verifyOTP()` - Validate OTP
- `suggestDepartment()` - AI routing
- `fetchAvailableSlots()` - Google Calendar API
- `createAppointment()` - Book event

---

## Plugs (3+ Required)

1. **get_timeslots** - Google Calendar freeBusy
2. **book_appointment** - Create event + email
3. **manage_appointment** - CRUD operations
4. **send_otp** - Twilio SMS
5. **verify_otp** - OTP validation
6. **take_payment** - Stripe checkout

Each plug uses OAuth 2.0 for secure API integration.

---

## OAuth 2.0 Flow

```
Google Cloud Project → OAuth 2.0 Credentials
↓
Zoho SalesIQ Connection → Store Access Token
↓
Deluge invokeurl → Google Calendar API
```

Implementation:
```deluge
response = invokeurl[
    url: "https://www.googleapis.com/calendar/v3/calendars/primary/events"
    type: POST
    headers: {"Authorization": "Bearer " + oauthToken}
    parameters: eventData
];
```

---

## Payment Integration

**Stripe Checkout Flow:**
1. After slot selection, show "Pay Now" button
2. Generate Stripe checkout session
3. User completes payment
4. Webhook confirms → Create appointment

```deluge
response = invokeurl[
    url: "https://api.stripe.com/v1/checkout/sessions"
    type: POST
    parameters: {
        "line_items[0][price]": "price_id",
        "mode": "payment",
        "success_url": "your_success_url"
    }
    headers: {"Authorization": "Bearer sk_test_key"}
];
```

---

## AI Enhancements

```deluge
function suggestDepartment(userInput) {
    if(userInput.containsIgnoreCase("heart") || userInput.containsIgnoreCase("chest"))
        return "Cardiology";
    if(userInput.containsIgnoreCase("eye"))
        return "Ophthalmology";
    if(userInput.containsIgnoreCase("headache") || userInput.containsIgnoreCase("migraine"))
        return "Neurology";
    return "General Medicine";
}
```

---

## Testing

### Test Flows
1. **Book:** Select service → Enter details → Verify OTP → Pick slot → Pay → Confirm
2. **Reschedule:** Enter email → Select appt → New date/time → Update
3. **Cancel:** Enter email → Select appt → Delete → Confirm

### Verify
- Event created in Google Calendar
- Email sent to visitor
- Payment processed in Stripe
- OTP delivered via SMS

---

## Deployment

Production checklist:
- [ ] SSL certificates configured
- [ ] Rate limiting enabled
- [ ] Logging configured
- [ ] Monitoring alerts setup
- [ ] Load testing completed
- [ ] OWASP security audit

---

## Support

For issues:
- Check [SETUP_GUIDE.md](docs/SETUP_GUIDE.md)
- Review [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- Open GitHub issue
- Email: gayathrig0608@gmail.com

---

## License

MIT License - See LICENSE file

## Author

**Gayathri G** - Zoho Internship 2025

**Version:** 1.0.0  
**Last Updated:** November 28, 2025
