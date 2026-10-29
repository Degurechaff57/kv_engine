#set page(
  paper: "a4",
  margin: (x: 2.3cm, top: 2.2cm, bottom: 2.2cm),
  header: context {
    if here().page() > 1 [
      #set text(size: 8pt, font: ("Helvetica", "Arial"), fill: rgb("#94a3b8"))
      #grid(
        columns: (1fr, auto),
        [Clean Blog Style · Editorial Tech Notes],
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

// Headings in clean modern sans-serif
#show heading.where(level: 1): it => [
  #v(14pt)
  #text(font: ("Helvetica", "Arial"), size: 13.5pt, weight: "bold", fill: rgb("#0f172a"))[#it.body]
  #v(3pt)
]
#show heading.where(level: 2): it => [
  #v(11pt)
  #text(font: ("Helvetica", "Arial"), size: 11pt, weight: "bold", fill: rgb("#1e293b"))[#it.body]
  #v(2.5pt)
]
#show heading.where(level: 3): it => [
  #v(10pt)
  #text(font: ("Helvetica", "Arial"), size: 10pt, weight: "bold", fill: rgb("#475569"))[#it.body]
  #v(2pt)
]

// Code Block: Clean Editorial Style (Soft Charcoal + Violet Tab)
#show raw.where(block: true): it => block(
  width: 100%,
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

// Inline code: Soft violet/lavender badge
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

// Blockquote / Key Takeaway box
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

// Editorial Note Box
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

// -------------------------------------------------------------
// DOCUMENT CONTENT
// -------------------------------------------------------------

// Header Category Badge
#box(
  fill: rgb("#f5f3ff"),
  inset: (x: 8pt, y: 3pt),
  radius: 12pt,
  stroke: 0.5pt + rgb("#ddd6fe"),
  [#text(size: 8pt, weight: "bold", font: ("Helvetica", "Arial"), fill: rgb("#7c3aed"))[AI WORKFLOWS & SYSTEMS ESSAY]]
)

#v(8pt)
#text(size: 21pt, weight: "bold", font: ("Helvetica", "Arial"), fill: rgb("#0f172a"))[
  Style 05: Clean Substack & Editorial Blog
]

#v(4pt)
#text(size: 10.5pt, font: ("Helvetica", "Arial"), fill: rgb("#64748b"))[
  A visual showcase of editorial typography, soft accents, code presentation, and reading flow.
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
      Published: Sept 2025 · 6 min read · #link("https://github.com/degurechaff57")[GitHub] · #link("https://arxiv.org")[ArXiv]
    ]
  ]
)

#v(6pt)
#line(length: 100%, stroke: 0.5pt + rgb("#f1f5f9"))
#v(8pt)

= 1. Reading Experience & Paragraph Flow

This template is crafted for *thoughtful long-form reading*, technical reflections, and conceptual deep dives. The body text is rendered in a warm, publication-grade serif font (`New Computer Modern`) paired with sharp sans-serif headings.

Text flows naturally with comfortable leading. Inline terminology like `PyTorch 2.0`, `torch.compile`, or `vLLM` is highlighted in gentle lavender pills that do not disrupt reading momentum. External hyperlinks are elegantly styled: #link("https://github.com/degurechaff57")[Explore Repository].

== 1.1 Conceptual Milestones
- *Algorithmic Determinism*: Isolating sources of non-associative floating point jitter.
- *Tool-Call Contracts*: Structuring LLM agent inputs with strict schema validation.
- *Observability Loops*: Continuous monitoring of production latency distributions.

= 2. Code Block Presentation (Charcoal + Lavender Accent)

Code snippets sit in a minimalist charcoal card with an understated language label, designed to blend harmoniously with editorial prose:

```rust
// Rust implementation: Asynchronous batch queue worker
pub async fn process_log_batch(
    &self, 
    entries: Vec<RaftEntry>
) -> Result<usize, ConsensusError> {
    let batch_size = entries.len();
    let index = self.raft.propose_batch(entries).await?;
    
    // Asynchronously submit completion queue entry to io_uring
    self.wal_writer.push_ring_buffer(index).await?;
    Ok(batch_size)
}
```

```python
# Python implementation: PyTorch Custom Attention Decoder
import torch
import torch.nn.functional as F

def paged_kv_attention(q: torch.Tensor, k_cache: torch.Tensor, v_cache: torch.Tensor):
    """Calculates scaled dot-product attention over segmented KV pages."""
    scale = 1.0 / (q.shape[-1] ** 0.5)
    scores = torch.matmul(q, k_cache.transpose(-1, -2)) * scale
    attn_weights = F.softmax(scores, dim=-1)
    return torch.matmul(attn_weights, v_cache)
```

= 3. Editorial Callouts & Key Takeaways

#takeaway(title: "Core Engineering Takeaway")[
  Useful software built on stochastic models requires treating prompts not as creative prose, but as typed function contracts with formal schema validation and deterministic regression test suites.
]

#v(4pt)
#note(title: "Practical Observation")[
  When deploying multi-turn agents, unconstrained conversation histories compound drift exponentially. Rolling context summarization prevents state degradation.
]

= 4. Mathematical Expressions

Mathematical formulations flow seamlessly alongside narrative prose without harsh font contrasts:

$ cal(L)_("total") = cal(L)_("CE")(y, hat(y)) + lambda sum_(l=1)^L ||bold(W)_l||_F^2 + gamma frac(1, B) sum_(i=1)^B "KL"(p_i || q_i) $

= 5. Minimalist Editorial Table

Tables in this style adopt a clean booktabs layout with horizontal separation rules and no vertical borders:

#align(center)[
  #table(
    columns: (1.4fr, 1fr, 1fr, 1fr),
    inset: 7pt,
    stroke: (x, y) => if y == 0 { (bottom: 1.2pt + rgb("#0f172a"), top: 1.2pt + rgb("#0f172a")) } else if y == 3 { (bottom: 1.2pt + rgb("#0f172a")) } else { (bottom: 0.5pt + rgb("#f1f5f9")) },
    align: (left, center, center, center),
    table.header(
      [*Runtime Engine*], [*Throughput (qps)*], [*p50 Latency*], [*p99 Latency*]
    ),
    [RocksDB + Epoll], [62,000], [0.85 ms], [3.82 ms],
    [Pipelined Raft (epoll)], [118,000], [0.42 ms], [1.95 ms],
    [*TurboKV (io_uring)*], [*184,000*], [*0.24 ms*], [*0.82 ms*],
  )
]
