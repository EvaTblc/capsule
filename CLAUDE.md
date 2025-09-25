# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Application Overview

This is a Ruby on Rails 7.2+ application called "Capsule" - a collection management system where users can organize items into collections with categories and tags. The app supports multiple item types (books, movies, toys, video games) with polymorphic models and metadata storage.

## Architecture

### Data Model Hierarchy
```
User (Devise + Google OAuth)
 └── Collection (belongs_to user)
     └── Category (belongs_to collection)
         └── Item (STI: BookItem, MovieItem, ToyItem, VideoGameItem)
             └── ItemsTag (many-to-many relationship)
```

### Key Features
- **Authentication**: Devise with Google OAuth2 integration
- **File Storage**: Active Storage for photos with Cloudinary integration
- **PWA Support**: Service worker and manifest for mobile app-like experience
- **Image Processing**: Photo variants and image previews
- **Barcode Scanning**: JavaScript-based barcode scanning functionality
- **Polymorphic Items**: Single Table Inheritance for different item types
- **Metadata Storage**: JSON metadata field for type-specific attributes

### Frontend Stack
- **CSS Framework**: Bootstrap 5.3 with custom SCSS
- **JavaScript**: Stimulus controllers with importmap
- **Icons**: Font Awesome
- **Components**: Custom component architecture in `app/assets/stylesheets/components/`

## Common Development Commands

### Database
```bash
bin/rails db:create          # Create databases
bin/rails db:migrate         # Run migrations
bin/rails db:seed            # Seed database
bin/rails db:reset           # Drop, create, migrate, and seed
```

### Testing
```bash
bin/rails test               # Run all tests except system tests
bin/rails test:db            # Reset database and run tests
bin/rails test test/models/  # Run specific test directory
```

### Code Quality
```bash
bin/rubocop                  # Run RuboCop linter
bin/rubocop -a               # Auto-correct RuboCop offenses
bin/brakeman                 # Run security analysis
```

### Server & Assets
```bash
bin/rails server             # Start development server
bin/rails assets:precompile  # Precompile assets for production
```

## Code Conventions

### Models
- Use Single Table Inheritance for item types (BookItem, MovieItem, etc.)
- Metadata stored as JSON hash in `metadata` field
- Validate metadata keys in subclasses using `check_metadata_keys`
- Use `ensure_metadata` callback to initialize empty metadata hash

### Controllers
- Nested routing: `/collections/:id/categories/:id/items/:id`
- Custom Devise controllers in `app/controllers/users/` namespace
- Use strong parameters for nested attributes

### Views
- Bootstrap-based styling with custom SCSS components
- Stimulus controllers for JavaScript functionality
- Simple Form gem for form helpers
- PWA manifest and service worker for mobile support

### File Organization
- Custom components in `app/assets/stylesheets/components/`
- Page-specific styles in `app/assets/stylesheets/pages/`
- Stimulus controllers in `app/javascript/controllers/`
- Custom helpers organized by functionality

## Environment Setup

### Required Services
- PostgreSQL database
- Cloudinary account for image hosting
- Google OAuth2 credentials for authentication

### Configuration Files
- `config/credentials.yml.enc` for secrets (use `bin/rails credentials:edit`)
- `.env` files for development environment variables (dotenv-rails)
- `config/meta.yml` for SEO meta tags configuration

### Key Gems
- **devise** + **omniauth-google-oauth2**: Authentication
- **bootstrap** + **sassc-rails**: Styling
- **cloudinary**: Image hosting and processing
- **simple_form**: Form builders
- **faker**: Test data generation

## Testing Strategy

The application uses Rails' built-in testing framework (not RSpec). Test files are organized in the standard Rails structure:
- `test/models/` for model tests
- `test/controllers/` for controller tests
- `test/system/` for integration tests (Capybara + Selenium)