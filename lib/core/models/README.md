# LawnBuddy Employee App Models

This directory contains the data models used in the LawnBuddy Employee App. These models correspond to the database models defined in the backend's `models.py` file.

## Model Structure

All models implement the `BaseModel` interface, which provides common functionality:
- `toJson()`: Convert the model to a JSON map
- `copyWith()`: Create a copy of the model with updated fields

## Code Generation

These models use the `json_serializable` package for JSON serialization. After making changes to any model, run the following command to generate the serialization code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Available Models

### User Models
- `Employee`: Represents an employee with role-based permissions

### Customer Models
- `Customer`: Represents a customer
- `CustomerLocation`: Represents a location associated with a customer

### Service Models
- `Service`: Represents a service offered by the company

### Appointment Models
- `Appointment`: Represents a one-time appointment
- `RecurringAppointment`: Represents a recurring appointment

### Invoice Models
- `Invoice`: Represents an invoice for services
- `InvoiceItem`: Represents a line item on an invoice

### Quote Models
- `Quote`: Represents a price quote for services
- `QuoteItem`: Represents a line item on a quote

### Equipment Models
- `Equipment`: Represents a piece of equipment
- `EquipmentCategory`: Represents a category of equipment

### Other Models
- `Review`: Represents a customer review
- `Photo`: Represents a job site photo
- `TimeLog`: Represents an employee's time tracking for a job

## Usage

Import the models using:

```dart
import 'package:lawnbuddy_employee/core/models/models.dart';
```

This will give you access to all the models in the application. 