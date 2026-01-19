# SpiderAttackEasy vs SpidersAttack Comparison

This document compares the two spider-based environments in Craftium.

## Summary Table

| Feature | SpiderAttackEasy | SpidersAttack |
|---------|------------------|---------------|
| **Environment ID** | `Craftium/SpiderAttackEasy-v0` | `Craftium/SpidersAttack-v0` |
| **Episode Length** | 2000 timesteps | 4000 timesteps |
| **Spider HP** | 1 (one-hit kill) | 25 |
| **Spider Damage** | 100 (instant kill) | 3 |
| **Spider Armor** | 100 (full damage) | 200 (50% damage reduction) |
| **Player HP** | 1 | ~20 (default) |
| **Spider Walk Speed** | 2 | 1 |
| **Spider Run Speed** | 7 | 3 |
| **Spawn Distance** | 5 units | 10 units |
| **Death Reward** | -1.0 penalty | None (just terminates) |

## Gameplay Profiles

### SpiderAttackEasy

- **Purpose:** High-pressure, reflex-based environment
- **Challenge:** Extreme danger (instant player death, fast enemies, spawned close)
- **Strategy:** Avoidance and quick reflexes are critical; dodge and hit
- **Learning Focus:** Reaction time, evasion, rapid combat

Key characteristics:
- Both player and spiders die in one hit
- Spiders are ~2x faster than in SpidersAttack
- Spiders spawn closer to the player (less reaction time)
- Shorter episodes with explicit death penalty (-1.0 reward)

### SpidersAttack

- **Purpose:** Extended combat survival with resource management
- **Challenge:** Attrition warfare (need multiple hits per spider, player can take multiple hits)
- **Strategy:** Tactical approach; manage damage taken, sustain battles
- **Learning Focus:** Combat duration, resource conservation, multi-spider management

Key characteristics:
- Spiders are tanky (25 HP + 50% damage reduction from armor)
- Player can survive multiple spider hits
- Spiders are slower and spawn farther away
- Longer episodes allow for extended engagements

## Common Elements

Both environments share:
- Same available actions: forward, left, right, jump, dig, mouse movements
- Same initial equipment: `default:sword_steel`
- Same wave-based spawning system (1 → 2 → 3 → 4 → 5 spiders)
- Same world configuration (superflat with bedrock and steel blocks)
