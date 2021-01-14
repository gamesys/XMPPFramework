//
//  GCDTCPSocketImpl.m
//  XMPPFramework
//
//  Created by Thierry Yseboodt on 04/06/2020.
//

#import "GCDTCPSocketImpl.h"
#import "XMPP.h"

@interface GCDTCPSocketImpl() <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;

@end

@implementation GCDTCPSocketImpl


- (instancetype)initWithDelegate:(id<GCDSocketprotocolDelegate>)aDelegate delegateQueue:(dispatch_queue_t)dq {
    if ((self = [super init])) {
        _delegate = aDelegate;
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dq];
    }
    return self;
}

- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError **)errPtr {
   return [self.socket connectToHost:host onPort:port error:errPtr];
}

- (void)disconnect {
    [self.socket disconnect];
}

- (void)writeData:(NSData *)data withTimeout:(NSTimeInterval)timeout tag:(long)tag {
    NSLog(@"[TCP Socket]: Writing %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self.socket writeData:data withTimeout:timeout tag:tag];
}

- (void)disconnectAfterWriting {
    [self.socket disconnectAfterWriting];
}

- (void)readDataWithTimeout:(NSTimeInterval)timeout tag:(long)tag {
    [self.socket readDataWithTimeout:timeout tag:tag];
}

- (void)setDelegate:(nullable id<GCDSocketprotocolDelegate>)delegate delegateQueue:(nullable dispatch_queue_t)delegateQueue {
    self.delegate = delegate;
    [self.socket setDelegate:self delegateQueue:delegateQueue];
}

- (void)startTLS:(nullable NSDictionary <NSString*,NSObject*>*)tlsSettings {
    [self.socket startTLS:tlsSettings];
}

- (BOOL)enableBackgroundingOnSocket {
    bool result = false;
    #if TARGET_OS_IPHONE
        result = [self.socket enableBackgroundingOnSocket];
    #endif

    return result;
}

- (void)performBlock:(dispatch_block_t)block {
    [self.socket performBlock:block];
}

- (BOOL)acceptOnPort:(uint16_t)port error:(NSError **)errPtr {
    return [self.socket acceptOnPort:port error:errPtr];
}

- (BOOL)connectToHost:(NSString *)host
               onPort:(uint16_t)port
          withTimeout:(NSTimeInterval)timeout
                error:(NSError **)errPtr {
   return [self.socket connectToHost:host onPort:port withTimeout:timeout error:errPtr];
}
- (BOOL)isIPv4PreferredOverIPv6 {
    return  self.socket.isIPv4PreferredOverIPv6;;
}

-(void)setIPv4PreferredOverIPv6:(BOOL)IPv4PreferredOverIPv6 {
    self.socket.IPv4PreferredOverIPv6 = IPv4PreferredOverIPv6;
}

-(BOOL)isConnected {
    return self.socket.isConnected;
}

-(NSString *)connectedHost {
    return self.socket.connectedHost;
}

-(uint16_t)connectedPort {
    return self.socket.connectedPort;
}

-(NSURL *)connectedUrl {
    return self.socket.connectedUrl;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if ([self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:self didConnectToHost:host port:port];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"[TCP Socket]: Received %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if ([self.delegate respondsToSelector:@selector(socket:didReadData:withTag:)]) {
        [self.delegate socket:self didReadData:data withTag:tag];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if ([self.delegate respondsToSelector:@selector(socket:didWriteDataWithTag:)]) {
        [self.delegate socket:self didWriteDataWithTag:tag];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    if ([self.delegate respondsToSelector:@selector(socketDidDisconnect:withError:)]) {
        [self.delegate socketDidDisconnect:self withError:err];
    }
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock {
    if ([self.delegate respondsToSelector:@selector(socketDidSecure:)]) {
        [self.delegate socketDidSecure:self];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReceiveTrust:(SecTrustRef)trust
completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    if ([self.delegate respondsToSelector:@selector(socket:didReceiveTrust:completionHandler:)]) {
        [self.delegate socket:self didReceiveTrust:trust completionHandler:completionHandler];
    }
}

@end
