## Table of Contents
1. [Game Overview](#game-overview)
	- [Core Gameplay Loop](#core-gameplay-loop)
	- [Target Audience](#target-audience)
	- [Unique Selling Points](#unique-selling-points)
2. [Core Gameplay & Mechanics](#core-gameplay--mechanics)
	- [Turn Structure](#turn-structure)
	- [Resource System](#resource-system)
	- [Territory Control](#territory-control)
	- [Seasonal Cycle](#seasonal-cycle)
3. [Factions](#factions)
	- [The Emberforge Dominion (Fire)](#the-emberforge-dominion-fire)
	- [The Tidesong Covenant (Water)](#the-tidesong-covenant-water)
4. [Units System](#units-system)
	- [Basic Unit Types](#basic-unit-types)
	- [Faction-Specific Units](#faction-specific-units)
5. [Buildings & Structures](#buildings--structures)
	- [Core Buildings](#core-buildings)
	- [Faction-Specific Structures](#faction-specific-structures)
6. [Research & Technology](#research--technology)
	- [Tech Tree Structure](#tech-tree-structure)
7. [Art Style & Visual Design](#art-style--visual-design)
	- [Overall Aesthetic](#overall-aesthetic)
	- [Asset Creation Strategy](#asset-creation-strategy)
8. [Audio Design](#audio-design)
	- [Sound Implementation Plan](#sound-implementation-plan)
9. [Gameplay Progression](#gameplay-progression)
	- [Campaign Mode](#campaign-mode)
	- [Skirmish Mode](#skirmish-mode)
	- [Victory Conditions](#victory-conditions)
10. [Single Player AI](#single-player-ai)
	- [AI Implementation Strategy](#ai-implementation-strategy)
11. [Technical Implementation](#technical-implementation)
	- [Mobile Optimization](#mobile-optimization)
	- [Save System](#save-system)
12. [Monetization](#monetization)
	- [Premium Game Model](#premium-game-model)
13. [Development Roadmap](#development-roadmap)
	- [Phase 1: Core Systems](#phase-1-core-systems-3-months)
	- [Phase 2: Content Development](#phase-2-content-development-6-months)
	- [Phase 3: Refinement](#phase-3-refinement-3-months)
	- [Phase 4: Launch & Support](#phase-4-launch--support-2-months--ongoing)
14. [Solo Development Strategies](#solo-development-strategies)
	- [Prioritization Framework](#prioritization-framework)
	- [Asset Pipeline](#asset-pipeline)
	- [Testing Methods](#testing-methods)
15. [Future Considerations](#future-considerations)
	- [Potential Expansions](#potential-expansions)

---

## Game Overview

Elemental Conquest is a vibrant, turn-based strategy game where players build civilizations aligned with elemental powers. Set in a procedurally generated world where elemental territories shape your strategies, players must expand, adapt to seasonal changes, and develop their elemental powers.

As a solo developer project, the initial release focuses tightly on two contrasting elemental factions (Fire and Water) with streamlined mechanics that are both achievable to implement alone and engaging for players.

### Core Gameplay Loop

The fundamental moment-to-moment experience in Elemental Conquest follows this pattern:
1. **Survey** the current state of your territory, resources, and threats
2. **Plan** your next moves based on seasonal effects
3. **Build** structures and recruit units to advance your strategy
4. **Expand** your influence through military action
5. **Adapt** to changing conditions and seasonal effects

This loop creates engaging gameplay while using systems that are technically feasible for a solo developer to implement.

### Target Audience

**Primary:** Mobile strategy gamers (25-45) seeking depth with accessibility:
- Enjoys turn-based games but has limited continuous play time
- Appreciates systems with meaningful choices
- Values both strategic depth and artistic cohesion

**Secondary:** Broader mobile gaming audience (18-35) looking for deeper experiences:
- Tired of shallow mobile game experiences
- Enjoys games with persistent progression
- Willing to invest time in learning engaging systems

### Unique Selling Points

1. **Elemental Territory System:** Dynamic map where territory alignment actively affects gameplay
2. **Seasonal Cycle:** Environmental changes that reward planning and adaptation
3. **Contrasting Faction Playstyles:** Two carefully designed factions with distinct strategic approaches
4. **Complete Single-Player Experience:** Full campaign and skirmish modes without requiring online connection

---

## Core Gameplay & Mechanics

### Turn Structure

- Same as gladius

### Resource System

#### Primary Resources

- **Elemental Energy:** Faction-specific resource (Flame for Fire faction, Flow for Water faction)
  - Visually represented as glowing essence flowing into storage structures
  - Caps based on storage facilities
- **Population:** Citizens who can become workers or military units
- **Food:** Required to maintain and grow population
- **Materials:** Used for construction and military equipment

#### Secondary Resources

- **Knowledge:** Advances research and unlocks new technologies
- **Harmony:** Increases stability and efficiency
- **Chaos:** Provides combat bonuses and destructive capabilities

#### Resource Visualization

- Color-coded resource meters
- Warning system for critical shortages or approaching caps
- Simple resource flow indicators

### Territory Control

The game world is divided into hexagonal tiles with elemental alignments. Players can:

- Build outposts to claim territory
- Receive bonuses when controlling territory aligned with their element:
  - +25% resource production
  - +20% unit strength
  - -15% building costs
- Suffer penalties when controlling territory opposed to their element:
  - -20% resource production
  - -15% unit strength
  - +25% building costs

**Neutral Territories:**
- Unclaimed or recently depleted areas
- No bonuses or penalties to any faction
- Convert to the controlling faction's element over time (3-5 turns)

**Territory Conversion:**
- Territories can be converted through specialized buildings or units
- Conversion is gradual (5-10 turns depending on opposition)
- Contested territories flash with multiple elemental colors

**Strategic Terrain Features:**
- Mountains: Defensive bonus, limit movement
- Rivers: Enhanced water element, movement barriers
- Volcanoes: Fire power source, valuable materials

### Seasonal Cycle

Each season lasts 12 turns and affects all elements:
- # Change bonuses to only positive ones, and make them small
#### Spring
- **Earth:** +15% growth and production
- **Air:** +10% movement and visibility
- **Water:** +5% resource efficiency
- **Fire:** -10% combat strength

#### Summer
- **Fire:** +20% combat and production
- **Earth:** +10% defense
- **Air:** -5% resource generation
- **Water:** -15% unit health

#### Autumn
- **Air:** +15% knowledge generation
- **Water:** +10% resource collection
- **Fire:** +5% population growth
- **Earth:** -10% movement speed

#### Winter
- **Water:** +20% defense and resource preservation
- **Air:** +5% efficiency
- **Earth:** -10% production
- **Fire:** -20% population growth and combat

**Seasonal Transitions:**
- Visual shifts in environment color palette
- Notification system with strategic recommendations

## Factions

### The Emberforge Dominion (Fire)

**Philosophy:** Expansion, industry, and combat prowess

**Strengths:**
- Fastest production rates
- Strongest direct combat units
- Superior weaponry
- Rapid territory conversion

**Weaknesses:**
- High resource consumption
- Vulnerable during winter

**Aesthetic:** Brass, copper, and crimson with angular architecture

**Gameplay Style:** Aggressive expansion with industrial focus

### The Tidesong Covenant (Water)

**Philosophy:** Adaptability, efficiency, and defensive capability

**Strengths:**
- Superior resource preservation and storage
- Strong defensive structures
- Ability to thrive in various territories

**Weaknesses:**
- Slower production
- Vulnerable during summer

**Aesthetic:** Fluid curves, blue-green palette

**Gameplay Style:** Defensive focus with efficient resource utilization

---

## Units System

### Basic Unit Types

Both factions have access to these fundamental units:

- **Citizen:** Basic worker, can be specialized
  - Can be assigned to buildings for resource generation
  - Limited self-defense capabilities

- **Scout:** Exploration unit
  - High visibility range
  - Fast movement
  - Weak in direct combat

- **Soldier:** Basic combat unit
  - Balanced attack and defense
  - Moderate movement
  - Can capture neutral territories

- **Harvester:** Resource-gathering specialist
  - Increases resource yield from territories
  - Very weak in combat

### Faction-Specific Units

#### Emberforge Dominion (Fire)
- **Flamecaster:** Ranged attacker with area damage
- **Obsidian Guard:** Heavy defensive unit

#### Tidesong Covenant (Water)
- **Tidal Guardian:** Defensive specialist with healing
- **Current Rider:** Fast naval harassment unit

---

## Buildings & Structures

### Core Buildings

All factions have access to these essential structures:

- **Settlement Center:** Central building, expands city radius
  - Initial building required for all settlements
  - Upgradeable to increase city size and population capacity

- **Elemental Nexus:** Generates elemental energy
  - Must be placed on aligned territory for maximum efficiency

- **Storehouse:** Stores resources
  - Increases resource caps
  - Provides buffers against shortages

- **Training Ground:** Produces military units
  - Required for military unit recruitment

- **Academy:** Generates knowledge
  - Accelerates research progress

- **Watchtower:** Provides visibility
  - Extends line of sight
  - Detects enemy units

### Faction-Specific Structures

#### Emberforge Dominion
- **Forge Heart:** Enhances production
- **Flame Altar:** Boosts combat prowess

#### Tidesong Covenant
- **Tidal Pool:** Enhances growth and healing
- **Current Channel:** Improves efficiency

---

## Research & Technology

### Tech Tree Structure

Research is organized into three interconnected spheres:

- **Material Sphere:** Buildings, resource extraction, and physical infrastructure
- **Military Sphere:** Units, combat mechanics, and defensive systems
- **Elemental Sphere:** Elemental manipulation and special abilities

Each faction has unique technologies reflecting their elemental nature, but the implementation is streamlined to be manageable for solo development.

---

## Art Style & Visual Design

### Overall Aesthetic

- **Stylized Low-Poly:** Clean, distinctive shapes with vibrant colors
- **Elemental Effects:** Simple but effective color themes for each element
- **Mobile-Optimized:** Distinctive silhouettes readable on small screens

### Asset Creation Strategy

- **Modular Design System:** Create base models that can be recolored and slightly modified to create variants
- **Texture Atlases:** Optimize rendering with shared texture sheets
- **Procedural Assistance:** Use procedural generation for terrain and map features
- **Asset Store Integration:** Selectively use quality third-party assets where appropriate, especially for common UI elements and effects

---

## Audio Design

### Sound Implementation Plan

- Use royalty-free music libraries with appropriate licensing
- Focus sound design on key interactions and elemental effects
- Simple adaptive system that changes music based on:
  - Player's elemental faction
  - Current season
  - Peace/war status

---

## Gameplay Progression

### Campaign Mode

- **Two Elemental Journeys:** A campaign for each faction
- **Progressive Difficulty:** Starts with tutorials, builds to complex scenarios

**Campaign Structure:**
- 4 missions per elemental campaign
- Escalating complexity introducing new systems gradually

### Skirmish Mode

- **Quick Match:** Generate balanced map for fast play
- **Custom World:** Adjust elemental distribution and map size

### Victory Conditions

- **Conquest:** Control 75% of the map
- **Knowledge:** Achieve maximum knowledge advancement
- **Dominance:** Maintain highest score for 10 full seasons

---

## Single Player AI

### AI Implementation Strategy

- Rule-based system with predefined behaviors by faction
- Focus on making AI appear intelligent rather than complex calculations
- Fire AI focuses on expansion and aggression
- Water AI emphasizes defense and resource management
- Difficulty levels primarily adjust resource bonuses and restrictions rather than behavior complexity

---

## Technical Implementation

### Mobile Optimization

- Target 30fps on mid-range devices
- Simplified particle systems for elemental effects
- Batch processing for turn calculations

### Save System

- **Auto-Save:** Automatic preservation at turn end
- **Manual Save Slots:** User-defined save states (3 slots)
- **Cloud Save:** Optional Google Play backup

---

## Monetization

### Premium Game Model

- One-time purchase price (<10pln)
- Complete experience with no in-app purchases required
- Free trial version with limited content

---

## Development Roadmap

### Phase 1: Core Systems (3 months)
- **Month 1:** Basic gameplay loop with map generation
- **Month 2:** Resource systems and turn management
- **Month 3:** Territory control and seasonal effects
- **Milestone:** Internal playable prototype

### Phase 2: Content Development (6 months)
- **Month 4-5:** Fire faction implementation
- **Month 6-7:** Water faction implementation
- **Month 8-9:** Core buildings, units and basic campaign
- **Milestone:** Feature-complete alpha build

### Phase 3: Refinement (3 months)
- **Month 10:** Balance testing and adjustment
- **Month 11:** UI polish and performance optimization
- **Month 12:** Audio implementation and final testing
- **Milestone:** Beta release candidate

### Phase 4: Launch & Support (2 months + ongoing)
- **Month 13:** Final polish and Google Play store preparation
- **Month 14:** Global release and initial support
- **Post-Launch:** Bug fixes and balance adjustments based on player feedback

---

## Solo Development Strategies

### Prioritization Framework

1. **Core Before Content:** Ensure fundamental systems work before creating variations
2. **Vertical Slice Approach:** Develop one complete feature chain before expanding
3. **Visual Hierarchy:** Prioritize functional visuals first, then enhancement
4. **Playtest Early, Playtest Often:** Get feedback on core mechanics before adding complexity

### Asset Pipeline

- **Art Creation Schedule:** Allocate specific days for art creation to maintain consistency
- **Reusable Components:** Design systems that allow asset reuse and recombination
- **Placeholder Strategy:** Use simple placeholders during development with consistent upgrade path
- **External Resources:** Budget for select paid assets when they significantly save time

### Testing Methods

- **Friends & Family Testing:** Regular testing sessions with trusted feedback sources
- **Automated Testing:** Simple test scripts for core systems
- **Device Testing Rotation:** Regular testing on different device types
- **Session Recording:** Use screen recording to observe player confusion points

---

## Future Considerations

### Potential Expansions

Items to consider only after successful launch:

- **Earth Faction:** Defensive specialist with resource efficiency
- **Air Faction:** Mobile specialist with knowledge and tech focus
- **Multiplayer Features:** Simple asynchronous play between friends

These expansions would only be pursued after the base game has proven successful and generated sufficient resources to support their development.

---

## Development Tools

- **Engine:** Godot 4 (free, open-source)
- **Art Production:** Blender, Aseprite, Inkscape
- **Sound Production:** Free DAW options (LMMS, Audacity)
- **Version Control:** Git with GitHub or similar
- **Project Management:** Trello or similar Kanban system

---

## Marketing Essentials

### Core Marketing Assets
- Game trailer (60 seconds)
- Google Play store assets (screenshots, description, icon)
- Simple landing page
- Social media presence on one platform (Twitter/X recommended)

### Launch Strategy
- Pre-launch announcements on indie game platforms
- Outreach to mobile game reviewers and content creators
- Launch discount promotion (first week)
