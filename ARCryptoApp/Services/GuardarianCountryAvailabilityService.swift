import Foundation

class GuardarianCountryAvailabilityService {
    private let baseURL = "https://api-payments.guardarian.com/v1/countries"
    
    func verifyCountrySupport() async -> Bool {
        guard let currentCountryCode = Locale.current.region?.identifier else {
            return false
        }
        
        do {
            guard let url = URL(string: baseURL) else {
                return false
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            let countries = try JSONDecoder().decode([Country].self, from: data)
            
            return countries.contains { country in
                country.codeIsoAlpha2 == currentCountryCode && country.supported
            }
        } catch {
            return false
        }
    }
}

private struct Country: Codable {
    let codeIsoAlpha2: String
    let supported: Bool
    
    enum CodingKeys: String, CodingKey {
        case codeIsoAlpha2 = "code_iso_alpha_2"
        case supported
    }
} 
