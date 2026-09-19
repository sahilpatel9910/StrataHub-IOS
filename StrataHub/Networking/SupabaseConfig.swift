import Foundation

/// Public-by-design values (Supabase's anon key is meant to ship in client bundles;
/// it's already embedded in StrataHub's public web JS). Same values as the web app's
/// NEXT_PUBLIC_SUPABASE_URL / NEXT_PUBLIC_SUPABASE_ANON_KEY.
enum SupabaseConfig {
    static let url = "https://iizhbllbjgadoxrnafim.supabase.co"
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlpemhibGxiamdhZG94cm5hZmltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU3ODcyNjIsImV4cCI6MjA5MTM2MzI2Mn0.buqoJc63ANxiKv3rtRxHYrtBcBRDi4rEvqRUgB5FqQc"
}
