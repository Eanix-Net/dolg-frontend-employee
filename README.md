# LawnBuddy Employee App

A Flutter application for LawnBuddy employees to manage appointments, customers, equipment, and more.

![App Login Screen](https://lawnbuddy.net/static/images/app-screenshot.png)
![Website Landing Page](https://lawnbuddy.net/static/images/website-screenshot.png)

## Features

- **Authentication**: Secure login for employees with role-based access control
- **Dashboard**: Overview of key business metrics
- **Appointments**: Manage one-time and recurring appointments
- **Customers**: View and manage customer information
- **Employees**: Admin and lead tools for managing employees
- **Equipment**: Track and manage equipment inventory
- **Invoices**: Create and manage customer invoices
- **Locations**: Manage customer locations
- **Photos**: Upload and view job site photos
- **Quotes**: Create and manage customer quotes
- **Reviews**: View and respond to customer reviews
- **Timelogs**: Track employee work hours
- **Customer Portal**: Admin tools for managing the customer portal
- **Integrations**: Admin tools for third-party integrations

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK for Android deployment
- Xcode for iOS deployment
- Chrome for web deployment

### Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   cd frontend-employee
   ```

2. Install dependencies:
   ```
   flutter pub get
   ```


3. Run the app:
   ```
   flutter run
   ```

### CORS Configuration for Web

When running the app in a web browser, you may encounter CORS (Cross-Origin Resource Sharing) issues when connecting to the API.

#### Server-Side CORS Configuration

CORS must be enabled on the server side. Ensure that the API server at https://app.example.net has the following headers in its responses:

```
Access-Control-Allow-Origin: https://yourappdomain.com  # Or * for any domain (less secure)
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Origin, Content-Type, X-Auth-Token, Authorization, X-User-Token
Access-Control-Allow-Credentials: true  # If you need to send cookies
```

#### Development Environment CORS Support

For local development, you can:

1. Run Flutter web:
   ```
   flutter run -d chrome 
   ```

2. If running in debug mode, install a browser extension that disables CORS for testing purposes.
   Note: This is only for development and should never be used in production.

## Architecture

The app follows a clean architecture approach with separation of concerns:

- **Core**: Contains the business logic, models, and services
  - **API**: API service for communicating with the backend
  - **Models**: Data models for the application
  - **Services**: Business logic services
  - **Utils**: Utility functions and helpers

- **UI**: Contains the presentation layer
  - **Screens**: Application screens organized by feature
  - **Common**: Common UI components
  - **Theme**: App theme and styling

## Role-Based Access Control

The app implements role-based access control with three levels:

- **Employee**: Basic access to view and interact with most features
- **Lead**: Additional capabilities to create and edit resources
- **Admin**: Full access to all features, including deletion and system configuration

## Responsive Design

The app is designed to work on multiple form factors:

- Mobile phones (Android and iOS)
- Tablets
- Web browsers

## License

This project is proprietary and confidential.

## Contact

For support or inquiries, please contact daniel@jaredweisinger.com
