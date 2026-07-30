# Server-owned chat state in MongoDB

RubbageChat will make the server authoritative for users, sessions, friendships, conversations, messages, attachments, and delivery state, persisted in the local MongoDB instance. Client SQLite identity and relationship state is removed because it cannot provide a consistent multi-device or public-server system; clients retain only presentation settings and transient view state.
