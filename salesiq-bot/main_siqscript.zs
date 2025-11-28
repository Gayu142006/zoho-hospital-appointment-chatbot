// ===============================================
// ZOHO HOSPITAL APPOINTMENT CHATBOT
// Main Deluge SalesIQ Script
// Version: 1.0.0
// ===============================================

// HANDLER: on_chat_opened
// Welcome user and display main menu
response = Map();
response.put("action", "reply");
response.put("replies", {
    "Welcome to ABC Hospital Online Assistant!",
    "How can we help you today?"
});
response.put("suggestions", {
    "Book appointment",
    "Manage appointment"
});
return {"data": response};

// ===============================================
// HANDLER: on_message
// ===============================================

user_input = input.get("text");
context = input.get("context");
result = Map();

if(user_input == "Book appointment") {
    result.put("action", "forward");
    result.put("next", "flow_book_appointment");
    return {"data": result};
}
else if(user_input == "Manage appointment") {
    result.put("action", "forward");
    result.put("next", "flow_manage_appointment");
    return {"data": result};
}

// AI: Suggest department based on symptoms
dept = suggestDepartment(user_input);
if(dept != "")
{
    context.put("suggested_department", dept);
    response = Map();
    response.put("action", "reply");
    response.put("replies", {
        "Based on your symptoms, we recommend " + dept + ".",
        "Would you like to book an appointment?"
    });
    response.put("suggestions", {
        "Yes, book appointment",
        "No, return to menu"
    });
    return {"data": response};
}

response = Map();
response.put("action", "reply");
response.put("replies", "Please choose an option below.");
response.put("suggestions", {
    "Book appointment",
    "Manage appointment"
});
return {"data": response};

// ===============================================
// FUNCTION: Suggest Department Based on Symptoms
// ===============================================
function suggestDepartment(userInput)
{
    input_lower = userInput.toLower();
    
    if(input_lower.contains("heart") || input_lower.contains("chest") || input_lower.contains("cardiac"))
        return "Cardiology";
    
    if(input_lower.contains("eye") || input_lower.contains("vision") || input_lower.contains("sight"))
        return "Ophthalmology";
    
    if(input_lower.contains("headache") || input_lower.contains("migraine") || input_lower.contains("brain") || input_lower.contains("neuro"))
        return "Neurology";
    
    if(input_lower.contains("tooth") || input_lower.contains("dental") || input_lower.contains("mouth"))
        return "Dentistry";
    
    if(input_lower.contains("bone") || input_lower.contains("joint") || input_lower.contains("fracture"))
        return "Orthopedics";
    
    return "";
}

// ===============================================
// FLOW: BOOK APPOINTMENT (Multi-step)
// ===============================================

step = ifnull(context.get("step"), "service_selection");
response = Map();

// STEP 1: Service Selection
if(step == "service_selection")
{
    response.put("action", "reply");
    response.put("replies", "Please choose the type of consultation you need:");
    
    cards = List();
    
    card1 = Map();
    card1.put("title", "General Consultation");
    card1.put("description", "Consult with a general physician");
    card1.put("buttons", {"Select:General Consultation"});
    cards.add(card1);
    
    card2 = Map();
    card2.put("title", "Cardiology");
    card2.put("description", "Heart and cardiovascular issues");
    card2.put("buttons", {"Select:Cardiology"});
    cards.add(card2);
    
    card3 = Map();
    card3.put("title", "Ophthalmology");
    card3.put("description", "Eye and vision problems");
    card3.put("buttons", {"Select:Ophthalmology"});
    cards.add(card3);
    
    response.put("cards", cards);
    context.put("step", "capture_details");
    return {"data": response};
}

// STEP 2: Capture Visitor Details
if(step == "capture_details")
{
    if(input.containsKey("text") && input.get("text").contains("Select:"))
    {
        service = input.get("text").replaceAll("Select:", "").trim();
        context.put("chosen_service", service);
    }
    
    response = Map();
    response.put("action", "reply");
    response.put("replies", "Please fill in your details to proceed:");
    response.put("input", {
        "type": "form",
        "fields": {
            {"type": "text", "name": "visitor_name", "label": "Full Name", "required": true},
            {"type": "email", "name": "visitor_email", "label": "Email", "required": true},
            {"type": "phone", "name": "visitor_phone", "label": "Phone Number", "required": true},
            {"type": "text", "name": "reason", "label": "Reason for Visit", "required": true},
            {"type": "date", "name": "preferred_date", "label": "Preferred Date", "required": true}
        }
    });
    context.put("step", "otp_send");
    return {"data": response};
}

// STEP 3: Send OTP
if(step == "otp_send")
{
    vals = input.get("values");
    if(vals != null)
    {
        context.put("visitor_name", vals.get("visitor_name"));
        context.put("visitor_email", vals.get("visitor_email"));
        context.put("visitor_phone", vals.get("visitor_phone"));
        context.put("reason", vals.get("reason"));
        context.put("preferred_date", vals.get("preferred_date"));
    }
    
    response = Map();
    response.put("action", "plug");
    response.put("name", "send_otp");
    response.put("params", {
        "phone": context.get("visitor_phone")
    });
    context.put("step", "otp_verify");
    return {"data": response};
}

// STEP 4: Verify OTP
if(step == "otp_verify")
{
    if(!input.containsKey("otp_code"))
    {
        response = Map();
        response.put("action", "reply");
        response.put("replies", "An OTP has been sent to your phone. Please enter it below:");
        response.put("input", {
            "type": "text",
            "name": "otp_code",
            "label": "Enter 6-digit OTP",
            "required": true
        });
        return {"data": response};
    }
    else
    {
        otp_val = input.get("otp_code");
        response = Map();
        response.put("action", "plug");
        response.put("name", "verify_otp");
        response.put("params", {
            "phone": context.get("visitor_phone"),
            "otp": otp_val
        });
        context.put("step", "fetch_slots");
        return {"data": response};
    }
}

// STEP 5: Fetch Available Slots
if(step == "fetch_slots")
{
    response = Map();
    response.put("action", "plug");
    response.put("name", "get_timeslots");
    response.put("params", {
        "date": context.get("preferred_date"),
        "department": context.get("chosen_service")
    });
    context.put("step", "select_slot");
    return {"data": response};
}

// STEP 6: Select Time Slot
if(step == "select_slot")
{
    slots = input.get("plug_response");
    if(slots == null)
        slots = {"09:00 AM", "10:00 AM", "02:00 PM", "03:00 PM"}; // Mock data
    
    response = Map();
    response.put("action", "reply");
    response.put("replies", "Available slots for " + context.get("preferred_date") + ":");
    response.put("input", {
        "type": "single_select",
        "name": "selected_slot",
        "label": "Choose a time:",
        "options": slots
    });
    context.put("step", "payment_prompt");
    return {"data": response};
}

// STEP 7: Payment Option
if(step == "payment_prompt")
{
    context.put("selected_slot", input.get("selected_slot"));
    
    response = Map();
    response.put("action", "reply");
    response.put("replies", {
        "You have selected: " + context.get("selected_slot"),
        "Would you like to pay for the consultation now?"
    });
    response.put("suggestions", {
        "Pay Now",
        "Pay at Hospital"
    });
    context.put("step", "process_payment");
    return {"data": response};
}

// STEP 8: Process Payment (Optional)
if(step == "process_payment")
{
    payment_choice = input.get("text");
    
    if(payment_choice == "Pay Now")
    {
        response = Map();
        response.put("action", "plug");
        response.put("name", "take_payment");
        response.put("params", {
            "amount": 500, // In INR
            "email": context.get("visitor_email"),
            "name": context.get("visitor_name")
        });
        context.put("payment_status", "paid");
        context.put("step", "confirm_booking");
        return {"data": response};
    }
    else
    {
        context.put("payment_status", "pending");
        context.put("step", "confirm_booking");
    }
}

// STEP 9: Confirm Booking
if(step == "confirm_booking")
{
    response = Map();
    response.put("action", "plug");
    response.put("name", "book_appointment");
    response.put("params", context); // Pass entire context with all details
    context.put("step", "booking_complete");
    return {"data": response};
}

// BOOKING COMPLETE
if(step == "booking_complete")
{
    response = Map();
    response.put("action", "reply");
    response.put("replies", {
        "Thank you! Your appointment has been booked.",
        "Confirmation details have been sent to " + context.get("visitor_email"),
        "We look forward to seeing you on " + context.get("preferred_date") + "."
    });
    context.put("step", "");
    return {"data": response};
}

// ===============================================
// FLOW: MANAGE APPOINTMENT
// ===============================================

// Similar structure for rescheduling and cancellation
// [SIMPLIFIED - See documentation for full implementation]

return {"data": response};
