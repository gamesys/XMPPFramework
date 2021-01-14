// 
// Core classes
// 

#pragma clang diagnostic push GAMESYS
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"
#pragma clang diagnostic ignored "-Wundef"
#pragma clang diagnostic ignored "-Wdocumentation-unknown-command"
#import "XMPPJID.h"
#import "XMPPStream.h"
#import "XMPPElement.h"
#import "XMPPIQ.h"
#import "XMPPMessage.h"
#import "XMPPPresence.h"
#import "XMPPModule.h"
#import "GCDSocketprotocol.h"
#import "GCDTCPSocketImpl.h"

// 
// Authentication
// 

#import "XMPPSASLAuthentication.h"
#import "XMPPCustomBinding.h"
#import "XMPPDigestMD5Authentication.h"
#import "XMPPSCRAMSHA1Authentication.h"
#import "XMPPPlainAuthentication.h"
#import "XMPPAnonymousAuthentication.h"
#import "XMPPDeprecatedPlainAuthentication.h"
#import "XMPPDeprecatedDigestAuthentication.h"

// 
// Categories
// 

#import "NSXMLElement+XMPP.h"
#pragma clang diagnostic pop GAMESYS
