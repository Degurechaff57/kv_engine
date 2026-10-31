#import "figures/m0_figures.typ" as figs

#set page(
  paper: "a4",
  margin: (x: 2.3cm, top: 2.2cm, bottom: 2.2cm),
  header: context {
    if here().page() > 1 [
      #set text(size: 8pt, font: "Times New Roman", fill: rgb("#94a3b8"))
      #grid(
        columns: (1fr, auto),
        [MiniKV, Linux Systems Programming, C++], [Gang Liu],
      )
      #v(-3pt)
      #line(length: 100%, stroke: 0.4pt + rgb("#f1f5f9"))
    ]
  },
  footer: context {
    set text(size: 8pt, font: "Times New Roman", fill: rgb("#94a3b8"))
    align(center)[#here().page()]
  },
)

#set text(
  font: "Times New Roman",
  size: 10pt,
  fill: rgb("#334155"),
  lang: "en",
)

#set par(
  justify: true,
  leading: 0.76em,
)

// Number level 1-3 headings automatically: `1.` for sections, `1.1` and
// `1.1.1` for subsections, matching the numbering already used in the prose
// (e.g. `Sec. 3.2`). Unnumbered headings such as `Abstract` do not advance
// the counter, so the section numbers stay stable.
#set heading(numbering: (..nums) => numbering(if nums.pos().len() == 1 { "1." } else { "1.1.1" }, ..nums))

// Headings in clean modern sans-serif. `sticky` keeps a heading with the block
// that follows it, so a section title never ends a page on its own. Re-showing
// `it` (rather than `it.body`) keeps the automatic number inside the styled line.
#show heading.where(level: 1): it => block(sticky: true)[
  #v(3pt)
  #set text(font: "Times New Roman", size: 16pt, weight: "bold", fill: rgb("#0f172a"))
  #it
  #v(3pt)
]
#show heading.where(level: 2): it => block(sticky: true)[
  #v(3pt)
  #set text(font: "Times New Roman", size: 14pt, weight: "bold", fill: rgb("#1e293b"))
  #it
  #v(3pt)
]
#show heading.where(level: 3): it => block(sticky: true)[
  #v(3pt)
  #set text(font: "Times New Roman", size: 12pt, weight: "bold", fill: rgb("#475569"))
  #it
  #v(3pt)
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
            #text(size: 7.5pt, font: "Times New Roman", fill: rgb("#a78bfa"), weight: "bold")[
              #if it.has("lang") [#upper(it.lang)] else [SNIPPET]
            ]
          ],
          [
            #text(size: 7pt, font: "Times New Roman", fill: rgb("#71717a"))[copy]
          ],
        )
      ],
    )
    #v(3pt)
    #set text(font: "Times New Roman", size: 8.5pt, fill: rgb("#f4f4f5"))
    #it
  ],
)

// Inline code: soft violet/lavender badge
#show raw.where(block: false): it => box(
  fill: rgb("#f5f3ff"),
  inset: (x: 4pt, y: 1.5pt),
  radius: 3pt,
  stroke: 0.4pt + rgb("#ddd6fe"),
  [
    #set text(fill: rgb("#6d28d9"), font: "Times New Roman", size: 8.5pt, weight: "medium")
    #it
  ],
)

// Blockquote / key takeaway box
#let takeaway(title: "Key Takeaway", body) = block(
  width: 100%,
  fill: rgb("#faf5ff"),
  radius: 6pt,
  inset: (x: 12pt, y: 10pt),
  stroke: (left: 3.5pt + rgb("#7c3aed")),
  [
    #text(font: "Times New Roman", weight: "bold", size: 9pt, fill: rgb("#5b21b6"))[#title] \
    #v(2pt)
    #set text(size: 9pt, fill: rgb("#4c1d95"))
    #body
  ],
)

// Editorial note box
#let note(title: "Observation", body) = block(
  width: 100%,
  fill: rgb("#f8fafc"),
  radius: 6pt,
  inset: (x: 12pt, y: 9pt),
  stroke: (left: 3.5pt + rgb("#64748b")),
  [
    #text(font: "Times New Roman", weight: "bold", size: 9pt, fill: rgb("#334155"))[#title] \
    #v(2pt)
    #set text(size: 8.8pt, fill: rgb("#475569"))
    #body
  ],
)


#box(fill: rgb("#f5f3ff"), inset: (x: 8pt, y: 4pt), radius: 12pt, stroke: 0.5pt + rgb("#ddd6fe"), [#text(
  size: 8pt,
  weight: "bold",
  font: "Times New Roman",
  fill: rgb("#7c3aed"),
)[MiniKV, SYSTEM PROGRAMMING, C++]])
#v(10pt)
#text(size: 21pt, weight: "bold", font: "Times New Roman", fill: rgb("#0f172a"))[
  Building a TCP Echo Server in C++
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
      align(center + horizon)[#text(fill: white, weight: "bold", font: "Times New Roman", size: 10pt)[GL]],
    )
  ],
  [
    #text(size: 9pt, weight: "bold", font: "Times New Roman", fill: rgb("#0f172a"))[Gang Liu (Silvan)] \
    #text(size: 7.5pt, font: "Times New Roman", fill: rgb("#94a3b8"))[
      Published: Oct 2026 · 20 min read
    ]
  ],
)


// Front matter: keep the heading style, but do not give it a section number.
#heading(level: 1, numbering: none)[Abstract]

This article studies the #emph[current] Linux TCP echo
server. It shares fundamental knowledge for constructing a mini KV storage service. This implementation is named "M0".

#outline(title: [Contents], depth: 2)

#pagebreak()


= Introduction
<introduction>
An echo server has a deliberately small application contract: read bytes
from a TCP connection and send the same bytes back. No database, message
grammar, or business logic is needed. That simplicity makes it an
unusually effective way to study what a Linux network program actually
owns and what the kernel does on its behalf.

C++20 does not define a standard socket interface. On Linux, a small
server therefore talks to the operating system through APIs such as
`socket()`, `bind()`, `listen()`, `accept()`, `recv()`, and `send()`.
The difficult part is not memorizing the API names, but understanding what each call guarantees, what it does not guarantee, and how misuse or unexpected conditions can break your assumptions.

In this M0 implementation, one parent process accepts connections and
forks one child for each accepted connection. Each child handles a
*blocking I/O* for its client. A `SIGCHLD` handler reaps terminated child processes
to prevent zombie processes from accumulating. The client can send data and read its echo. This article first explains the underlying Linux
mechanisms, then connects them to design and code, reviews the existing
functional observations, and ends with seven questions worth thinking
through independently.

= Linux Networking and Process Fundamentals
<linux-networking-and-process-fundamentals>
== Why TCP for Echo? TCP versus UDP

At first glance, UDP seems the natural choice for a trivial Echo server: it preserves datagram boundaries and avoids connection handshakes. An Echo server can indeed be implemented over either protocol.

However, we deliberately choose *TCP*. The goal of this Echo server is not merely to reflect bytes, but to lay the architectural groundwork for the upcoming *MiniKV* protocol.

Real-world client-server systems like MiniKV require :
- connection establishment
- persistent sessions, stream framing
- precise EOF handling.

Implementing Echo over TCP introduces the fundamental per-client socket lifecycle and resource models that will be reused throughout this project. In short, TCP introduces more initial complexity such as boundary issues (@fig-tcp-stream), but it provides the exact mental model needed for production network programming.

#figure(
  figs.tcp-stream(),
  caption: [TCP preserves byte order but not the boundaries of application send calls.],
) <fig-tcp-stream>

#pagebreak()
@tab-tcp-udp contrasts TCP and UDP, highlighting how TCP's complexities serve our learning objectives:

#figure(
  table(
    // columns: (1.2fr, 1.3fr, 1.3fr, 1.5fr),
    columns: (auto, auto, auto),
    align: (clo, row) => if row == 0 { center } else { left },
    inset: 5pt,
    stroke: 0.4pt + rgb("#cbd5e1"),

    [*Dimension*], [*TCP (`SOCK_STREAM`)*], [*UDP (`SOCK_DGRAM`)*],

    [Connection model],
    [Connection-oriented: stateful peer connection established prior to I/O.],
    [Connectionless: datagrams transmitted independently to peer addresses.],

    [Server socket lifecycle], [`socket → bind → listen → accept`], [`socket → bind`; shared `recvfrom` / `sendto`],

    [Data transfer semantics],
    [Unstructured byte stream; message boundaries are not preserved.],
    [Discrete datagrams; message boundaries preserved within MTU limits.],

    [Failure modes],
    [`EPIPE`, `ECONNRESET`, abrupt peer disconnects, half-closes.],
    [Silently dropped packets, truncation (`EMSGSIZE`), timeouts.],
  ),
  kind: table,
  supplement: [Table],
  caption: [Comparison of TCP and UDP.],
) <tab-tcp-udp>

Throughout this chapter, identifiers set in inline code (e.g., `socket`, `bind`) refer to Linux system calls. Detailed interface signatures and error specifications can be found in Section 2 of the manual pages (e.g., `man 2 socket`).

Important calls of TCP in Linux;
=== `recv()` — receive bytes from a connected socket

`recv(sockfd, buf, len, flags)` copies up to `len` bytes into caller-owned memory.
- *Input parameters, in order*
  - `sockfd`: connected socket FD; e.g. the child's `conn_fd`.
  - `buf`: writable pointer such as `buffer.data()`.
  - `len`: maximum requested bytes; commonly `sizeof(buffer)` or `buffer.size()`; it is *not* a message length.
  - `flags`: usually `0`; `MSG_DONTWAIT` is a per-call nonblocking option; `MSG_PEEK` inspects without consuming.
- *Return value*
  - positive = bytes copied;
  - zero = TCP orderly EOF after queued data;
  - `-1` = failure (`errno` such as `EINTR`, `EAGAIN`, `ECONNRESET`).
- *Documentation lookup*
  - `man 2 recv` or `man 2 recvfrom`; see @linux-recv.

=== `send()` — enqueue bytes on the connected socket

`send(sockfd, buf, len, flags)` attempts to accept some or all bytes into the local transmission path.
- *Input parameters, in order*
  - `sockfd`: connected socket FD.
  - `buf`: pointer to `len` readable bytes.
  - `len`: number of bytes still awaiting transmission; decrement after each positive short send.
  - `flags`: `0` by default; Linux `MSG_NOSIGNAL` suppresses `SIGPIPE` for this send; `MSG_DONTWAIT` affects this call only.
- *Return value*
  - nonnegative count accepted (possibly smaller than `len`); `-1` on failure such as `EINTR` or `EPIPE`. Success does *not* prove the peer application consumed the data.
- *Documentation lookup*
  - `man 2 send`; see @linux-send.

=== UDP counterparts — `recvfrom()` and `sendto()`

`recvfrom(sockfd, buf, len, flags, src_addr, addrlen)`can return the datagram's source address.

`sendto(sockfd, buf, len, flags, dest_addr, addrlen)` can name a destination without establishing a stream connection.

- *`recvfrom(sockfd, buf, len, flags, src_addr, addrlen)` inputs*
  - `sockfd`, `buf`, `len`, `flags`: correspond to the arguments of `recv()`.
  - `src_addr`: output `sockaddr*` for source address; `NULL` if unneeded.
  - `addrlen`: input/output size of `src_addr`; `NULL` when `src_addr` is null.
- *`sendto(sockfd, buf, len, flags, dest_addr, addrlen)` inputs*
  - `sockfd`, `buf`, `len`, `flags`: corresponding send arguments.
  - `dest_addr`: destination `sockaddr*`; may be `NULL` for a connected datagram socket.
  - `addrlen`: byte size of `dest_addr`.
- *Return value*
  - `recvfrom`: received bytes or `-1`; a zero-length UDP datagram may return `0` (*not TCP EOF*). `sendto`: byte count or `-1`; a datagram should not be split into multiple application sends to compensate for TCP-style short sends.
- *Documentation lookup*
  - `man 2 recvfrom`, `man 2 sendto`; see @linux-recv @linux-send.


== Socket lifecycle: from address to connected FD

@fig-socket-lifecycle shows the server's control sequence. `getaddrinfo()` produces candidate addresses; `socket()` creates a socket FD; `bind()` assigns a local address; `listen()` makes it passive; and `accept()` returns a *new* connected FD while the listening FD continues to accept clients @linux-getaddrinfo @linux-accept.

#figure(
  figs.socket-lifecycle(),
  caption: [M0 TCP socket lifecycle; `accept()` creates a connected FD without replacing the listener.],
) <fig-socket-lifecycle>

Details of above APIs:
=== `getaddrinfo()` — address resolution

`getaddrinfo(node, service, hints, res)` obtains address candidates without manually constructing `sockaddr_in` or `sockaddr_in6`.
- *Input/output parameters*
  - `node`: hostname or `nullptr` for wildcard/local addresses according to flags.
  - `service`: port name such as `"2026"` or service string.
  - `hints`: pointer to `addrinfo` filters; common settings `AF_UNSPEC`, `SOCK_STREAM`, `AI_PASSIVE`.
  - `res`: output pointer to allocated linked-list results; release with `freeaddrinfo()`.
- *Return value*
  - `0` for success; a nonzero EAI error code (report with `gai_strerror()`, not general `errno` alone).
- *Documentation lookup*
  - `man 3 getaddrinfo`; see @linux-getaddrinfo.

#pagebreak()

=== `socket()` — allocate a socket FD

`socket(domain, type, protocol)` creates an endpoint and returns its process-local descriptor.
- *Input parameters*
  - `domain`: `AF_INET`, `AF_INET6`, or `AF_UNIX`.
  - `type`: `SOCK_STREAM` (TCP), `SOCK_DGRAM` (UDP); Linux can OR `SOCK_CLOEXEC` / `SOCK_NONBLOCK`.
  - `protocol`: normally `0` to select the default protocol for that family/type.
- *Return value*
  - nonnegative FD; `-1` with `errno` on failure. Close a successfully allocated FD on later setup failure.
- *Documentation lookup*
  - `man 2 socket`; see @linux-socket.

=== `setsockopt()` — configure the endpoint

`setsockopt(sockfd, level, optname, optval, optlen)` changes a socket option; M0 uses `SO_REUSEADDR`.
- *Input parameters*
  - `sockfd`: socket being configured.
  - `level`: `SOL_SOCKET` for generic options; `IPPROTO_TCP` for TCP-specific options.
  - `optname`: e.g. `SO_REUSEADDR` (reuse binding under documented rules), `SO_KEEPALIVE`.
  - `optval`: pointer to value, typically `int one = 1`.
  - `optlen`: size of the pointed-to value, typically `sizeof(one)`.
- *Return value*
  - `0` success; `-1` / `errno` failure. `SO_REUSEADDR` does not permit arbitrarily stealing an active listener.
- *Documentation lookup*
  - `man 7 socket`; see @linux-setsockopt.

=== `bind()` — choose the local address

`bind(sockfd, addr, addrlen)` associates the socket with a local address.
- *Input parameters*
  - `sockfd`: allocated but not yet bound listening candidate.
  - `addr`: pointer to a family-specific `sockaddr`; commonly `ai_addr` from `getaddrinfo()`.
  - `addrlen`: address byte size, often `ai_addrlen`.
- *Return value*
  - `0` success; `-1` on error (`EADDRINUSE`, `EACCES`, invalid address). Close the failed candidate FD before moving on.
- *Documentation lookup*
  - `man 2 bind`; see @linux-bind.

=== `listen()` — transition to passive TCP listening

`listen(sockfd, backlog)` queues connections awaiting acceptance.
- *Input parameters*
  - `sockfd`: successfully bound `SOCK_STREAM` socket.
  - `backlog`: requested queue length for fully established connections awaiting `accept()`, e.g. M0 uses `10`; may be capped by `somaxconn`.
- *Return value*
  - `0` success; `-1` / `errno` failure. Backlog is not the maximum active client count.
- *Documentation lookup*
  - `man 2 listen`; see @linux-listen.

=== `accept()` — obtain one connected socket

`accept(sockfd, addr, addrlen)` dequeues a pending established connection.
- *Input/output parameters*
  - `sockfd`: listening FD, retained by the parent.
  - `addr`: optional peer-address output; `nullptr` when not needed.
  - `addrlen`: in/out peer-address buffer size; `nullptr` if `addr` is null.
- *Return value*
  - a new connected FD on success, `-1` / `errno` on failure. `EINTR` usually retries; `EMFILE` / `ENFILE` require backpressure or operational handling; Linux may surface pending network errors from `accept()`.
- *Documentation lookup*
  - `man 2 accept`; see @linux-accept.

== What is an FD? Kernel structures and reference lifetime

The integer `fd` is an *index in a process descriptor table*, not the socket itself. A useful Linux conceptual route is illustrated in @fig-fd-kernel. Actual internal pointers, layering, and fields are implementation details of particular kernel revisions;
#figure(
  figs.fd-kernel(),
  caption: [Conceptual Linux FD lookup: process table entry to a socket and TCP protocol state.],
) <fig-fd-kernel>

Three distinctions explain why the small integer supports many operations:
+ *Process-local descriptor number*: `4` indexes one table in one process; the same integer in another process can mean something completely different.
+ *Open file description (`struct file`)*: stores per-open-file status, operations, and a reference to the underlying object. Descriptors duplicated by `dup()` or inherited by `fork()` can reference the same open file description.
+ *Object-specific behavior*: kernel operations dispatch according to object type/operations; files, pipes, sockets, and epoll objects expose FD-based interfaces without having identical internal implementations.

A socket FD can therefore be passed to `recv()`, `send()`, `poll()`, `fcntl()`, or `close()` because the kernel resolves the descriptor to the correct object and checks the requested operation; *the integer alone contains none of the TCP state*. `/proc/<pid>/fd` and `/proc/<pid>/fdinfo` reveal live process-visible descriptors and some flags, but not arbitrary private kernel structure layouts @linux-open @linux-proc.

`fork()` copies descriptor table entries into a new process. Parent and child have separate descriptor tables but corresponding entries reference the same open file descriptions. Closing an inherited FD drops only *that process's reference*; the other process may continue using its reference. File *status* flags (e.g. `O_NONBLOCK`) belong to the shared open file description, while descriptor flags (e.g. `FD_CLOEXEC`) are per descriptor @linux-fork @linux-fcntl.

// TODO: add a socket struct memory layout and a fork fd layout.

=== `close()` — release one descriptor reference

`close(fd)` removes the calling process's FD table entry; it does not close copies still referenced by another process.
+ *Input parameters*
  + `fd`: a valid process-local descriptor, such as `conn_fd` or `listen_fd`.
+ *Return value* — `0` for success, `-1` with `errno` for an error (including `EBADF` for an invalid number). Do not blindly retry `close()` after `EINTR`: on Linux the FD number is generally already released and may have been reused.
+ *Documentation lookup* — `man 2 close`; see @linux-close.

=== `fcntl()` — manipulate descriptor or open-file-description flags

`fcntl(fd, cmd, ...)` is a multiplexed control API; the meaning of its optional third argument depends on `cmd`.
+ *Input parameters*
  + `fd`: existing descriptor.
  + `cmd`: `F_GETFL` reads file status flags; `F_SETFL` updates flags such as `O_NONBLOCK`; `F_GETFD` / `F_SETFD` read or set descriptor flags such as `FD_CLOEXEC`.
  + `...`: for `F_SETFL`, an integer flag bitset, commonly `old_flags | O_NONBLOCK`; for query commands, no third argument is used.
+ *Return value* — query commands return flags, update commands normally return `0`, and errors return `-1`. Check the specific `cmd` contract.
+ *Documentation lookup* — `man 2 fcntl`; see @linux-fcntl.

== Linux I/O modes and the fork-per-connection choice

Three questions must not be conflated: (i) does a particular call block, (ii) how does code discover readiness/completion, and (iii) how is concurrency organized across processes or threads? `O_NONBLOCK` concerns syscall behavior, `select` / `poll` / `epoll` are readiness notification mechanisms, and `io_uring` supplies an asynchronous submission/completion interface. These mechanisms are not mutually exclusive categories @linux-epoll @linux-uring.

#figure(
  table(
    columns: (1.06fr, 1.3fr, 1.3fr, 1.5fr),
    inset: 4pt,
    stroke: 0.4pt + rgb("#cbd5e1"),
    [*Mode / primitive*], [*Typical calls*], [*Strength*], [*Trade-off / suitable scene*],
    [Blocking synchronous],
    [`accept`, `recv`, `send`],
    [Smallest control flow, easy debugging],
    [Execution context waits; good for teaching or small worker pools],

    [Nonblocking alone],
    [`fcntl(O_NONBLOCK)` + `recv`],
    [One call does not wait for unavailable data],
    [Must handle `EAGAIN` and avoid busy spinning],

    [`select` / `poll` readiness],
    [`select`, `poll` then `recv`],
    [Monitor multiple FDs, portable],
    [`select` FD-set limits; repeated scanning, moderate sets],

    [`epoll` readiness],
    [`epoll_ctl`, `epoll_wait`],
    [Scalable Linux interest/ready lists],
    [Reactor state machine; edge-triggered paths must drain to `EAGAIN`],

    [`io_uring` completion],
    [SQEs → CQEs],
    [Batch/asynchronous operations and completion records],
    [More complex lifetime/cancellation; kernel support/security policy matters],
  ),
  kind: table,
  supplement: [Table],
  caption: [Linux network I/O mechanisms: blocking, readiness, and completion are different axes.],
) <tab-io-modes>

Table @tab-io-modes is qualitative; no throughput or latency ranking is claimed. In M0, the parent blocks in `accept()` while one child per client blocks in `recv()`. @fig-io-contexts shows why client B can progress even if child A is idle: the scheduler sees separate processes. The `fork()` concurrency policy is *not* an alternative implementation of nonblocking I/O; it is a separate axis.

#figure(
  figs.io-contexts(),
  caption: [Multiple blocking processes can still service clients concurrently.],
) <fig-io-contexts>

*Advantages of one `fork()` per connection:* straight-line code, independent address spaces, simple per-client ownership, and a reproducible stepping stone toward an event loop. *Disadvantages:* process creation/context-switch/memory overhead, process and FD limits, costly cross-process shared state, a client can hold a child in a blocking read or write, and reaping becomes mandatory. Use it as an M0 learning baseline; an `epoll` Reactor or a bounded worker pool becomes a natural later experiment, not an unmeasured claim of superiority @linux-fork @linux-epoll.

== Signals, SIGCHLD, and reproducible counterexamples

A *signal* is an asynchronous notification to a process or thread. `SIGCHLD` may notify a parent about child state changes. A terminated child usually retains a zombie process-table record until its parent collects the exit status; standard signals are not lossless event counters, so one delivered `SIGCHLD` does *not* prove exactly one child exited @linux-signal @linux-waitpid.

@fig-reaping explains the M0 reaping policy: register a `SIGCHLD` handler, then repeat nonblocking `waitpid()` until no further child is waitable. An early `SIGCHLD` before handler installation can be missed if installed too late: configure the policy before the accept/fork loop.

#figure(
  figs.child-reaping(),
  caption: [SIGCHLD is a prompt to drain child-exit state, not one event record per child.],
) <fig-reaping>

=== `fork()` — create a child process

`fork()` duplicates the calling process's execution context, subject to copy-on-write memory and inherited FD references.
+ *Input parameters* — none.
+ *Return value* — in parent: positive child PID; in child: `0`; on failure: `-1` with `errno` (no child created, so parent still owns `conn_fd`).
+ *Documentation lookup* — `man 2 fork`; see @linux-fork.

=== `sigaction()` — install a signal disposition

`sigaction(signum, act, oldact)` registers a handler or disposition for a specified signal.
+ *Input/output parameters*
  + `signum`: `SIGCHLD` for child state changes; `SIGPIPE` for write-to-broken-pipe events.
  + `act`: pointer to `struct sigaction`; set `sa_handler`, empty `sa_mask` with `sigemptyset()`, and typically `SA_RESTART | SA_NOCLDSTOP` for this M0 design. `SA_NOCLDWAIT` changes reaping semantics and is not combined with manual collection here.
  + `oldact`: optional output for the previous action, or `nullptr`.
+ *Return value* — `0` on success, `-1` / `errno` on failure. `SA_RESTART` restarts certain interrupted syscalls, not all; retain `EINTR` handling.
+ *Documentation lookup* — `man 2 sigaction`, `man 7 signal`; see @linux-sigaction @linux-signal.

=== `waitpid()` — reap a child and obtain status

`waitpid(pid, status, options)` checks or waits for child state changes.
+ *Input/output parameters*
  + `pid`: `-1` for any child, positive PID for a specific child.
  + `status`: pointer to integer status; `nullptr` if status is irrelevant; decode non-null status using `WIFEXITED`, `WEXITSTATUS`, etc.
  + `options`: `WNOHANG` to avoid waiting; optionally `WUNTRACED` / `WCONTINUED` for other state transitions.
+ *Return value* — positive PID = a child was collected; `0` = none currently waitable under `WNOHANG`; `-1` = error, commonly `ECHILD` once no eligible children remain, or `EINTR`.
+ *Documentation lookup* — `man 2 waitpid`; see @linux-waitpid.

An async-signal-safe *minimal handler* is sufficient for teaching; `waitpid()` and saving/restoring `errno` are permitted, but C++ I/O, dynamic allocation, and arbitrary logging should stay out of the handler @linux-safety.

```cpp
void reap_children(int) {
    const int saved_errno = errno;
    while (::waitpid(-1, nullptr, WNOHANG) > 0) { }
    errno = saved_errno;
}
```

*Counterexample A — no reaping.* Temporarily disable the handler (in a local test branch only), start the server, connect and close a client, then inspect `ps -o pid,ppid,stat,cmd --ppid <server-pid>`; a `Z` state with `<defunct>` may appear while the parent stays alive. Restore reaping and repeat. *Counterexample B — only one `waitpid` per handler.* Trigger a batch of short-lived child connections; standard `SIGCHLD` notifications can coalesce, potentially leaving zombies. The exact race is timing-dependent, so absence of a zombie in one run is not proof of correctness @linux-signal @linux-waitpid.

*Counterexample C — unhandled `SIGPIPE`.* Terminate a client while the server is sending, and the default disposition may kill the child. M0 uses `send(..., MSG_NOSIGNAL)` so an error such as `EPIPE` can instead be handled locally. Disconnect timing matters and may yield a different error; do not label every disconnect as `EPIPE` @linux-send.

== Beyond signal handlers: other Linux notification and event facilities

Signals are only one way to notify an application. The following concepts are ordered by the *learning dependency* from byte-stream IPC to multiplexing and fd-based process management; most are *not implemented in M0*. Their common theme is turning external state changes into work the program can explicitly observe.

#figure(
  table(
    columns: (1fr, 1.45fr, 1.5fr),
    inset: 5pt,
    stroke: 0.4pt + rgb("#cbd5e1"),
    [*Facility*], [*Purpose*], [*When useful*],
    [`pipe` / `socketpair`], [Byte-stream or local socket IPC], [Parent-worker commands and results],
    [`select` / `poll`], [FD readiness polling], [Small/portable multiplexers],
    [`epoll`], [Linux scalable readiness notification], [Reactor / many sockets],
    [`eventfd`], [FD-readable counter notification], [Wake an event loop from worker threads],
    [`signalfd`], [Consume blocked signals as FD records], [Handle signals inside one event loop],
    [`timerfd`], [Timer expirations as readable FD], [Connection timeout management],
    [`pidfd`], [Stable FD referring to process], [Monitor and manage process lifecycle with fewer PID-reuse pitfalls],
  ),
  kind: table,
  supplement: [Table],
  caption: [Related Linux facilities: IPC, readiness, timers, signals, and process handles.],
) <tab-event-facilities>

=== Pipe and socketpair: local communication

*Motivation / history:* early Unix pipes connected a producer and consumer without disk files; Unix-domain socket pairs generalize local IPC to bidirectional communication. *Minimal use:* create a channel before `fork()`, close the unused ends in each process, and transfer a short command or result between parent and worker.

`pipe(pipefd)` creates a pair of unidirectional FDs.
+ *Parameters*
  + `pipefd`: output array `int pipefd[2]`; index `0` is the read end, index `1` the write end.
+ *Return value* — `0` on success, `-1` with `errno` on failure.
+ *Manual / lookup* — `man 2 pipe`; see @linux-pipe.

`socketpair(domain, type, protocol, sv)` creates two connected local endpoints.
+ *Parameters*
  + `domain`: generally `AF_UNIX` for local sockets.
  + `type`: commonly `SOCK_STREAM` or `SOCK_DGRAM`.
  + `protocol`: usually `0`.
  + `sv`: output array `int sv[2]` containing the two endpoint FDs.
+ *Return value* — `0` on success; `-1` with `errno` on failure.
+ *Manual / lookup* — `man 2 socketpair`; see @linux-socketpair.

=== select / poll / epoll: readiness before I/O

*Motivation / history:* blocking on one FD is insufficient for many unrelated connections. `select` and `poll` exposed readiness sets; Linux `epoll` later introduced a persistent interest/ready set designed to scale across many FDs. The simplest practical test uses one connected socket and waits for readability before calling `recv()`.

`poll(fds, nfds, timeout)` checks the readiness of a `pollfd` array.
+ *Parameters*
  + `fds`: pointer to `pollfd` entries; e.g. `.fd = conn_fd`, `.events = POLLIN`.
  + `nfds`: number of valid entries in the array.
  + `timeout`: milliseconds to wait; `0` polls immediately, `-1` waits without a deadline.
+ *Return value* — positive count of ready entries, `0` timeout, `-1` error.
+ *Manual / lookup* — `man 2 poll`; `select` is described by `man 2 select`; see @linux-poll @linux-select.

For a larger set, the three main `epoll` calls are:
+ *`epoll_create1(flags)`*
  + `flags`: often `EPOLL_CLOEXEC` or `0`.
  + Return: epoll FD or `-1`; lookup: `man 2 epoll_create1` / `man 7 epoll` @linux-epoll.
+ *`epoll_ctl(epfd, op, fd, event)`*
  + `epfd`: existing epoll instance FD.
  + `op`: `EPOLL_CTL_ADD`, `EPOLL_CTL_MOD`, or `EPOLL_CTL_DEL`.
  + `fd`: target FD (for example `conn_fd`).
  + `event`: pointer to desired `epoll_event` (usually `EPOLLIN`; `EPOLLET` optionally requests edge triggering).
  + Return: `0` or `-1`; lookup: `man 2 epoll_ctl` @linux-epoll.
+ *`epoll_wait(epfd, events, maxevents, timeout)`*
  + `epfd`: epoll FD.
  + `events`: writable result array of `epoll_event`.
  + `maxevents`: capacity of that array, greater than zero.
  + `timeout`: milliseconds, `-1` indefinitely.
  + Return: positive ready-event count, `0` timeout, `-1` error; lookup: `man 2 epoll_wait` @linux-epoll.

An edge-triggered event loop typically sets sockets nonblocking and drains reads/writes until `EAGAIN`; otherwise an event can be missed while buffered data remains @linux-epoll.

=== eventfd: counter-based wakeup

*Motivation / history:* a pollable kernel counter allows a worker to wake an event loop without inventing a pipe message format. *Minimal use:* a worker writes an unsigned 64-bit `1` into the eventfd; the loop reads the accumulated count.

`eventfd(initval, flags)` creates the notification counter.
+ *Parameters*
  + `initval`: initial 64-bit counter value, usually `0`.
  + `flags`: commonly `EFD_NONBLOCK | EFD_CLOEXEC` or `0`.
+ *Return value* — a new FD, or `-1` with `errno`.
+ *Manual / lookup* — `man 2 eventfd`; see @linux-eventfd.

=== signalfd: consume signals as FD records

*Motivation / history:* classic signal handlers run under async-signal-safety restrictions. A `signalfd` lets an event loop read selected *blocked* signals instead. *Minimal use:* block `SIGCHLD`, obtain a signalfd, read `signalfd_siginfo`, and still reap terminated children using `waitpid()`.

`signalfd(fd, mask, flags)` creates or reconfigures a signal FD.
+ *Parameters*
  + `fd`: `-1` to create a new descriptor; an existing signalfd to update.
  + `mask`: pointer to the set of signals to receive, usually initialized with `sigemptyset` / `sigaddset`; those signals should be blocked appropriately.
  + `flags`: `SFD_NONBLOCK`, `SFD_CLOEXEC`, or `0`.
+ *Return value* — signal FD on success; `-1` / `errno` on error.
+ *Manual / lookup* — `man 2 signalfd`; see @linux-signalfd.

=== timerfd: timer expirations as readable records

*Motivation / history:* timeout scheduling fits naturally into readiness-based loops when timers are FDs. *Minimal use:* arm a monotonic timer and read an unsigned 64-bit expiration count after `poll()` reports it readable.

`timerfd_create(clockid, flags)` constructs the timer FD.
+ *Parameters*
  + `clockid`: commonly `CLOCK_MONOTONIC` (immune to wall-clock adjustments).
  + `flags`: `TFD_NONBLOCK | TFD_CLOEXEC` or `0`.
+ *Return value* — timer FD or `-1`; lookup: `man 2 timerfd_create` @linux-timerfd.

`timerfd_settime(fd, flags, new_value, old_value)` arms/disarms it.
+ *Parameters*
  + `fd`: timer FD returned by `timerfd_create`.
  + `flags`: `0` for relative time or `TFD_TIMER_ABSTIME` for absolute time.
  + `new_value`: pointer to `itimerspec` containing initial expiration and interval.
  + `old_value`: optional pointer for previous timer settings; may be `nullptr`.
+ *Return value* — `0` or `-1`; lookup: `man 2 timerfd_settime` @linux-timerfd.

=== pidfd: stable reference to a process

*Motivation / history:* bare PIDs can be reused and make race-free process management awkward. A pidfd is a kernel-backed reference that can become readable on process exit. *Minimal use:* obtain a pidfd for a known child and `poll()` it while keeping normal child-reaping semantics in mind.

`pidfd_open(pid, flags)` obtains a process descriptor (the manual documents syscall invocation and kernel-version constraints).
+ *Parameters*
  + `pid`: the target task/process PID (commonly a child PID).
  + `flags`: usually `0`; newer kernels provide additional options such as `PIDFD_NONBLOCK`.
+ *Return value* — pidfd on success; `-1` with `errno` on failure.
+ *Manual / lookup* — `man 2 pidfd_open`; see @linux-pidfd.

= Echo Server Architecture and Resource Ownership

== Process / FD architecture and the ownership transitions

@fig-fork-ownership extends the lifecycle of @fig-socket-lifecycle. After `accept()` succeeds, the parent owns `listen_fd` plus a new `conn_fd`. After `fork()`, *both descriptor tables* have references to both kernel open file descriptions; the parent immediately closes its accepted FD, and the child immediately closes its inherited listening FD. The child owns the echo task and eventually closes its accepted FD. The parent remains responsible for child termination collection @linux-fork @linux-close.

#figure(
  figs.fork-ownership(),
  caption: [FD ownership handoff after `fork()` and the required cleanup on each process path.],
) <fig-fork-ownership>

#figure(
  table(
    columns: (1fr, 1.28fr, 1.28fr, 1.52fr),
    inset: 5pt,
    stroke: 0.4pt + rgb("#cbd5e1"),
    [*Stage*], [*Parent `listen_fd`*], [*Parent `conn_fd`*], [*Child descriptors / action*],
    [Before accept], [Owned], [Not present], [No child yet],
    [After accept], [Owned], [Owned], [No child yet],
    [Immediately after fork], [Owned], [Still referenced], [Both `listen_fd`, `conn_fd` inherited],
    [After handoff], [Owned], [Closed], [`listen_fd` closed; `conn_fd` retained],
    [After child EOF/error], [Owned], [Closed], [`conn_fd` closed; child exits],
    [After wait], [Owned], [Closed], [Child status collected],
  ),
  kind: table,
  supplement: [Table],
  caption: [Ownership matrix (logical states, not numeric FD guarantees).],
) <tab-fd-ownership>

*Important:* both processes might numerically name the inherited FD `4`, but that does not make `4` a global connection ID. Closing the listener in each child avoids keeping the listening socket alive unnecessarily after parent exit. Closing the accepted FD in the parent ensures it does not delay connection teardown after the child finishes. A negative `fork()` result means no ownership transfer occurred; the parent must close its `conn_fd` @linux-open @linux-fork.

== Happy path, error paths, and buffer/flush design

The *happy path* is `getaddrinfo → socket → setsockopt → bind → listen → accept → flush → fork`; the parent closes `conn_fd`, the child closes `listen_fd`, then loops `recv → send_all` until EOF before closing `conn_fd` and exiting. The client may call `shutdown(SHUT_WR)` after sending and continue to receive its echo; the reverse stream remains usable as @fig-halfclose demonstrates @linux-shutdown.

#figure(
  figs.half-close(),
  caption: [TCP half-close: the client can stop transmitting yet continue receiving echoed data.],
) <fig-halfclose>

The *error path* deserves an explicit policy rather than a generic "print error" branch:
+ *Address / listener setup:* test every `getaddrinfo` result; close each failed candidate FD; free address results; abort cleanly if none binds/listens.
+ *`accept()` failure:* `EINTR` retries, selected transient network errors may retry, and resource exhaustion (`EMFILE`, `ENFILE`) requires a controlled stop/backoff rather than a hot loop.
+ *`fork()` failure:* log outside any handler, close the accepted FD in the parent, avoid entering the child path, and continue or stop according to policy.
+ *Child `recv()` result:* positive bytes enter the send loop; zero means orderly receive EOF; `EINTR` retries; other negative results terminate this client's loop (future nonblocking versions also handle `EAGAIN`).
+ *Child `send()` result:* advance by the positive count; retry `EINTR`; for a zero-byte no-progress result, treat as failure to avoid a spin; terminate on `EPIPE` / `ECONNRESET` and other fatal errors. Use `MSG_NOSIGNAL` to avoid unintended process termination.
+ *Normal shutdown:* child closes its socket exactly once and exits; parent reaps it. RAII wrappers can clarify single-process ownership but inherited descriptors require explicit post-fork decisions.

The buffers in @fig-buffers belong to different layers and cannot be substituted for one another. `recv` writes into the application array (M0: 100 bytes), whose meaningful length is the *return value*, not the array capacity. The kernel maintains socket send/receive queues; a successful `send` accepts bytes locally, not an application-level acknowledgement. `std::cout` has user-space buffering, distinct from the kernel FD @linux-recv @linux-send @linux-stdio.

#figure(
  figs.buffers(),
  caption: [Different buffering layers: application arrays and C++ stream buffers versus kernel-managed socket/output state.],
) <fig-buffers>

*Why flush before fork?* An unflushed user-space stream buffer can be copied into the child at `fork()`. If both processes subsequently flush their private copies, one log line can appear twice even though there was only one `accept()`. Therefore `std::cout.flush()` before `fork()` is reasonable for the M0 logging path; flushing is *not* a way to force TCP delivery or erase kernel socket data. Using `_exit()` instead of buffered C/C++ exit paths affects the duplication story but also bypasses C++ destructor cleanup; do not silently mix these approaches @linux-fork @linux-stdio.

=== `shutdown()` — change one or both transport directions

`shutdown(sockfd, how)` disables part of a full-duplex connected socket.
+ *Input parameters*
  + `sockfd`: connected socket FD.
  + `how`: `SHUT_RD` disables receives, `SHUT_WR` disables sends, `SHUT_RDWR` disables both directions.
+ *Return value* — `0` success or `-1` / `errno` failure. Unlike `close()`, `shutdown()` does not release the process FD number.
+ *Documentation lookup* — `man 2 shutdown`; see @linux-shutdown.

= Implementation and Reproduction

The fragments below are condensed pedagogical sketches, not a claim to have audited a complete `server.cpp` source in the supplied archive. The package contains the note and diagrams, but not a separately verified, buildable C++ server tree. Adapt these snippets into an executable only with the error handling of Sec. 3.2.

== Socket setup and listener

```cpp
addrinfo hints{};
hints.ai_family = AF_UNSPEC;
hints.ai_socktype = SOCK_STREAM;
hints.ai_flags = AI_PASSIVE;

addrinfo* result = nullptr;
int rc = ::getaddrinfo(nullptr, "2026", &hints, &result);
if (rc != 0) { /* report gai_strerror(rc) */ }
// For each result: socket -> setsockopt -> bind -> listen.
// Close failed candidates, freeaddrinfo(result) in all paths.
```

The original notes report use of a listener at `0.0.0.0:2026`, a `listen()` backlog of `10`, and a 100-byte receive buffer. These are *documented design/recorded-note values*, not evidence of IPv6 coverage, high concurrency, or a validated backlog limit.

== Connection handoff and echo loop

```cpp
// Parent: check accept and fork errors before branching.
int conn_fd = ::accept(listen_fd, nullptr, nullptr);
if (conn_fd < 0) { /* EINTR/transient/fatal handling */ }
else {
    std::cout.flush();  // Prevent duplicated pending log text.
    pid_t pid = ::fork();
    if (pid < 0) { ::close(conn_fd); }
    else if (pid == 0) {
        ::close(listen_fd);
        char buf[100];
        for (;;) {
            ssize_t n = ::recv(conn_fd, buf, sizeof buf, 0);
            if (n == 0) break;
            if (n < 0) { if (errno == EINTR) continue; break; }
            size_t off = 0;
            while (off < static_cast<size_t>(n)) {
                ssize_t m = ::send(conn_fd, buf + off,
                    static_cast<size_t>(n) - off, MSG_NOSIGNAL);
                if (m > 0) { off += static_cast<size_t>(m); continue; }
                if (m < 0 && errno == EINTR) continue;
                goto child_done; // simplified error exit
            }
        }
child_done:
        ::close(conn_fd);
        ::_exit(0); // example only; destructors do not run
    } else { ::close(conn_fd); }
}
```

This example shows only the structural invariants. In production C++ prefer structured error propagation instead of `goto`, and consider child exit status, logging, timeouts, and initialization constraints. The `SIGCHLD` disposition should be established *before* `fork()` begins.

== Minimal verification procedures (not new measurements)

+ *Binary integrity:* send payloads longer than 100 bytes and containing zero bytes; compare exact output bytes, not text formatting.
+ *Split sends:* issue several client writes and verify concatenated echoed bytes, without assuming one `recv` per write.
+ *Half-close:* send data, call client `shutdown(SHUT_WR)`, then read until EOF and compare.
+ *Idle concurrency:* leave client A connected but idle, use client B to exchange data, and verify B can finish.
+ *Zombie check:* connect/disconnect repeatedly, then use `ps` to inspect child states while the server remains alive.
+ *Failure injection:* induce client reset, `fork` pressure/limits (in a controlled environment), and a full send buffer; verify cleanup and no busy loop.

A smoke test can use Python's `socket.create_connection(("127.0.0.1", 2026))` and `sendall`, followed by a receive loop; automated tests should assert exact payload length and content. Record compiler, Linux kernel, command line, and exit status if results are later published.

= Limitations and Engineering Trade-offs

M0 is deliberately not a production TCP service. One child per connection consumes OS process resources; there is no connection timeout, bounded concurrent-child admission, application-level framing, graceful fleet shutdown, structured logs, or benchmark suite. Binary payload correctness must be tested, not inferred from a text echo. Kernel buffering and `send_all()` do not establish end-to-end application acknowledgement. None of the qualitative design arguments is a measured QPS or latency claim.

The next natural iteration should make one change at a time: instrument correctness and FD ownership first, add bounded resource handling, then compare a single-process nonblocking `epoll` Reactor with the existing process-per-connection baseline under the same workload and explicit resource caps. `io_uring` is a separate, later experiment @linux-epoll @linux-uring.

= Some Insights

== Does the parent's `close(conn_fd)` close the child's connection?
`TODO: add an instance or supply in chap3`

No. Both processes own separate FD entries referencing the same inherited open file description. The parent's `close()` removes only one reference; child I/O continues until its own closure or connection state change. This is why the ownership matrix @tab-fd-ownership matters more than remembering an integer @linux-fork @linux-close.

== Why is one SIGCHLD not one child termination?
`说法很奇怪看不懂`

Standard signals can coalesce. The handler should use `waitpid(-1, ..., WNOHANG)` in a loop, because the authoritative state is the kernel's set of waitable children, not the number of signal deliveries @linux-signal @linux-waitpid.

== Why can the client finish sending but still receive?

TCP is full duplex. `shutdown(SHUT_WR)` announces no more bytes in the *client->server* direction, yet the reverse direction can still carry the echo, as shown in @fig-halfclose @linux-shutdown.

== How does a blocking server support concurrent clients?

A blocking call suspends one execution context, not every process. Independent children allow B to progress while A waits; @fig-io-contexts clarifies this without claiming process-per-connection scales well.

== Why could fork duplicate a printed line?

An unflushed user-space `std::cout` buffer is copied along with address-space state. Both processes can later flush the same pending bytes, as distinguished in @fig-buffers @linux-fork.

== What does successful `send_all()` establish?

It establishes that the attempted byte range was accepted locally in positive `send()` steps, not that the peer application consumed or persisted those bytes @linux-send.

== Does `listen(10)` mean ten simultaneous clients?

No. On current Linux, backlog concerns already established connections waiting for `accept()`, not all previously accepted and actively serviced clients. It is additionally subject to system limits @linux-listen.

= References
#bibliography("m0_references.bib", title: none, style: "ieee")

