import Foundation
import SocketIO

var manager: SocketManager!
var socket: SocketIOClient!

@objc(NativeSocketIO) class NativeSocketIO : CDVPlugin {
    
    // var manager: SocketManager!
    // var socket: SocketIOClient!

    @objc func connect(_ command: CDVInvokedUrlCommand) {
        let options = command.arguments[0] as! NSDictionary
        let url = options["url"] as! String
        //let namespace = options["namespace"] as! String
        let path = options["path"] as! String
        let query = options["query"] as! [String:Any]
        var timeout = Double(0)
        var reconnection = true
        var reconnectionDelay = 0
        var reconnectionDelayMax = 0
        var reconnectionAttempts = 0
        
        if options["timeout"] != nil {
            timeout = options["timeout"] as! Double
        }
        
        if options["reconnection"] != nil {
            reconnection = options["reconnection"] as! Bool
        }

        if options["reconnectionDelay"] != nil {
            reconnectionDelay = options["reconnectionDelay"] as! Int
        }
        
        if options["reconnectionDelayMax"] != nil {
            reconnectionDelayMax = options["reconnectionDelayMax"] as! Int
        }
        
        if options["reconnectionAttempts"] != nil {
            reconnectionAttempts = options["reconnectionAttempts"] as! Int
        }
        
        manager = SocketManager(socketURL: URL(string: url)!, config: [.log(true), .compress, .forceWebsockets(true), .path(path), .connectParams(query), .secure(true), .reconnects(reconnection), .reconnectWait(reconnectionDelay), .reconnectWaitMax(reconnectionDelayMax), .reconnectAttempts(reconnectionAttempts), .secure(true)])
        // manager.parseEngineBinaryData(Data) {
            
        // }
        socket = manager.defaultSocket //.socket(forNamespace: namespace)
        
        self.commandDelegate.run(inBackground: {
            socket.on(clientEvent: .connect) {data, ack in
                print("socket connect \(String(describing: manager.engine?.sid))")
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: manager.engine?.sid)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
            
            socket.on(clientEvent: .error) {data, ack in
                print("socket error \(data)")
            }
            
            socket.on(clientEvent: .statusChange) {data, ack in
                print("socket statusChange \(data)")
            }
            
            socket.on(clientEvent: .websocketUpgrade) {data, ack in
                print("socket websocketUpgrade \(data)")
            }
            
            // socket.onAny() {event in
            //    print("socket onAny \(event)")
            // }
            
            socket.connect(timeoutAfter: timeout, withHandler: nil)
        })
    }

    @objc func on(_ command: CDVInvokedUrlCommand) {
        let options = command.arguments[0] as! NSDictionary
        let event = options["event"] as! String

        socket.on(event) {(data, ack) in
            // print("on event \(event) \(data)")
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: data)
            pluginResult?.setKeepCallbackAs(true)
            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc func emit(_ command: CDVInvokedUrlCommand) {
        let options = command.arguments[0] as! NSDictionary
        let event = options["event"] as! String
        var params = [] as SocketData
        
        if options["params"] != nil {
            params = options["params"] as! SocketData
        }
        
        self.commandDelegate.run(inBackground: {
            socket.emit(event, params) {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
        })
    }
    
    @objc func disconnect(_ command: CDVInvokedUrlCommand) {
        socket.disconnect()
    }
    
    @objc func removeAllListeners(_ command: CDVInvokedUrlCommand) {
        socket.removeAllHandlers()
    }
}
