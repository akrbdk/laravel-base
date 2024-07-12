## Laravel-base repository for quickly starting new projects

## Installation using Docker

1. Clone the project using Git.
2. Run `make install-backend`.
3. Adjust the `DB_*` parameters in the `.env` file.
4. Run `composer install` inside the `php` container.
5. Inside the `php` container, run the following commands:
    ```bash
    php artisan key:generate --ansi
    php artisan migrate
    php artisan orchid:admin admin admin@admin.com password
    php artisan db:seed --class=ClientSeeder
    php artisan db:seed --class=ServiceSeeder
    ```
6. Open in a browser: http://localhost
