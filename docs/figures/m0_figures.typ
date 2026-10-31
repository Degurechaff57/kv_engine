// Original, editable diagrams redrawn using Fletcher 0.5.8 and CeTZ 0.5.3.
// Package choices and call conventions follow Gang_Liu_Typst_Diagram_Toolkit.
#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "@preview/cetz:0.5.3" as cetz

#let ink = rgb("#334155")
#let blue = rgb("#2962A3")
#let pale = rgb("#EAF4FF")
#let green = rgb("#EAF8F0")
#let purple = rgb("#F3E8FF")

// Figure body only; figure caption and label belong to the main document.
#let tcp-stream() = cetz.canvas({
  import cetz.draw: *
  rect((0, 2), (2.6, 3), fill: pale, stroke: blue)
  content((1.3, 2.5), [`send("ABC")`])
  rect((3, 2), (5.7, 3), fill: pale, stroke: blue)
  content((4.35, 2.5), [`send("DEF")`])
  line((1.3, 1.95), (1.3, 1.45), stroke: ink, mark: (end: ">"))
  line((4.35, 1.95), (4.35, 1.45), stroke: ink, mark: (end: ">"))
  rect((0, 0.45), (5.7, 1.35), fill: rgb("#F1F5F9"), stroke: ink)
  content((2.85, 0.9), [`ABCDEF` — ordered stream])
  line((2.85, 0.4), (2.85, -0.15), stroke: ink, mark: (end: ">"))
  rect((0, -1.25), (2, -0.3), fill: green, stroke: rgb("#2E8063"))
  content((1, -0.78), [`recv`: `AB`])
  rect((2.35, -1.25), (5.7, -0.3), fill: green, stroke: rgb("#2E8063"))
  content((4.025, -0.78), [`recv`: `CDEF`])
})

#let socket-lifecycle() = diagram(
  cell-size: 24mm,
  node-stroke: 0.75pt + blue,
  node-fill: pale,
  edge-stroke: 0.85pt + ink,
  node((0,0), [`getaddrinfo()`], corner-radius: 3pt),
  node((1,0), [`socket()`], corner-radius: 3pt),
  node((2,0), [`bind()`], corner-radius: 3pt),
  node((3,0), [`listen()`], corner-radius: 3pt),
  edge((0,0),(1,0),"-|>"),
  edge((1,0),(2,0),"-|>"),
  edge((2,0),(3,0),"-|>"),
  node((3,1), [`accept()`], corner-radius: 3pt),
  node((2,1), [connected FD], corner-radius: 3pt),
  node((1,1), [`fork()`], corner-radius: 3pt),
  node((0,1), [child echo], corner-radius: 3pt),
  edge((3,0),(3,1),"-|>"),
  edge((3,1),(2,1),"-|>"),
  edge((2,1),(1,1),"-|>"),
  edge((1,1),(0,1),"-|>"),
)

#let fd-kernel() = diagram(
  spacing: 1pt,
  cell-size: 21mm,
  node-stroke: 0.75pt + blue,
  node-fill: pale,
  edge-stroke: 0.85pt + ink,
  node((0,0), [userspace `int fd = 4`], corner-radius: 3pt),
  node((0,1), [task `files_struct`], corner-radius: 3pt),
  node((0,2), [`fdtable` (`fd[4]`)], corner-radius: 3pt),
  node((0,3), [`struct file`], corner-radius: 3pt),
  node((0,4), [`struct socket`], corner-radius: 3pt),
  node((0,5), [`struct sock` (TCP state)], corner-radius: 3pt),
  edge((0,0),(0,1),"-|>"),
  edge((0,1),(0,2),"-|>"),
  edge((0,2),(0,3),"-|>"),
  edge((0,3),(0,4),"-|>"),
  edge((0,4),(0,5),"-|>"),
  node((1.8,2), [other FDs: files, pipes, epoll], corner-radius: 3pt),
  edge((0,2),(2,2),"-|>"),
)

#let io-contexts() = diagram(
  cell-size: 28mm,
  node-stroke: 0.75pt + blue,
  node-fill: pale,
  edge-stroke: 0.85pt + ink,
  node((0,0), [parent blocks\ in `accept()`], corner-radius: 3pt),
  node((1,0), [child A blocks\ in `recv()`], corner-radius: 3pt),
  node((2,0), [child B handles\ active client], corner-radius: 3pt),
  node((1,1), [separate scheduling contexts], corner-radius: 3pt),
  edge((0,0),(1,1),"-|>"),
  edge((1,0),(1,1),"-|>"),
  edge((2,0),(1,1),"-|>"),
)

#let child-reaping() = diagram(
  cell-size: 24mm,
  node-stroke: 0.75pt + blue,
  node-fill: pale,
  edge-stroke: 0.85pt + ink,
  node((0,0), [child exits], corner-radius: 3pt),
  node((1,0), [`SIGCHLD`], corner-radius: 3pt),
  node((2,0), [handler], corner-radius: 3pt),
  edge((0,0),(1,0),"-|>"),
  edge((1,0),(2,0),"-|>"),
  node((2,1), [`waitpid(-1, ..., WNOHANG)`], corner-radius: 3pt),
  node((1,1), [repeat while `pid > 0`], corner-radius: 3pt),
  node((0,1), [no waitable child: return], corner-radius: 3pt),
  edge((2,0),(2,1),"-|>"),
  edge((2,1),(1,1),"-|>"),
  edge((1,1),(0,1),"-|>"),
)

#let fork-ownership() = diagram(
  spacing: 1pt,
  cell-size: 25mm,
  node-stroke: 0.75pt + blue,
  node-fill: pale,
  edge-stroke: 0.85pt + ink,
  node((1,0), [parent accepts `conn_fd`], corner-radius: 3pt),
  node((1,1), [`fork()` duplicates FD entries], corner-radius: 3pt),
  node((0,2), [parent: close `conn_fd`], corner-radius: 3pt),
  node((2,2), [child: close `listen_fd`], corner-radius: 3pt),
  node((0,3), [parent: next `accept()`], corner-radius: 3pt),
  node((2,3), [child: `recv()` / `send_all()`], corner-radius: 3pt),
  node((2,4), [child: close `conn_fd`; exit], corner-radius: 3pt),
  node((1,5), [parent reaps with `waitpid()`], corner-radius: 3pt),
  edge((1,0),(1,1),"-|>"),
  edge((1,1),(0,2),"-|>"),
  edge((1,1),(2,2),"-|>"),
  edge((0,2),(0,3),"-|>"),
  edge((2,2),(2,3),"-|>"),
  edge((2,3),(2,4),"-|>"),
  edge((2,4),(1,5),"-|>"),
)

#let buffers() = cetz.canvas({
  import cetz.draw: *
  rect((0, 1), (3.6, 2.1), fill: pale, stroke: blue)
  content((1.8, 1.55), [user `std::cout` buffer])
  rect((4.4, 1), (8, 2.1), fill: green, stroke: rgb("#2E8063"))
  content((6.2, 1.55), [kernel FD / output])
  line((3.65, 1.55), (4.35, 1.55), mark: (end: ">"), stroke: ink)
  rect((0, -1.3), (3.6, -0.2), fill: purple, stroke: rgb("#7c3aed"))
  content((1.8, -0.75), [user `recv` array (100 B)])
  rect((4.4, -1.3), (8, -0.2), fill: green, stroke: rgb("#2E8063"))
  content((6.2, -0.75), [kernel TCP socket buffers])
  line((4.35, -0.75), (3.65, -0.75), mark: (end: ">"), stroke: ink)
})

#let half-close() = diagram(
  spacing: 1pt,
  cell-size: 29mm,
  node-stroke: 0.75pt + blue,
  node-fill: pale,
  edge-stroke: 0.85pt + ink,
  node((0,0), [client `send()`], corner-radius: 3pt),
  node((1,0), [server `recv()`], corner-radius: 3pt),
  node((0,1), [client `shutdown(SHUT_WR)`], corner-radius: 3pt),
  node((1,1), [server drains to EOF], corner-radius: 3pt),
  node((1,2), [server sends echo], corner-radius: 3pt),
  node((0,2), [client still `recv()`s], corner-radius: 3pt),
  edge((0,0),(1,0),"-|>"),
  edge((0,0),(0,1),"-|>"),
  edge((0,1),(1,1),"-|>"),
  edge((1,1),(1,2),"-|>"),
  edge((1,2),(0,2),"-|>"),
)
