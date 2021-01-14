//
//  GCDWebSocketImpl.swift
//  XMPPFramework
//
//  Created by Thierry Yseboodt on 03/10/2019.
//

import Foundation
import Starscream
import CFNetwork

protocol NetworkAddress {
    static var family: Int32 { get }
    static var maxStringLength: Int32 { get }
}
extension in_addr: NetworkAddress {
    static let family = AF_INET
    static let maxStringLength = INET_ADDRSTRLEN
}
extension in6_addr: NetworkAddress {
    static let family = AF_INET6
    static let maxStringLength = INET6_ADDRSTRLEN
}

extension String {
    init<A: NetworkAddress>(address: A) {
        // allocate a temporary buffer large enough to hold the string
        var buf = ContiguousArray<Int8>(repeating: 0, count: Int(A.maxStringLength))
        self = withUnsafePointer(to: address) { rawAddr in
            buf.withUnsafeMutableBufferPointer {
                String(cString: inet_ntop(A.family, rawAddr, $0.baseAddress, UInt32($0.count)))
            }
        }
    }
}

func addressToIP(data: Data) -> String? {
    return data.withUnsafeBytes {
        let family = $0.baseAddress!.assumingMemoryBound(to: sockaddr_storage.self).pointee.ss_family
        // family determines which address type to cast to (IPv4 vs IPv6)
        if family == numericCast(AF_INET) {
            return String(address: $0.baseAddress!.assumingMemoryBound(to: sockaddr_in.self).pointee.sin_addr)
        } else if family == numericCast(AF_INET6) {
            return String(address: $0.baseAddress!.assumingMemoryBound(to: sockaddr_in6.self).pointee.sin6_addr)
        }
         return nil
    }
}


func addressToPort(data: Data) -> UInt16? {
    return data.withUnsafeBytes {
        return UInt16($0.baseAddress!.assumingMemoryBound(to: sockaddr_in.self).pointee.sin_port)
    }
}

@objc public class GCDWebSocketImpl: NSObject, GCDSocketprotocol {

    public var isConnected: Bool {
        return self.webSocket?.isConnected ?? false
    }

    weak public var delegate: GCDSocketprotocolDelegate?

    public var connectedHost: String? {
        return self.webSocket?.currentURL.host
    }

    public var connectedPort: UInt16 {
        return UInt16(self.webSocket?.currentURL.port ?? 0)
    }

    public var connectedUrl: URL? {
        return self.webSocket?.currentURL
    }

    public var isDisconnected: Bool {
        return !self.isConnected
    }

    var webSocket: WebSocket?


    var queue: DispatchQueue = DispatchQueue.main

    let socketQueueLabel = "com.xmpp.my-socket-queue"
    lazy var socketQueue = DispatchQueue(label: socketQueueLabel, attributes: [])
    let socketQueueKey = DispatchSpecificKey<Void>()

    @objc public init(delegate: GCDSocketprotocolDelegate, delegateQueue: DispatchQueue) {
        self.delegate = delegate
        self.queue = delegateQueue
        super.init()

        socketQueue.setSpecific(key: socketQueueKey, value: ())
    }

    public func connect(toHost host: String, onPort port: UInt16, withTimeout timeout: TimeInterval) throws {
        //virgingames-notifications.chat.ppc2.pgt01.gamesysgames.com
        //8443
        let url = URL(string: "wss://\(host):\(port)/ws/")!

        self.webSocket = WebSocket(url: url, protocols: ["xmpp"])
        self.webSocket?.delegate = self
        self.webSocket?.pongDelegate = self
        self.webSocket?.connect()
    }

    public func connect(toHost host: String, onPort port: UInt16) throws {
        try self.connect(toHost: host, onPort: port, withTimeout: 30)
    }

    public func connect(toAddress remoteAddr: Data) throws {
        if let host = addressToIP(data: remoteAddr), let port = addressToPort(data: remoteAddr) {
            try self.connect(toHost: host, onPort: port, withTimeout: 30)
        }
    }

    public func disconnect() {
        self.webSocket?.disconnect()
    }

    public func write(_ data: Data, withTimeout timeout: TimeInterval, tag: Int) {
        self.webSocket?.write(string: String(data: data, encoding: .utf8)!) {
            self.delegate?.socket?(self, didWriteDataWithTag: tag)
            print("[Socket] data written: \(String(data: data, encoding: .utf8)!)")
        }
   }

    public func disconnectAfterWriting() {
         self.webSocket?.disconnect()
    }

    public func readData(withTimeout timeout: TimeInterval, tag: Int) {
        // Not sure if  should queue up read messages until this gets hit ?
    }

    public func setDelegate(_ delegate: GCDSocketprotocolDelegate?, delegateQueue: DispatchQueue?) {
        self.delegate = delegate
    }

    public func startTLS(_ tlsSettings: [String : NSObject]?) {
      //  does not apply to websocket
    }

    public func enableBackgroundingOnSocket() -> Bool {
        return false
    }

    public func perform(_ block: @escaping () -> Void) {
        if (DispatchQueue.getSpecific(key: socketQueueKey) != nil) {
            block()
        } else {
            let _ = socketQueue.sync {
                block
            }
        }
    }
}

extension GCDWebSocketImpl : WebSocketDelegate, WebSocketPongDelegate {
    public func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        if let data = data {
            print("[Socket] pong received: \(String(data: data, encoding: .utf8)!)")
        }

    }

    public func websocketDidConnect(socket: WebSocketClient) {
        self.queue.async {
            self.delegate?.socket?(self, didConnectToHost: self.connectedHost!, port: self.connectedPort)
             print("[Socket] connected")
        }
    }

    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        self.queue.async {
            self.delegate?.socketDidDisconnect?(self, withError: error)
        }
    }

    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        self.queue.async {
            self.delegate?.socket?(self, didRead: text.data(using: .utf8)!, withTag: 0)
            print("[Socket] message received: \(text)")
        }
    }

    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        self.queue.async {
            self.delegate?.socket?(self, didRead: data, withTag: 0)
            print("[Socket] data received: \(String(data: data, encoding: .utf8)!)")
        }
    }
}
