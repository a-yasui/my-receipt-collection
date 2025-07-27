# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a cooking recipe management site (料理メモサイト) that focuses on efficient input and clear display. It supports nested recipe structures, allowing recipes to include sub-recipes (e.g., sauces, marinades).

## Tech Stack

- **Frontend**: Vue.js 3 + Composition API (Node.js 24)
- **Backend**: PHP 8.3 (Laravel)
- **Database**: MySQL 8.4
- **Infrastructure**: Docker + Docker Compose (without version field)
- **Reverse Proxy**: Traefik (running externally)
- **Styling**: Tailwind CSS or Bootstrap

## Key Commands

### Quick Start
```bash
# Initial setup (first time only)
make setup

# Start development environment
make up

# Stop environment
make down
```

### Docker Commands
```bash
# View logs
docker compose logs -f [service_name]

# Execute commands in containers
docker compose exec backend php artisan [command]
docker compose exec frontend npm run [command]
```

### Laravel Development
```bash
# Run migrations
make migrate
# or directly: docker compose exec backend php artisan migrate

# Create new migration
docker compose exec backend php artisan make:migration [migration_name]

# Run tests
docker compose exec backend php artisan test

# Clear cache
docker compose exec backend php artisan cache:clear
docker compose exec backend php artisan config:clear

# Access backend shell
make shell-backend
```

### Vue.js Development
```bash
# Install dependencies (done automatically on container start)
docker compose exec frontend npm install

# Development server (runs automatically)
# Manual restart: docker compose restart frontend

# Build for production
docker compose exec frontend npm run build

# Run tests
docker compose exec frontend npm run test

# Lint code
docker compose exec frontend npm run lint

# Access frontend shell
make shell-frontend
```

## Architecture Overview

### Infrastructure
- **Networks**:
  - `degg-develop-net` (external, for Traefik routing)
  - `my-receipt-net` (internal, for service communication)
- **Access URL**: http://my-receipt.localhost
- **Container Names**:
  - `my-receipt-backend` (PHP 8.3 + Nginx) - connected to both networks
  - `my-receipt-frontend` (Node.js 24 + Vite) - connected to both networks
  - `my-receipt-mysql` (MySQL 8.4) - internal network only
  - `my-receipt-redis` (Redis 7) - internal network only

### Database Structure
The system uses a hierarchical recipe structure where:
- Main recipes can have sub-recipes (sauces, marinades, etc.)
- Ingredients can reference sub-recipes
- All recipes share the same `recipes` table with `parent_recipe_id` for hierarchy

Key tables:
- `recipes`: Stores both main and sub-recipes
- `ingredients`: Recipe ingredients with optional sub-recipe references
- `steps`: Cooking instructions
- `tags`: Recipe categorization
- `favorite_ingredients`: Frequently used ingredients for autocomplete

### API Structure
RESTful API endpoints under `/api/`:
- Recipe CRUD operations
- Ingredient favorites management
- Tag management
- Search functionality
- Health check at `/api/health`

### Frontend Component Architecture
```
src/
 components/
    Recipe/          # Recipe-related components
    Ingredient/      # Ingredient management
    Step/           # Cooking steps
    Common/         # Shared components
    Layout/         # Page layout components
 views/              # Page components
 stores/             # State management
 router/             # Vue Router configuration
```

## Development Phases

Current implementation follows these phases:
1. **Phase 1**: Basic CRUD functionality
2. **Phase 2**: Nested recipe structure
3. **Phase 3**: Efficiency features (autocomplete, drag-drop, timers)
4. **Phase 4**: Advanced features (import/export, printing)

## Key Features to Remember

1. **Nested Recipe Support**: When implementing ingredients, always consider that an ingredient might reference a sub-recipe
2. **Efficiency Focus**: Prioritize features that make input faster (autocomplete, favorites, drag-and-drop)
3. **Clear Display**: The UI should make it easy to see recipe relationships and navigate between main and sub-recipes
4. **Timer Integration**: Steps can have associated cooking times for timer functionality

## Testing Approach

- Backend: Use PHPUnit for Laravel tests
  ```bash
  docker compose exec backend php artisan test
  ```
- Frontend: Use Vue Test Utils and Vitest
  ```bash
  docker compose exec frontend npm run test
  ```
- E2E: Consider Cypress for end-to-end testing

## Common Patterns

### Creating Sub-recipes
Sub-recipes are created with a `parent_recipe_id` and can be referenced by ingredients through `sub_recipe_id`.

### Ingredient Autocomplete
Use the `favorite_ingredients` table to provide suggestions based on usage frequency.

### Recipe Search
Implement full-text search on recipe titles and filter by tags.

### Docker Compose Configuration
- No `version` field in docker-compose.yml (not required in recent Docker versions)
- Dual network architecture: external network for Traefik routing, internal network for service communication

## Environment Setup

### Prerequisites
- Docker and Docker Compose installed
- Traefik running on `degg-develop-net` network

### Initial Setup
Run `make setup` to automatically:
1. Configure Laravel project environment
2. Create Vue.js project if not exists
3. Build and start all containers
4. Run database migrations
5. Generate Laravel APP_KEY

Note: Laravel project is already included in the `backend/` directory.

### Directory Structure
```
my-cook-receipt/
├── backend/          # Laravel project
├── frontend/         # Vue.js project
├── docker/           # Docker configurations
│   ├── php/         # PHP/Nginx configs
│   ├── mysql/       # MySQL initialization
│   └── nginx/       # Nginx config
├── docker-compose.yml
├── Makefile         # Convenient commands
└── .env.docker      # Environment template
```
