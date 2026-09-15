# Character sprite slots

Replace these files while keeping the same names, or assign a new texture in each character scene.

| File | Scene | Suggested canvas |
| --- | --- | --- |
| `player_ship.svg` | `characters/player/player.tscn` (Falcon) | 64 × 72 px |
| `player_swift.svg` | `characters/player/swift.tscn` (Swift) | 64 × 72 px |
| `player_titan.svg` | `characters/player/titan.tscn` (Titan) | 76 × 76 px |
| `enemy_scout.svg` | `characters/enemies/scout.tscn` | 52 × 52 px |
| `enemy_striker.svg` | `characters/enemies/striker.tscn` | 60 × 60 px |
| `enemy_tank.svg` | `characters/enemies/tank.tscn` | 76 × 76 px |

PNG and WebP work too. If you change format, drag the new texture into the `Texture` property of the scene's `Sprite2D` node. Keep the ship pointing upward and enemies pointing downward. Transparent backgrounds are recommended.
