# Bug Game — Design Document

**Status:** v5 (living document; Your First Forest tutorial)
**Last updated:** 2026-10-02
**Working title:** Underleaf

Consolidates the design conversation and *Bug Game — Design Outline v2* (Google Doc), plus the
sense-acquisition decisions made after that doc was written (§5.1, new in v3), and the approved
engagement direction (§§18–19, new in v4), and the approved tutorial (§20, v5).
The shipped tutorial rules in §20 supersede older first-playable sequencing. This local document is the current design reference;
the linked Google Doc remains the historical v2 source.

Legend: **Decided** = approved direction. **Proposed** = concrete design to prototype, not yet
validated. **Open** = needs an answer. **Watch** = decided but fragile. Planned features are not
claims about what the current playable build implements.

**Current priority:** build and playtest one excellent ten-minute ecological mystery (§18), before
expanding the species roster. Supporting engagement systems and their rollout are detailed in §19.

---

## 1. Vision & Pillars

**Pitch**

> A 2D naturalist game where you cultivate a real cloud-forest habitat, raise and document its
> insects, see the world through their senses, and learn to protect it.

**Pillars**

1. **Perception is the verb.** Sensory modes (chemical, vibration, UV, ultrasound, polarization)
   are how you find, identify, and document species. This is the unoccupied design space — no
   shipped bug game makes *what it's like to be the animal perceiving* the mechanic.
2. **Beauty is earned through ecology.** The gorgeous specimen is the payoff for correct habitat,
   correct conditions, correct timing — never a drop table.
3. **Factually correct, honestly uncertain.** Real species, real requirements, cited. Gaps in the
   science are shown as gaps.
4. **Active stewardship.** The game teaches how habitats are actually protected — not as a message,
   as a mechanic. See §15.

**Tone** *(Decided)* — Cozy and relaxing (Alba, Stardew), but failure is possible. Failure is
*graded* rather than punishing: most mistakes produce a lesser outcome, only genuine neglect
produces loss.

**Origin:** inspired by Ed Yong, *An Immense World* — the book supplies a mechanic, not just a theme.

---

## 2. Player Fantasy & Audience

- **Fantasy** *(Decided)*: a presence over the forest — no avatar, no hands, no tools. Diorama /
  god view. You shape conditions; you never handle animals.
- **Audience**: cozy-sim players with a nonfiction streak (APICO, Strange Horticulture, Wingspan,
  iNaturalist users). Secondary: entomology hobbyists, who will catch every error.
- **Age floor** *(Decided)*: teen–adult. Codex entries can use real terminology. Predation and
  parasitism shown honestly.

---

## 3. Core Loop & Time

**Moment-to-moment:** observe → switch sensory mode → notice something invisible in the default
view → document it.

**Session:** notice an ecological question → observe and optionally predict → adjust one variable
(host plant, deadwood, moisture, canopy) or watch a natural sequence → advance time → compare
what changed → tend developing larvae → record a species or relationship plate.

**Engagement direction (Decided, v4):** figuring out the forest is the primary reward structure.
Predictions are optional, revision is welcome, and evidence matters more than meeting a revealed
percentage. See §18 for the first complete experiment and §19 for the broader systems.

**Meta:** unlock elevation zones → grow the species list → improve specimen quality → complete the
notebook → move into stewardship (§15).

### Time model *(Decided)*

Real seasons drive behavior; time auto-advances at an accelerated rate, with the ability to skip
days or end a day early.

> **Watch:** the time model is the sneakiest dependency in the whole design. It silently determines
> simulation architecture, save format, and whether habitat changes feel rewarding or like waiting.
> Cheap to decide now, expensive to change later.

### Seasons — cloud forest, not temperate

Cloud forest does not run a four-season temperate cycle. The real calendar:

| Season | Approx. months | Character |
| --- | --- | --- |
| Dry | Dec–Apr | Less rain, but heavy fog immersion; strong trade winds on exposed ridges |
| Transition | Apr–May | Onset of rains; major emergence window |
| Wet | May–Nov | Heavy rainfall, peak growth, peak fungal activity |

The master variable is **fog immersion** — horizontal precipitation stripped from passing cloud by
vegetation. Fog frequency, wind exposure, and cloud-base height drive epiphyte growth, deadwood
moisture, and insect activity windows. **Build the calendar on mist regime, not temperature.**

*Consequence:* no periodical cicadas, no autumn color. Different and better payoffs: synchronized
emergences at rain onset, ridge-vs-slope contrast, seasonal fog banks that literally change
visibility.

### First 60 seconds *(Decided)*

The camera settles on a new patch of forest with a generated baseline ecosystem already running — a
few common species interacting, no menus. Each world seed varies the starting area.

### Procedural generation — constrained

Seeds vary *which real species are present and how terrain is laid out*, never invented species or
invented requirements.

Seed variables: elevation band, disturbance history (treefall gap vs. closed canopy), stream
presence, epiphyte load, ridge exposure. Assembly rules stay hard-coded from real ecology.

The seed must also guarantee a **tier-1 sense grantor** in the opening patch (see §5.1
bootstrapping).

---

## 4. The Three Collection Loops

| Loop | Verb | Reward | Risk |
| --- | --- | --- | --- |
| Attract | Modify habitat | New species appears | Slow feedback |
| Rear | Shepherd larvae through instars | Morph quality | Fiddly; needs good UI |
| Document | Observe in the right sensory mode | Notebook plate | Can become a checklist chore |

**Dependencies:** Attract supports Rear; rearing creates documentation opportunities. Document
unlocks perception, which improves observation and habitat decisions. **Clarification (v4):**
rearing is not a universal prerequisite for documenting wild adults or the opening sense grantors.
Preserve a short bootstrap and test the connected loops without making every species a rearing task.

**No capture** *(Decided)*: no bug net, no jar, no human artifacts of any kind.

**Rearing failure** *(Decided)*: a larva dies only if dangerously exposed. Imperfect-but-safe
conditions produce a smaller or plainer adult rather than a loss.

**Rearing without hands**: since there is no avatar and no enclosure, rearing means **shaping the
microhabitat around a larva in situ** — moisture, cover, decay stage of its log, predator and
parasitoid pressure nearby. You never pick anything up.

**Rarity that doesn't lie:** rarity emerges from ecology, not drop tables — seasonal windows,
time-of-day, weather triggers, host-plant maturity, population thresholds. Rare color morphs appear
only once a population is large enough to express them, so the gorgeous variant rewards *not*
over-collecting.

**Morph quality is real biology:** in *Dynastes* and other rhinoceros beetles, male horn size is
nutrition-dependent, producing distinct major and minor morphs. Larval substrate literally
determines whether you get the huge-horned specimen. Collectible variation that is skill
expression, not gacha.

---

## 5. Sensory Mode System

- Each mode is a **full re-render** of the scene, not an overlay filter.
- Every mode must have at least one species **undetectable** without it, and one behavior only
  legible through it.
- **One mode at a time.** Forces choice; keeps the render simple.
- **Binding** *(Decided)*: small selection menu plus direct keys.

| Mode | Reveals | Anchor species |
| --- | --- | --- |
| Chemical | Pheromone gradients, trails | Ants (leafcutters), orchid bees |
| Vibration | Substrate song along stems | Treehoppers |
| UV | Nectar guides, wing patterning | Bees, sulphur butterflies |
| Ultrasound | Bat echolocation, moth clicks | Tiger moths |
| Polarization | Sky compass, circular polarization | *Chrysina* scarabs, foraging ants |

**Acquisition is biological, not technological.** Built equipment contradicts the no-human-artifacts
rule in §4. Instead: **you acquire a sense by documenting the animal that has it.** This closes the
meta loop tightly (document → perceive → document), stays consistent with the diorama framing, and
makes each sense feel granted by an animal rather than crafted.

> **Original prototype principle:** test sensory switching before large content production.
> The first playable build now exists. The next test puts perception inside a complete ecological
> mystery (§18); a palette change alone does not demonstrate an engaging sensory mechanic.

### 5.1 Sense-Acquisition Spine *(new in v3 — Decided)*

This system does three jobs at once — progression, tutorial sequencing, and zone gating. Ordering
was prioritized over player freedom.

**Decisions:**
- Order is **strictly linear** — one path, tight tutorial.
- **Five senses, four zones** resolved by adding a **night layer as a fifth "zone."**
- *Chrysina* / polarization stays **last** — save the showstopper for the end.

**The spine:**

| Stage | Sense | Grantor | Opens |
| --- | --- | --- | --- |
| 1 | Chemical | Ants | Premontane — trails, colony structure |
| 2 | Vibration | Treehoppers | Lower montane — the understory you can't see into |
| 3 | UV | A canopy bee (see below) | Upper montane — epiphyte bloom layer |
| 4 | Ultrasound | Tiger moths | **Night**, across every zone already unlocked |
| 5 | Polarization | *Chrysina* | Elfin ridge — open sky, the payoff |

The order falls out of **habitat**, not arbitrary difficulty tuning: chemical is ground-level,
abundant, visible in default vision (lowest-stakes bootstrap); vibration is for dense understory you
genuinely can't see into; UV needs flowers, i.e. the epiphyte-loaded canopy; ultrasound needs night
and bats; polarization needs open sky, which only the wind-stunted ridge provides.

**The night layer is the strongest piece of this design.** It isn't spatial — unlocking night
doubles the existing map instead of adding terrain. Same four zones, different rosters, different
behavior. Art cost is a lighting pass plus palette work; content gain is enormous. It's also
factually right: most tropical insect diversity is nocturnal, and the moth–bat ultrasound arms race
is one of the best stories in the book. Placing it fourth gives a **midgame reversal** — three zones
in, the player thinks they know the forest, then learns they've been seeing half of it.

**Strict linearity needs one mitigation.** A corridor gets boring. Fix: **every sense stays live in
every earlier zone.** Acquiring vibration fills the "finished" premontane patch with treehopper song
you couldn't perceive before. Backtracking is the reward, not a chore — the metroidvania trick,
except here the retroactive discovery is literally true to how perception works.

**Within a stage, keep freedom:** only the grantor species is required; everything else in the zone
is optional.

**Ecological correction — stage 3.** Orchid bees (Euglossini) are mostly lowland-to-premontane;
placing them at upper montane is exactly the error the secondary audience catches. **Fix taken:**
swap the grantor to a high-elevation bumblebee (*Bombus ephippiatus* reaches montane Central
America) and keep euglossines as **premontane** content — their fragrance-collecting behavior then
becomes a chemical-mode showpiece in zone 1, which is a better use of them anyway. This also spreads
charismatic species across stages instead of bunching them.

**Cost per sense** — *Open.* One sighting = fast acquisition, tree becomes the content. Sustained
observation or a successful rear = each sense feels earned, but early game slows. Not yet decided.

**Bootstrapping** *(Decided in principle)*: default vision must be enough to find the tier-1 grantor
(ants), and the world seed guarantees an obvious grantor in the opening patch.

**Supporting design task:** the **acquisition moment** itself — what happens on screen when a sense is
granted. These are the five biggest emotional beats in the game and probably should *not* all work
the same way. Prototype their interaction language through §§18 and 19.3 before expensive art.

---

## 6. Species Data Schema

```
id, genus, species, common_name

habitat_requirements: [host_plants, decay_stage, moisture, canopy, epiphyte_load, elevation_band]
phenology:            [season_window, fog_dependency, time_of_day, weather_triggers]
life_stages:          [egg, instars[], pupa, adult] + duration + substrate needs
morphs:               [conditions -> variant]
sensory_signature:    [which modes reveal it, what they show]
interactions:         [predators, prey, parasitoids, mutualists, host]
art:                  [sprite_set, palette_cycle_params, plate_asset]
sources:              [citation[], confidence: high|medium|unknown]
```

Schema note: `months_active` and `temp_range` are replaced by `season_window` and `fog_dependency`
to match §3. Species live as data files (JSON or Godot Resources), never hardcoded logic, so sources
can be cited in-game.

**Open**
- Target species count for v1 (suggest 25–35).
- Does `confidence: unknown` surface in-game as a visible "we don't know" tag? *Recommend yes —
  nobody else does this.*
- Verify the specific ant and treehopper species against GBIF occurrence data for the target
  elevation band before writing them into the schema.

### 6.1 Proposed observation and mystery records (v4)

Keep the species catalog separate from each world's evidence history. The priority prototype needs
only a small authored record; do not build a generic content framework before the experience works.

```
mystery: id, question, prerequisites, patch_ids, available_modes, research_status
observation: id, subject_or_patch, game_time, mode, visible_evidence, weather_context
trial: id, before_observation_ids, optional_prediction, intervention, changed_variables,
       comparison_patch, observation_interval, after_observation_ids, limitations, state
relationship_plate: id, participant_ids, evidence_ids, interpretation, claim_sources, confidence
individual_history: id, species_id, last_observed_location, stage_events, optional_player_label
```

Proposed mystery states: available, noticed, comparing, trial_running, reviewing, recorded.
Leaving the area suspends presentation, not the evidence history. Save the current state and enough
event history to resume, reconstruct skipped observations, and avoid duplicate rewards. A later
save-schema migration must preserve existing species discoveries and habitat progress.

---

## 7. World Structure & Region

**Region** *(Decided)*: **Central American cloud forest** (Monteverde-type), chosen for maximum
color — *Chrysina* scarabs, morphos, glasswings, orchid bees. Cost accepted: built from papers
rather than field-checked.

**Zone gating — by perception, not currency.** Elevation bands come free with the region; each
requires a sense acquired lower down (§5.1).

1. **Premontane forest** — starting zone
2. **Lower montane cloud forest** — core zone, peak epiphyte load
3. **Upper montane** — cooler, mossier, mist-saturated
4. **Elfin / dwarf forest** — wind-stunted ridge crest; the showstopper species live here
5. **Night** — non-spatial fifth layer overlaying all of the above

**Ending — soft.** Seasons loop indefinitely, but completing the notebook triggers an epilogue in
which the forest persists without you. Pillar 4 then becomes the postgame (§15). *Conservation as
endgame is more honest than conservation as tutorial.*

**Completion clarification (v4):** relationship mysteries enrich the notebook without automatically
adding mandatory completion gates. Preserve the existing species/plate completion contract for
now; any revised ending requirement needs an explicit later decision.

---

## 8. Art Direction & Tech Art

- **Style** *(Decided)*: pixel art at Stardew-scale resolution.
- **Notebook plates** *(Decided)*: separate, more detailed illustrations — these carry the beauty
  pillar. The split is: readable sprites in world, lush illustration in the trophy case.
- **Iridescence — palette cycling, not shader.** Insect color is largely structural (thin-film
  interference, photonic crystals), but at this sprite resolution it's a few pixels. Animate it with
  palette cycling — a long-established pixel-art technique. Cheap, authentic, reads as craft rather
  than compromise.

**Budget math.** ~30 species × ~3 visible life stages × ~4 frames ≈ **360 sprites**, plus **30
detailed plates**. The plates are the real cost and the thing to timebox. The pixel choice also cuts
the cost of the five sensory-mode art passes substantially. Night adds a lighting pass and palette
work.

---

## 9. UX & Screens

- World view (default + 5 sensory states, × day/night)
- Notebook / codex — *(Decided)* standard menu, with **full-screen plate view as the trophy moment**
- Larva tending (microhabitat conditions, instar tracking)
- Habitat editing (plants, deadwood, water, canopy)
- Calendar / time control
- Species detail page (sources + confidence)
- Optional mystery question, progressive hints, and local patch selection (§18)
- Paired observations, optional prediction, and trial replay (§§18–19)
- Relationship pages and individual observation histories (§19)
- Stewardship view (§15, postgame)

---

## 10. Audio

- Real recordings where available: treehopper substrate song, cicada choruses, bat calls pitched
  into audible range.
- Audio is **mechanically load-bearing** in vibration and ultrasound modes — species get identified
  by sound.
- **Open:** check Macaulay Library and equivalent licensing *before* designing around specific
  recordings.

---

## 11. Tech Stack

- **Godot 4, GDScript.** 2D is first-class, the node/scene model fits "many small autonomous
  agents," free with no revenue strings, and GDScript is close to Python.
- Species as JSON or Godot Resources loaded at runtime.
- Sensory modes as swappable shader/render layers over a shared scene graph.

**Current implementation baseline (updated 2026-10-01):** version-2 JSON saves use a temporary
file and replacement and preserve v1 backups during migration. All four zones update on daily
simulation steps; the first mystery also records within-day observation intervals.

**Implemented for the first mystery:** patch-level observations and trial history (§6.1), hourly
evidence snapshots, off-screen progression, and review of skipped intervals. **Still open:**
validate the timing and evidence presentation with players before generalizing this model.

---

## 12. Scope Tiers

**Current baseline (v4):** a playable Godot edition exists with seven species, eight plates, the
five-sense spine, four zones, night, simplified rearing, and basic stewardship. This is not the full
v1 below. Its threshold-based interactions are the starting point for the engagement prototype.

| Tier | Contents | Question it answers |
| --- | --- | --- |
| **Prototype** (weeks) | One scene, two sensory modes, three species, placeholder art | *Is mode-switching fun?* |
| **Vertical slice** | One elevation zone, one season, ~8 species, one complete rear, final-quality art on a few assets | *Does the three-loop cycle close?* |
| **v1** | 25–35 species, full seasonal cycle, 4 elevation zones + night, complete notebook, stewardship postgame | — |

**Current next prototype:** the single ecological mystery in §18, using the existing clearing and
visible/chemical perception. Add no species until the learning and engagement test passes.

**Earlier prototype candidate (deferred):** a log, treehopper family, parasitoid, and guarding ant.
Do not assume the opening leafcutter species is the treehopper's mutualist. Verify the actual
species-level relationship before revisiting this candidate; it is not part of the priority slice.

**Open:** time budget per tier against a full CS courseload.

---

## 13. Research & Accuracy Pipeline

- Sources: GBIF (occurrence data, real ranges, free), BugGuide, iNaturalist, primary literature for
  anything sensory. The **Monteverde research literature is unusually deep** — decades of published
  work on a single site.
- Every species entry carries citations and a confidence tag.
- **v4 addition:** cite causal relationships and sensory interpretations at the claim level.
  Distinguish a supported fact, an observed game event, and a model assumption. A general species
  source does not validate every associated behavior. See §18.12 for the priority research review.
- **Open:** find one entomologist or tropical ecologist to review the roster. A few emails buys
  enormous credibility.

---

## 14. Risks

- **Art volume** — plates are the bottleneck. Timebox them.
- **Slow feedback** — mitigate with partial signals (a sensory mode showing a species is nearby but
  unsupported).
- **Notebook-as-chore** — completion pressure overriding curiosity.
- **Research burden** — 30 sourced species is a real task, not background activity.
- **Recipe following** — exact target percentages can replace observation; prototype readable clues
  and optional detail views (§§18, 19.4).
- **Schoolwork friction** — predictions and reflections must remain optional, brief, and ungraded.
- **False causal lessons** — keep comparisons fair, record confounds, and qualify conclusions.
- **Attachment becoming obligation** — preserve life-history events without requiring daily visits.
- **Sensory gimmicks** — test whether each mode changes what the player can infer, not just color.
- **Seasonal legibility** — a wet/dry/fog calendar is less intuitive than four seasons. Players need
  to *see* the mist regime, not read it in a menu.
- **Linear corridor fatigue** — mitigated by retroactive perception (§5.1), but verify in playtest.

---

## 15. Stewardship System (Pillar 4)

Postgame content, unlocked after the notebook epilogue. Real threats, real responses.

**Threats**
- Rising cloud base (fewer fog-immersion hours at lower elevations)
- Edge effects from adjacent clearing — drier margins, altered microclimate
- Invasive plants displacing host species
- Fungal pathogens

**Responses**
- Corridor planting between habitat fragments
- Shade-tree retention
- Epiphyte transplant onto young trees
- Host-plant restoration for specialist species

**Design intent: cozy-compatible failure.** Nothing here is a timer or a boss — threats degrade what
you built slowly, and responses must be grounded in conservation practice.

**Engagement expansion (v4):** make threats and recovery observable locally. Players investigate,
choose a response, and monitor evidence over time; avoid permanent checkbox bonuses or a universal
health target. Start with one reviewed threat scenario (§19.8), after the mystery prototype passes.

---

## 16. Competitive Landscape

The space is weirdly barren; search results are dominated by asset-flip shovelware, which is itself
useful information.

**Worth playing**
- **Empires of the Undergrowth** (Slug Disco, 2024) — the benchmark. Real biology drives behavior,
  but it's combat-first: ecology as war.
- **APICO** — closest existing vibe. Pixel beekeeping, real species names, conservation framing.
  *Study its codex and breeding UI closely.*
- **Hive Time** — free, small, charming. Proof of how much a tiny scope can carry.
- **Ecosystem** (Slug Disco) — best existing "build a food web and watch it stabilize or collapse."
- **Bug Fables** — zero science, but proof stylized bugs can carry a game aesthetically.
- **Viva Piñata** — the reference for "each creature unlocked by a requirements puzzle."

**Worth studying, not bug games**
- **Equilinox** — solo-dev scoping case study (ThinMatrix devlogs).
- **Terra Nil** — restoration instead of extraction as a core loop.
- **Wingspan** (board game) — gold standard for making real biology *be* the mechanics.

**The gap:** every one of these picks one thing — colony management, breeding, food webs. **None
does perception.** Even the big-budget attempt (Empire of the Ants, 2024) got panned for shallow
gameplay: beautiful ants, no idea what to do with them.

---

## 17. Next Steps (v4 roadmap; tutorial update in §20)

1. **Build one complete ten-minute ecological mystery** using the detailed proposal in §18.
   Prioritize sensory evidence, a local intervention, comparison, and a notebook payoff.
2. **Review the mystery's causal claims and model limits** (§18.12). Do not turn an unverified
   species preference into a tutorial rule.
3. **Playtest understanding, enjoyment, and transfer** (§18.13). Iterate on the same small experience
   until players can explain the outcome and show curiosity about another question.
4. **Add one contrasting mystery and an optional return discovery** (§19). Test the structure's
   replay value before scaling it into a content pipeline.
5. **Deepen the existing rearing and notebook systems** through individual histories and relationship
   pages, then develop the remaining sensory actions and one local stewardship scenario.
6. **Expand the roster and art budget only after the interaction works.** Review local occurrence,
   host associations, sources, and confidence for both existing and new entries.

The linear sense order stays fixed. Broader sense-acquisition cost remains open; the first mystery
is optional and does not resolve that question for every species. These are design-document changes;
implementation and new playtest results must be tracked separately.

---

## 18. Priority: One Excellent Ten-Minute Ecological Mystery *(new in v4)*

**Implementation checkpoint — 2026-10-01:** app version 0.2 implements the authored route,
local patches, baseline and repeat intervals, shelter-growth preview, optional predictions and
reflections, progressive hints, paired evidence, relationship plate, and resumable save state.
Study weather is a fixed illustrative sequence; research review (§18.12), human playtesting
(§18.13), and a playable transfer scenario remain future work. The proposed ten-minute pacing is
not yet validated. See README for the current playable sequence and explicit model limits.

### 18.1 Decision and purpose

**Decided:** the next design and implementation priority is one complete, roughly ten-minute
mystery in the existing forest. It must connect a sensory clue, one habitat experiment, a visible
consequence, and a notebook payoff. Test whether players can explain **why** the outcome happened
before expanding the roster or producing more mysteries.

**Proposed working mystery:** **The Patch That Holds the Mist** — “Why does this little patch
stay damp after the clearing begins to dry?” The title, precise pacing, scene layout, and interaction
copy below are a concrete prototype proposal, not additional locked decisions.

The current playable build demonstrates acquisition and progression, but exact habitat percentages
can turn discovery into following a recipe. This prototype tests a different source of satisfaction:
noticing a difference, trying an explanation, seeing a consequence, and recognizing the relationship
somewhere new. It must be enjoyable even when the player never opens a long species description.

**Player-facing promise:** “There is something happening here that you can work out.”

**Design question:** Does understanding a small piece of the forest feel rewarding enough to make
the player voluntarily investigate another one?

### 18.2 What the player should learn

The learning targets are narrow and assessable:

1. **Local conditions matter.** Nearby places can change differently during the same weather interval.
2. **Test an explanation.** Change one condition, retain a comparison, and observe both again.
3. **A result supports a limited conclusion.** A single trial in this modeled clearing is evidence;
   it does not prove a universal rule about all forests or all insects.
4. **Different senses answer different questions.** A scent trail can reveal a route. It cannot
   directly measure moisture, diagnose an insect's motivation, or establish causation.

The specific canopy–water relationship, environmental signs, and rate of change must pass the
research review in §18.12 before educational release. The prototype's intended qualitative model
is that, under a matched post-wetting interval, increased shelter can reduce modeled water loss.
Do not generalize this into “more canopy always means more water” or “every insect wants shade.”

Success is not remembering a percentage, reciting a definition, or picking a prewritten “correct”
answer. It is using an observation to make a plausible prediction and recognizing its limits.

### 18.3 Placement in the existing game

Use **one premontane clearing**, with visible and chemical perception. Preserve the strict sense
order in §5.1. The ants remain the first grantor; this mystery neither gives vibration early nor
requires a new species.

In the main game, the mystery becomes available just after the player documents the ants. In a
standalone playtest, begin at that same point and give one sentence of context: “The ants have
opened the forest's scent world.” Test the original first-minute ant introduction separately so a
failed onboarding sequence cannot be mistaken for a failed mystery.

The sensory opening is spatial: chemical perception makes a partly concealed ant route legible,
leading the player's attention around a log to the second microhabitat. Returning to visible light
lets the player compare surface and shelter clues. The trail explains **how the player found the
patch**, not why it is damp or why the ants chose that route. Do not invent a humidity-sensing
ability or force the colony to follow moisture thresholds for the sake of this lesson.

The mystery is optional within the stage. Players can leave, pursue the treehopper, or return later.
Completing it awards a relationship plate and a useful observation bookmark, not a currency reward,
new compulsory gate, or faster route around the five-sense progression.

### 18.4 Scene, cast, and scope

Build a compact composition with two recognizable microhabitats in the same view:

| Element | Function in the mystery | Presentation |
| --- | --- | --- |
| Existing leafcutter route | Sensory invitation and spatial navigation | Moving leaves in visible light; continuous, directional trail information in chemical perception |
| Patch A: beside the fallen log | Starting comparison with greater shelter | A distinctive forked stem, partial cover, and readable surface condition |
| Patch B: at the edge of the opening | The intervention site | A contrasting patch with similar substrate, less shelter, and a clear canopy silhouette |
| Shared weather interval | Fair comparison | Both patches experience the same displayed weather history and observation window |
| One adjustable shelter feature | Player's experimental variable | Select local cover to encourage shade; no hands, watering can, pruning tool, or equipment |
| Existing ambient insects | Keep the forest alive | Behaviors continue independently; they are not success indicators unless the relationship is separately supported |

The two patches need **local state**, not two decorative locations backed by the same zone slider.
Use matching substrate and starting wetness in the initial controlled comparison. Mark natural
observations made before this controlled trial separately; real-looking scenes do not automatically
make a valid experiment.

No new species, parasite system, full host-plant catalog, or complete weather simulation is needed
for this test. Reuse the log, plants, ant art, sense controls, time controls, and notebook shell.
Spend new art effort on the difference the player needs to perceive.

### 18.5 Intended ten-minute experience

These are pacing targets, not a countdown or an enforced sequence of clicks. Observation and
thinking time are never scored. A relaxed player can take twenty minutes or stop halfway.

| Approximate time | Player experience | Game response | Learning / engagement purpose |
| --- | --- | --- | --- |
| 0:00–1:00 | Notices leaves moving toward an obscured route; chooses chemical perception | The trail resolves around the log rather than simply brightening the whole scene | A small sensory surprise invites action without a tutorial wall |
| 1:00–2:30 | Follows the route; switches back to visible light; looks between the two patches | Local details differ; inspecting either patch offers a short observation, not an answer | Establish a question the player has actually seen |
| 2:30–3:30 | Bookmarks the patches and optionally predicts what shelter might change | Notebook holds an observation pair and optional prediction | Convert curiosity into an experiment without an exam |
| 3:30–5:00 | Encourages shade over Patch B while leaving A alone | Canopy visibly changes after a labeled growth interval; a trial summary names the changed condition | Make the intervention understandable and keep comparison intact |
| 5:00–7:00 | Advances to a comparable wetting event and subsequent drying interval; watches both patches | Side-by-side observations show relative change; early feedback appears before the final result | Connect the action to a consequence without idle waiting |
| 7:00–8:30 | Compares before/after and revises or retains the prediction | Notebook assembles the actual sequence and offers another trial if evidence is mixed | Support reasoning from evidence rather than a hidden pass flag |
| 8:30–10:00 | Sees a relationship plate emerge and notices another patch with a related clue | A small, optional transfer opportunity remains in the living world | Test whether understanding produces voluntary exploration |

**Sensory payoff:** the trail that looked incomplete becomes a coherent route.
**Experimental payoff:** a difference in change becomes visible across matched observations.
**Emotional payoff:** the player recognizes the clearing as a place with intelligible relationships.
**Notebook payoff:** a beautiful record of something they worked out, with their own trial preserved.

### 18.6 Exact interaction proposal

**Discover.** Inspection highlights a natural feature, not a quest marker hovering above an animal.
The first note can read: “This surface still looks damp.” Inspecting the other patch adds: “This
one has changed since the mist passed.” Avoid immediately naming shade as the answer.

**Frame the question.** Once the player has observed both locations, offer a small, dismissible
notebook prompt: “What might explain the difference?” The player can choose “Shelter may matter,”
“Something else may differ,” “I want to watch first,” or record their own short note. No response
is graded. Skipping prediction never blocks an experiment or reward.

**Choose an intervention.** Selecting Patch B shows a local canopy preview and the action
“Encourage shelter here.” The preview identifies the area affected. Numeric model values remain
available in an optional detailed view. The default interaction asks the player to select a patch
and a meaningful change rather than find a threshold such as 65%.

**Acknowledge time.** Growing cover requires an explicitly labeled time advance. Do not show a
mature canopy appearing instantaneously and imply this is real tree growth. Use a brief scene
transition and note that growth and trial duration are compressed for play. Players may instead
pause and inspect the proposed change before accepting it.

**Start the comparison.** Record the new shelter state, wait for the next comparable wetting event,
and then compare both patches over the same subsequent interval. The trial card lists “Changed:
cover at Patch B” and “Held comparable: substrate, initial wetness, weather interval.” The player
can see when any of these assumptions fail.

**Observe the outcome.** Present paired snapshots or short replays at the same elapsed time. Use
both scene changes and a plain-language caption such as “Patch B changed more slowly this time.”
A detailed view can show the modeled moisture trajectory. Do not replace the scene with a green
checkmark or make precision dependent on distinguishing two close shades of green.

**Reflect.** Offer “Matches my prediction,” “I would revise it,” and “I need another comparison.”
These record the player's interpretation; they do not assert that the game knows the player's
understanding. Completion follows adequate observations, not selection of the preferred sentence.

### 18.7 Simulation contract and causal honesty

The trial needs a small, explicit model that can be inspected and tested:

- Each patch stores moisture, shelter, substrate identity, observation timestamps, and intervention
  history. Shared weather comes from one event sequence, not separately randomized patch weather.
- The trial separates **water arriving** from **water being retained or lost**. Fog interception,
  rainfall input, and evaporation are not one unexplained “moisture bonus.” For this first test,
  isolate the post-wetting loss interval and hold additional inputs comparable.
- Increased shelter changes the modeled loss process; it does not simply set moisture to a target
  or spawn a rewarded insect. Rates are qualitative game approximations until independently reviewed.
- For the first prototype, use a deterministic weather sequence and no hidden random outcome.
  Vary layout later. The learning result must survive a different seed without relying on chance.
- If weather changes mid-trial, record the change and qualify the conclusion. Offer a repeat at
  another comparable interval rather than silently normalizing away contradictory evidence.
- If the player changes both patches or several variables, keep their actions valid but explain
  why attribution is now harder: “More than one condition changed.” Offer another comparison.
- Do not reward identifying shelter as the sole cause when the evidence only establishes an
  association. The notebook distinguishes “I noticed” from “In this trial, after I changed…”

A lesson about fog interception can follow later. It should ask a different question—where water
comes from—and use an independently supported mechanism. This priority mystery concerns retention
under controlled conditions. Its evocative title must not blur that distinction in the actual copy.

### 18.8 Clues, hints, and assistance

Use an optional hint ladder. Show one level at a time, only when requested; do not display the
answer automatically after a timer expires.

| Level | Example wording | What it preserves |
| --- | --- | --- |
| 1: Attention | “Look at both sides of the fallen log.” | The player still notices the difference |
| 2: Comparison | “Return to the two patches after the same amount of time.” | The player still decides what might matter |
| 3: Hypothesis | “Could the cover above a patch change what happens below?” | The player still designs the intervention |
| 4: Procedure | “Change the cover at one patch. Keep the other as a comparison.” | The result still has to be observed |
| 5: Explanation | “Here is what this trial showed, and what it did not test.” | The player can learn even if the puzzle was not satisfying |

Hints never reduce specimen quality, progress, or the notebook reward. A “Show observations
clearly” option adds labels, patterns, and motion emphasis. A “Show model details” option exposes
percentages and comparison values but labels them as simulation quantities, not field measurements.
Provide visual alternatives for sound, reduced motion, keyboard selection of patches, and a pause
that leaves all evidence readable. None of these assistance options should bypass the need to
present honest evidence.

### 18.9 Outcomes, recovery, and replay

| Outcome | Response | Progress consequence |
| --- | --- | --- |
| Prediction supported in a clean trial | Preserve the observation pair and explain the scope of the result | Relationship plate can be completed |
| Initial prediction not supported | Show the actual result, retain the original prediction, invite revision | Same eventual reward; no “wrong answer” penalty |
| Player watches without predicting | Assemble an observational record and invite an experiment | No forced quiz; trial remains available |
| Several variables changed | Mark the evidence as difficult to attribute | Offer a repeat without erasing the player's habitat work |
| Player leaves or closes the app | Save the current question, observations, and trial stage | Resume with a short reminder; no restart tax |
| Player skips several days | Preserve relevant simulated observations and events for a replay | Do not lose the only opportunity to see the causal result |
| Current conditions no longer support a fair comparison | Name the limitation and offer the next suitable interval | No dead end or invisible failure state |

No animal must die to teach this first lesson. Trial patches should not contain a vulnerable tracked
larva at setup. Do not grant general invulnerability to unrelated wildlife; simply avoid constructing
a tutorial that requires dangerous manipulation. The player is testing an environmental relationship,
not trying to earn a tragic failure scene.

For replays, vary patch placement, canopy shape, and the route by which the player notices the
comparison. Preserve the model and interpretable evidence. Do not invert the scientific rule to
make a second playthrough surprising. Once solved, let the player inspect the plate without forcing
a repeat whenever a new forest is generated.

### 18.10 Notebook payoff: a relationship plate

**Proposed plate title:** “A Shelter That Holds.” This is a relationship page, separate from a
species portrait and not counted as a newly discovered species.

The finished page contains:

- A detailed illustration of the two microhabitats, with the intervention visible.
- A concise question in the player's language: “Why did these patches change differently?”
- The original observation pair, a dated intervention, and the later comparison.
- The player's optional prediction and reflection, preserved as their interpretation.
- A short conclusion tied to this trial, plus one sentence about what was not tested.
- The scientific source, model simplifications, and confidence for each causal claim.
- A “Return to this place” bookmark that centers the camera without moving any animal.

Draft conclusion structure: “After shelter increased at Patch B, its modeled moisture declined
more slowly during this matched interval. This supports a role for shelter here. It does not tell us
which insects prefer this patch or how every cloud-forest site behaves.” Final copy must reflect
the player's actual result; never award a canned success narrative after contradictory events.

Reveal the illustration in stages as the player gathers evidence. The final moment should be quiet
and generous: the forest remains audible, the page completes, and the player can linger or close
it. No score burst, extraction animation, or expensive cinematic is required.

### 18.11 Prototype production order and definition of done

| Order | Deliverable | Acceptance check |
| --- | --- | --- |
| 1 | One authored clearing and two independent local patch states | Editing one patch does not silently change the other |
| 2 | Ant route reveal plus two readable environmental observations | A tester can locate both patches without reading a full explanation |
| 3 | One shelter intervention and explicit time transition | The player can identify exactly what changed and where |
| 4 | Matched trial interval and event history | A repeat with the same conditions yields the same interpretable evidence |
| 5 | Paired observation view and progressive notebook page | The recorded evidence agrees with the actual simulation history |
| 6 | Optional prediction, reflection, and hint ladder | Skipping or revising a prediction never blocks the experience |
| 7 | Pause, leave/return, save/load, and skipped-time handling | The trial survives interruption without losing its crucial observations |
| 8 | One transfer prompt at another patch | The player can apply the idea without being given another threshold recipe |
| 9 | Small formative playtest and review | Evidence supports learning and voluntary curiosity, not just task completion |

**Must have for the test:** one mystery, two modes, two patches, one intervention, one relationship
plate, recoverable trial state, readable outcomes, and explicit model limits.

**Defer:** roster expansion, a generalized quest editor, branching narrative, procedural mystery
generation, recorded calls, a large relationship network, multiple conservation threats, and a
complete rearing redesign. Placeholder presentation is acceptable except where it prevents the
player from reading the evidence. The existing app is a base, not proof that these new systems exist.

### 18.12 Research and content review before educational release

Treat these as research tasks, not claims established by approving this design:

1. Verify the specific shelter, radiation, wind, and water-loss relationships represented by the
   chosen scene. Identify conditions under which the simple model breaks down.
2. Verify which visual signs can legitimately indicate the chosen surface condition. An attractive
   change in foliage must not imply a biological response that occurs on a different timescale.
3. Confirm the ant species' local occurrence and the foraging behavior shown. Do not attach a
   “prefers damp patches” claim to the route unless species-specific evidence supports it.
4. Review wording that distinguishes fog interception from moisture retention and limits causal
   conclusions from one trial.
5. Have a biology-informed reviewer trace each claim from scene cue to notebook conclusion to
   citation. Store unsupported parts as explicit model assumptions or remove them.

A source attached to a species name does not validate every mechanic involving that species. The
claim review must cover the relationship itself. No new external factual claims are considered
verified by this design revision alone.

### 18.13 Playtest plan and decision rules

Start with five formative testers who have not read this document. Include people unfamiliar with
insect ecology. This is a small design test, not evidence of broad educational effectiveness.

**Before play:** ask what they think could make two nearby forest patches stay wet for different
amounts of time. Keep the question neutral and brief; do not teach the intended answer.

**During play:** observe without coaching. Record time to first inspection, first mode switch,
recognition of the contrast, intervention, comparison, hint requests, and moments of uncertainty.
With consent, keep local notes or a session recording. Do not add remote telemetry for this prototype.
Distinguish confusion about controls from uncertainty about the ecological question.

**Immediately after play, ask:**

- “What changed, and what do you think caused the difference?”
- “What evidence made you think that?”
- “What would you change or keep the same in another trial?”
- “What does this result *not* tell you?”
- “Is there something else in the forest you want to look at?”

**Transfer check:** show a different patch arrangement with the same underlying relationship. Ask
what they expect and how they would test it. Do not copy the original layout or ask them to recall
a target percentage. An optional next-day conversation can check what stayed with them.

**Provisional targets for deciding the next iteration:**

| Target | Evidence to look for |
| --- | --- |
| At least 4 of 5 can explain the changed variable and observed result in their own words | Mechanism-based explanation rather than “I moved the slider until it worked” |
| At least 3 of 5 attempt a sensible transfer prediction or comparison | Understanding applies beyond the first arrangement |
| At least 3 of 5 voluntarily inspect another feature or ask a new question | Curiosity persists after the reward |
| No tester must depend on audio alone, fine color discrimination, or an exact percentage | The evidence is accessible |
| Most reach an interpretable result in about 8–15 minutes | Waiting, navigation, and reading do not consume the experience |
| No persistent misconception that scent vision measures water or that all species want more shade | The lesson respects the limits of its representation |

These thresholds are iteration guides, not grades for players or statistically meaningful success
rates. Keep individual observations; an average completion time can hide a serious usability issue.

**Decision rules:** if testers finish but cannot explain why, revise the intervention and comparison
feedback before adding content. If they learn but find it tedious, shorten waiting and improve the
sensory reveal. If they follow hints mechanically, make the initial contrast more legible. If they
understand and voluntarily investigate again, build one second mystery with a different relationship
and check whether the engagement survives repetition.

---

## 19. Supporting Engagement Systems *(new in v4)*

**Decided direction:** develop engagement through ecological curiosity, experimentation, attachment,
and stewardship. The eight ideas below are accepted design directions. Their detailed mechanics,
budgets, and rollout remain proposals to validate, with §18 taking priority.

### 19.1 A library of small ecological mysteries

Author each mystery around a question a player can notice in the scene. Use the same compact
structure: **question → sensory evidence → possible explanation → observation or intervention →
consequence → notebook record → optional new question**. Not every mystery needs a manipulation;
watching a repeated behavior can be the right method when intervention would be misleading.

Candidate content, all subject to claim-level research:

| Question | Main action | Educational focus | Scope / dependency |
| --- | --- | --- | --- |
| Why does this patch stay damp? | Compare local patches and alter shelter | Microhabitat and experimental comparison | Priority prototype, §18 |
| Where are the leaves going? | Follow workers and a chemical route | Distinguishing an observed route from an explanation of colony activity | Early optional ant study; nest interiors must be labeled illustrations if not directly observable |
| What is speaking through this stem? | Locate and compare substrate pulses | A communication channel outside ordinary human hearing | After vibration; verify the chosen species and signal |
| Why do these flowers look different now? | Compare visible and UV structure, then observe visits | Perception changes available information | After UV; no invented species-specific nectar guides |
| What changes when the forest enters night? | Compare the same location across times | An incomplete survey is not an empty habitat | After night; use reviewed activity windows |
| What does this flashing shell reveal? | Compare viewing conditions and optical patterns | Structural appearance and limits of interpreting an animal's senses | Late polarization; distinguish reflection from demonstrated vision |

Avoid writing thirty versions of “increase a value, wait, receive an insect.” Vary whether the
player follows, compares, listens, returns, predicts, or watches a sequence. Reuse places and
species so deeper knowledge can be rewarding without inflating the roster.

### 19.2 Observe, predict, test, and revise

Make the notebook a place to keep a thought, not a mandatory worksheet. Prediction choices must
include uncertainty and an option to watch first. Free text is optional; the game never pretends
to grade arbitrary prose. A player can revise an interpretation without erasing the original record.

Preserve the before state, intervention, elapsed time, weather, and outcome automatically. This
removes clerical work and lets the player focus on interpretation. Later mysteries can introduce
one complication at a time: another variable changed, an observation interval was unsuitable, or a
second trial did not match the first.

Give curiosity the same quality of reward as a correct initial guess. Achievement, if used at all,
should recognize careful observation or revisiting an explanation, not a streak of correct answers.
Do not let a wrong prediction reduce an animal's condition or delay sense acquisition.

### 19.3 Sensory discoveries with distinctive actions

Each mode should add an interpretable structure to the shared world. It should also have a
recognizable acquisition moment that immediately lets the player do something new.

| Sense | Proposed player action | Discovery moment | Scientific / accessibility boundary |
| --- | --- | --- | --- |
| Chemical | Follow branches and compare active routes or scent sources | Scattered movement becomes a connected path | A rendered plume is a translation; it is not every animal's exact experience or a universal resource detector |
| Vibration | Locate a source along connected stems; compare pulse patterns | A quiet plant resolves into localized activity | Pair audio with spatial pulse marks and a replay; no precision rhythm game required |
| UV | Compare contrasting floral or wing structures between views | A familiar surface reveals previously unavailable contrast | Verify each depicted pattern; avoid suggesting false colors are a literal bee's-eye photograph |
| Ultrasound | Read timing between illustrated bat pulses and moth responses | Night becomes structured by interactions the player could not hear | Slow and visualize events; synthetic sound must be labeled; do not conflate warning, mimicry, and jamming |
| Polarization | Compare orientation-dependent patterns in light | A previously familiar object becomes optically distinct | Polarized reflection alone does not establish an animal's ability to perceive it |

Keep one mode active at a time. Allow the notebook to compare observations recorded in different
modes without turning the live scene into an all-information overlay. Avoid rewarding rapid mode
cycling: each view should support a short period of purposeful attention.

### 19.4 Readable environmental clues instead of threshold recipes

Default habitat feedback should explain what the player can observe: shelter, leaf condition,
substrate change, movement, or a supported behavioral response. Reserve precise model quantities
for an optional detail view and explicit assistance. Never present model percentages as measured
species requirements.

Provide at least two complementary ways to understand an important state, such as an altered
silhouette plus a brief inspection note. Cues should develop over time rather than flip instantly
between “wrong” and “correct.” Give early feedback after a change and explain when a response
requires growth or another activity window.

An approaching animal that leaves again is a useful candidate cue only if its behavior is
supported. Do not make every absence mean the player has failed: season, time, detection, or simple
uncertainty can also matter. “Not observed yet” is often a more honest label than “unsuitable.”

### 19.5 Attachment through an individual's life history

Choose a small number of trackable animals for optional longitudinal observation. A larva remains
associated with a particular host leaf or local feature; the player can bookmark its location and
return to notice feeding traces, molts, growth, and pupation. Development occurs in place.

Give the notebook a short chronological story: first observed, shelter changed, molt recorded,
pupation noticed, adult emergence. An optional personal label belongs to the player's notes, not
to the taxonomy. Avoid ownership language, pet-care meters, or an implication that the animal
exists solely to reward the player.

Do not force daily check-ins. Preserve important events during skips and allow replay when the
player returns. If an unmarked animal moves out of view, say that it is no longer observed;
persistent simulation identity does not justify claiming real-world certainty about relocation.

The emerging adult should be a visual and emotional payoff. Any relationship between care,
development, adult size, color, or morphology needs species-specific support. Do not generalize
the *Dynastes* horn example to morpho coloration or treat reduced beauty as a universal indicator
of poor care. Clearly separate a game condition score from biological evidence.

### 19.6 A notebook of relationships

Add relationship pages alongside species portraits, not in place of them. Examples include a
verified host association, a documented communication behavior, or a supported pollination
interaction. A page begins with a question and fills with observations, rather than presenting a
completed ecological diagram before the player has seen its evidence.

Use three explicit evidence states:

- **Observed here:** the game recorded the behavior or condition in this world.
- **Supported explanation:** the interpretation has an appropriate source and fits the observations.
- **Still uncertain:** a link, identification, or causal explanation remains unresolved.

Keep personal notes distinct from the sourced natural-history text. Every relationship can link to
its participants, location, season, and evidence. Show a small relevant set of connections on a page;
do not start with an overwhelming graph of everything in the ecosystem.

For the priority prototype, build one handcrafted relationship page. A generalized relationship
browser comes later. Relationship pages are optional enrichment and do not add mandatory completion
requirements to the existing notebook ending unless a later explicit design decision changes §7.

### 19.7 Earlier places become newly interesting

On acquiring a sense, offer one quiet invitation to return to a familiar location: a bookmark,
a remembered stem, or a notebook question that now seems approachable. Do not fill the world with
notification badges or require a circuit of every previous zone.

Each new sense should eventually support at least one meaningful optional discovery in a place
already visited, subject to the research and art budget. Reuse a recognizable landmark so the
player can connect old and new observations. A return visit should add a behavior, relationship,
or interpretation, not merely recolor an already completed collectible.

Preserve uncertainty. A source may be seasonal or currently inactive; the notebook can suggest a
reasonable observation window without promising that a species must appear on demand. First
playtests should use reliable encounter windows so randomness does not obscure the design test.

### 19.8 Stewardship with observable local consequences

Retain stewardship as the postgame in §15. Earlier habitat care teaches observation; the larger
conservation scenarios arrive after the notebook epilogue. The aim is to apply accumulated knowledge
to protecting connected places.

Start with one slow, visible problem, such as a drying edge in a carefully reviewed scenario. Let
the player compare edge and interior, inspect the change over time, choose a response, and observe
its local effects. The sequence is **notice → investigate → act → monitor → adapt**.

Replace permanent one-click restoration bonuses with spatial, persistent changes when this system
is developed. A corridor needs appropriate placement and habitat; shade retention changes a local
canopy; host restoration needs time. Their outcomes should come from the model, not from checking
four boxes. Specific responses and outcomes require conservation evidence at the relevant scale.

Avoid a universal “forest health” target that encourages making every patch identical. Let the
notebook show which relationships persist, which places are connected, and which conditions remain
uncertain. Some tradeoffs can be legitimate; an open patch is not automatically a broken forest.

The first stewardship expansion should include one threat, two plausible responses, a comparison
period, and a recovery record. Defer multiple interacting threats until players can understand the
first. No escalating countdown, boss encounter, or guilt-based demand to keep playing is needed.

### 19.9 Implementation sequence after the priority test

| Priority | Work | Gate before expanding |
| --- | --- | --- |
| P0 | The complete mystery in §18 | Players understand the causal comparison and want to investigate again |
| P1 | One second mystery built around vibration; one optional revisit | The structure still engages when the sensory action and question differ |
| P1 | Individual observation history for the existing morpho cycle | Players become attached without needing frequent maintenance or check-ins |
| P2 | More relationship pages and a lightweight browser | Enough reviewed relationships exist to justify navigation beyond a few pages |
| P2 | Distinct discovery actions for the remaining senses | Each interaction is understandable, accessible, and scientifically bounded |
| P3 | One local stewardship scenario | Players can trace intervention to outcome without a universal health score |
| Later | Roster growth and broader seasonal variability | Existing systems support deeper play; sources and art can keep pace |

When an expansion adds facts but no new way to observe, reason, or care, reconsider its priority.
The content budget should favor meaningful relationships over a longer list of names.

---

## Appendix: Source Material

- Chat: `https://claude.ai/share/1deb6621-695a-4b9f-9915-12285b1d0d30` — "Bug ecosystem exploration
  game design"
- Doc: *Bug Game — Design Outline v2*, Google Docs `1MALaqRc1CNT9ADJ9cpP01VOn_0S2xxXOCZ3zsivL_Zc`
- Doc (v1, superseded): Google Docs `1WQJ8IxBOT0tH5Ma5-gSmi4tN9sek3cAgMZnROn3Ojvo`
- Ed Yong, *An Immense World* (2022) — conceptual seed

- Design revision v4: user-approved engagement brainstorm, 2026-10-01; prioritized a ten-minute
  ecological mystery and expanded the eight supporting ideas. Detailed mechanics remain proposals
  pending the research and playtest checks recorded above.

## 20. Your First Forest — guided tutorial (Decided, v5)

This small roster is now the tutorial edition, not a miniature finished campaign.
This section supersedes the first-playable onboarding, optional-inquiry sequencing,
and eight-plate ending wherever they conflict. The larger game vision remains intact.
The local design document remains authoritative; the linked Google Doc is historical.

### Purpose and narrative

The player is a quiet presence over a cloud-forest clearing, with no avatar or capture.
Opening: “Learn to notice its hidden inhabitants, understand how their surroundings
change, and help a butterfly complete its life cycle.” Three goals anchor the journey:
observe hidden life, investigate one habitat relationship, follow an egg to adulthood.
Seven guided chapters provide a visible finite path. Optional species pages do not
measure tutorial completion. Existing saves retain progress and enter free exploration;
the guide offers a backed-up fresh tutorial and non-destructive lesson review.

### Authored sequence and transitions

1. **Notice life.** Start with no creature selected. Prompt the moving leaves, point
   toward the ant colony, and require inspection before documentation. Recording opens
   a short notebook explanation. The first sense is earned but not silently activated.
2. **Reveal a hidden world.** Player chooses chemical perception, sees the route, and
   follows it around the log. Explain sensory views as translated information and
   unlock order as a game convention, not an insect gaining a new biological sense.
3. **Ask, change, compare.** Return to visible light. Introduce “sheltered patch” and
   “open patch”; A/B are supporting identifiers. Explain equal starting wetness and
   equal elapsed time before “matched interval.” Preserve optional predictions and
   reflections, the unchanged control, snapshots, repeatability, and limited conclusion.
   Offer Observe one hour later / Wait for cover to grow / Repeat equal wetting.
   Recording the relationship is a chapter accomplishment and explicitly leads to care.
4. **Make room for a life.** Explain that the study taught comparison, not butterfly
   habitat requirements. The local study canopy does not modify whole-zone controls.
   Guided actions establish native host growth, cover, and moisture separately, with
   visible responses and reasons. These remain illustrative settings, not rearing advice.
   Advance to an egg and record it in a persistent life history.
5. **Practice new perceptions.** Follow the existing strict treehopper → bumblebee →
   moth → scarab → ridge optical-study route. Introduce each sense deliberately, name
   the next region, show why habitat actions matter, and inspect before recording.
   Each lesson returns attention to the butterfly's development. Extra orchid-bee pages
   stay optional. Do not claim the fictional discovery cues are verified insect behavior.
6. **Return to a familiar life.** Show egg → caterpillar → pupa → adult and dated stage
   observations. Continue to the next change skips uninteresting time without hiding
   its passage. Stop at stage boundaries; if conditions are unsafe, offer recovery
   instead of skipping blindly. Find and document the adult in ordinary visible light.
7. **Tutorial complete.** Celebrate the actual observed adult and saved relationship.
   Recap what the player did. Continue exploring, revisit lessons, or investigate
   stewardship. Do not promise a larger unimplemented campaign. Optional pages remain.

### One guide, one immediate action

A persistent chapter strip shows progress independently of species count. The sidebar
provides Goal / Next / Why and only the relevant lesson actions. During the mystery,
the inquiry panel is the active guide rather than competing with Next discovery.
Callouts outline the current creature or host leaf in the world; missing a small sprite
must not become the learning challenge. All controls remain keyboard reachable.
Guided time advances explicitly, so reading or leaving the window cannot consume a
life stage. Ordinary automatic time and full habitat controls return in exploration.
Instructions and lesson review are always available; closing the welcome does not
remove the persistent objective. Pages distinguish creatures, relationships, and life
history. Unlock messages explain what changed and ask the player to try the new view.

### Educational and scope safeguards

Use plain language before terminology. Keep scientific caveats accessible, while
retaining a concise model limitation on the comparison page. Preserve sources and
uncertainty on species pages. Never turn the moisture experiment into proof of insect
preference or real-world care instructions. Habitat percentages and eight-day rearing
remain compressed game rules. The tutorial prepares learning; it does not validate
these abstractions scientifically. Human novice playtesting and scientific review
remain outstanding, not implied by automated checks.

### Acceptance and validation

A fresh player should be able to state the overall aim, current task, why it matters,
what changed, and how to resume. Verify real rendered action reachability from welcome
through adult and completion, including all senses, study stages, growth, care, and
returning home. Verify save/reload mid-study and during rearing, migration of old saves,
non-destructive review, modal isolation, keyboard access, and optional exploration.
Render opening, study, life history, and ending at the shipped window size. Rebuild and
sign the app, then launch its bundled engine outside the source checkout with a
separate save fixture. Never reset the user's existing forest during validation.

### v5 implementation map

`scripts/tutorial.gd` owns chapter guidance, inspection targets, care actions, lesson
review, and the dated life history. `main.gd` integrates guided versus exploration
controls and deliberate sense unlocks. `ecology.gd` saves schema v3 and migrates
older worlds without starting them over. `mystery_ui.gd` provides plain-language
comparison steps and the care handoff. `tests/test_tutorial.gd` exercises the
whole journey using rendered hit targets and isolated save files. The shipped
macOS build is 0.3.0. Next: novice playtesting for purpose/next-action comprehension
and pacing, plus scientific review, before expanding the species dataset.
