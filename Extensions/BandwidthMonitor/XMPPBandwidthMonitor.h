/**
 * Simple XMPP module that tracks average bandwidth of the xmpp stream.
 * 
 * For now, this is a really simple module.
 * But perhaps in the future, as developers adapt this module,
 * they will open source their additions and improvements.
**/

#import <Foundation/Foundation.h>

#pragma clang diagnostic push GAMESYS
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
#pragma clang diagnostic ignored "-Wdocumentation"
#pragma clang diagnostic ignored "-Woverriding-method-mismatch"
#pragma clang diagnostic ignored "-Wundef"
#pragma clang diagnostic ignored "-Wdocumentation-unknown-command"
#import "XMPP.h"
#pragma clang diagnostic pop GAMESYS

#define _XMPP_BANDWIDTH_MONITOR_H

@interface XMPPBandwidthMonitor : XMPPModule

@property (readonly) double outgoingBandwidth;
@property (readonly) double incomingBandwidth;

@end
