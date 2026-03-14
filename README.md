# lex-narrative-self

Autobiographical narrative and self-concept for the LegionIO cognitive architecture. Models the agent's personal history as episodes, threads, and an evolving identity.

## What It Does

Maintains an autobiography of personal episodes — each with a significance score, emotional valence, domain, and tags. Episodes are grouped into narrative threads by thematic overlap. A self-concept emerges from the statistical pattern of episode types over time via exponential moving average. Older low-significance episodes fade naturally.

## Usage

```ruby
client = Legion::Extensions::NarrativeSelf::Client.new

# Record an experience
client.record_episode(
  description:       'Successfully debugged a complex race condition',
  episode_type:      :achievement,
  domain:            :engineering,
  significance:      0.8,
  emotional_valence: 0.7,
  tags:              ['debugging', 'concurrency']
)

# Create a narrative thread to track a recurring theme
client.create_thread(theme: 'debugging', domain: :engineering)

# Retrieve recent and significant episodes
client.recent_episodes(count: 5)
client.significant_episodes(min_significance: 0.7)

# Self-concept summary
summary = client.self_summary
# => {
#   total_episodes: 42,
#   dominant_types: [:achievement, :discovery, :insight],
#   dominant_domains: [:engineering, :coordination],
#   active_threads: ['debugging', 'planning'],
#   self_concept: { achievement: 0.72, discovery: 0.61, ... },
#   narrative_richness: 0.64
# }

# Tick decay (call each processing cycle)
client.update_narrative_self
```

## Episode Types

`:achievement`, `:failure`, `:discovery`, `:connection`, `:conflict`, `:resolution`, `:insight`, `:surprise`, `:decision`, `:transition`, `:reflection`

## Significance Labels

| Range | Label |
|---|---|
| 0.8+ | `:pivotal` |
| 0.6–0.8 | `:important` |
| 0.3–0.6 | `:routine` |
| < 0.3 | `:minor` |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
