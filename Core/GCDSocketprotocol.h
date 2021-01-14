//
//  GCDSocketprotocol.h
//  XMPPFramework
//
//  Created by Thierry Yseboodt on 02/06/2020.
//

#ifndef GCDSocketprotocol_h
#define GCDSocketprotocol_h

#import <Foundation/Foundation.h>
@protocol GCDSocketprotocolDelegate;

#pragma clang diagnostic push GAMESYS
#pragma clang diagnostic ignored "-Wnullability-completeness"

@protocol GCDSocketprotocol <NSObject>

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


@protocol GCDSocketprotocolDelegate <NSObject>
@optional

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
**/
- (void)socket:(NSObject<GCDSocketprotocol> *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
**/
- (void)socket:(NSObject<GCDSocketprotocol> *)sock didReadData:(NSData *)data withTag:(long)tag;

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
**/
- (void)socket:(NSObject<GCDSocketprotocol> *)sock didWriteDataWithTag:(long)tag;

/**
 * Called when a socket disconnects with or without error.
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * then an invocation of this delegate method will be enqueued on the delegateQueue
 * before the disconnect method returns.
 *
 * Note: If the GCDAsyncSocket instance is deallocated while it is still connected,
 * and the delegate is not also deallocated, then this method will be invoked,
 * but the sock parameter will be nil. (It must necessarily be nil since it is no longer available.)
 * This is a generally rare, but is possible if one writes code like this:
 *
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * In this case it may preferrable to nil the delegate beforehand, like this:
 *
 * asyncSocket.delegate = nil; // Don't invoke my delegate method
 * asyncSocket = nil; // I'm implicitly disconnecting the socket
 *
 * Of course, this depends on how your state machine is configured.
**/
- (void)socketDidDisconnect:(NSObject<GCDSocketprotocol> *)sock withError:(nullable NSError *)err;

/**
 * Called after the socket has successfully completed SSL/TLS negotiation.
 * This method is not called unless you use the provided startTLS method.
 *
 * If a SSL/TLS negotiation fails (invalid certificate, etc) then the socket will immediately close,
 * and the socketDidDisconnect:withError: delegate method will be called with the specific SSL error code.
**/
- (void)socketDidSecure:(NSObject<GCDSocketprotocol> *)sock;

/**
 * Allows a socket delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if startTLS is invoked with options that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * Thus this method uses a completionHandler block rather than a normal return value.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
**/
- (void)socket:(NSObject<GCDSocketprotocol> *)sock didReceiveTrust:(SecTrustRef)trust
                                    completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler;

@end


#endif /* GCDSocketprotocol_h */

#pragma clang diagnostic pop GAMESYS
