
import Foundation
import SFMCSDK
import Cdp
import Personalization

final class SalesforceHelpers {
    private init() {}
    
    /* Enforce DC Module to send events by adding 20 dummy events to the queue */
    static func ForceEventsToBeSent(){
        for _ in 0...21 {
            SFMCSdk.track(event: CustomEvent(
                name: "dummy",
                attributes: [
                    "interactionName": "dummy",
                ]
            )!)
        }
    }
    
    static func ResetProfileAttributes(){
        SFMCSdk.identity.edit { identityModifier in
            identityModifier.clearAllAttributes()
            return identityModifier
        }
        
        SFMCSdk.cdp.setConsent(consent: .optOut)
        SFMCSdk.cdp.setConsent(consent: .optIn)
        
        ForceEventsToBeSent()
    }
    
    static func SendContactPointEmailEvent(emailAddress: String, firstName: String) {
        SFMCSdk.cdp.setConsent(consent: Consent.optIn)
        
        SFMCSdk.identity.edit { identityModifier in

            identityModifier.addAttributes(attributes: [
                "email": emailAddress,
                "firstName": firstName,
                "lastName": "",
                "isAnonymous": "0"
            ])
            return identityModifier
        }
        
        ForceEventsToBeSent()
    }
    
    static func SendCustomEngagementEvent(eventType: String, interactionName: String = "engagement", item: Item? = nil, itemType: String = "", personalizationId: String = "", personalizationContentId: String = ""){
        SFMCSdk.track(event: CustomEvent(
            name: eventType,
            attributes: [
                "interactionName": interactionName,
                "personalizationId": personalizationId,
                "personalizationContentId": personalizationContentId,
                "id": item?.id ?? "",
                "type": itemType
            ]
        )!)
        
        ForceEventsToBeSent()
    }
}
