# Use PHP 8.1 image
FROM php:8.1-fpm

# Set the working directory inside the container
WORKDIR /var/www

# Install system dependencies and PHP extensions required by Composer and Laravel
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy the rest of the application files
COPY ./ /var/www

# Install PHP dependencies
RUN composer install

# Expose port 8000
EXPOSE 8000

# Start the Laravel app
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
