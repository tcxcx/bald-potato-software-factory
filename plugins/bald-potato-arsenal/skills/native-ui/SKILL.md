---
name: native-ui
description: Authoring guide for the Native markup (.native) view tier of native-rendered Native SDK apps. TypeScript cores are the default and use this skill together with ts-core; Zig cores are an explicit alternative and this guide labels their lower-level UiApp recipes. Use when building or modifying native UI (widgets, layout, bindings, messages), writing .native files, wiring views to Model/Msg/update, testing markup views, or verifying a native app through the automation harness.
---

# Author native UI with Native markup

A native-rendered Native SDK app is a markup view plus an app core. The primary authoring path is:

- `src/app.native` — the entire UI: elements, layout, bindings, message dispatch.
- `src/core.ts` — `Model`, the discriminated `Msg` union, `update(model, msg)`, effects, subscriptions, and derived binding helpers.
- `app.zon` — identity, windows, assets, permissions, and policy.

The TypeScript core is checked and compiled ahead of time to native code; no JS runtime ships in the binary. Load `native skills get ts-core` beside this skill for every default app implementation. A Zig core (`src/main.zig`) is first-class when explicitly selected with `native init --template zig-core`; the Zig-only wiring, builder, and runtime-extension recipes below are labeled so they are not mistaken for the default.

The markup compiles to the same widget tree a hand-written `canvas.Ui(Msg)` builder view would produce: identical structural widget ids, identical typed handler table. Markup can never mutate state — it binds values and dispatches messages; all logic lives in the app core, whichever core language the existing tree uses.

Editors highlight `.native` markup well in HTML mode — the default scaffold writes no editor config, so add `.vscode/settings.json` with `"files.associations": {"*.native": "html"}` yourself, or scaffold with `native init --full`, which writes it.

Start a new app with `native init` (zero-config: `app.zon` + `src/core.ts` + `src/app.native` + assets; the CLI generates the build graph). Use `examples/chatbot`, `examples/soundboard`, and `examples/system-monitor` as substantial TypeScript references. The `native check|dev|test|build` verbs drive any app directory shaped this way.

## Menu-bar status items (TypeScript default)

Export `statusItem(model: Model): StatusItemState` from `src/core.ts`. The generated launcher installs icon/tooltip/click-open commands plus the boot presentation/menu, re-derives it after every committed update, and patches presentation/menu independently. Import `StatusItemState` from `@native-sdk/core/events`. Commands route through the core's `commandMsg(name): Msg | null` export. There is no app-owned Zig wiring and `statusItem` is automatically marked shell-bound for the markup lint.

```ts
import { asciiBytes, utf8Bytes } from "@native-sdk/core";
import { type StatusItemState } from "@native-sdk/core/events";

export function statusItem(model: Model): StatusItemState {
  return {
    iconPath: asciiBytes("assets/menu-bar.svg"),
    tooltip: utf8Bytes("Player status"),
    activationCommand: asciiBytes("app.refresh"),
    alternateActivationCommand: asciiBytes("player.toggle"),
    openCommand: asciiBytes("app.refresh"),
    presentation: { title: model.playing ? utf8Bytes("MB PLAY") : utf8Bytes("MB"), width: 62, tone: "normal", iconOpacity: 1, monospaced: true, fontSize: 13, fontWeight: "semibold" },
    items: [
      { id: 1, label: utf8Bytes("Open"), command: asciiBytes("app.open"), separator: false, enabled: true, detail: asciiBytes(""), role: "command", key: asciiBytes(""), modifiers: { primary: false, command: false, control: false, option: false, shift: false } },
      { id: 0, label: asciiBytes(""), command: asciiBytes(""), separator: true, enabled: false, detail: asciiBytes(""), role: "command", key: asciiBytes(""), modifiers: { primary: false, command: false, control: false, option: false, shift: false } },
      { id: 2, label: model.playing ? utf8Bytes("Pause") : utf8Bytes("Play"), command: asciiBytes("player.toggle"), separator: false, enabled: true, detail: utf8Bytes("configured ✓"), role: "agent", key: asciiBytes(""), modifiers: { primary: false, command: false, control: false, option: false, shift: false } },
    ],
  };
}
```

Presentation fields style the persistent menu-bar item. Inside its dropdown, `metric` carries prominent primary/secondary text, `segmented` carries up to eight typed command options, and `chart` carries 1–32 bounded values with captions and accessibility. These are generic composable row payloads, not text conventions.

## App wiring (Zig cores and extensions only)

A default TypeScript app writes none of this: generated wiring connects `src/core.ts`, `src/app.native`, and `app.zon`. Use the following only when the existing app has a Zig core or the task explicitly requires owned runtime wiring.

```zig
const HabitsApp = native_sdk.UiApp(Model, Msg);

pub fn main(init: std.process.Init) !void {
    // `create` heap-allocates the multi-MB app struct and constructs the
    // Model in place — neither ever rides the stack (avoid `App.init(alloc,
    // model, ...)`: its by-value Model is a stack-overflow trap once the
    // Model grows).
    const app_state = try HabitsApp.create(std.heap.page_allocator, .{
        .name = "habits",
        .scene = shell_scene,             // one window, one gpu_surface view
        .canvas_label = "habits-canvas",  // must match the ShellView label
        .update = update,
        .markup = .{
            .source = @embedFile("app.native"),
            .watch_path = "src/app.native", // dev hot reload; omit in release
            .io = init.io,
        },
    });
    defer app_state.destroy();
    app_state.model = initialModel(); // boot state: assign through the pointer
    try runner.runWithOptions(app_state.app(), .{ ... }, init);
}
```

(`create` requires every Model field to carry a default; the model starts as `.{}` and boot state is assigned through the returned pointer. Tests that instantiate the app per fixture should use `create`/`destroy` too — a runtime-built Model passed to `init` by value crashes the test stack once models get large.)

The runtime owns the loop: install on first GPU frame, presentation, resize, pointer/keyboard dispatch into `update` + rebuild. With `watch_path` set, editing the `.native` file while the app runs hot-reloads the view within ~2s, preserving model state and widget ids; parse failures keep the last good view and set `app_state.markup_diagnostic` (line/column/message).

**Release: compile the markup at comptime.** `canvas.CompiledMarkupView(Model, Msg, source).build` parses the `.native` source entirely at compile time and produces the identical tree (same ids, handlers, dispatch) with no parser in the binary; markup or binding mistakes become compile errors with line/column. Hand it to `.view`, and gate the runtime engine per build mode:

```zig
const dev = @import("builtin").mode == .Debug;
const App = native_sdk.UiAppWithFeatures(Model, Msg, .{ .runtime_markup = dev });
const CompiledView = canvas.CompiledMarkupView(Model, Msg, @embedFile("app.native"));
// options:
.view = CompiledView.build,
.markup = if (dev) .{ .source = ..., .watch_path = "src/app.native", .io = init.io } else null,
```

With both set (dev), the compiled view renders until the watched file first changes, then the interpreter hot-reloads it. See the native reference fixture in `tests/ts-core/habits_reference.zig` for this Zig wiring pattern.

### Webview panes: canvas + live web content in one window

For TypeScript apps, export `webPanes(model: Model): readonly WebViewPane[]` from `core.ts`. Import the descriptor from `@native-sdk/core/events`; return `label`, nullable `anchor`, `url`, `x`, `y`, `width`, `height`, and `reloadToken`. The label identifies an existing manifest WebView; the anchor identifies a widget label such as `<panel label="preview-pane" grow="1"/>`. See `examples/canvas-preview` for pane, frame, and tray coordination in one compiled core. The native adapter copies bytes and validates finite geometry and safe integer tokens; the OS owns WebView hosting and navigation policy.

For all u64 reload states, return `readonly ExactWebViewPane[]` instead. Its `reloadToken` is decimal ASCII bytes; the host validates the full u64 range without rounding. `WebViewPane` retains its existing safe-number token.

### TypeScript terminal panes

Bind `<terminal pty="{shellKey}" scrollback="{scrollback}" on-terminal="terminalChanged" label="Shell" autofocus="true" grow="1"/>` to a `Uint8Array` helper or field naming the same key as `Cmd.ptySpawn`. Import `TerminalState` from `@native-sdk/core/events` for the message payload. The native host resolves the name to its PTY capability; engine identities never cross through a JavaScript number. Both view backends preserve the complete four-field state report. A bound slot remains reserved through exit until app teardown, keeping the ended screen stable across rebuilds. Restarting the same name reuses its slot; the existing four-slot budget applies. Keep `.terminal_sessions = true` and the lazy Ghostty pin in the app's owned build, as in `examples/workbench`. Native integer PTY bindings remain supported.

For Zig cores and extensions:

Declare the webview in the scene next to the gpu_surface (parent it to the canvas view), reserve its region with an empty panel carrying a semantics label, and let `Options.web_panes` snap the webview to that widget's layout frame while the model drives navigation:

```zig
const shell_views = [_]native_sdk.ShellView{
    .{ .label = "app-canvas", .kind = .gpu_surface, .fill = true, .gpu_backend = .metal },
    .{ .label = "preview", .kind = .webview, .parent = "app-canvas", .url = "https://example.com/", .x = 240, .y = 76, .width = 704, .height = 548 },
};
// view: ui.panel(.{ .grow = 1, .semantics = .{ .label = "preview-pane" } }, .{})
fn panes(model: *const Model, out: []App.WebViewPane) usize {
    out[0] = .{ .label = "preview", .anchor = "preview-pane", .url = model.url(), .reload_token = model.reload_token };
    return 1;
}
// options: .web_panes = panes,
```

URL changes navigate; bumping `reload_token` reloads the same URL (the CenterPane/Preview-tab shape). Pane URLs must pass `security.navigation.allowed_origins`. Panes reconcile against the runtime's live webview state on every rebuild and presented frame, so shell relayouts cannot detach them. `examples/canvas-preview` is the live reference; `zig build test-canvas-preview-smoke` verifies it.

### Menu-bar extra (status item)

This is the Zig-core/custom-wiring form. Default TypeScript apps use the exported `statusItem(model)` helper above.

`Options.status_item` installs a macOS `NSStatusItem` once, on the installing frame; its menu items dispatch commands through the same `on_command` mapping the toolbar and menus use (source `.tray`):

```zig
.status_item = .{ .title = "ZN", .tooltip = "My App", .items = &.{
    .{ .id = 1, .label = "Refresh", .command = "app.refresh" },
    .{ .separator = true },
    .{ .id = 2, .label = "Quit", .command = "app.quit" },
} },
```

For a LIVE menu-bar extra (an open-count badge in the title, a latest-items dropdown), add `Options.status_item_fn` — the `web_panes` pattern: consulted on install and after every rebuild, re-applied only when its output changed (title and menu patch independently; the static `status_item` keeps icon/tooltip). Format derived strings into the provided scratch; item `command`s dispatch through `on_command` exactly like static items:

```zig
fn statusItem(model: *const Model, scratch: *App.StatusItemScratch) App.StatusItemState {
    const title = std.fmt.bufPrint(&scratch.title_buffer, "ZN {d}", .{model.open_count}) catch "ZN";
    scratch.items[0] = .{ .id = 1, .label = "Refresh", .command = "app.refresh" };
    var count: usize = 1;
    for (model.latest(), 0..) |issue, i| { // per-row commands: map "issue.select.N" in on_command
        scratch.items[count] = .{ .id = @intCast(10 + i), .label = issue.title, .command = issue.select_command };
        count += 1;
    }
    return .{ .title = title, .items = scratch.items[0..count] };
}
// options: .status_item_fn = statusItem,
```

Title updates retitle the live `NSStatusItem` button without re-creating it; platforms without a tray-title seam keep menu updates and log the title gap once.

### Windowed lists in markup

Use `<virtual-window>` to resolve one retained range before rendering, then `<virtual-list>` to request only its rendered rows. The window declares a stable literal `id`, an `as` range name, an `item-count`, and either `item-extent` or an exported Model-first `extent-estimate` helper. Optional `gap`, `overscan`, `viewport-fallback`, `index-base`, and `anchor="leading|trailing"` describe the complete content geometry.

```html
<virtual-window id="records" as="range" item-count="{loaded}" item-extent="48" overscan="4">
  <column>
    <virtual-list window="range" each="rows" as="row" grow="1" label="Records">
      <list-item key="{row.id}" focusable="true" on-press="select:{row.id}">{row.title}</list-item>
    </virtual-list>
    <status-bar>{range.first_visible_index}–{range.last_visible_index}</status-bar>
  </column>
</virtual-window>
```

In a TypeScript core, `rows(model: Model, range: VirtualListRange): readonly Row[]` takes the complete SDK range from `@native-sdk/core/events` and returns exactly `range.end_index - range.start_index` rows in rendered-index order. An extent estimator has shape `rowExtent(model: Model, index: number): number`; its retained identity survives rebuilds. Each row has one keyed root. Ordinary scroll styling, `on-scroll`, and reach-start/end messages belong on `virtual-list`.

Each window has one root and exactly one consuming list; windows cannot nest. A range can pass through a template argument, and secondary window views have their own retained descriptors. The full range exposes visible and rendered bounds, content extent, row extent, and offset; use it for footer text without copying scroll state into the model. See `examples/feed` for variable-height estimates, stable row queries, and retained selection.

### Native scrolling (macOS)

Zero app code: on macOS every non-virtualized `scroll` region — and every windowed virtual list (`ui.virtualList`), whose driver content size is the full virtual extent — is driven by an invisible `NSScrollView` — OS momentum and the system overlay scrollbar — while the engine renders the content. `widget.value` stays the offset of record, so the rebuild reconcile rule ("user offset survives rebuilds until the source offset changes"), automation snapshot offsets (`scroll=[offset=..]`), and `Options.sync` all work exactly as before; the engine-drawn scrollbar simply stops painting for natively driven regions. Programmatic scrolls still work: change the source offset (or scroll via keyboard/automation) and the runtime pushes it into the native scroller. GTK/Win32 and mobile embeds keep the engine's wheel physics unchanged. Nested-scroll saturation handoff (inner region exhausted, outer continues) is per-region native today: the inner region stops at its edge like a standalone scroller.

**Overscroll is off by default, per region, on both paths.** Scroll regions pin at their content edges — the native scroller gets non-elastic edges, the engine's wheel/kinetic physics clamp, and kinetic motion stops cleanly at the boundary. Bouncing is a per-region opt-in: `overscroll="rubber_band"` in markup (the `scroll` element only — the validator rejects it elsewhere with a teaching error) or `ElementOptions.overscroll = .rubber_band` in Zig views. The `ScrollPhysics.overscroll` design token (`ScrollPhysicsOverrides` in a theme) flips the app-wide default; per-region values override it, and `.none` pins a region regardless of the token. The rubber-band shape — excursion bound, resistance, spring-back rate — stays themable through the `rubberband_*` physics tokens.

### Context menus: one declared menu, platform-decided presentation

Authors write ONE menu; the platform decides how it presents. The default is the real OS context menu at the pointer — `NSMenu` on macOS, `TrackPopupMenu` on Windows, `GtkPopoverMenu` on Linux — and the selection dispatches the item's typed `Msg`. On hosts without a native menu presenter (the mobile toolkit hosts and embed hosts today), the SAME declared items present automatically as an anchored canvas surface at the click point, with the standard anchored-surface behavior (Escape and outside-click dismiss, late z-pass, window clipping). Never two authored menus, never a canvas imitation where the OS menu exists.

Markup declares the menu as a `<context-menu>` element — a DIRECT child of the interactive element whose right-click it answers (a hit-target kind, or an element made interactive by `on-press`/`on-double-press`/`on-toggle`/`on-hold`/`on-drag`). It is metadata, not content: it renders nothing in the row's flow. Children are `menu-item`s (`on-press` required, `disabled` optional, the text content is the label) and bare `<separator/>`s, with `if`/`else`/`for` around them to swap or repeat items — a menu whose items all evaporate at runtime simply declares no menu (the All Notes row pattern). Conditional MENUS are spelled as conditional ITEMS: the `<context-menu>` itself takes no attributes and cannot sit behind a structure tag. No submenus: the platform channel carries flat items (label, enabled, separator) only.

```html
<list-item on-press="open_note:{n.id}" label="{n.title}">
  <text grow="1">{n.title}</text>
  <context-menu>
    <if test="{n.deleted}">
      <menu-item on-press="restore_note:{n.id}">Restore</menu-item>
      <menu-item on-press="purge_note:{n.id}">Delete Permanently</menu-item>
    </if>
    <else>
      <menu-item on-press="copy_note_id:{n.id}">Copy</menu-item>
      <menu-item on-press="trash_note:{n.id}">Delete</menu-item>
    </else>
  </context-menu>
</list-item>
```

The compiled TypeScript view supports one direct menu with at most 32 labeled `menu-item` leaves and bare separators. Items require `on-press` and may bind `disabled`; structure tags inside menus currently remain on the native markup backend. The menu is copied into the native tree arena before the compiled result expires.

The Zig builder's mirror is `ElementOptions.context_menu` — per-widget items in the chrome-menu shape with typed messages:

```zig
ui.listItem(.{
    .on_press = Msg{ .select = entry.index },
    .context_menu = &.{
        .{ .label = "Open Section", .msg = Msg{ .select = entry.index } },
        .{ .separator = true },
        .{ .label = "Refresh Dashboard", .msg = .refresh },
    },
}, entry.title)
```

The deepest declaring widget on the hit route wins; disabled items and separators are fine (`enabled = false`, `.separator = true`). Zero-code defaults need no declaration: editable text fields present the standard Cut / Copy / Paste / Select All menu wired to the existing clipboard actions, and a selected static text presents Copy (these defaults are presenter-only — without an OS menu they degrade to the keyboard clipboard paths). Touch long-press is design-noted for the mobile embeds: the iOS host's under-slop `Pending` touch state is the timer seam, pending a secondary-button leg in the embed ABI and `UIEditMenuInteraction` presentation.

Automation drives the native path honestly: snapshots list every widget's declared items in invocation order (`context_menu=["Rename","Delete"]`, separators keep their slots, disabled items say so), `widget-context-press <view> <id>` performs the real secondary click (presenting the menu), and `widget-context-menu <view> <id> <item-index>` invokes an item — the selection dispatches as the same `context_menu_action` platform event a real pick produces; the journal records the complete widget invocation so replay reconstructs its pending request before selection, because the OS menu's tracking loop cannot be driven programmatically. Dead invocations fail by name (undeclared menu, index out of range, separator slot, disabled item). `examples/notes` row menus and `examples/gpu-dashboard` nav rows carry live menus; `zig build test-example-notes`, `test-example-gpu-dashboard`, and the runtime context-menu suite verify dispatch, the fallback surface, and the verb.

## Elements

| Markup | Widget | Notes |
| --- | --- | --- |
| `row`, `column` | flex containers | main axis horizontal / vertical |
| `stack`, `panel`, `card` | overlay containers | children stack on top of each other — `gap` can never space them and is a validation error (put a `column`/`row` inside for flow) |
| `scroll` | scroll_view | wrap multiple children in a `column` inside it |
| `list`, `grid` | list, grid | vertical stack / cell grid |
| `tabs`, `toggle-group`, `button-group`, `radio-group`, `breadcrumb`, `pagination` | row containers | children flow horizontally. Give every `radio-group` an accessible `label`; it is one logical `radiogroup`: descendant radios at any nesting depth share one Tab stop; arrows wrap while Home/End move to the edges, focus and selection move together, and selecting one clears the rest of the nearest group scope |
| `table` > `table-row` > `table-cell` | table, data_row, data_cell | rows only inside a table, cells only inside a row (for/if wrappers are fine); cells are text leaves, dispatch with `on-press` |
| `dropdown-menu` | dropdown_menu | vertical menu surface; children are `menu-item`s. `anchor="below\|above"` floats it against its PARENT's frame (see Pickers): late z-pass above the whole tree, window-clipped, auto-flipping at the window edges, zero flow space. Pair with `on-dismiss` |
| `accordion` | accordion | header via `text` attr; children show while `selected`, dispatch `on-toggle` |
| `alert`, `bubble` | surfaces | `alert` title via `text` attr; children stack inside. `bubble` hugs its message up to 80% of the thread (`ghost` exempt; explicit `width` wins) and takes one `<reactions>` child — the reaction pill straddling its bottom edge, one text run, dock via `text-alignment` (default `end`); `text=` on bubble itself is a teaching error (that channel belongs to the pill). Grouped runs are spacing, not vocabulary: 8 gap within a sender's run, 32 between turns |

---

> **Full Reference**: Read `references/FULL_SKILL.md` in this skill directory for the remaining sections of this skill.
