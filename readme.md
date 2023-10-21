# Henny

Modern and efficient Swift wrapper for the official Hacker News API.
Henny uses Firebase Realtime Database to fetch data from the official Hacker News API which has proven to be faster than querying the official API directly.

## Features

- Fast and efficient data fetching using Firebase RTDB, `async/await`, `URLSession`, and `Codable`.
- Advanced data loading strategies like `AsyncStream<Element>`.
- Metadata retrieval for links using Link Presentation cached using LRU on disk.
- Built-in caching for offline usage.
- Paginate data with `limit` and `offset` parameters.
- Comprehensive data types with additional computed properties.
- Recursive data fetching for comments.
- Support for authenticated requests to post, vote, and retrieve user settings.
- Includes a testing suite for common use cases.

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
