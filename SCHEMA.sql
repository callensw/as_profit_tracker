-- AS Profit Tracker Database Schema
-- Run these commands in your Supabase SQL Editor to set up or update the database

-- ============================================
-- TABLE: as_clients
-- ============================================
-- If creating fresh:
CREATE TABLE IF NOT EXISTS as_clients (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    hourly_rate DECIMAL(10,2),
    email TEXT,
    phone TEXT,
    address TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- If table exists but missing hourly_rate column, run this:
-- ALTER TABLE as_clients ADD COLUMN IF NOT EXISTS hourly_rate DECIMAL(10,2);

-- If table exists but missing address column, run this:
-- ALTER TABLE as_clients ADD COLUMN IF NOT EXISTS address TEXT;

-- ============================================
-- TABLE: as_transactions
-- ============================================
CREATE TABLE IF NOT EXISTS as_transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID REFERENCES as_clients(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    category TEXT,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLE: as_time_entries
-- ============================================
CREATE TABLE IF NOT EXISTS as_time_entries (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID REFERENCES as_clients(id) ON DELETE SET NULL,
    hours DECIMAL(5,2) NOT NULL,
    description TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLE: as_mileage
-- ============================================
CREATE TABLE IF NOT EXISTS as_mileage (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    client_id UUID REFERENCES as_clients(id) ON DELETE SET NULL,
    driver TEXT NOT NULL DEFAULT 'Driver 1',
    miles DECIMAL(10,2) NOT NULL,
    purpose TEXT,
    date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================
-- Enable RLS on all tables
ALTER TABLE as_clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE as_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE as_time_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE as_mileage ENABLE ROW LEVEL SECURITY;

-- Policies for as_clients
CREATE POLICY "Users can view own clients" ON as_clients FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own clients" ON as_clients FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own clients" ON as_clients FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own clients" ON as_clients FOR DELETE USING (auth.uid() = user_id);

-- Policies for as_transactions
CREATE POLICY "Users can view own transactions" ON as_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own transactions" ON as_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own transactions" ON as_transactions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own transactions" ON as_transactions FOR DELETE USING (auth.uid() = user_id);

-- Policies for as_time_entries
CREATE POLICY "Users can view own time entries" ON as_time_entries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own time entries" ON as_time_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own time entries" ON as_time_entries FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own time entries" ON as_time_entries FOR DELETE USING (auth.uid() = user_id);

-- Policies for as_mileage
CREATE POLICY "Users can view own mileage" ON as_mileage FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own mileage" ON as_mileage FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own mileage" ON as_mileage FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own mileage" ON as_mileage FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- FIX: Add missing columns to existing tables
-- Run these if you get schema errors
-- ============================================

-- Add hourly_rate column to as_clients (fixes "Could not find the 'hourly_rate' column" error)
ALTER TABLE as_clients ADD COLUMN IF NOT EXISTS hourly_rate DECIMAL(10,2);

-- Add address column to as_clients
ALTER TABLE as_clients ADD COLUMN IF NOT EXISTS address TEXT;

-- Add driver column to as_mileage
ALTER TABLE as_mileage ADD COLUMN IF NOT EXISTS driver TEXT NOT NULL DEFAULT 'Driver 1';
