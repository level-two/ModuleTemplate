# Gateways

This folder contains Gateway protocols. These protocols abstract the data access layer from the business logic, making testing and data source changes easier without affecting the business logic.

Repositories typically implement these protocols. They fetch data from the data source and map it to business models.

Repository protocols should only use Business Models, not data models.

Use async-await for asynchronous one-shot methods. For operations that can fail, throw an error instead of returning a Result type.

Use AsyncSequence for one-shot actions that produce multiple values or provide an intermediate state.

Use Combine for persistent data streams.
