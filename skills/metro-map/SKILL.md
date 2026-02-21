---
name: metro-map
description: Generate an nf-core metro map (subway-style pipeline diagram) using nf-metro. Use when the user wants to visualize a pipeline, create a metro map, generate a subway plot, or produce a workflow diagram from a Nextflow DAG.
argument-hint: "[pipeline-dir | dag.mmd]"
disable-model-invocation: true
allowed-tools:
  - Bash(pip install nf-metro*)
  - Bash(nf-metro *)
  - Bash(nextflow run * -preview -with-dag *)
  - Bash(nextflow run * -with-dag *)
  - Bash(conda run -n nf-core *)
  - Read
  - Edit
  - Write
  - Glob
  - Grep
---

# Metro Map Generator

Generate subway-style metro maps for nf-core/Nextflow pipelines using [nf-metro](https://github.com/pinin4fjords/nf-metro).

## Quick Commands

```bash
# One-step: DAG straight to SVG
nextflow run . -preview -with-dag dag.mmd
nf-metro render dag.mmd -o metro.svg --from-nextflow --title "My Pipeline"

# Two-step: DAG → editable .mmd → SVG (recommended for quality maps)
nextflow run . -preview -with-dag dag.mmd
nf-metro convert dag.mmd -o pipeline.mmd --title "My Pipeline"
nf-metro validate pipeline.mmd
nf-metro render pipeline.mmd -o metro.svg
```

## Process

### Step 1: Ensure nf-metro Is Installed

```bash
pip install nf-metro
nf-metro --version
```

### Step 2: Generate the Nextflow DAG

Run the pipeline in preview mode to produce a Mermaid DAG without executing tasks:

```bash
nextflow run . -preview -with-dag dag.mmd
```

If the pipeline requires parameters, supply a minimal params file or profile:

```bash
nextflow run . -preview -with-dag dag.mmd -profile test
nextflow run . -preview -with-dag dag.mmd -params-file params.yml
```

The output `dag.mmd` is a `flowchart TB` Mermaid file — this is **not** directly renderable by nf-metro. It must be converted first (Step 3) or rendered with `--from-nextflow` (Step 4).

### Step 3: Convert DAG to nf-metro Format (Recommended)

The two-step workflow allows hand-tuning before rendering:

```bash
nf-metro convert dag.mmd -o pipeline.mmd --title "My Pipeline"
```

The converter:
- Drops non-process nodes (channels, operators)
- Reconnects edges through dropped nodes
- Breaks cycles
- Maps subworkflows to sections
- Detects bypass lines (edges spanning 2+ sections) and spur lines (dead-end processes)
- Assigns metro lines (longest path = "main", others auto-colored)
- Humanizes labels (SCREAMING_SNAKE → Title Case, abbreviates >16 chars)

### Step 4: Validate the Metro Map

Always validate before rendering:

```bash
nf-metro validate pipeline.mmd
```

Validation checks:
- All edges have `-->|line_id|` annotations
- All `line_id` values reference defined `%%metro line:` directives
- All station IDs referenced by sections exist
- No empty sections
- Correct Mermaid syntax

On success, prints station/edge/line/section counts. Exits with code 1 on failure.

Use `nf-metro info pipeline.mmd` for a structural summary (per-line and per-section breakdown).

### Step 5: Render the SVG

```bash
nf-metro render pipeline.mmd -o metro.svg
```

Key render options:

| Option | Default | Description |
|--------|---------|-------------|
| `--theme [nfcore\|light]` | `nfcore` | Visual theme (dark or light) |
| `--x-spacing FLOAT` | `60` | Horizontal spacing between layers |
| `--y-spacing FLOAT` | `40` | Vertical spacing between tracks |
| `--max-layers-per-row INT` | auto (~15) | Fold threshold for serpentine layout |
| `--animate / --no-animate` | off | Animated balls traveling along lines |
| `--debug / --no-debug` | off | Debug overlay (ports, hidden stations, waypoints) |
| `--logo PATH` | none | Logo image (overrides title text) |
| `--line-order [definition\|span]` | from file | Track ordering strategy |

Generate both theme variants:

```bash
nf-metro render pipeline.mmd -o metro_dark.svg --theme nfcore --logo logo_dark.png
nf-metro render pipeline.mmd -o metro_light.svg --theme light --logo logo_light.png
```

### Step 6: Inspect for Collisions

After rendering, **read the SVG file** and inspect for visual collisions:

1. **Label overlaps** — labels overlapping other labels or station pills
2. **Line crossings** — routes crossing through section boxes or labels
3. **Section crowding** — sections packed too tightly, labels clipped at edges
4. **Truncated labels** — important process names cut off or abbreviated poorly

Use debug mode to diagnose layout issues:

```bash
nf-metro render pipeline.mmd -o metro_debug.svg --debug
```

Debug mode shows hidden stations, port positions, and edge waypoints.

### Step 7: Fix Collisions — Iterative Refinement

If collisions are found, apply fixes in the `.mmd` file and re-render. Work through these strategies in order:

#### 7a. Adjust Spacing (easiest, no .mmd edits)

```bash
# More horizontal room between stations
nf-metro render pipeline.mmd -o metro.svg --x-spacing 80

# More vertical room between tracks
nf-metro render pipeline.mmd -o metro.svg --y-spacing 55

# Combine both
nf-metro render pipeline.mmd -o metro.svg --x-spacing 80 --y-spacing 55
```

#### 7b. Shorten or Rewrite Labels

Edit station labels in the `.mmd` file to reduce collisions:

```mermaid
%% Before: long label causes overlap
FASTQC[FastQC Quality Control Analysis]

%% After: shorter label fits
FASTQC[FastQC]
```

Use multi-line labels for important but long names:

```mermaid
TRIMGALORE[Trim\nGalore]
```

#### 7c. Relocate Sections with Grid Directives

Override automatic section placement when sections collide or the layout is suboptimal:

```mermaid
%%metro grid: preprocessing | 0,0
%%metro grid: alignment | 1,0
%%metro grid: variant_calling | 2,0
%%metro grid: reporting | 2,1
```

Grid format: `section_id | col,row[,rowspan[,colspan]]`

Use rowspan/colspan for large sections:

```mermaid
%%metro grid: main_workflow | 0,0,1,2
%%metro grid: qc | 2,0
%%metro grid: reporting | 2,1
```

#### 7d. Control Section Flow Direction

Change internal flow direction to reduce width or height:

```mermaid
subgraph preprocessing[Preprocessing]
  %%metro direction: TB
  %% Stations flow top-to-bottom instead of left-to-right
end
```

Directions: `LR` (left-to-right, default), `RL` (right-to-left, for serpentine folds), `TB` (top-to-bottom, compact vertical layout).

#### 7e. Control Port Placement

Fix inter-section routing issues by specifying entry/exit sides:

```mermaid
subgraph alignment[Alignment]
  %%metro entry: left | main
  %%metro exit: right | main
  %%metro exit: bottom | qc_line
end
```

Sides: `left`, `right`, `top`, `bottom`. Comma-separate multiple line IDs per port.

#### 7f. Use Hidden Stations for Better Routing

Insert hidden stations (prefix with `_`) to create better branch points:

```mermaid
%% Hidden junction for cleaner fan-out
_branch[ ]
PROCESS_A[Process A]
PROCESS_B[Process B]
_branch -->|main| PROCESS_A
_branch -->|qc_line| PROCESS_B
```

Hidden stations participate in layout and routing but render no marker or label.

#### 7g. Adjust Line Ordering

Control which lines get inner vs outer tracks:

```mermaid
%%metro line_order: span
```

- `definition` — preserves order from the `.mmd` file (first-defined = innermost)
- `span` — longest-spanning lines get inner tracks (often cleaner)

Or use `--line-order span` on the CLI.

#### 7h. Change Fold Threshold

For wide pipelines, control when sections wrap to the next row:

```bash
# Wrap after 10 layers instead of default ~15
nf-metro render pipeline.mmd -o metro.svg --max-layers-per-row 10
```

### Step 8: Re-validate and Re-render

After every edit, always re-validate before re-rendering:

```bash
nf-metro validate pipeline.mmd && nf-metro render pipeline.mmd -o metro.svg
```

Repeat Steps 6–8 until no collisions remain.

## Mermaid Directive Reference

### Global Directives (before `graph LR`)

| Directive | Example |
|-----------|---------|
| `%%metro title: <text>` | `%%metro title: nf-core/rnaseq` |
| `%%metro logo: <path>` | `%%metro logo: docs/images/logo.png` |
| `%%metro style: <dark\|light>` | `%%metro style: dark` |
| `%%metro line: <id> \| <name> \| <#hex>` | `%%metro line: main \| Main \| #2db572` |
| `%%metro grid: <id> \| <col>,<row>[,rs,cs]` | `%%metro grid: qc \| 1,1` |
| `%%metro legend: <position>` | `%%metro legend: br` |
| `%%metro line_order: <definition\|span>` | `%%metro line_order: span` |
| `%%metro file: <station> \| <label>` | `%%metro file: OUT_BAM \| BAM` |

### Section Directives (inside `subgraph`)

| Directive | Example |
|-----------|---------|
| `%%metro entry: <side> \| <lines>` | `%%metro entry: left \| main,qc` |
| `%%metro exit: <side> \| <lines>` | `%%metro exit: right \| main` |
| `%%metro direction: <LR\|RL\|TB>` | `%%metro direction: TB` |

### Station Syntax

| Pattern | Description |
|---------|-------------|
| `ID[Label]` | Standard station |
| `ID([Label])` | Stadium-shaped station |
| `ID[Line 1\\nLine 2]` | Multi-line label |
| `_ID[ ]` | Hidden station (routing only) |
| `ID[ ]` + `%%metro file: ID \| Label` | File terminus with document icon |

### Edge Syntax

```mermaid
SOURCE -->|line_id| TARGET
SOURCE -->|line1,line2| TARGET
```

Edges between sections must be placed **outside** all `subgraph`/`end` blocks.

## Collision Fix Checklist

When inspecting the rendered SVG, check for and resolve these issues:

- [ ] **Label-label overlaps** — shorten labels, increase `--y-spacing`, or use multi-line labels
- [ ] **Label-station overlaps** — increase `--x-spacing` or shorten adjacent labels
- [ ] **Section overlap** — add `%%metro grid:` directives with explicit positions
- [ ] **Route crossing labels** — add hidden stations, adjust port sides, or change section direction
- [ ] **Clipped labels at section edges** — increase spacing or shorten labels
- [ ] **Cramped sections** — use `%%metro direction: TB` for narrow sections, add rowspan/colspan
- [ ] **Too many line crossings** — try `%%metro line_order: span` or reorder line definitions
- [ ] **Pipeline too wide** — reduce `--max-layers-per-row` to enable serpentine folding
