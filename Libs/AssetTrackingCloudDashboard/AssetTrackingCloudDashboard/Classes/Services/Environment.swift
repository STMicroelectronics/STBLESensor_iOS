//
//  Environment.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 30/10/2020.
//

import Foundation

public struct Environment {
    public let baseUrl: String
    let region: String
    let clientId: String
    let identityProvider: String
    let oauth: CognitoOauth
    let endpoints: WebCloudEndpoint
    
    struct CognitoOauth {
        let authorizationUrl: String
        let tokenUrl: String
        let redirectUrl: String
    }
    
    struct WebCloudEndpoint {
        let webUrl: String
        let webLogoutUrl: String
    }
    
    public static var current = atrdev
}

/**
 ASSET TRACKING Environment
 **/
public extension Environment {
    static let atrprod: Environment = Environment(baseUrl: "https://jim3rgi6d3.execute-api.eu-central-1.amazonaws.com/",
                                               region: "eu-central-1",
                                               clientId: "bhfuavci9uthr174tpc8iqfjc",
                                               identityProvider: "sso-myst-com",
                                               oauth: CognitoOauth.atrprod,
                                               endpoints: WebCloudEndpoint.atrprod)
    
    static let atrpreprod: Environment = Environment(baseUrl: "https://gizravz67f.execute-api.eu-central-1.amazonaws.com/",
                                                  region: "eu-central-1",
                                                  clientId: "3fpkoee5ucalq6989eqcr106r4",
                                                  identityProvider: "sso-myst-com",
                                                  oauth: CognitoOauth.atrpreprod,
                                                  endpoints: WebCloudEndpoint.atrpreprod)
    
    static let atrdev: Environment = Environment(baseUrl: "https://ve06ehxrol.execute-api.eu-central-1.amazonaws.com/",
                                                  region: "eu-central-1",
                                                  clientId: "2o6it54i3qoghg6njcaot8f5t4",
                                                  identityProvider: "sso-myst-com",
                                                  oauth: CognitoOauth.atrdev,
                                                  endpoints: WebCloudEndpoint.atrdev)
}

extension Environment.CognitoOauth {
    static let atrprod = Environment.CognitoOauth(authorizationUrl: "https://bowl-domain.auth.eu-central-1.amazoncognito.com/oauth2/authorize",
                                               tokenUrl: "https://bowl-domain.auth.eu-central-1.amazoncognito.com/oauth2/token",
                                               redirectUrl: "stassettracking://callback/")
    
    static let atrpreprod = Environment.CognitoOauth(authorizationUrl: "https://cup-domain.auth.eu-central-1.amazoncognito.com/oauth2/authorize",
                                               tokenUrl: "https://cup-domain.auth.eu-central-1.amazoncognito.com/oauth2/token",
                                               redirectUrl: "stassettracking://callback/")
    
    static let atrdev = Environment.CognitoOauth(authorizationUrl: "https://devcup-domain.auth.eu-central-1.amazoncognito.com/oauth2/authorize",
                                                  tokenUrl: "https://devcup-domain.auth.eu-central-1.amazoncognito.com/oauth2/token",
                                                  redirectUrl: "stassettracking://callback/")
}

extension Environment.WebCloudEndpoint {
    static let atrprod = Environment.WebCloudEndpoint(webUrl: "https://d3aqorzcqycube.cloudfront.net/",
                                                   webLogoutUrl: "https://bowl-domain.auth.eu-central-1.amazoncognito.com/logout?")
    
    static let atrpreprod = Environment.WebCloudEndpoint(webUrl: "https://dnnnwy09xgwth.cloudfront.net/",
                                                  webLogoutUrl: "https://cup-domain.auth.eu-central-1.amazoncognito.com/logout?")
    
    static let atrdev = Environment.WebCloudEndpoint(webUrl: "https://d1pfd9bmiq67h4.cloudfront.net/",
                                              webLogoutUrl: "https://devcup-domain.auth.eu-central-1.amazoncognito.com/logout?")
}


/**
 PREDICTIVE MAINTENANCE Environment
 **/
public extension Environment {
    
    static let predmntprod: Environment = Environment(baseUrl: "https://1k8p44lea1.execute-api.eu-west-1.amazonaws.com/live",
                                               region: "eu-west-1",
                                               clientId: "3rkn4dlco2in15m7v4iuo7g6u",
                                               identityProvider: "mystlive",
                                               oauth: CognitoOauth.predmntprod,
                                               endpoints: WebCloudEndpoint.predmntprod)
}

extension Environment.CognitoOauth {
    static let predmntprod = Environment.CognitoOauth(authorizationUrl: "https://364380975641-predmaintapp-live.auth.eu-west-1.amazoncognito.com/oauth2/authorize",
                                               tokenUrl: "https://364380975641-predmaintapp-live.auth.eu-west-1.amazoncognito.com/oauth2/token",
                                               redirectUrl: "stpredmnt://callback/")
}

extension Environment.WebCloudEndpoint {
    static let predmntprod = Environment.WebCloudEndpoint(webUrl: "https://d3aqorzcqycube.cloudfront.net/",
                                                   webLogoutUrl: "https://bowl-domain.auth.eu-central-1.amazoncognito.com/logout?")
}
