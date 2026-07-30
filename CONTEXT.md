# RubbageChat

RubbageChat is a person-to-person messaging context in which the server owns identity, relationships, conversations, and delivery state.

## Language

**User**:
A person registered with RubbageChat and identified by one stable nine-digit account.
_Avoid_: Client, connection, account object

**Account**:
The stable nine-digit login identifier assigned to a User.
_Avoid_: User ID, socket ID

**Session**:
A time-limited authorization granted to one authenticated User on one client device.
_Avoid_: Login connection, online state

**FriendRequest**:
A pending request from one User to establish a Friendship with another User.
_Avoid_: Notification, application

**Friendship**:
A mutual relationship between exactly two Users that permits direct conversation.
_Avoid_: Contact row, crony

**Conversation**:
The ordered message stream shared by two Users.
_Avoid_: Chat window, peer

**Message**:
A persisted item authored by one Conversation member and addressed to the Conversation.
_Avoid_: Packet, socket payload

**Attachment**:
A persisted file description associated with a Message and readable only by Conversation members.
_Avoid_: File task, upload packet

**Delivery**:
The server-owned state describing whether a Message is stored, delivered, or read by a User.
_Avoid_: Online send
