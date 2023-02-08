//
//  CardTokenisationResponse.swift
//  flutter_checkout_payment
//
//  Created by Edward Poot on 07/02/2023.
//

import Foundation

class CardTokenisationResponse: Codable {
    
    public let type: String?
    public let token: String?
    public let expiresOn: String?
    public let expiryMonth: Int?
    public let expiryYear: Int?
    public let scheme: String?
    public let last4: String?
    public let bin: String?
    public let cardType: String?
    public let cardCategory: String?
    public let issuer: String?
    public let issuerCountry: String?
    public let productId: String?
    public let productType: String?
    public let billingAddress: BillingAddress?
    public let phone: Phone?
    public let name: String?
    
    internal init(type: String? = nil, token: String? = nil, expiresOn: String? = nil, expiryMonth: Int? = nil, expiryYear: Int? = nil, scheme: String? = nil, last4: String? = nil, bin: String? = nil, cardType: String? = nil, cardCategory: String? = nil, issuer: String? = nil, issuerCountry: String? = nil, productId: String? = nil, productType: String? = nil, name: String? = nil, billingAddress: BillingAddress? = nil, phone: Phone? = nil) {
        self.type = type
        self.token = token
        self.expiresOn = expiresOn
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.scheme = scheme
        self.last4 = last4
        self.bin = bin
        self.cardType = cardType
        self.cardCategory = cardCategory
        self.issuer = issuer
        self.issuerCountry = issuerCountry
        self.productId = productId
        self.productType = productType
        self.name = name
        self.billingAddress = billingAddress
        self.phone = phone
    }
}

class BillingAddress: Codable {
    
    public let addressLine1: String?
    public let addressLine2: String?
    public let postcode: String?
    public let country: String?
    public let city: String?
    public let state: String?
    
    internal init(addressLine1: String?, addressLine2: String?, postcode: String?, country: String?, city: String?, state: String?) {
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.postcode = postcode
        self.country = country
        self.city = city
        self.state = state
    }
}

class Phone: Codable
{
    public let countryCode: String?
    public let number: String?
    
    internal init(countryCode: String?, number: String?) {
        self.countryCode = countryCode
        self.number = number
    }
}
