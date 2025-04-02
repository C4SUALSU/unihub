# unihub

# UNIHUB MVP (Current Stage)

## Current Features
- **User Roles**: Admin, Vendor, User with role-based access
- **Events Management**: Admins can create/update events
- **Food Vendors**: 
  - Vendors can create shops and list items
  - Users can view vendor shops and items
- **Services Marketplace**:
  - Service vendors can list offerings
  - Users can view services
- **Messaging System**:
  - Real-time chat between users and vendors
  - Conversation history
- **Supabase Integration**:
  - Authentication
  - Realtime database
  - Storage for images
  - Row Level Security (RLS)

## Project Structure
```
lib/
├── models/          # Data models
├── pages/           # All screens:
│   ├── add_event_page.dart
│   ├── add_service_page.dart
│   ├── add_shop_page.dart
│   ├── chat_page.dart
│   ├── events_page.dart
│   ├── food_vendors_page.dart
│   ├── home_page.dart
│   ├── login_page.dart
│   ├── service_detail_page.dart
│   ├── services_page.dart
│   ├── shop_detail_page.dart
│   └── vendors_page.dart
├── services/        # Supabase services
└── main.dart
```

## Setup Instructions

### 1. Supabase Setup
**Required SQL Schema**:
```sql
-- User roles enum
CREATE TYPE public.user_role AS ENUM ('admin', 'vendor', 'user');

-- User profiles
CREATE TABLE public.profiles (
  id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  role user_role NOT NULL DEFAULT 'user'
);

-- Vendors
CREATE TABLE public.vendors (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  image_url TEXT,
  user_id UUID REFERENCES auth.users(id)
);

-- Shop items
CREATE TABLE public.shop_items (
  id SERIAL PRIMARY KEY,
  vendor_id INTEGER REFERENCES vendors(id),
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT
);

-- Services
CREATE TABLE public.services (
  id SERIAL PRIMARY KEY,
  vendor_id INTEGER REFERENCES vendors(id),
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  image_url TEXT
);

-- Messages
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  recipient_id UUID NOT NULL REFERENCES auth.users(id),
  content TEXT NOT NULL,
  conversation_id TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

**RLS Policies**:
```sql
-- For vendors table
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert their own vendor profile" 
ON public.vendors FOR INSERT
WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own vendor profile" 
ON public.vendors FOR UPDATE
USING (auth.uid() = user_id);
CREATE POLICY "Anyone can view vendor profiles" 
ON public.vendors FOR SELECT
USING (true);

-- For shop_items table
ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Vendors can manage their own items" 
ON public.shop_items FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM vendors
    WHERE vendors.id = shop_items.vendor_id
    AND vendors.user_id = auth.uid()
  )
);

-- For services table
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Vendors can manage their own services" 
ON public.services FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM vendors
    WHERE vendors.id = services.vendor_id
    AND vendors.user_id = auth.uid()
  )
);
```

### 2. Flutter Setup
1. Update `lib/main.dart` with your Supabase credentials:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

2. Add required dependencies in `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.9.0
  uuid: ^3.0.7
```

3. Create storage buckets in Supabase:
   - `event-images` (public read access)
   - `vendor-images` (public read access)
   - `service-images` (public read access)

## Known Issues
1. Vendor pages need UI cleanup
2. Missing real-time updates on vendor pages
3. No search/filter functionality
4. Inconsistent loading states

## Next Steps (Cleaning Vendor Pages)
1. **UI Improvements**:
   - Add pull-to-refresh
   - Better error handling UI
   - Consistent card designs
2. **Functionality**:
   - Real-time updates for vendor items
   - Vendor dashboard
   - Category filters
3. **Performance**:
   - Image caching
   - Pagination for large lists

## Contribution Guidelines
1. Create feature branches for changes
2. Test RLS policies after schema changes
3. Update documentation when adding new features
```

This README provides a clear snapshot of the current project state and roadmap. For the next steps in cleaning vendor pages, focus on:

1. Standardizing the UI components across all vendor-related pages
2. Adding proper loading/error states
3. Implementing consistent data fetching patterns
4. Adding real-time capabilities using Supabase Realtime

Would you like me to elaborate on any specific improvement for the vendor pages?