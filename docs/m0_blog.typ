// ---------------------------------------------------------------------------
// MiniKV · M0 technical note
// Style is duplicated from docs/05-clean-blog.typ so this file stays a single
// self-contained document; the fonts, page geometry and visual language match
// the editorial template exactly.
// ---------------------------------------------------------------------------

#set page(
  paper: "a4",
  margin: (x: 2.3cm, top: 2.2cm, bottom: 2.2cm),
  header: context {
    if here().page() > 1 [
      #set text(size: 8pt, font: ("Helvetica", "Arial"), fill: rgb("#94a3b8"))
      #grid(
        columns: (1fr, auto),
        [MiniKV · M0 Technical Note],
        [Gang Liu],
      )
      #v(-3pt)
      #line(length: 100%, stroke: 0.4pt + rgb("#f1f5f9"))
    ]
  },
  footer: context {
    set text(size: 8pt, font: ("Helvetica", "Arial"), fill: rgb("#94a3b8"))
    align(center)[#here().page()]
  }
)

#set text(
  font: ("New Computer Modern", "Times New Roman"),
  size: 10pt,
  fill: rgb("#334155"),
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.76em,
)

// Headings in clean modern sans-serif. `sticky` keeps a heading with the block
// that follows it, so a section title never ends a page on its own.
#show heading.where(level: 1): it => block(sticky: true)[
  #v(14pt)
  #text(font: ("Helvetica", "Arial"), size: 13.5pt, weight: "bold", fill: rgb("#0f172a"))[#it.body]
  #v(3pt)
]
#show heading.where(level: 2): it => block(sticky: true)[
  #v(11pt)
  #text(font: ("Helvetica", "Arial"), size: 11pt, weight: "bold", fill: rgb("#1e293b"))[#it.body]
  #v(2.5pt)
]
#show heading.where(level: 3): it => block(sticky: true)[
  #v(10pt)
  #text(font: ("Helvetica", "Arial"), size: 10pt, weight: "bold", fill: rgb("#475569"))[#it.body]
  #v(2pt)
]

// Code block: clean editorial style (soft charcoal + violet tab). Non-breakable,
// so a snippet is never split across two pages.
#show raw.where(block: true): it => block(
  width: 100%,
  breakable: false,
  fill: rgb("#18181b"),
  radius: 5pt,
  inset: (top: 0pt, bottom: 9pt, left: 12pt, right: 12pt),
  stroke: 0.5pt + rgb("#27272a"),
  [
    #block(
      width: 100%,
      inset: (y: 5pt),
      stroke: (bottom: 0.5pt + rgb("#27272a")),
      [
        #grid(
          columns: (1fr, auto),
          align: (horizon, horizon),
          [
            #text(size: 7.5pt, font: ("Helvetica", "Arial"), fill: rgb("#a78bfa"), weight: "bold")[
              #if it.has("lang") [#upper(it.lang)] else [SNIPPET]
            ]
          ],
          [
            #text(size: 7pt, font: ("Courier", "Courier New"), fill: rgb("#71717a"))[copy]
          ]
        )
      ]
    )
    #v(3pt)
    #set text(font: ("Courier", "Courier New"), size: 8.5pt, fill: rgb("#f4f4f5"))
    #it
  ]
)

// Inline code: soft violet/lavender badge
#show raw.where(block: false): it => box(
  fill: rgb("#f5f3ff"),
  inset: (x: 4pt, y: 1.5pt),
  radius: 3pt,
  stroke: 0.4pt + rgb("#ddd6fe"),
  [
    #set text(fill: rgb("#6d28d9"), font: ("Courier", "Courier New"), size: 8.5pt, weight: "medium")
    #it
  ]
)

// Blockquote / key takeaway box
#let takeaway(title: "Key Takeaway", body) = block(
  width: 100%,
  fill: rgb("#faf5ff"),
  radius: 6pt,
  inset: (x: 12pt, y: 10pt),
  stroke: (left: 3.5pt + rgb("#7c3aed")),
  [
    #text(font: ("Helvetica", "Arial"), weight: "bold", size: 9pt, fill: rgb("#5b21b6"))[#title] \
    #v(2pt)
    #set text(size: 9pt, fill: rgb("#4c1d95"))
    #body
  ]
)

// Editorial note box
#let note(title: "Observation", body) = block(
  width: 100%,
  fill: rgb("#f8fafc"),
  radius: 6pt,
  inset: (x: 12pt, y: 9pt),
  stroke: (left: 3.5pt + rgb("#64748b")),
  [
    #text(font: ("Helvetica", "Arial"), weight: "bold", size: 9pt, fill: rgb("#334155"))[#title] \
    #v(2pt)
    #set text(size: 8.8pt, fill: rgb("#475569"))
    #body
  ]
)

// ---------------------------------------------------------------------------
// Document-specific components
// ---------------------------------------------------------------------------

// Small syscall-path card used by the mechanism diagram.
#let stage(title, body, active: false) = block(
  width: 100%,
  fill: if active { rgb("#faf5ff") } else { rgb("#f8fafc") },
  radius: 5pt,
  inset: (x: 9pt, y: 7pt),
  stroke: 0.5pt + (if active { rgb("#ddd6fe") } else { rgb("#e2e8f0") }),
  [
    #text(
      font: ("Helvetica", "Arial"),
      size: 7.2pt,
      weight: "bold",
      fill: if active { rgb("#7c3aed") } else { rgb("#94a3b8") },
    )[#upper(title)]
    #v(2.5pt)
    #set text(size: 7.8pt, fill: rgb("#475569"))
    #body
  ],
)

// One interview question with its grounded answer.
#let probe(question, body) = block(
  width: 100%,
  inset: (x: 0pt, y: 4pt),
  [
    #text(
      font: ("Helvetica", "Arial"),
      weight: "bold",
      size: 9.2pt,
      fill: rgb("#0f172a"),
    )[#question]
    #v(2pt)
    #set text(size: 9.4pt, fill: rgb("#334155"))
    #body
  ],
)

// Booktabs-style horizontal rules shared by every table in this note.
#let book-stroke(last-row) = (x, y) => if y == 0 {
  (top: 1.2pt + rgb("#0f172a"), bottom: 1.2pt + rgb("#0f172a"))
} else if y == last-row {
  (bottom: 1.2pt + rgb("#0f172a"))
} else {
  (bottom: 0.5pt + rgb("#f1f5f9"))
}

// ---------------------------------------------------------------------------
// Title block
// ---------------------------------------------------------------------------

#box(
  fill: rgb("#f5f3ff"),
  inset: (x: 8pt, y: 3pt),
  radius: 12pt,
  stroke: 0.5pt + rgb("#ddd6fe"),
  [#text(size: 8pt, weight: "bold", font: ("Helvetica", "Arial"), fill: rgb("#7c3aed"))[MINIKV · M0 · TECHNICAL NOTE]]
)

#v(8pt)
#text(size: 21pt, weight: "bold", font: ("Helvetica", "Arial"), fill: rgb("#0f172a"))[
  Constructing a TCP Echo Server
]

#v(4pt)
#text(size: 10.5pt, font: ("Helvetica", "Arial"), fill: rgb("#64748b"))[
  A very simple TCP echo server as the beginning of MiniKV project, named M0.
]

#v(10pt)
#grid(
  columns: (auto, 1fr),
  gutter: 10pt,
  align: horizon,
  [
    #box(
      width: 28pt,
      height: 28pt,
      radius: 14pt,
      fill: rgb("#7c3aed"),
      align(center + horizon)[#text(fill: white, weight: "bold", font: ("Helvetica", "Arial"), size: 10pt)[GL]]
    )
  ],
  [
    #text(size: 9pt, weight: "bold", font: ("Helvetica", "Arial"), fill: rgb("#0f172a"))[Gang Liu (Silvan)] \
    #text(size: 7.5pt, font: ("Helvetica", "Arial"), fill: rgb("#94a3b8"))[
      Published: Oct 2026 · 20 min read
    ]
  ]
)

#v(6pt)
#line(length: 100%, stroke: 0.5pt + rgb("#f1f5f9"))
#v(8pt)

// ---------------------------------------------------------------------------
// 1. Problem and Hypothesis
// ---------------------------------------------------------------------------

= 1. Problem and Hypothesis

MiniKV begins with a deliberately boring program: a TCP echo server that sends every received byte back unchanged. Nothing is stored and no protocol is parsed, yet the program exercises the whole lifecycle that every later version inherits. It resolves a local address, creates a socket, makes it reusable, binds, listens, accepts, serves one connection, and releases every descriptor exactly once. M0 exists so that the next milestone (M1) key/value service can be written over a network layer whose failure modes are already understood.

The build under test makes two claims, and this note tests only those claims:

+ *Fork isolation.* If the parent closes its copy of the connection descriptor immediately after `fork()`, each connection's blocking `recv()` is confined to a child process, so an idle client cannot stop the accept loop from serving another client.
+ *Stream copy.* If every chunk returned by `recv()` is written back with a write-all loop, TCP segmentation does not corrupt the echo: the received byte sequence equals the sent byte sequence no matter how the bytes were split.

Everything else here is context. The note reports no throughput and no latency; the single wall-clock figure in §4 is one observation from one interactive run, not a measurement of the server's performance. The program has no framing, no timeout, no persistence and no test harness yet. It is a learning milestone that the next version reuses, not a service.

#note(title: "Scope and evidence locator")[
  #grid(
    columns: (auto, 1fr),
    gutter: (10pt, 3.5pt),
    [Version], [M0 echo server, working tree on top of commit `0d0962a`. Both M0 sources were untracked at run time, so the file digests below are the binding identity.],
    [Environment], [Ubuntu 26.04.1 LTS · Linux 7.0.0-38-generic x86_64 · AMD Ryzen 7 9700X (16 logical CPUs) · g++ 15.2.0 · CMake 4.2.3 · Ninja 1.13.2. Run date: 2026-10-29, loopback only.],
    [Sources], [
      #text(font: ("Courier", "Courier New"), size: 7.4pt)[
        `src/echo_server.cc`: 13bc9694d27ee95562f59f9dba4d6bb009c00d68e5af4de52af97dca35a1bc72 \
        `src/echo_client.cc`: dd196112c3cb45f4ebe8ef7cedbd07b0d1c4b620022a71f82c32a1d1c1061f1a \
        `CMakeLists.txt`: 74b947120d25117f8daf9127de1f5c7613c00c12e22594f77a235ead58722756
      ]
    ],
    [Evidence], [Command output quoted in §3 and §4 was captured from that session and is reproduced verbatim. The session transcript is not stored as a separate artifact: this revision has no `artifacts/runs` directory yet.],
    [Missing], [No throughput, latency distribution, CPU, RSS or fd time series; no automated tests or sanitizer run; no backlog-pressure or error-injection experiment. §5 states the limits this leaves.],
  )
]

// ---------------------------------------------------------------------------
// 2. Mechanism and Boundaries
// ---------------------------------------------------------------------------

= 2. Mechanism and Boundaries

== 2.1 TCP is a byte stream, not a message pipe

`send()` hands bytes to the kernel and reports how many it accepted; `recv()` returns whatever has arrived by the time it runs. Neither call preserves the writer's call boundaries. On loopback this is easy to observe: 240 bytes written by two separate `send()` calls came back as a single `recv()` chunk in §4. The server therefore never treats one `recv()` as one message. It echoes each chunk and relies on the byte sequence, not on framing. An echo service needs no framing because the transformation is the identity.

Formally, if the client stream $S$ arrives as chunks $s_1, s_2, dots.c, s_m$ with $1 <= |s_i| <= 100$ bytes each, the server's contract is:

$ "echo"(S) = S, quad |S| = sum_(i=1)^m |s_i| $

The bound of 100 bytes is `kChunkSize`, the size of the stack buffer in the child. It is a property of this implementation, not of TCP: the kernel may hand `recv()` any positive number of bytes up to the buffer size, and a different buffer size moves the chunk boundaries without changing the echoed stream.

== 2.2 The syscall path, and where the state lives

The server's `main()` performs six steps. Only the first four run once; the last two run once per accepted connection.

#grid(
  columns: (1fr, auto, 1fr),
  gutter: (8pt, 6pt),
  align: horizon,
  stage("1 · resolve", [
    `getaddrinfo(nullptr, "2026", hints)` with `AI_PASSIVE` returns wildcard candidates suitable for `bind()`, for IPv6, IPv4, or both.
  ]),
  align(center)[#text(fill: rgb("#94a3b8"), size: 12pt)[→]],
  stage("2 · bind", [
    For each candidate: `socket()` → `setsockopt(SO_REUSEADDR)` → `bind()`; a failed `bind()` or `listen()` closes its fd and tries the next candidate.
  ]),
  stage("3 · listen", [
    The socket becomes passive. Completed handshakes wait in the kernel accept queue; `kBacklog = 10` is advisory and may be rounded by the kernel.
  ]),
  align(center)[#text(fill: rgb("#94a3b8"), size: 12pt)[→]],
  stage("4 · accept", [
    The parent blocks here. One successful `accept()` returns a new fd bound to exactly one established connection.
  ], active: true),
  stage("5 · fork + echo", [
    The child owns `conn_fd` and loops on `recv()` → `send_all()`; the parent closes its copy and returns to `accept()`.
  ]),
  align(center)[#text(fill: rgb("#94a3b8"), size: 12pt)[→]],
  stage("6 · close", [
    `recv()` returns 0 on orderly shutdown; the child closes `conn_fd` and calls `exit(0)`. A `SIGCHLD` handler reaps it.
  ], active: true),
)

#v(3pt)
#text(size: 8.4pt, fill: rgb("#64748b"))[
  The diagram reflects this build's process and descriptor ownership. It is an implementation map, not performance evidence. Peer addresses are logged with `inet_ntop()` before the fork; `std::cout` is flushed first so the child does not repeat the parent's buffered text on exit.
]

Two details of the loop matter for later versions. First, `accept()` is blocking, so the parent sets `SA_RESTART` on its `SIGCHLD` handler; without it, a child exiting mid-wait would interrupt `accept()` with `EINTR`. The loop also retries `EINTR`, so this is a wake-up cost rather than a correctness requirement. Second, a failed `accept()` is logged and the loop continues: one transient error must not end the server.

== 2.3 Who owns each descriptor

A file descriptor is owned per process, and `fork()` duplicates the descriptor table. Every copy must be closed by the process that holds it, or by process exit.

#align(center)[
  #block(breakable: false)[
  #table(
    columns: (1.0fr, 1.0fr, 2.9fr),
    inset: 7pt,
    stroke: book-stroke(5),
    align: (left, left, left),
    table.header(
      [*Owner*], [*Descriptor*], [*Released when*]
    ),
    [Parent, startup], [`listen_fd`], [Stays open for the process lifetime; closed explicitly on every error path before `main` returns.],
    [Parent, post-fork], [`conn_fd` copy], [Immediately after `fork()` returns. The parent keeps only the listener, so the accept loop is never pinned by a client.],
    [Child], [`listen_fd` copy], [First statement in the child. The child never calls `accept()`, so it must not keep a second reference to the listening socket.],
    [Child], [`conn_fd`], [Before `exit(0)`, after the echo loop ends on `recv() == 0` or an I/O error.],
    [Any candidate], [fd from a failed `socket()` / `bind()` / `listen()`], [Closed before the next candidate. Otherwise every retry leaks one descriptor until `EMFILE`.],
  )
  ]
]

The child's exit path is `std::exit(0)`, not a `return`: falling back into `main` would let the child call `accept()` on a socket it does not own. The parent's buffered output is flushed before `fork()` for the same reason in reverse: both processes would otherwise flush the same pending text, and the log line announcing a connection would appear twice.

#takeaway(title: "Where the boundary sits")[
  The kernel owns queues and socket buffers; the process owns descriptors. An echo server owns neither message boundaries nor delivery schedules, only the obligation to write back every byte it read, completely, and to close each descriptor copy exactly once.
]

// ---------------------------------------------------------------------------
// 3. Minimal Reproduction and Controls
// ---------------------------------------------------------------------------

= 3. Minimal Reproduction and Controls

== 3.1 Build, start, and drive

The reproduction needs no test framework: build two executables, start one, drive the other. The port is checked first so a stale listener cannot be mistaken for this build.

```bash
# from the repository root
cmake -S . -B build -G Ninja
cmake --build build
ss -tuln | grep :2026     # expected: no output, port free
```

```bash
# terminal A
./build/echo_server
# server: listening on port 2026, press Ctrl-C to stop

# terminal B
./build/echo_client localhost
# Please enter message: hello
# client: received 'hello'
```

The current `CMakeLists.txt` sets C++20 and no warning flags, so this note makes no claim about a warning-clean build. Both binaries are built from `src/echo_server.cc` and `src/echo_client.cc`; nothing else links into them.

== 3.2 Controls that separate the two claims

Each probe changes one factor and enough of the setup is fixed that a success or a timeout can be attributed. The fork-isolation claim needs a control that would behave differently under a serial server, not merely one that shows two clients can connect.

#align(center)[
  #block(breakable: false)[
  #table(
    columns: (1.15fr, 1.8fr, 2.15fr),
    inset: 7pt,
    stroke: book-stroke(7),
    align: (left, left, left),
    table.header(
      [*Factor*], [*Probe*], [*What it distinguishes*]
    ),
    [Fixed invariants], [Port `2026`, `kBacklog = 10`, `kChunkSize = 100`, `AF_UNSPEC`, one listener], [Every run shares the same build and constants, so differences come from the probe, not the configuration.],
    [Chunk crossing], [Provided client, 250-byte line], [Forces at least three server chunks; a single-chunk echo design would still pass a 5-byte message but fail here.],
    [Write segmentation], [Probe script: 2 × 120 B writes, 50 ms apart, then `shutdown(SHUT_WR)`], [Tests aggregation and EOF handling; the echo must be the 240 bytes, not two 120-byte replies.],
    [Idle-client isolation], [Client A connects, then waits 2 s before sending; client B sends immediately], [A serial accept-then-serve loop would leave B waiting about 2 s; fork-per-connection lets B finish while A idles.],
    [Child count], [`ps --ppid <server>` while A and C are both connected], [One child per accepted connection is the visible form of the fork model; children must also disappear after close.],
    [Signal stop], [SIGINT to the server, as Ctrl-C does], [No SIGINT handler is installed, so the default disposition must end the process and release the port.],
    [Server absent], [Provided client with no listener], [Exercises the `ECONNREFUSED` path and the documented exit code.],
  )
  ]
]

Not varied in this round: backlog pressure, slow readers that block the child's `send()`, IPv6-only targets, connection counts beyond two, and injected failures such as `EADDRINUSE` or `fork()` returning `-1`. Those remain open for §5.

== 3.3 The two code paths that carry the claims

Address resolution is the only part that depends on the host's address families. `AI_PASSIVE` plus a null node asks for wildcard addresses; the candidate loop makes the program work whether the machine offers IPv6, IPv4, or both.

```cpp
addrinfo hints{};
hints.ai_family   = AF_UNSPEC;     // allow either IPv4 or IPv6
hints.ai_socktype = SOCK_STREAM;   // TCP: ordered, reliable byte stream
hints.ai_flags    = AI_PASSIVE;    // produce wildcard addresses for bind()
// (result-status check and the RAII wrapper for the list are omitted here)
getaddrinfo(nullptr, kPort.data(), &hints, &raw);
```

The ownership handoff is short, but every line is load-bearing. The excerpt below is from `src/echo_server.cc` (§4 of `logs/m0_log.md` walks the same block); the peer address and length arguments are elided.

```cpp
// peer address and length arguments elided below
const int conn_fd = ::accept(listen_fd, /* peer address */ ...);
const pid_t pid = ::fork();
if (pid == 0) {
  ::close(listen_fd);            // the child never accepts
  // recv -> send_all loop until recv() returns 0
  ::close(conn_fd);
  std::exit(0);                  // end this forked copy, not just a block
}
::close(conn_fd);                // parent keeps only the listener
```

The child's echo loop is the stream-copy claim: every positive `recv()` result is written back completely, and only `0` or an error ends the loop.

```cpp
while (true) {
  const ssize_t n = ::recv(conn_fd, buffer.data(), buffer.size(), 0);
  if (n == -1) {
    if (errno == EINTR) continue;  // interrupted by a signal; retry
    std::perror("server: recv");
    break;
  }
  if (n == 0) break;               // client shut down its write side
  if (!send_all(conn_fd, buffer.data(), static_cast<std::size_t>(n))) break;
}
```

`send_all()` loops until the requested length has been written, retries `EINTR`, and passes `MSG_NOSIGNAL` so that a peer that has already closed turns into an `EPIPE` error return instead of a fatal `SIGPIPE`. The client mirrors this: it reads until it has received exactly as many bytes as it sent, because TCP may deliver the echo across several segments.

// ---------------------------------------------------------------------------
// 4. Actual Results
// ---------------------------------------------------------------------------

= 4. Actual Results

The observations below were captured in one interactive session on the environment listed in §1. They are functional checks, not a benchmark; every output line is copied from that run.

#align(center)[
  #block(breakable: false)[
  #table(
    columns: (1.2fr, 1.75fr, 2.15fr),
    inset: 7pt,
    stroke: book-stroke(8),
    align: (left, left, left),
    table.header(
      [*Check*], [*Probe*], [*Observed*]
    ),
    [Short echo], [Provided client, line `hello`], [Client printed `received 'hello'`, exit 0.],
    [Chunk crossing], [Provided client, 250-byte line], [250 bytes returned; byte-identical to the input, exit 0.],
    [Split writes + half-close], [Probe: 2 × 120 B writes, 50 ms apart, `shutdown(SHUT_WR)`], [240 bytes echoed and read in one `recv()`; byte-identical.],
    [Idle-client isolation], [A holds its connection 2 s; B sends immediately], [B finished in 5 ms wall clock (one sample, client process start included); both exit 0.],
    [Listener shape], [`ss -tlnp` after start], [`LISTEN 0 10 0.0.0.0:2026`, exactly one socket, listener fd 3.],
    [Child count], [`ps --ppid` while A and C are connected], [Two child processes; after both close, none remain and no `Z` state appeared.],
    [Signal stop], [SIGINT, as Ctrl-C], [Server exited with status 130; port 2026 released.],
    [Server absent], [Provided client, no listener], [`client: connect: Connection refused`; `could not connect to localhost`; exit 2.],
  )
  ]
]

== 4.1 Reading the observations

The fork-isolation claim is supported in the narrow sense the probe was designed for. While client A's child was blocked in `recv()`, client B connected and received its echo in 5 ms; a serial server would have held B until A's connection ended about two seconds later. The child count confirms the mechanism: one child per connection while both clients were connected, and none left after they closed. The absence of `Z` states is evidence for the `SIGCHLD` reaping loop, not proof that no zombie can ever appear; a child could in principle exit between samples.

The stream-copy claim is supported by the two segmentation probes. The 250-byte line crossed the 100-byte chunk buffer and came back identical. The 240 bytes written in two calls with a pause came back as one 240-byte stream, which is exactly the non-correspondence §2.1 predicts; the client's read-exact-count loop, not a message boundary, is what makes the exchange terminate correctly.

The descriptor table in §2.3 is consistent with what the process showed: the parent held descriptors 0, 1, 2 and 3 (the listener), and no accepted connection descriptor accumulated in it. The child-per-connection count and the clean `SIGINT` exit both point at the same design: the listener is the only long-lived socket.

#note(title: "How to read the 5 ms")[
  The 5 ms figure measures the wall-clock duration of the whole client command, including process start and the shell pipeline. It is one sample on loopback, taken while another connection was open. It shows that B was not waiting for A; it says nothing about throughput, server latency, CPU cost, or behaviour with many connections.
]

Two artifacts of the capture are worth naming so they are not mistaken for bugs. In the captured stream the client's `attempting connection` line can appear after `connect: Connection refused`, because stdout was redirected to a file (block-buffered) while `perror` writes unbuffered to stderr; the program's own order is unchanged. And the server log contains exactly one `connection from 127.0.0.1` line per accepted connection, which is the flushed-before-`fork()` behaviour described in §2.2.

// ---------------------------------------------------------------------------
// 5. Conclusions, Limits, and the Next Experiment
// ---------------------------------------------------------------------------

= 5. Conclusions, Limits, and the Next Experiment

== 5.1 What the evidence supports

- *C1 — Blocking is confined to the child.* The idle-client probe, the two-child observation and the immediate parent-side `close()` together support the claim that a slow or idle peer cannot stall the accept loop.
- *C2 — Echo survives segmentation.* A 250-byte line and 240 bytes in two writes both round-tripped byte-identically; the split-write probe also showed that `recv()` chunk boundaries do not mirror `send()` boundaries.
- *C3 — Descriptor ownership is explicit.* Each duplicate is closed exactly once, the parent retains only the listener, and the child exits through `exit(0)` after closing its connection.
- *C4 — Lifecycle behaves as documented.* SIGINT ends the process with status 130 and frees the port; with no listener, the client fails with `ECONNREFUSED` and exit code 2.

== 5.2 Limits of this round

- *No measurements.* Fork cost, connection rate, throughput and latency are unmeasured. The 5 ms figure is a single functional observation.
- *Fork scales poorly.* One process per connection is fine for a teaching build and poor as a service; the crossover point is unknown.
- *No timeout.* An idle client holds a child process and its kernel buffers indefinitely. This is what makes the one-connection-at-a-time limit of the next version worth measuring.
- *No backpressure policy.* A slow reader blocks the child in `send_all()`; there is no bound on how long that lasts or on the bytes buffered for it.
- *No automated verification.* The checks in §4 were manual. Error paths (`EADDRINUSE`, `fork()` failure, `EPIPE`, partial writes forced by a small send buffer) were not exercised.
- *One address family was used.* The candidate loop supports IPv6, but on this host `bind()` selected `0.0.0.0`; the IPv6 path was not verified.
- *No framing.* Echo needs none, but the next version cannot inherit the loop as-is: a request parser must handle partial frames across arbitrary chunk boundaries.

== 5.3 The next experiment

The next version keeps the blocking, single-connection service loop and replaces the echoed payload with a framed protocol and an in-memory key/value store. Keeping the I/O model fixed is the point: it makes the serial-serving limit of one connection at a time measurable, so that any later move to `epoll` or threads is justified by an observed waiting time rather than by the intuition that `fork()` is expensive.

The first experiments to run on that build are the ones this round could not answer: hold one connection idle while a second client requests service; fill the backlog with unaccepted handshakes; force a slow reader against a large response. Each produces a number and a visible failure mode, and together they decide whether the next I/O model is worth its complexity.

#takeaway(title: "What M0 buys the project")[
  M0 is complete because its mechanism is observable, not because it is fast: fork confines blocking, write-all preserves the byte stream, and every descriptor copy has one owner and one close. Performance is the next round's question, and M0 deliberately leaves it open.
]

// ---------------------------------------------------------------------------
// 6. Interview Probes
// ---------------------------------------------------------------------------

= 6. Interview Probes

#probe([Why does the parent close `conn_fd` right after `fork()`?])[
  `fork()` copies the descriptor table; after it returns, parent and child each hold a reference to the same connection. The parent does not serve it, so it closes its copy immediately and keeps only `listen_fd`. If it forgot, the parent would leak one descriptor per connection until `EMFILE`, and the connection would stay open even after the child exited. The child closes its `listen_fd` copy for the symmetric reason: it never accepts, and the listener should be owned by exactly one process.
]

#probe([Does one `send()` become one `recv()`?])[
  No. TCP is a byte stream, and the kernel is free to aggregate or split. In §4, 240 bytes written by two `send()` calls came back as one 240-byte `recv()` chunk on the client's read side. The consequence is that the echo loop must handle any positive chunk size up to its buffer, and the next version's frame parser must handle a frame split across several reads and several frames in one read.
]

#probe([Why loop `waitpid(-1, nullptr, WNOHANG)` inside the SIGCHLD handler?])[
  Multiple children can exit before the handler runs, and `SIGCHLD` is not queued per child; a single `waitpid()` would collect one and leave the rest as zombies. `WNOHANG` keeps the handler from blocking, and the loop drains every exited child. The handler also saves and restores `errno`, because it can interrupt code that relies on the value, and `SA_RESTART` lets an interrupted `accept()` resume instead of returning `EINTR`.
]

#probe([Why flush `std::cout` before `fork()`?])[
  Buffered standard I/O lives in user memory, and `fork()` copies it into both processes. Pending text written before the fork would be flushed once by the parent and again by the child on `exit()`, duplicating log lines. Flushing before the fork makes the child start with an empty buffer for the lines it writes itself.
]

// ---------------------------------------------------------------------------
// 7. References
// ---------------------------------------------------------------------------

= 7. References

- Brian “Beej Jorgensen” Hall, *Beej's Guide to Network Programming* — the clearest short treatment of `getaddrinfo()`, the client/server skeleton and byte-order pitfalls: #link("https://beej.us/guide/bgnet/")[beej.us/guide/bgnet].
- Linux man-pages project — #link("https://man7.org/linux/man-pages/man2/socket.2.html")[socket(2)], #link("https://man7.org/linux/man-pages/man2/bind.2.html")[bind(2)], #link("https://man7.org/linux/man-pages/man2/listen.2.html")[listen(2)], #link("https://man7.org/linux/man-pages/man2/accept.2.html")[accept(2)], #link("https://man7.org/linux/man-pages/man2/fork.2.html")[fork(2)], #link("https://man7.org/linux/man-pages/man2/waitpid.2.html")[waitpid(2)], #link("https://man7.org/linux/man-pages/man7/signal.7.html")[signal(7)] and #link("https://man7.org/linux/man-pages/man7/tcp.7.html")[tcp(7)].
- The repository's own record: `logs/m0_log.md` (§4) for the build and verification steps this note expands.
- Source of the program under test: `src/echo_server.cc`, `src/echo_client.cc`.

#v(6pt)
#text(size: 8.4pt, fill: rgb("#94a3b8"))[
  External references support the mechanism described here. The observations in §4 belong to this repository's run; they are not general performance results and are not attributed to the references.
]
