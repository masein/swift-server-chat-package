import Vapor

var env = try Environment.detect()
let app = Application(env)

defer {
    app.shutdown()
}
var clientsSet = Set<Client>()
var clientsArray: [Client] = []
var currentClient: Client!

app.webSocket("chat") { req, client in
    // since our hash function is on connection, username is not important
    currentClient = Client(username: "Kossher", connection: client)
    
    client.onClose.whenComplete { _ in
        clientsSet.remove(currentClient)
    }
    
    client.onText { _, text in
        do {
            guard let data = text.data(using: .utf8) else {
                return
            }
            let incomingMessage = try JSONDecoder().decode(SubmittedChatMessage.self, from: data)
            let outgoingMessage = ReceivingChatMessage(message: incomingMessage.message,
                                                       sender: incomingMessage.sender,
                                                       senderID: incomingMessage.senderID,
                                                       receiver: incomingMessage.receiver)
            currentClient = Client(username: incomingMessage.sender,
                                   connection: currentClient.connection)
            clientsSet.insert(currentClient)
            let json = try JSONEncoder().encode(outgoingMessage)
            guard let jsonString = String(data: json, encoding: .utf8) else {
                return
            }
            print("Incomming message: \(incomingMessage)")
            print("Outgoing message: \(outgoingMessage)")
            for client in clientsSet {
                if client.username == incomingMessage.sender ||
                    client.username == incomingMessage.receiver {
                    print("Client Username: \(String(describing: client.username))")
                    client.connection.send(jsonString)
                }
            }
        }
        catch {
            print(error)
        }
    }
}

try app.run()

extension WebSocket: Hashable {
    public static func == (lhs: WebSocket, rhs: WebSocket) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
