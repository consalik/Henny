# Henny

Modern and efficient Swift wrapper for the official Hacker News API.
Henny uses Firebase Realtime Database to fetch data from the official Hacker News API which has proven to be faster than querying the official API directly.

## Features

- **Firebase**: Fast and efficient querying of the official Hacker News API using Firebase Realtime Database with support for persistence. The API includes comprehensive data types for all endpoints.
- **Streaming**: Improve loading times and responsiveness by streaming items with `AsyncStream<Element>`.
- **Metadata**: Retrieve metadata for items including images and summaries of websites using the Link Presentations framework.
- **Caching**: Built-in caching for metadata and items including support for persistence.
- **Pagination**: Paginate data with `limit` and `offset` parameters.
- **Comments**: Recursively fetch comments for items.
- **Authentication**: Sign in to your Hacker News account to vote, comment, and submit.
- **Search**: Search for items on Hacker News using Algolia.
- **Testing**: Includes a testing suite for common use cases.

## Usage

Henny is changing rapidly and is not yet ready for production use.
But if you want to try it out, you can install it using Swift Package Manager:

```swift
.package(url: "https://github.com/consalik/Henny.git", branch: "master")
```

## Roadmap

- [x] Add support for including metadata in requests or fetching in parallel. Including images and summaries of websites.
- [ ] Improve performance of initial metadata retrieval.
- [ ] Add more authentication requests.
- [ ] Add in-memory caching for metadata for faster access.
- [ ] Add way to order streamed items.

## License

MIT
