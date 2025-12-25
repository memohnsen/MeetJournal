//
//  Supabase.swift
//  MeetJournal
//
//  Created by Maddisen Mohnsen on 12/25/25.
//

import Foundation
import Supabase

let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as! String
let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as! String

let supabase = SupabaseClient(
  supabaseURL: URL(string: supabaseURL)!,
  supabaseKey: supabaseKey
)

func getSupabaseClient() -> SupabaseClient {
    return SupabaseClient(
        supabaseURL: URL(string: supabaseURL)!,
        supabaseKey: supabaseKey
    )
}
