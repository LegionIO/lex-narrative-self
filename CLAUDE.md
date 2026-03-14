# lex-narrative-self

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-narrative-self`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::NarrativeSelf`

## Purpose

Autobiographical narrative and self-concept for the cognitive architecture. Models autonoetic consciousness — the ability to mentally time-travel through personal experience. Maintains an `Autobiography` of episodes, narrative threads linking episodes by theme, and a self-concept that emerges from the statistical pattern of lived experience via EMA.

## Gem Info

- **Gemspec**: `lex-narrative-self.gemspec`
- **Homepage**: https://github.com/LegionIO/lex-narrative-self
- **License**: MIT
- **Ruby**: >= 3.4

## File Structure

```
lib/legion/extensions/narrative_self/
  version.rb
  client.rb
  helpers/
    constants.rb         # All numeric constants and type lists
    episode.rb           # Episode class — personal event with significance and emotional valence
    narrative_thread.rb  # NarrativeThread class — thematic thread linking episodes
    autobiography.rb     # Autobiography class — top-level store with self_concept and queries
  runners/
    narrative_self.rb    # Runner module — all public runner methods
spec/
  helpers/constants_spec.rb
  helpers/episode_spec.rb
  helpers/narrative_thread_spec.rb
  helpers/autobiography_spec.rb
  runners/narrative_self_spec.rb
  client_spec.rb
```

## Key Constants

From `Helpers::Constants`:
- `MAX_EPISODES = 500`, `MAX_THREADS = 50`, `MAX_CHAPTER_SIZE = 20`
- `EPISODE_DECAY = 0.005`, `THREAD_DECAY = 0.01`, `SIGNIFICANCE_FLOOR = 0.05`
- `SIGNIFICANCE_ALPHA = 0.15`, `EMOTIONAL_BOOST = 0.3`, `THREAD_MATCH_THRESHOLD = 0.3`
- `TRAIT_ALPHA = 0.1`, `MAX_SELF_CONCEPT_TRAITS = 30`, `MAX_TIMELINE_WINDOW = 100`
- `EPISODE_TYPES = %i[achievement failure discovery connection conflict resolution insight surprise decision transition reflection]`
- `SIGNIFICANCE_LABELS`: `:pivotal` (0.8+), `:important`, `:routine`, `:minor`

## Runners

All methods delegate to memoized `@autobiography` instance of `Helpers::Autobiography`.

| Method | Key Parameters | Returns |
|---|---|---|
| `record_episode` | `description:`, `episode_type:`, `domain:`, `significance:`, `emotional_valence:`, `tags:` | `{ episode: episode.to_h }` |
| `recent_episodes` | `count: 10` | `{ episodes:, count: }` |
| `significant_episodes` | `min_significance: 0.6` | `{ episodes:, count: }` |
| `episodes_by_type` | `episode_type:` | `{ episodes:, count: }` |
| `create_thread` | `theme:`, `domain:` | `{ thread: thread.to_h }` |
| `strongest_threads` | `count: 5` | `{ threads:, count: }` |
| `timeline` | `window:` | `{ timeline:, count: }` |
| `self_summary` | — | `{ summary: { total_episodes:, dominant_types:, dominant_domains:, active_threads:, self_concept:, narrative_richness: } }` |
| `update_narrative_self` | — | tick decay; removes faded episodes and weak threads |
| `narrative_self_stats` | — | `{ stats: autobiography.to_h }` |

## Helpers

### `Helpers::Episode`
Personal event: `id`, `description`, `episode_type`, `domain`, `significance` (0–1), `emotional_valence` (−1–1), `tags`, `thread_ids`. `boost(amount)` adds significance with emotional factor. `decay` reduces by `EPISODE_DECAY`. `faded?` when below `SIGNIFICANCE_FLOOR`. `matches_tags?` returns fractional overlap.

### `Helpers::NarrativeThread`
Thematic thread: `id`, `theme`, `domain`, `strength`, `episode_ids`. Episodes auto-linked when tag/domain overlap >= `THREAD_MATCH_THRESHOLD`. `strength` reinforces +0.1 per episode, decays by `THREAD_DECAY`. `weak?` when below floor.

### `Helpers::Autobiography`
Top-level store. `record_episode` creates an `Episode`, auto-links to matching threads, and updates self-concept via EMA(`TRAIT_ALPHA`). `self_summary` returns type/domain distributions, active threads, and `narrative_richness` (type diversity + thread activity, 0–1). `decay_all` prunes faded episodes and weak threads.

## Integration Points

- `update_narrative_self` called each tick to drive episode/thread decay
- `self_summary` feeds identity-related phases in `lex-tick` or `lex-cortex` (planned)
- `emotional_valence` on episodes can correlate with `lex-emotion` valence output
- `tags` on episodes can be matched to `lex-memory` trace domains for cross-extension context

## Development Notes

- State is fully in-memory; reset on process restart
- `Autobiography` evicts lowest-significance episodes when `MAX_EPISODES` is exceeded (sorts then shifts)
- `self_concept` hash maps `episode_type` symbols to EMA-updated float values (0–1)
- `narrative_richness` = average of type_diversity and thread_activity scores
