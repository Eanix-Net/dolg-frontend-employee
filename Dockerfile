FROM ubuntu:20.04 AS build

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-8-jdk \
    wget

# Set up Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

# Set Flutter to use web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Copy the app files to the container
WORKDIR /app
COPY ./ .

# Get app dependencies
RUN flutter pub get

# Build the app for the web
RUN flutter build web --release --dart-define-from-file=/app/.env

# Stage 2 - Create the run-time image
FROM nginx:1.21-alpine

# Copy the build output to the nginx public folder
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx server
CMD ["nginx", "-g", "daemon off;"] 
