//
//  GCDTCPSocketImpl.h
//  XMPPFramework
//
//  Created by Thierry Yseboodt on 04/06/2020.
//

#import <Foundation/Foundation.h>
#import "GCDSocketprotocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GCDTCPSocketImpl : NSObject <GCDSocketprotocol>

- (instancetype)initWithDelegate:(id<GCDSocketprotocolDelegate>)aDelegate delegateQueue:(dispatch_queue_t)dq;

- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError **)errPtr;

- (void)disconnect;

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)disconnectAfterWriting;

- (BOOL)connectToAddress:(NSData *)remoteAddr error:(NSError **)errPtr;

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag;

- (void)setDelegate:(nullable id<GCDSocketprotocolDelegate>)delegate delegateQueue:(nullable dispatch_queue_t)delegateQueue;

- (void)startTLS:(nullable NSDictionary <NSString*,NSObject*>*)tlsSettings;

- (BOOL)enableBackgroundingOnSocket;

- (void)performBlock:(dispatch_block_t)block;

@property (atomic, assign, readwrite, getter=isIPv4PreferredOverIPv6) BOOL IPv4PreferredOverIPv6;

@property (atomic, readonly) BOOL isConnected;

@property (atomic, weak, readwrite, nullable) id<GCDSocketprotocolDelegate> delegate;

@property (atomic, readonly, nullable) NSString *connectedHost;
@property (atomic, readonly) uint16_t  connectedPort;
@property (atomic, readonly, nullable) NSURL    *connectedUrl;

@property (atomic, readonly) BOOL isDisconnected;

- (BOOL)connectToHost:(NSString *)host
     onPort:(uint16_t)port
withTimeout:(NSTimeInterval)timeout
      error:(NSError **)errPtr;

@end

NS_ASSUME_NONNULL_END
