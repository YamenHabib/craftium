# Creating a New Spider Attack Variant in Craftium

## Overview
This guide explains what files to change and how to reinstall when creating a new spider attack environment variant with modified configuration.

---

## Spider Game Mechanics

This section explains the core spider stats and mechanics in Craftium.

### HP (Health Points)

HP determines how much damage a spider can take before dying.

| Spider Type | HP Range | File Location |
|-------------|----------|---------------|
| **Spiders-Attack Spider** | 25 (fixed) | `craftium-envs/spiders-attack/mods/craftium_env/init.lua:38-39` |
| **Common Mobs Spider** | 10-30 (variable) | `craftium-envs/common_mods/mobs_monster/spider.lua:65-66` |
| **VoxeLibre Spider** | 16 (fixed) | `craftium-envs/common_games/VoxeLibre/mods/ENTITIES/mobs_mc/spider.lua:45-46` |
| **VoxeLibre Cave Spider** | 1-12 (variable) | Same file, lines 124-125 |

### Damage (Attack Power)

Damage is how many health points the spider removes from the player per hit.

| Spider Type | Damage Per Hit | File Location |
|-------------|----------------|---------------|
| **Spiders-Attack Spider** | 3 | `craftium-envs/spiders-attack/mods/craftium_env/init.lua:37` |
| **Common Mobs Spider** | 3 | `craftium-envs/common_mods/mobs_monster/spider.lua:64` |
| **VoxeLibre Spider** | 2 | `craftium-envs/common_games/VoxeLibre/mods/ENTITIES/mobs_mc/spider.lua:42` |
| **VoxeLibre Cave Spider** | 2 + Poison (7 sec) | Same file, lines 123 and 145-149 |

### Armor (Defense)

Armor reduces incoming damage. **Higher armor = more defense**.

| Spider Type | Armor Value | File Location |
|-------------|-------------|---------------|
| **Spiders-Attack Spider** | 200 | `craftium-envs/spiders-attack/mods/craftium_env/init.lua:40` |
| **Common Mobs Spider** | 200 | `craftium-envs/common_mods/mobs_monster/spider.lua:67` |
| **VoxeLibre Spider** | 100 (fleshy & arthropod) | `craftium-envs/common_games/VoxeLibre/mods/ENTITIES/mobs_mc/spider.lua:51` |

**How Armor Works:**
- The damage calculation is: `actual_damage = incoming_damage * (armor_value / 100.0)`
- Armor of 100 means 100% of damage is absorbed (full damage taken)
- Armor of 200 means damage is halved
- Defined in `craftium-envs/common_mods/mobs/api.lua:2876, 2898-2899`

### What Happens When a Spider Gets Hit

When a spider takes damage, several things occur:

1. **Damage Calculation** (`common_mods/mobs/api.lua:2874-2901`)
   - Damage is calculated based on tool capability, armor groups, and punch interval
   - Health is reduced: `self.health = self.health - floor(damage)`

2. **Knockback Effect** (`common_mods/mobs/api.lua:3038-3072`)
   - Only triggers on full punch (when punch interval timer is complete)
   - Applies upward velocity of 2 (unless already in air)
   - Uses tool's knockback value or defaults to damage amount
   - Pauses spider movement for 0.25 seconds

3. **Visual Effects** (`common_mods/mobs/api.lua:2978-3015`)
   - **Blood particles**: Shows at hit location, scales with damage (2x more blood for damage > 10)
   - **Hit flash**: Applies reddish damage texture modifier for 0.3 seconds

4. **Sound Effects** (`common_mods/mobs/api.lua:2971-2973`)
   - Plays punch sound or tool-specific sound
   - Plays spider's damage sound ("mobs_spider_hurt")

5. **Invulnerability Period** (VoxeLibre only - `common_games/VoxeLibre/mods/ENTITIES/mcl_mobs/combat.lua:467-471`)
   - 0.5 second invulnerability after being hit
   - Prevents rapid successive damage

### Other Spider Stats

| Stat | Spiders-Attack | Common Mobs | VoxeLibre |
|------|----------------|-------------|-----------|
| **Attack Type** | dogfight (melee) | dogfight (melee) | dogfight (melee) |
| **Reach** | 2 blocks | 2 blocks | 2 blocks |
| **Walk Speed** | 1 block/sec | 1 block/sec | 1.3 blocks/sec |
| **Run Speed** | 3 blocks/sec | 3 blocks/sec | 2.4 blocks/sec |
| **Jump** | Yes | Yes | Yes |
| **View Range** | 20 blocks | 15 blocks | 16 blocks |
| **Water Damage** | 5/sec | 5/sec | — |
| **Lava Damage** | 5/sec | 5/sec | — |

### Special Abilities

- **Wall Climbing**: Common Mobs spiders can climb vertical walls (`common_mods/mobs_monster/spider.lua:153-227`)
- **Jump Attack**: Spiders jump at the player during attack with 1.5x upward velocity multiplier
- **Cobweb Shooting**: Orange Spider variant can shoot cobwebs dealing 3 damage (`common_mods/mobs_monster/spider.lua:129-137`)
- **Poison** (Cave Spider only): Applies poison level 2 for 7 seconds

### Information Not Found

The following information could not be determined from the codebase:
- Exact formula for damage falloff based on distance (appears to be melee-only, no ranged damage)
- Spider respawn/regeneration mechanics (spiders do not regenerate health)
- Stamina or fatigue system for spiders (none exists - spiders have unlimited stamina)

---

## Files You Need to Change/Create

### 1. Create New Environment Directory
Create a new directory structure under `craftium-envs/`:

```
craftium-envs/spiders-attack-yourvariant/
├── mods/
│   ├── craftium_env/
│   │   ├── init.lua          (YOUR MAIN CONFIG FILE)
│   │   └── mod.conf
│   ├── mobs -> ../../common_mods/mobs (symlink)
│   ├── mobs_monster -> ../../common_mods/mobs_monster (symlink)
│   ├── superflat -> ../../common_mods/superflat (symlink)
│   └── voxel_api -> ../../common_mods/voxel_api (symlink)
├── games/ (can be empty or copy from spiders-attack)
└── worlds/
    └── world/
        ├── world.mt          (world configuration)
        ├── env_meta.txt
        ├── map.sqlite
        └── auth.sqlite
```

### 2. Main Configuration File: `init.lua`

**Location**: `craftium-envs/spiders-attack-yourvariant/mods/craftium_env/init.lua`

**Key parameters you can change**:

```lua
-- Spider wave configuration
local max_spiders = 5              -- Maximum number of spiders in final wave
local num_spiders = 1              -- Starting number of spiders
local dead_spiders = 0             -- Counter for dead spiders

-- Spawn positions
local spider_spawn = {x = -2.5, y = 5, z = -10}
local player_spawn = {x = -2.5, y = 4.5, z = -1.7}

-- Spider entity definition
mobs:register_mob("craftium:my_spider", {
    type = "monster",
    passive = false,
    attack_type = "dogfight",
    reach = 2,
    damage = 3,                    -- Damage per hit
    hp_min = 25,                   -- Starting HP
    hp_max = 25,                   -- Max HP
    armor = 200,                   -- Defense (higher = more defense)
    collisionbox = {-0.7, -0.01, -0.7, 0.7, 0.6, 0.7},
    visual = "mesh",
    mesh = "mobs_spider.b3d",
    textures = {
        {"mobs_spider_orange.png"},  -- Spider texture
    },
    makes_footstep_sound = false,
    sounds = {
        random = "mobs_spider",
        war_cry = "mobs_spider",
        attack = "mobs_spider",
        damage = "mobs_spider_hurt",
        death = "mobs_spider_death",
        distance = 10,
    },
    walk_velocity = 1,             -- Walking speed
    run_velocity = 3,              -- Running speed
    jump = true,
    view_range = 15,
    -- ... other properties
})

-- Reward system
reward = 1.0    -- Reward for killing a spider
penalty = 0.0   -- Penalty (if any)
```

### 3. Mod Configuration: `mod.conf`

**Location**: `craftium-envs/spiders-attack-yourvariant/mods/craftium_env/mod.conf`

```conf
name = craftium_env
description = Craftium environment - Your Spider Variant
depends = default, mobs, mobs_monster, voxel_api
```

### 4. World Configuration: `world.mt`

**Location**: `craftium-envs/spiders-attack-yourvariant/worlds/world/world.mt`

```conf
enable_damage = false
creative_mode = true
mod_storage_backend = sqlite3
auth_backend = sqlite3
player_backend = sqlite3
backend = sqlite3
gameid = minetest
world_name = world
server_announce = false

# Loaded mods:
load_mod_superflat = mods/superflat
load_mod_craftium_env = mods/craftium_env
load_mod_mobs_monster = mods/mobs_monster
load_mod_mobs = mods/mobs
load_mod_mobs_animal = false
load_mod_voxel_api = mods/voxel_api
```

### 5. Python Registration: `craftium/__init__.py`

**Location**: `craftium/__init__.py`

Add a new registration block (around line 181-208, after the original SpidersAttack-v0):

```python
register(
    id="Craftium/SpidersAttack-YourVariant-v0",  # YOUR UNIQUE ID
    entry_point="craftium.craftium_env:CraftiumEnv",
    additional_wrappers=[
        WrapperSpec(
            name="DiscreteActionWrapper",
            entry_point="craftium.wrappers:DiscreteActionWrapper",
            kwargs=dict(
                actions=["forward", "left", "right", "jump", "dig",
                        "mouse x+", "mouse x-", "mouse y+", "mouse y-"],
                mouse_mov=0.5,
            ),
        )
    ],
    kwargs=dict(
        env_dir=os.path.join(root_path, "craftium-envs/spiders-attack-yourvariant"),
        obs_width=64,                    # Observation width
        obs_height=64,                   # Observation height
        max_timesteps=4000,              # Max steps per episode
        init_frames=200,                 # Initialization frames
        _minetest_conf=dict(
            give_initial_stuff=True,
            initial_stuff="default:sword_steel",  # Starting weapon
        ),
        _voxel_obs_available=True,
    )
)
```

## Common Configuration Changes

### Easy Difficulty Variant
- Reduce `max_spiders` to 3
- Reduce spider `damage` to 2
- Reduce spider `armor` to 100
- Give better weapon: `"default:sword_diamond"`

### Hard Difficulty Variant
- Increase `max_spiders` to 10
- Increase spider `hp_min/hp_max` to 40
- Increase spider `damage` to 5
- Increase spider `armor` to 250
- Keep weapon as `"default:sword_steel"` or give worse weapon

### Multi-Spider Start
- Change `num_spiders = 3` (start with 3 spiders instead of 1)
- Adjust spawn positions to spread them out

### Custom Rewards
- Change `reward = 5.0` for higher reward per kill
- Add `penalty = -0.1` for time penalty

## How to Reinstall After Changes

### Quick Method (Development Mode)
If you only changed Python files or Lua files:

```bash
# From the project root directory
pip install -e .
```

This installs in editable mode, so changes to Python and Lua files take effect immediately without reinstalling.

### Full Rebuild (If You Changed C++ Code)
If you modified the Minetest engine or C extensions:

```bash
# 1. Clean previous build
make clean

# 2. Reconfigure with CMake
cmake . -DRUN_IN_PLACE=TRUE -DCMAKE_BUILD_TYPE=Release

# 3. Rebuild
make -j$(nproc)

# 4. Reinstall Python package
pip install --force-reinstall .
```

### After Creating a New Environment
If you created a new environment directory and registered it:

```bash
# Reinstall to pick up new environment
pip install --force-reinstall .

# Or in editable mode
pip install -e .
```

### Testing Your Changes

```python
import gymnasium as gym
import craftium

# Create your new environment
env = gym.make("Craftium/SpidersAttack-YourVariant-v0", render_mode="human")

# Test it
obs, info = env.reset()
for _ in range(1000):
    action = env.action_space.sample()
    obs, reward, terminated, truncated, info = env.step(action)
    if terminated or truncated:
        obs, info = env.reset()

env.close()
```

## File Locations Summary

| File | Purpose | Required for New Variant |
|------|---------|--------------------------|
| `craftium-envs/spiders-attack-yourvariant/mods/craftium_env/init.lua` | Main environment logic and spider config | YES - MAIN FILE TO EDIT |
| `craftium-envs/spiders-attack-yourvariant/mods/craftium_env/mod.conf` | Mod metadata | YES |
| `craftium-envs/spiders-attack-yourvariant/worlds/world/world.mt` | World settings | YES (copy from original) |
| `craftium/__init__.py` | Python environment registration | YES - ADD NEW REGISTER() BLOCK |
| `craftium-envs/common_mods/mobs_monster/spider.lua` | Generic spider definition | NO (only if creating new mob type) |

## Quick Start Checklist

1. [ ] Copy entire `spiders-attack/` directory to new name
2. [ ] Edit `init.lua` to change spider parameters
3. [ ] Edit `craftium/__init__.py` to add new registration with unique ID
4. [ ] Run `pip install -e .` to install in development mode
5. [ ] Test with Python script
6. [ ] If issues: check `worlds/world/debug.txt` for Lua errors

## Tips

- Start by copying the existing `spiders-attack` environment
- Make small changes first and test frequently
- Check `worlds/world/debug.txt` for Lua errors
- Use `render_mode="human"` to visually debug the environment
- Keep unique environment IDs to avoid conflicts
- Symlinks to common_mods avoid code duplication
