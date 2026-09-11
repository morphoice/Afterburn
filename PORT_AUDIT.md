# Afterburn — Unity → Godot port audit

Ground truth for the Godot port. Every figure below was read out of the Unity
project; the source file is named beside it. Nothing here is estimated.

Unity source: `Unity/Afterburn/Assets/`
Godot port:   `Godot/`

---

## 1 — Sprites

`aseprite -b --list-tags --data` on each `.aseprite`, and the importer settings
out of the matching `.aseprite.meta`.

### Aseprite files

| File | Frames | Frame size | Sheet size | Frame duration | Tags |
|---|---|---|---|---|---|
| `Sprites/Gunfire.aseprite` | 4 | 9 × 9 | 36 × 9 | 42 ms | none |
| `Sprites/Mig28.aseprite` | 12 | 320 × 156 | 3840 × 156 | 83 ms | none |
| `Sprites/Mig28 Back.aseprite` | 16 | 320 × 168 | 5120 × 168 | 77 ms | none |
| `Sprites/Ocean.aseprite` | 8 | 1000 × 800 | 8000 × 800 | 42 ms | none |
| `Sprites/explosion1.aseprite` | 11 | 64 × 64 | 704 × 64 | 40 ms | none |
| `Sprites/speedlines.aseprite` | 8 | 840 × 640 | 6720 × 640 | 83 ms | none |
| `Tomcat/Crosshairs.aseprite` | 4 | 13 × 13 | 52 × 13 | 100 ms | none |
| `Tomcat/Missiles.aseprite` | 1 | 74 × 31 | 74 × 31 | 100 ms | none |
| `Tomcat/tomcat.aseprite` | 48 | 240 × 100 | 11520 × 100 | 83 ms | 18 (below) |
| `Fonts/Aseprite/Afterburn Gold.aseprite` | 1 | 128 × 64 | 128 × 64 | 100 ms | none |
| `Fonts/Aseprite/Afterburn Sans Gold.aseprite` | 1 | 128 × 64 | 128 × 64 | 100 ms | none |
| `Fonts/Aseprite/Afterburn White.aseprite` | 1 | 72 × 64 | 72 × 64 | 100 ms | none |

### tomcat.aseprite tags

The only tagged file. Each tag is a pose; `from`/`to` are frame indices.

| Tag | from–to | Tag | from–to | Tag | from–to |
|---|---|---|---|---|---|
| U2C | 0–2 | CC | 18–20 | D2C | 36–38 |
| U2R1 | 3–5 | CR1 | 21–23 | D2R1 | 39–41 |
| U2R2 | 6–8 | CR2 | 24–26 | D2R2 | 42–44 |
| U1R2 | 9–11 | D1R2 | 27–29 | D3C | 45–45 |
| U1R1 | 12–14 | D1R1 | 30–32 | D3R1 | 46–46 |
| U1C | 15–17 | D1C | 33–35 | D3R2 | 47–47 |

15 poses of 3 frames, then 3 poses of a single frame (D3C, D3R1, D3R2).
Two pitch steps up, three down; three lateral steps each side of centre.

### Importer settings (`.aseprite.meta`)

Identical across all sprite files unless noted:

| Setting | Value |
|---|---|
| `spriteMode` | 2 (Multiple) |
| `spritePixelsToUnits` | **32** |
| `alignment` (file default) | 0 |
| `spritePivot` (file default) | {0.5, 0.5} |
| `textureType` | 8 (Sprite 2D and UI) |
| `filterMode` | 0 (Point) |
| `spriteExtrude` | 1 — **except `Mig28.aseprite`: 4** |
| `alphaIsTransparency` | 1 |
| `generatePhysicsShape` | 0 |
| `fileImportMode` | 1 |
| `defaultPivotAlignment` | 0 |
| `mosaicPadding` | 4 |
| `spritePadding` | 2 |

Per-sprite entries carry `alignment: 9` (Custom) with their own pivot.

### Sprites Unity actually imported

Unity's Aseprite importer emits fewer sprites than the `.aseprite` has frames
where frames are identical. The import data is what the game uses.

| Sheet | `.aseprite` frames | Sprites in `animatedSpriteImportData` | Names |
|---|---|---|---|
| Mig28 | 12 | **12** | `Mig28_Frame_0` … `_11` |
| Mig28 Back | 16 | **5** | `Mig28 Back_Frame_0` … `_4` |
| explosion1 | 11 | **10** | `Frame_0` … `Frame_9` |
| Ocean | 8 | **8** | `Ocean_Frame_0` … `_7` |
| speedlines | 8 | **8** | `speedlines_Frame_0` … `_7` |
| Crosshairs | 4 | **4** | `Crosshairs_Frame_0` … `_3` |
| Missiles | 1 | **1** | `Missiles` |
| tomcat | 48 | **47** | `tomcat_Frame_0` … `_46` |
| Gunfire | 4 | **3** | `Gunfire_Frame_0` … `_2` |

The `.aseprite.meta` files are all newer than their `.aseprite` (checked with
`stat -f%Sm`), so these counts are current, not stale.

### Per-sprite pivots

Pivots are relative to each sprite's **trimmed** rect in Unity's packed atlas,
not to the untrimmed frame. Uniform where listed as 0.5/0.5.

- **Ocean**: all 8 frames pivot {0.5, 0.5}.
- **speedlines**: all 8 frames pivot {0.5, 0.5}.
- **Crosshairs**: all 4 frames pivot {0.5, 0.5}.
- **Missiles**: {0.4927536, 0.51785713}, rect 69 × 28 at (4, 4).
- **Mig28**: frames 3, 6, 7, 8, 9, 10, 11 pivot {0.5, 0.5} on a 322 × 158 rect.
  Frames 0, 1, 2, 4, 5 are trimmed and carry off-centre pivots
  (0: {0.48425198, 0.6171875} on 254 × 128; 1: {0.49407116, 0.325} on 253 × 80;
  2: {0.5348837, 0.59090906} on 301 × 132; 4: {0.45228216, 0.5} on 241 × 72;
  5: {0.475, 0.47297296} on 240 × 74).
- **explosion1**: pivots have **negative y** (Frame_0 {0.45833334, −0.86956525},
  Frame_1 {0.575, −0.2820513}, Frame_2 {0.5, −0.033333335}, Frame_3 {0.5, 0},
  Frame_4 {0.48387095, −0.033333335}, Frame_5 {0.52459013, 0},
  Frame_6 {0.5, 0}, Frame_7 {0.5, 0}, Frame_8 {0.49090907, −0.0925926},
  Frame_9 {0.4883721, −0.20454547}). The pivot sits at or below the bottom
  edge, which is why `ExplosionEffect.cs:42` shifts the effect down by
  `baseScale` to recentre it.
- **Gunfire**: also negative y ({0.5, −0.14285715}, {0.5, −0.16666667},
  {0.49999997, −0.4}).
- **tomcat**: 47 distinct pivots, y falling from 0.70422536 (nose-high poses)
  to 0.4259259 (nose-low). x stays within 0.484–0.507.

### PNGs in the Godot port

`Godot/assets/sprites/*.png` dimensions read from the PNG IHDR. Each matches
the corresponding aseprite `--sheet` size exactly, so they are untrimmed
horizontal strips at full frame stride:

| PNG | Size | Frames × stride |
|---|---|---|
| `Crosshairs.png` | 52 × 13 | 4 × 13 |
| `Gunfire.png` | 36 × 9 | 4 × 9 |
| `Mig28.png` | 3840 × 156 | 12 × 320 |
| `Mig28 Back.png` | 5120 × 168 | 16 × 320 |
| `Missiles.png` | 74 × 31 | 1 × 74 |
| `Ocean.png` | 8000 × 800 | 8 × 1000 |
| `explosion1.png` | 704 × 64 | 11 × 64 |
| `speedlines.png` | 6720 × 640 | 8 × 840 |
| `tomcat.png` | 11520 × 100 | 48 × 240 |

The Godot PNGs carry **all** aseprite frames, including the ones Unity's
importer collapsed. Region indices must follow Unity's import order, not a
naive 0..n−1 over the strip.

---

## 2 — Prefabs

### `Assets/Enemies/Mig28.prefab`

GameObject `Mig28`, `m_Layer: 6`.

| Component | Values |
|---|---|
| Transform | pos {0.22, 1.24, −5}, rot identity, **localScale {0.05, 0.05, 1}** |
| SpriteRenderer | material guid `a97c105638bdf8b4a8650670310a4cd3`; `m_SortingLayerID: 582728797`, `m_SortingLayer: 2`, `m_SortingOrder: 0`; **`m_Sprite` fileID `6167915509708134240` guid `d00b81c0dd60542eea9f2aea1e6671e6` (Mig28.aseprite)**; colour {1,1,1,1}; flipX 0, flipY 0; `m_DrawMode: 0`; `m_Size {1,1}` |
| Rigidbody2D | `m_BodyType: 1` (Kinematic), mass 1, linearDamping 0, angularDamping 0.05, gravityScale 1 |
| PolygonCollider2D | `m_IsTrigger: 1`, offset {0,0}, 2 paths (4 and 18 points), tiling pivot {0.48412699, 0.61904764}, oldSize {7.875, 3.9375} |
| MonoBehaviour | `MigController` (guid `80b6d3ef13257434998c21df8de762ac`); `flyby` = Mig Flyby.wav; `explosion` = Explosion.wav; `explosionSprites` = **10 entries** from explosion1.aseprite; **`distance: 20000`**; **`health: 2`** |
| AudioSource | clip none, playOnAwake 0, volume 1, pitch 1, loop 0 |

**No Animator and no Animation component.** A single static sprite.

### `Assets/Enemies/Mig28Rear.prefab`

GameObject `Mig28Rear`, `m_Layer: 6`.

| Component | Values |
|---|---|
| Transform | pos {−0.664, 1.24, 1}, rot identity, **localScale {0.05, 0.05, 1}** |
| SpriteRenderer | same material, same sorting (582728797 / 2 / 0); **`m_Sprite` fileID `6167915509708134240` guid `d00b81c0dd60542eea9f2aea1e6671e6` — the Mig28 (front) sheet, not `Mig28 Back`**; colour {1,1,1,1}; flipX 0; `m_Size {1,1}` |
| Rigidbody2D | Kinematic, gravityScale 1, angularDamping 0.05 |
| PolygonCollider2D | trigger, 2 paths (5 and 19 points), same tiling pivot/oldSize |
| MonoBehaviour | `RearMigController` (guid `b24584f27ed414b1089e38a818f02400`); same flyby/explosion clips; `explosionSprites` = **the same 10 entries**; **`overtakeSpeed: 50`**; **`health: 2`** |
| AudioSource | same as Mig28 |

**No Animator and no Animation component.** A single static sprite, and it is
the *front* sheet's sprite, identical to Mig28.prefab.

### `Assets/Enemies/Explosion.prefab`

GameObject `Explosion`, `m_Layer: 7`.

| Component | Values |
|---|---|
| Transform | pos {0,0,0}, rot identity, **localScale {1, 1, 1}** |
| SpriteRenderer | same material guid; `m_SortingLayerID: 582728797`, `m_SortingLayer: 2`, **`m_SortingOrder: 50`**; `m_Sprite` fileID `−384206497182960473` guid `e30726500687947c2843c9cc95fa1bc3` (explosion1) — the same fileID as `explosionSprites[0]`; colour {1,1,1,1}; **`m_Size {0.75, 0.71875}`** |
| **Animation** (class 111) | `m_Animation` fileID `7279527565904841652` guid `e30726500687947c2843c9cc95fa1bc3`, `m_PlayAutomatically: 1`, `m_WrapMode: 0` |
| MonoBehaviour | `ExplosionEffect` (guid `770b53a6d2a1f4d778b105c45f686c31`); **`lifetime: 0.5`**; **`fadeSpeed: 2`** |

This prefab **does** use an animation clip — but `ExplosionEffect.Start()`
destroys any Animator and drives frames from `explosionSprites` itself
(lines 19–31, 53–58). The prefab is also never instantiated by any script:
both controllers call `gameObject.AddComponent<ExplosionEffect>()` on the MiG
itself. `fadeSpeed` is serialized but **never read anywhere in the C# source.**

Material guid `a97c105638bdf8b4a8650670310a4cd3` resolves outside `Assets/`, to
`Library/PackageCache/com.unity.render-pipelines.universal@.../Runtime/Materials/Sprite-Lit-Default.mat`
— the URP default sprite material, no custom shader.

---

## 3 — Scene: `Assets/Scenes/Level One.unity`

91 objects. Scene roots, in `SceneRoots` order:
`Main Camera`, `Tomcat`, `Crosshairs`, `Sky` (prefab instance), `EventSystem`,
`UI`, `AudioEffects`.

### Hierarchy

```
Main Camera            pos {0, 0, -10}   scale {1,1,1}
  Post Processing      pos {-0.005821824, -0.90589345, 9.973644}
Tomcat                 pos {0, 2.659, -10}  scale {1,1,1}
  AudioEngine          pos {0,0,0}
  AudioAfterburner     pos {0,0,0}
  speedlines           (prefab instance, see below)
Crosshairs             pos {0, 0.431, -9}   scale {1, 1, 0}
Sky                    (prefab instance)  pos {0.157, 0, 10}  localScale.z 0
  Enemies              pos {0,0,0}  scale {1, 1, 0}   [added to the instance]
    EnemySpawner       pos {0,0,0}  scale {1,1,1}
EventSystem            pos {0,0,0}
UI                     RectTransform, scale {0,0,0}
  Panel                anchor {0.5,1}, sizeDelta {350, 32}, anchoredPos {0, -16}
  TextAltitude         anchor {0.5,0.5},  anchoredPos {-30, 120}
  TextHits             anchor {0,0.5},    anchoredPos {10, 110}
  TextScore            anchor {0,0.5},    anchoredPos {10, 120}
  TextScoreCount       anchor {0,0.5},    anchoredPos {52, 120}
  TextHitCount         anchor {0,0.5},    anchoredPos {43, 110}
  Missiles             (prefab instance)
AudioEffects           pos {4.1102595, -0.16791613, -4.323679}
  Bob / Afterburn / Gun / Missile   all pos {0,0,0}
```

All rotations in the scene are identity; all `m_LocalEulerAnglesHint` are zero.

### Prefab instances and their guid resolution

Every guid was resolved by grepping `guid:` across `*.meta`.

| Instance | fileID | `m_SourcePrefab` guid | Resolves to | Parent transform |
|---|---|---|---|---|
| **Sky** | 834568181 | `d0a0e2a9c53eb4deb939fd328d7aa828` | **`Sprites/Ocean.aseprite`** | 0 (scene root) |
| **speedlines** | 501355149 | `0aedc6c3d7ff94bd899908e18c8ee157` | **`Sprites/speedlines.aseprite`** | **1850582136 = Tomcat** |
| **Missiles** | 1805506234 | `773e9e524c0834816a5fe1fb7c4b2bfe` | **`Tomcat/Missiles.aseprite`** | 1848974428 = UI |

**The "Sky" prefab is not missing.** Its source is the model prefab that
Unity's Aseprite importer generates inside `Ocean.aseprite`
(`generateModelPrefab: 1` in the meta). The `m_SourcePrefab` fileID
`-8435245712485981826` is that generated sub-asset; the same fileID appears for
all three instances, which is the importer's fixed id for the generated prefab.
The only three `.prefab` files in the project are `Explosion`, `Mig28` and
`Mig28Rear`, and none of them is referenced by a `PrefabInstance`.

Stripped objects confirm this: `&1681221727` (Sky GameObject) and `&913759791`
(Sky Animator) both carry `m_CorrespondingSourceObject … guid:
d0a0e2a9c53eb4deb939fd328d7aa828`.

### Sky instance overrides

- `m_Name: Sky`, `m_Layer: 3`, `m_IsActive: 1`
- Animator `m_Enabled: 1`, `m_Controller` → `Sprites/Ocean Animation.controller`
  (guid `410d25100823741eab3b4888e45891d6`)
- `m_SortingLayer: 1`, `m_SortingLayerID: -1526996339`
- `m_LocalPosition {0.157, 0, 10}`, `m_LocalScale.z: 0`, rotation identity

### speedlines instance overrides

- `m_Name: speedlines`, `m_Layer: 8`
- `m_SortingLayer: 4`, `m_SortingLayerID: -296194247`
- `m_Materials.Array.data[0]` → `Sprites/speedlinesMat.shadergraph`
  (guid `268bb5b37195d4438bedcf279f3eccc0`)
- `m_LocalPosition {0, 0, 0}`, rotation identity
- `m_TransformParent: 1850582136` — **the Tomcat transform**

### Missiles instance overrides

- `m_Name: Missiles`, `m_Layer: 11`
- `m_SortingLayer: 5`, `m_SortingLayerID: -360740805`
- `m_LocalScale {32.8125, 32.8125, 32.8125}`
- `m_LocalPosition {-130, -107.4, 0}`, rotation identity
- Parented to the UI canvas

### Scene components

| Object | Component | Values |
|---|---|---|
| Main Camera | Camera | **orthographic 1, orthographic size 4.09375**, near 0, far 1000, `m_ClearFlags: 2`, background {0.31011927, 0.33153227, 0.6509434, 0} |
| Tomcat | SpriteRenderer | `m_SortingLayerID: 1006858939`, `m_SortingLayer: 3`, **`m_SortingOrder: 10`**, sprite fileID `-1909522266106633135` guid `5a74e9991a1b747a5b721861b0ffa797` (tomcat.aseprite), colour {1,1,1,1}, size {1,1} |
| Tomcat | Rigidbody2D | Kinematic, **gravityScale 0** |
| Tomcat | Animator | controller guid `cbbdc8d9624ee4cf08d30066bed149f5` |
| Tomcat | TomcatController | **`speed: 1`**, `distance: 0`; `skyanim` → Sky Animator; `gunFire` → Gun; `tm_hits`/`tm_score` **fileID 0 (unassigned — resolved by name at runtime)**; `sky` → Sky GameObject; `bobAltitude` → Altitude.wav |
| Crosshairs | SpriteRenderer | `m_SortingLayer: 3`, **`m_SortingOrder: 5`**, sprite fileID `-5168256213217209183` guid `ef3e9d48fabd54f7d8ba3a219821cff2` (Crosshairs), **`m_Size {0.13, 0.13}`** |
| Crosshairs | Rigidbody2D | Kinematic, gravityScale 1 |
| Crosshairs | CircleCollider2D | **`m_Radius: 0.1`**, `m_IsTrigger: 1`, offset {0,0} |
| EnemySpawner | EnemySpawner | `migPrefab` guid `f98256d99a63b420ab51b608ad667e09` (= Mig28.prefab), `rearMigPrefab` guid `575ff1fd2ec9e45bcb0c0f313871d1a7` (= Mig28Rear.prefab), **`timeBetweenWaves: 5`, `timeBetweenRearWaves: 7`, `enemiesPerWave: 4`, `rearEnemiesPerWave: 2`** |
| Canvas (UI) | Canvas | `m_RenderMode: 1` (Screen Space – Camera), `m_PlaneDistance: 10`, `m_SortingLayerID: -360740805`, sortingOrder 0 |
| Panel | Image | colour {0.5254902, 0.25490198, 0.7882353, **a: 0**} — fully transparent |

### Scene AudioSources

| Object | Clip guid | Clip | playOnAwake | volume | loop |
|---|---|---|---|---|---|
| AudioEngine | `ee6b9f79c13be4687890e2481ee38218` | Tomcat Engine | 1 | **0.1** | 1 |
| AudioAfterburner | `3f3c94db81acd4af2ad35ab1a97d90c3` | Tomcat Afterburner | 1 | **0.1** | 1 |
| Bob | `6a0f41af078bf47779dcb4603fc8fc72` | Altitude | 0 | **0.508** | 0 |
| Afterburn | `f65606f69b1504fe3a0ea662cda5d358` | Afterburn theme | 1 | **0.4** | 0 |
| Gun | `3bff39d21690442d4b422662c8585d25` | Gunshot | 0 | **0.1** | 0 |
| Missile | none | — | 1 | 1 | 0 |

### TextMeshPro objects

| Object | Text | Font asset guid | Font | Size |
|---|---|---|---|---|
| TextAltitude | `ALTITUDE` | `aedd7b5e924774486b7976622e1ebdce` | **Afterburn Sans Gold** | 8 |
| TextHits | `HITS` | `aedd7b5e924774486b7976622e1ebdce` | Afterburn Sans Gold | 8 |
| TextScore | `SCORE` | `aedd7b5e924774486b7976622e1ebdce` | Afterburn Sans Gold | 8 |
| TextScoreCount | `0` | `cc07a18d965e14505aeb1168f5ded753` | **Afterburn Sans White** | 8 |
| TextHitCount | `0` | `cc07a18d965e14505aeb1168f5ded753` | Afterburn Sans White | 8 |

Labels are Gold, counts are White. All colour {1,1,1,1}, all size 8.

---

## 4 — C# source: every numeric literal

### `Tomcat/TomcatController.cs`

| Line | Literal | Context |
|---|---|---|
| 50 | `10000f` | `altitude` initial |
| 51 | `0` | `distance` initial |
| 52 | `300` | `ammo` initial |
| 53 | `0` | `hits` initial |
| 54 | `0` | `score` initial |
| 108 | `1.25f` | `inputMultiplier` |
| 128 | `10f` | `delta = inputMovement * velocity * Time.deltaTime * 10f` |
| 131 | `-3.2f, 3.2f` | clamp crosshair x |
| 132 | `-2.8f, 2.8f` | clamp crosshair y |
| 136 | `10f` | `rotation = Euler(0,0, -newPosition.x * 10f)` |
| 138 | `0.5f` | aircraft rides `newPosition.y - 0.5f` |
| 139 | `4f` | lerp rate `Time.deltaTime * 4f * speed` |
| 143 | `1.5f` | `skyPosition.x = -newPosition.x * 1.5f` |
| 144 | `1.5f` | `skyPosition.y = -newPosition.y * 1.5f` |
| 148 | `8` | sky roll `Euler(0, 0, newPosition.x * 8)` |
| 155 | `-2.5f, 2.5f` | clamp `aot` |
| 156 | `-2, 2` | clamp for `stateX` |
| 162 | `1000`, `0`, `30000` | altitude integration and clamp |
| 166 | `0.5f` | UI update interval |
| 186 | `10000`, `5` | altitude warning threshold, repeat interval |
| 193 | `0.2f` | engine pitch from `|newPosition.y|` |
| 194 | `2f` | pitch lerp rate |
| 195 | `6` | `panStereo = newPosition.x / 6` |
| 200 | `0.125f` | fire interval |
| 206 | `0.4f` | `OverlapCircle` radius |
| 211 | `1` | health decrement |
| 228 | `15000f` | hit band floor |
| 231 | `500` | hit score |
| 233 | `10000f` | hit band floor |
| 236 | `200`, `10000f`, `5000f`, `200` | hit score interpolation |
| 238 | `5000f` | hit band floor |
| 241 | `100`, `5000f`, `5000f`, `100` | hit score interpolation |
| 243 | `2000f` | hit band floor |
| 246 | `50`, `2000f`, `3000f`, `50` | hit score interpolation |
| 251 | `20`, `2000f`, `30` | hit score interpolation |

### `Enemies/MigController.cs`

| Line | Literal | Context |
|---|---|---|
| 12 | `10000` | `distance` default |
| 13 | `2` | `health` default |
| 43 | `0f`, `2f` (×π) | `wobbleOffset = Random.Range(0, 2π)` |
| 44 | `2f, 4f` | `wobbleSpeed` |
| 45 | `-0.3f, 0.3f` | `driftX` |
| 46 | `-0.1f, 0.1f` | `driftY` |
| 50 | `0f, 1f` | `dirChoice` |
| 52 | `0.35f` | veer-left probability |
| 55 | `-1f` | `flybyHorizontalDir` |
| 56 | `-0.4f, 0.4f` | `flybyVerticalDir` |
| 58 | `0.7f` | veer-right probability |
| 61 | `1f` | `flybyHorizontalDir` |
| 62 | `-0.4f, 0.4f` | `flybyVerticalDir` |
| 67 | `-0.3f, 0.3f` | `flybyHorizontalDir` |
| 68 | `0f, 1f`, `0.5f`, `0.8f`, `-0.8f` | vertical veer choice |
| 82 | `0.1f` | **`scaleFactor`** |
| 85 | `4500f` | **flyby trigger distance** |
| 93 | `1`, `20000` | `normalizedDistance = 1 - distance/20000` |
| 94 | `1`, `10000` | `normalizedAltitude = 1 - altitude/10000` |
| 96 | `5` | `verticalDisplace = -normAlt * normDist * 5` |
| 97 | `25` | `horizontalDisplace = sky.x * normDist / 25` |
| 105 | — | `flybyProgress` |
| 108 | `0f, 1f` | `SmoothStep` |
| 111 | `10f` | **`maxHorizontalVeer`** |
| 112 | `6f` | **`maxVerticalVeer`** |
| 120 | `1.3f` | **horizon offset** |
| 123 | `0.5f` | drift rate during flyby |
| 126 | `1f`, `0.12f` | `altitudeScaleModifier = 1 - verticalVeer*0.12` |
| 129 | `10000`, `100` | `scale = (10000 / max(distance,100)) * scaleFactor * mod` |
| 132 | `12f`, `1.3f`, `10f`, `100f` | cull bounds |
| 141 | `0.1f` | **wobble amplitude** |
| 147 | `1.3f` | horizon offset |
| 150 | `10000` | `scale = (10000 / distance) * scaleFactor` — **no `max()` here** |
| 166 | `50f` | **`bankAngle` horizontal term** |
| 167 | `20f`, `0.5f` | **`bankAngle` vertical term = dir × prog × 20 × 0.5 = ×10** |
| 184 | `-35f` | **flipX threshold** |
| 194 | `50000`, `2`, `50` | `distance -= (50000/distance*2) + 50` |
| 206 | `6f` | **`explosionEffect.baseScale = scale * 6f`** |
| 211 | `15000f`, `1500f`, `1f`, `10f` | **`approachSpeed = clamp((15000-distance)/1500, 1, 10)`** |
| 229 | `8000f` | kill band floor |
| 232 | `300`, `8000f`, `12000f`, `300` | kill bonus |
| 234 | `4000f` | kill band floor |
| 237 | `150`, `4000f`, `4000f`, `150` | kill bonus |
| 239 | `1000f` | kill band floor |
| 242 | `50`, `1000f`, `3000f`, `100` | kill bonus |
| 247 | `20`, `1000f`, `30` | kill bonus |

### `Enemies/RearMigController.cs`

| Line | Literal | Context |
|---|---|---|
| 11 | `50f` | `overtakeSpeed` default — **never read in this file** |
| 12 | `2` | `health` default |
| 28 | `0f, 1f` | `spawnChoice` |
| 30 | `0.3f` | from-above probability |
| 33 | `-1.5f, 1.5f` | spawn x |
| 34 | `1.5f` | spawn y |
| 35 | `0.14f` | spawn scale |
| 37 | `0.6f` | from-below probability |
| 40 | `-1.5f, 1.5f` | spawn x |
| 41 | `-1.5f` | spawn y |
| 42 | `0.14f` | spawn scale |
| 44 | `0.8f` | from-left probability |
| 46 | `-2f` | spawn x |
| 47 | `-0.5f, 1f` | spawn y |
| 49 | `0.14f` | spawn scale |
| 54 | `2f` | spawn x |
| 55 | `-0.5f, 1f` | spawn y |
| 56 | `0.14f` | spawn scale |
| 71 | `0.8f` | **`moveSpeed`** |
| 75 | `2f`, `0.3f` | **`weave = sin(time*2) * 0.3`** |
| 80 | `1f`, `7f` | banking window |
| 82 | `2f`, `2f`, `20f` | **`bankAngle = cos(time*2) * 2 * 20`** → ±40° |
| 84 | `20f`, `0.2f` | bank-driven x nudge |
| 86 | `7f` | veer-off threshold |
| 90 | `45f` | **veer bank angle** |
| 91 | `1.5f` | **veer x speed** |
| 102 | `0.14f`, `0.03f`, `8f` | **`scale = Lerp(0.14, 0.03, time/8)`** |
| 105 | `0.5f` | flyby sound delay |
| 113 | `-30f` | **flipX threshold — −30, not −35** |
| 116 | `8f`, `12f`, `8f` | cull: age, \|x\|, \|y\| |
| 132 | `3f` | phase boundary |
| 133 | `2000f` | simulated distance |
| 135 | `8f`, `2000f`, `5000f`, `3f`, `5f` | simulated distance |
| 137 | `5000f`, `8000f`, `8f`, `3f` | simulated distance |
| 141 | `6f` | **`baseScale = scale * 6f`** |
| 146 | `3f`, `6f` | **`approachSpeed = 6` when time < 3** |
| 148 | `8f`, `3f`, `0.5f`, `3f`, `5f` | **`approachSpeed = Lerp(3, 0.5, (time-3)/5)`** |
| 150 | `0.3f` | **`approachSpeed = 0.3` when time ≥ 8** |
| 164 | `4000f` | kill band floor |
| 166 | `150`, `4000f`, `2000f`, `150` | kill bonus |
| 168 | `2000f` | kill band floor |
| 170 | `75`, `2000f`, `2000f`, `75` | kill bonus |
| 174 | `30`, `2000f`, `45` | kill bonus |

**The rear MiG's kill bands are a different curve from the front MiG's**
(150/300 at 4000, 75/150 at 2000, 30/75 at 0), and it never uses `distance` —
it derives `simulatedDistance` from `time`.

### `Enemies/EnemySpawner.cs`

| Line | Literal | Context |
|---|---|---|
| 9 | `5f` | `timeBetweenWaves` |
| 10 | `7f` | `timeBetweenRearWaves` |
| 11 | `4` | `enemiesPerWave` |
| 12 | `2` | `rearEnemiesPerWave` |
| 14–17 | `0f`, `0f`, `0`, `0` | timers and counters |
| 22 | `0.5f` | rear timer head start |
| 52 | `-2f, 2f` | **`xPos = Lerp(-2, 2, i/(enemiesPerWave-1))`** |
| 55 | `15000f`, `500f` | **`startDistance = 15000 + i*500`** |
| 57 | `2f` | **`spawnPos = (xPos, 2f)`** |
| 78 | `0f`, `-5f` | **rear `spawnPos = (0, -5)`** |
| 85 | `2f, 4f` | delay between rear spawns |

### `Enemies/ExplosionEffect.cs`

| Line | Literal | Context |
|---|---|---|
| 7 | `0.5f` | **`lifetime`** |
| 8 | `0.3f` | **`baseScale` default (overwritten by both callers)** |
| 9 | `0f` | `approachSpeed` default |
| 13 | `0f` | `timer` |
| 30 | `1f, 1f, 1f, 1f` | colour reset to opaque white |
| 42 | `1f` | **`pos.y -= baseScale * 1f`** |
| 45 | `1f` | z of localScale |
| 55–56 | — | `frameIndex = min(floor(timer/lifetime * N), N-1)` |
| 63 | `1f`, `10f` | **`scaleMultiplier = 1 + (timer/lifetime) * (approachSpeed/10)`** |
| 64 | `1f` | z of localScale |

**There is no fade.** `fadeSpeed` is serialized in the prefab but never read;
`Start()` sets alpha to 1 and nothing lowers it. The object is destroyed
outright at `timer >= lifetime`.

### Every transform / sprite / animation write

| File:line | Write |
|---|---|
| TomcatController:133 | `crosshairs.transform.position = newPosition` |
| TomcatController:136 | `transform.rotation = Euler(0, 0, -newPosition.x * 10f)` |
| TomcatController:137 | `transform.position = Lerp(pos, (newPosition.x, newPosition.y - 0.5f, 0), dt*4*speed)` |
| TomcatController:145 | `skyanim.SetFloat("speed", speed)` |
| TomcatController:148 | `sky.transform.rotation = Slerp(rot, Euler(0,0, newPosition.x * 8), dt*speed)` |
| TomcatController:149 | `sky.transform.position = Lerp(pos, skyPosition, dt*speed)` |
| TomcatController:152 | `sprite.flipX = newPosition.x < 0f` |
| TomcatController:158 | `anim.SetInteger("X", stateX)` |
| TomcatController:159 | `anim.SetInteger("Y", stateY)` |
| MigController:153 | `transform.position = new Vector2(finalX, finalY)` |
| MigController:154 | `transform.localScale = new Vector2(scale, scale)` |
| MigController:181 | `transform.rotation = Euler(0, 0, bankAngle)` |
| MigController:184 | `spriteRenderer.flipX = bankAngle < -35f` |
| MigController:189 | `transform.rotation = Quaternion.identity` |
| MigController:190 | `spriteRenderer.flipX = false` |
| RearMigController:34/41/48/55 | `transform.position = new Vector2(...)` (spawn) |
| RearMigController:35/42/49/56 | `transform.localScale = new Vector2(0.14f, 0.14f)` |
| RearMigController:99 | `transform.position = new Vector2(xPos, currentPos.y)` |
| RearMigController:111 | `transform.localScale = new Vector2(scale, scale)` |
| RearMigController:112 | `transform.rotation = Euler(0, 0, bankAngle)` |
| RearMigController:113 | `spriteRenderer.flipX = bankAngle < -30f` |
| EnemySpawner:59 | `Instantiate(migPrefab, spawnPos, Quaternion.identity, transform)` |
| EnemySpawner:80 | `Instantiate(rearMigPrefab, spawnPos, Quaternion.identity, transform)` |
| ExplosionEffect:29 | `spriteRenderer.sprite = explosionSprites[0]` |
| ExplosionEffect:30 | `spriteRenderer.color = Color(1,1,1,1)` |
| ExplosionEffect:33 | `transform.rotation = Quaternion.identity` |
| ExplosionEffect:36 | `spriteRenderer.flipX = false` |
| ExplosionEffect:43 | `transform.position = pos` (y lowered by `baseScale`) |
| ExplosionEffect:45 | `transform.localScale = new Vector3(baseScale, baseScale, 1f)` |
| ExplosionEffect:57 | `spriteRenderer.sprite = explosionSprites[frameIndex]` |
| ExplosionEffect:64 | `transform.localScale = Vector3(baseScale*mult, baseScale*mult, 1f)` |

**No script writes a sprite animation frame on either MiG.** `MigController`
lines 157–180 state the aircraft uses a single sprite and that a nine-view
system is not built:

> `// NOTE: This calculates the viewing angle for future 9-sprite system`
> `// TODO: Replace with sprite selection based on bankAngle when 9 sprites ready`

---

## 5 — Materials and fonts

### `Sprites/speedlinesMat.shadergraph`

32 JSON documents. Target: `UniversalTarget` with
`UniversalSpriteUnlitSubTarget` — **Sprite Unlit**, no lighting.

Target settings:

| Field | Value |
|---|---|
| `m_SurfaceType` | 0 (Opaque) |
| `m_AlphaMode` | **2 (Additive)** |
| `m_RenderFace` | 2 (Both) |
| `m_ZTestMode` | 4 (LEqual) |
| `m_ZWriteControl` | 0 (Auto) |
| `m_AlphaClip` | false |
| `m_AllowMaterialOverride` | false |

Node graph — four edges, read from `GraphData.m_Edges`:

```
Property(Texture2D) ──slot0──▶ Sample Texture 2D ──slot0──▶ Multiply.A (slot0)
Color ──────────────slot0──▶ Multiply.B (slot1)
Multiply ───────────slot2──▶ SurfaceDescription.BaseColor (slot0)
```

- `Texture2DShaderProperty` named `Texture`, default texture
  fileID `-8328923581568760697` guid `0aedc6c3d7ff94bd899908e18c8ee157`
  — a sprite out of `speedlines.aseprite`.
- `ColorNode` value **{r: 0.15399514138698578, g: 0.14449094235897064,
  b: 0.1603773832321167, a: 0.0}**, `mode: 0` (Default/sRGB).
- `MultiplyNode` slot B has a stored default of 2.0 in every component, but
  **slot B is driven by the Color node**, so the 2.0 never reaches the shader.

`SurfaceDescription.Alpha` is a block node with **no incoming edge**, so alpha
stays at its default. The vertex blocks (Position, Normal, Tangent) are
likewise unconnected — pass-through.

**What it does:** samples the speedlines texture and multiplies the RGBA by a
near-black colour (≈0.154, 0.144, 0.160) whose alpha is 0, then writes that to
BaseColor and draws it **additively**. Additive blending ignores the
destination-darkening a low multiplier would do in alpha blending; the effect
is a very faint additive brightening — roughly 15 % of the texture's own
brightness added to whatever is behind it.

### TMP fonts, `Assets/Fonts/`

Four assets. The scene uses only the two Sans variants.

| Asset | Family name | Atlas | Glyphs |
|---|---|---|---|
| `Afterburn Gold.asset` | Afterburn Gold | 128 × 64 | 94 |
| `Afterburn White.asset` | Afterburn White | 128 × 64 | 94 |
| `Afterburn Sans Gold.asset` | **Afterburn Sans Gold** | 128 × 64 | 95 |
| `Afterburn Sans White.asset` | **Afterburn Sans Gold** (sic) | 128 × 64 | 95 |

`Afterburn Sans White.asset` carries `m_FamilyName: Afterburn Sans Gold` — the
family name was not changed when the white variant was made. Cosmetic.

Face metrics, identical across all four:

| Metric | Value |
|---|---|
| `m_PointSize` | **8** |
| `m_Scale` | 1 |
| `m_LineHeight` | **8** |
| `m_AscentLine` | **6** |
| `m_CapLine` | **8** |
| `m_MeanLine` | 0 |
| `m_Baseline` | **0** |
| `m_SuperscriptOffset` | 6 |
| `m_SubscriptOffset` | −2 |
| `m_UnderlineOffset` | 0.6015625 |
| `m_UnderlineThickness` | 0.3984375 |
| `m_StrikethroughOffset` | 3.2 |
| `m_StrikethroughThickness` | 0.3984375 |
| `m_TabWidth` | 1 |

Atlas: `m_AtlasWidth: 128`, `m_AtlasHeight: 64`, `m_AtlasPadding: 1`,
`m_AtlasRenderMode: 4122`, `m_AtlasPopulationMode: 0` (Static).
All four share `m_SourceFontFileGUID: 6b766bea0c00c4a6599c7291f3c51cf3`.

Glyph advances in the Sans fonts take only the values **1, 6, 7, 8, 9** — a
fixed-step bitmap face. Sample glyphs from `Afterburn Gold`:
index 2 → advance 1, 1 × 1 rect (space);
index 3 → 4 × 8, bearing (2, 8), advance 7;
index 4 → 5 × 3, bearing (2, 5), advance 8;
index 5 → 8 × 8, bearing (0, 8), advance 9.

---

## 6 — Coordinate mapping, Unity → Godot

Unity 2D: **+y up**, rotation **counter-clockwise positive**, positions in
**world units** at `spritePixelsToUnits: 32`.
Godot 2D: **+y down**, rotation **clockwise positive**, positions in **pixels**.

Three transformations, each applied independently:

1. **Scale**: `pixels = units × 32` (PPU from the meta, §1).
2. **Vertical axis**: `y_godot = −y_unity`. Any expression whose result is a
   y-coordinate or a y-offset flips sign.
3. **Rotation**: `rotation_godot_degrees = −rotation_unity_z_degrees`.

   Derivation. A Unity rotation of +θ about +z maps a point
   `(x, y) → (x cos θ − y sin θ, x sin θ + y cos θ)`. Substituting `y = −y'`
   to express the same motion in Godot's frame gives
   `(x, y') → (x cos θ + y' sin θ, −x sin θ + y' cos θ)`.
   Godot's own rotation by `φ` is `(x cos φ − y' sin φ, x sin φ + y' cos φ)`.
   Matching terms: `cos φ = cos θ` and `−sin φ = sin θ`, so **`φ = −θ`**.

   Where Unity writes `Euler(0, 0, A)`, Godot uses `rotation_degrees = -A`.

### Every transform write from §4, mapped

| # | Unity write (file:line) | Unity expression | Godot equivalent | Sign derivation |
|---|---|---|---|---|
| 1 | TomcatController:133 | `crosshairs.position = newPosition` where `newPosition = crossPos + input*speed*dt*10`, clamped x ∈ [−3.2, 3.2], y ∈ [−2.8, 2.8] | `crosshairs.position = Vector2(clamp(ax, -3.2*32, 3.2*32), clamp(ay, -2.8*32, 2.8*32))` with the stick's y **negated** at the input | x: ×32 only. y: ×32 and ×(−1); clamp bounds are symmetric so they are unchanged by the flip. |
| 2 | TomcatController:136 | `rotation = Euler(0, 0, -newPosition.x * 10f)` | `rotation_degrees = +(aim.x / 32) * 10` | Unity angle `A = −x·10`. Godot `= −A = +x·10`. x is unaffected by the y-flip, so the aim x in **pixels** is divided by 32 to recover units. |
| 3 | TomcatController:137 | `position = Lerp(position, (newPosition.x, newPosition.y − 0.5f, 0), dt*4*speed)` | `position = position.lerp(Vector2(aim.x, aim.y + 0.5*32), 1 − exp(−4*speed*dt))` | x: ×32. y: Unity subtracts 0.5 units (**downward** in Unity, since −y is down); in Godot down is **+y**, so the offset becomes `+0.5*32 = +16 px`. Lerp rate is frame-rate dependent in Unity; `1 − exp(−k·dt)` is the delta-independent equivalent. |
| 4 | TomcatController:148 | `sky.rotation = Slerp(rot, Euler(0,0, newPosition.x * 8), dt*speed)` | `sky.rotation_degrees = lerp(cur, −(aim.x / 32) * 8, 1 − exp(−speed*dt))` | Unity angle `A = +x·8`. Godot `= −A = −x·8`. |
| 5 | TomcatController:149 | `sky.position = Lerp(pos, (−newPosition.x*1.5, −newPosition.y*1.5), dt*speed)` | `sky.position = sky.position.lerp(Vector2(−aim.x*1.5, +aim.y*1.5), w)` | x: ×32, factor −1.5 kept. y: Unity `−y·1.5`; flipping gives `−(−y_g·1.5) = +y_g·1.5`. **The y factor becomes +1.5, not −1.5.** |
| 6 | TomcatController:152 | `sprite.flipX = newPosition.x < 0f` | `sprite.flip_h = aim.x < 0.0` | x only; unchanged. |
| 7 | TomcatController:155–157 | `aot = clamp(crossY − tomcatY, −2.5, 2.5)`; `stateY = round(aot)`; `stateX = abs(round(clamp(newPosition.x, −2, 2)))` | `aot = clamp(−(cross.y − tomcat.y)/32, −2.5, 2.5)`; same rounding | `aot` is a **difference of y values**, so it flips sign: `y_u = −y_g` on both terms gives `aot_u = −(cross_g − tomcat_g)`. Divide by 32 for units. `stateX` uses x only, unchanged. |
| 8 | TomcatController:162 | `altitude = clamp(altitude + 1000*transform.position.y*dt, 0, 30000)` | `altitude += 1000 * (−position.y/32) * dt` | Climb follows Unity's **+y up**, so Godot's `position.y` is negated; ÷32 for units. |
| 9 | TomcatController:195 | `audioEngine.panStereo = newPosition.x / 6` | `pan = (aim.x/32) / 6` | x only; ÷32 for units. |
| 10 | TomcatController:206 | `OverlapCircle(crosshairs.position, 0.4f, mask)` | circle query, `radius = 0.4 * 32 = 12.8 px` | Radius is a length: ×32, no sign. |
| 11 | MigController:153 | `position = (finalX, finalY)` where `finalY = sky.y + 1.3 − verticalDisplace (+ verticalVeer)` | `position.y = −(sky_y_u) − 1.3*32 + drop*32 (− veer_y*32)`, i.e. compute in Godot as `horizon − drop (+ veer)` with `horizon = sky.position.y − 1.3*32` | Every term of `finalY` flips. `+1.3` (up in Unity) becomes `−1.3·32` px in Godot. `verticalDisplace` is itself `−normAlt·normDist·5`, so `−verticalDisplace` is `+normAlt·normDist·5` up in Unity ⇒ **negative** y in Godot. |
| 12 | MigController:154 | `localScale = (scale, scale)` | `scale = Vector2(s, s)` | Dimensionless ratio. **No ×32 and no sign flip.** `s = 0.1 * 10000/distance` exactly as in Unity. |
| 13 | MigController:181 | `rotation = Euler(0, 0, bankAngle)` where `bankAngle = hDir·prog·50 + vDir·prog·20·0.5` | `rotation_degrees = −bankAngle` | Angle flip. The `vDir` term also encodes a vertical direction, and `vDir` itself flips when the break course is expressed in Godot's frame — the two negations in that term cancel, so express the course in **Unity's** frame and negate once at the end. |
| 14 | MigController:184 | `spriteRenderer.flipX = bankAngle < −35f` | `sprite.flip_h = bankAngle_unity < −35.0` — equivalently `rotation_degrees > 35.0` | Test the Unity-frame angle, or invert the comparison when testing the Godot angle. |
| 15 | MigController:189–190 | `rotation = identity; flipX = false` | `rotation = 0.0; flip_h = false` | No sign. |
| 16 | MigController:141 | `wobble = sin(t·ws + wo) · 0.1 · normDist`, added to **x** | `+ sin(...) * 0.1 * 32 * depth` on x | x only: ×32, no flip. |
| 17 | MigController:97 | `horizontalDisplace = sky.x · normDist / 25` | `slide = sky.position.x * depth / 25` | x only, and both sides are already in pixels, so **no extra ×32** — the ratio `/25` is dimensionless. |
| 18 | MigController:111–112, 119–120 | `maxHorizontalVeer = 10f`, `maxVerticalVeer = 6f` | `10*32 = 320 px`; `6*32 = 192 px`, applied with a **negated** sign on y | Lengths: ×32. The vertical veer's direction flips with the axis. |
| 19 | MigController:132 | cull `|finalX| > 12`, `|finalY − (sky.y+1.3)| > 10`, `distance < 100` | `|x| > 12*32`, `|y − horizon| > 10*32`, `distance < 100` | Lengths ×32. The y test is on an **absolute difference**, so the flip cancels. `distance` is not a world coordinate — **no conversion.** |
| 20 | RearMig:34/41/48/55 | spawn `(x, 1.5)`, `(x, −1.5)`, `(−2, y)`, `(2, y)`, x ∈ [−1.5,1.5], y ∈ [−0.5,1] | `(x*32, −1.5*32)`, `(x*32, +1.5*32)`, `(−2*32, −y*32)`, `(2*32, −y*32)` | **The above/below cases swap**: Unity `+1.5` (above) is Godot `−48`; Unity `−1.5` is Godot `+48`. The side cases keep x and negate the random y range, whose bounds are **asymmetric** (`[−0.5, 1]` becomes `[−1, 0.5]`). |
| 21 | RearMig:35/42/49/56 | `localScale = (0.14, 0.14)` | `scale = Vector2(0.14, 0.14)` | Dimensionless. No conversion. |
| 22 | RearMig:68–72 | `dir = pos.normalized`; `pos += dir · 0.8 · dt` | `pos += pos.normalized() * 0.8*32 * dt` | A normalized direction is invariant under a uniform y-flip of both the vector and the frame. Speed is a length rate: ×32. |
| 23 | RearMig:75–77 | `perp = (−dir.y, dir.x)`; `pos += perp · weave · dt`, `weave = sin(2t)·0.3` | `across = Vector2(−dir.y, dir.x)`; `pos += across * sin(2t) * 0.3*32 * dt` | Under `y → −y`, `dir = (dx, −dy_g)` and Unity's perp `(−dir.y, dir.x) = (dy_g, dx)`; mapping that back to Godot gives `(dy_g, −dx)`, which is **`−(−dir_g.y, dir_g.x)`**. So the cross-track term flips sign; equivalently keep `(−dir.y, dir.x)` and negate the weave. Amplitude ×32. |
| 24 | RearMig:99 | `position = (xPos, currentPos.y)` | `position.x = xPos` only | x write; y untouched, so no flip needed. |
| 25 | RearMig:102 | `scale = Lerp(0.14, 0.03, time/8)` | `lerpf(0.14, 0.03, age/8.0)` | Dimensionless. |
| 26 | RearMig:111 | `localScale = (scale, scale)` | `scale = Vector2(s, s)` | Dimensionless. |
| 27 | RearMig:112 | `rotation = Euler(0, 0, bankAngle)`, `bankAngle = cos(2t)·2·20` = ±40, or `veerSide·45` | `rotation_degrees = −bankAngle` | Angle flip. |
| 28 | RearMig:113 | `flipX = bankAngle < −30f` | `flip_h = bankAngle_unity < −30.0` | Threshold is **−30**, distinct from the front MiG's **−35**. |
| 29 | RearMig:84, 91 | `xPos = currentPos.x + (bank/20)·dt·0.2`; `xPos = currentPos.x + veerSide·dt·1.5` | `+ (bank_u/20)*dt*0.2*32`; `+ side*dt*1.5*32` | x only: ×32, no flip. |
| 30 | RearMig:116 | cull `time > 8`, `|x| > 12`, `|y| > 8` | `age > 8`, `|x| > 12*32`, `|y| > 8*32` | Absolute values; flip cancels. ×32. |
| 31 | Spawner:52, 57 | `xPos = Lerp(−2, 2, i/(n−1))`; `spawnPos = (xPos, 2f)` | `Vector2(lerp(−2*32, 2*32, t), −2*32)` | x: ×32, symmetric. y: Unity `+2` (up) ⇒ Godot **`−64`**. |
| 32 | Spawner:55 | `startDistance = 15000 + i*500` | `15000.0 + i*500.0` | `distance` is a game-logic scalar, **not** a coordinate. No ×32, no flip. |
| 33 | Spawner:78 | rear `spawnPos = (0, −5)` | `Vector2(0, +5*32)` | Unity `−5` (below) ⇒ Godot **`+160`**. Note both controllers overwrite this in `Start()`. |
| 34 | Explosion:42 | `pos.y −= baseScale * 1f` | `position.y += baseScale * 1.0` | Unity lowers y (down); Godot's down is +y ⇒ **`+=`**. `baseScale` is dimensionless, applied to a position here — Unity's own code mixes a scale into a world offset, so this offset is in **units**: ×32 in Godot. |
| 35 | Explosion:45, 64 | `localScale = (baseScale, baseScale, 1)`; `× scaleMultiplier` | `scale = Vector2(b, b)`; `× mult` | Dimensionless. |

### Summary of the three rules

| Quantity | Conversion |
|---|---|
| x position / x offset / x length | `× 32` |
| y position / y offset | `× −32` |
| length, radius, absolute-value bound | `× 32` |
| `localScale` | unchanged (dimensionless) |
| z-euler rotation (degrees) | `× −1` |
| `distance`, `altitude`, score, time | unchanged |
| normalized direction vector | invariant |
| perpendicular `(−y, x)` of a direction | **sign flips** |

---

## 7 — Defect list and what was changed

Fifty-three defects. Each row names the fix applied in task 8.

| # | File | Defect | Fix |
|---|---|---|---|
| D1 | `mig.tscn` | MiG animated over 5 frames; the prefab has a single static sprite and the nine-view system is an explicit TODO (`MigController.cs:157-180`). | `Sprite` is now a `Sprite2D` with one `AtlasTexture`. |
| D2 | `mig.tscn` | Frame regions `0,320,640,1280,1600` skipped index 3 arbitrarily. | Gone with D1. |
| D3 | `rear_mig.tscn` | Used `Mig28 Back.png`. The prefab's sprite guid is `d00b81c0…` = **Mig28.aseprite**, the front sheet. | Now references `Mig28.png`, matching the prefab. |
| D4 | `rear_mig.tscn` | Animated over 5 frames; prefab is a single static sprite. | `Sprite2D` with one region. |
| D5 | both mig scenes | Explosion animation had **11** frames; Unity uses **10**. | Reduced to 10, matching `explosionSprites`. |
| D6 | both mig scenes | Explosion `speed = 18.0` fps. | **20.0** fps = 10 frames / `lifetime` 0.5 s. |
| D7 | `mig.gd`, `rear_mig.gd` | `explosion.scale = Vector2.ONE * 6.0` — 6.0 absolute. | `scale.x * Explosion.SCALE_MULTIPLE`, six times the aircraft's own scale. |
| D8 | `mig.gd`, `rear_mig.gd` | No `approachSpeed` growth and no downward recentring. | New `scripts/explosion.gd` implements `ExplosionEffect.cs` whole: frame stepping over `LIFETIME`, growth by `1 + t/L * (speed/10)`, the `baseScale` y drop, no fade. |
| D9 | `mig.gd` | `BANK_VERTICAL = 10.0` then multiplied by `0.5` again — effective 5.0. | `BANK_VERTICAL = 20.0` and `BANK_VERTICAL_WEIGHT = 0.5`, as the source spells it. |
| D10 | `mig.gd` | `maxf(distance, 1.0)` in the distance decrement. | Divides by raw `distance`. |
| D11 | `mig.gd` | Approach scale clamped at 1.0. | Approach divides by raw `distance`; only the break-off branch clamps, at **100**. |
| D12 | `mig.gd` | Bare `10000.0` altitude divisor. | Named `ALTITUDE_REFERENCE`. |
| D13 | `rear_mig.gd` | `BANK_WEAVE = 40.0` hid the source's `2 * 20`. | `BANK_WEAVE_GAIN = 2.0` and `BANK_WEAVE_SPAN = 20.0`. |
| D14 | `rear_mig.gd` | Scored off the front MiG's bands. | `Scoring.REAR_KILL_BANDS` added; `_simulated_distance()` reproduces `RearMigController.cs:131-137`. |
| D15 | `rear_mig.gd` | Weave bank not negated for Godot's euler. | All state held in the source's frame; `_commit()` writes `rotation_degrees = -_bank`. |
| D16 | `rear_mig.gd` | Cross-track weave sign. | Resolved by D15: the perpendicular is computed in the source's frame, then the whole position flips once. |
| D17 | `rear_mig.gd` | Spawn y unflipped; above/below swapped; side y range not negated. | Spawn positions held in source units and flipped in `_commit()`. |
| D18 | `rear_mig.gd` | Weave ran from t=0. | Gated to `BANK_FROM < age < BANK_UNTIL`, and `_bank = 0` below 1 s. |
| D19 | `rear_mig.gd` | No positional cull. | `|x| > 12`, `|y| > 8` in world units, alongside the lifetime check. |
| D20 | `tomcat.gd` | `speed` folded into a constant. | `const SPEED = 1.0` named and commented as the scene's serialized value. |
| D21 | `tomcat.gd` | Roll used the aircraft's x. | Uses `_aim.x` — the crosshair's — per `TomcatController:136`. |
| D22 | `tomcat.gd` | Sky slide negated both axes. | `Vector2(-_aim.x, _aim.y) * 1.5`; the y sign survives the axis flip. |
| D23 | `tomcat.gd` | `ATTACK_SPAN = 1.75` and its pitch formula appear nowhere in the source. **Invented.** | Replaced with the source's `aot = clamp(aimY - tomcatY, -2.5, 2.5)`, `state_y = round(aot)`. |
| D24 | `tomcat.gd` | Provenance of the bank/flip split. | `flip_h` now tests `_aim.x < 0` directly, as `TomcatController:152` does. |
| D25 | `tomcat.gd` | Engine pitch normalised by `AIM_BOUNDS.y` and lerped at a fixed 0.05. **Invented.** | `SPEED + |aim.y| * 0.2`, lerped at `2.0 * delta`. |
| D26 | `tomcat.gd` | No stereo pan. | **Not fixed — not portable.** No `AudioStreamPlayer` in Godot 4.7.2 exposes a stereo pan (property list checked). Documented in the function's comment rather than approximated. |
| D27 | `tomcat.gd` | — | `AIM_RADIUS = 0.4` units, converted at use. Verified distinct from the scene collider's 0.1. |
| D28 | `tomcat.gd` | Pose grid reachability. | **Corrected finding.** `TomcatAnimator.controller` maps (X,Y) to poses with Y ∈ −2..2 only, so `D3C`, `D3R1`, `D3R2` have no transition into them. They are kept in the SpriteFrames as authored; the comment in `tomcat.tscn` records this. |
| D29 | `game.tscn` | **Speedlines was a child of `Sky`.** | Reparented to **Tomcat**, per `m_TransformParent: 1850582136`. |
| D30 | `game.tscn` | Speedlines had no material. | `CanvasItemMaterial` with `blend_mode = 1` (additive) and `modulate` set to the shadergraph's Color node. |
| D31 | `game.tscn` | Ocean at `(0, -36)`. **Invented.** | Removed. `Sky` carries the source's `{0.157, 0}` ⇒ `(5.024, 0)`; Ocean sits at its parent's origin. |
| D32 | `game.tscn` | Ocean `speed = 12.0` fps. | **23.8095** fps = 1000/42 ms. |
| D33 | `game.tscn` | Speedlines `speed = 24.0` fps. | **12.0482** fps = 1000/83 ms. |
| D34 | `game.tscn` | Crosshairs `speed = 10.0` fps. | Already correct (100 ms). Kept. |
| D35 | `game.tscn` | Camera at `(0, 2)`. **Invented.** | Removed. The source's camera is at the origin in x/y, and its ortho size 4.09375 × 32 × 2 = **262 px**, which is exactly `project.godot`'s `viewport_height`. |
| D36 | `game.tscn` | Crosshairs at origin. | `(0, -13.792)` from `{0, 0.431}`. |
| D37 | `game.tscn` | Tomcat had no position. | `(0, -85.088)` from `{0, 2.659}`. |
| D38 | `game.tscn` | No `Missiles` node. | **Not fixed.** It is a UI decoration under the canvas; adding it would need the HUD rebuilt around a Control tree, which the source's five fixed labels do not require. Recorded here rather than guessed at. |
| D39 | `tomcat.tscn` | `Muzzle` marker at `(0, -6)`. **Invented.** | Removed. `gunFire` points at the Gun AudioSource GameObject at `{0,0,0}`; `fired` now emits the crosshair position. |
| D40 | `tomcat.tscn` | `Engine` `max_distance = 4000`, `panning_strength = 1.5`. **Invented.** | Removed. `Engine` is now a non-spatial `AudioStreamPlayer`, matching a Unity AudioSource with `Pan2D: 0` and an explicit `panStereo`. |
| D41 | `tomcat.tscn` | Pose speed 12.0 fps. | **12.0482** fps = 1000/83 ms. |
| D42 | `*.tscn` | No sorting order. | Draw order now follows tree order, which reproduces the source's layering: Sky/Ocean behind, Tomcat with Speedlines as its child, Crosshairs, HUD. Numeric sorting layers are not carried over as numbers. |
| D43 | `hud.tscn` | Three labels in a VBox. | Five labels at the source's anchors and offsets: `TextAltitude`, `TextHits`, `TextScore`, `TextHitCount`, `TextScoreCount`. |
| D44 | `hud.gd` | Formatted `"SCORE %06d"` etc. | Counts are bare numbers in their own labels, refreshed every 0.5 s, as `TomcatController:166-180` does. The altitude count does not exist in the source and is not invented. |
| D45 | `spawner.gd` | `SPAWN_DISTANCE - 5000.0 + i * stagger`. | `START_DISTANCE = 15000.0` written directly. |
| D46 | `spawner.gd` | Spawn y `+64.0` unflipped. | `-SPAWN_HEIGHT * PPU` = `-64.0`. |
| D47 | `spawner.gd` | Rear spawn position never set. | `(0, +160)` from `{0, -5}`. |
| D48 | `flight.gd` | — | `MAX_ALTITUDE`, `START_ALTITUDE`, `SPAWN_DISTANCE` all verified. Unused signals removed now the HUD polls. |
| D49 | `scoring.gd` | Interpolation derived the span from the next band's floor; the source hard-codes each divisor. | Each band now carries its own divisor, so the 8000 kill band divides by **12000** as the source does. |
| D50 | `audio.gd` | No volumes. | `VOLUMES` table with the scene's levels; `get_volume_db()` applied to engine, gun and warning. |
| D51 | `tomcat.gd` | — | `CLIMB_RATE = 1000.0` verified. |
| D52 | `tomcat.gd` | — | `FIRE_INTERVAL`, `ALTITUDE_WARN`, `WARN_INTERVAL` verified. |
| D53 | `tomcat.gd` | Ammo decremented and gated firing; the source never touches `ammo`. | `AMMO_START` and the ammo gate removed. |

### Defects found during the fix

| # | File | Defect |
|---|---|---|
| D54 | `assets/fonts/*.png.import` | `importer="skip"`. The atlas the `.fnt` references is not imported, so the font renders nothing. **Fixed** — all three atlas PNGs now carry a `texture` / `CompressedTexture2D` import copied from `assets/sprites/Mig28.png.import`, with `mipmaps/generate=false` and the project's default texture filter 0 (Nearest), matching the source's `filterMode: 0`. |
| D55 | `assets/fonts/` | The port carried only **Afterburn Gold**. The scene uses **Afterburn Sans Gold** (labels) and **Afterburn Sans White** (counts). **Fixed** — both Sans atlases copied from `Assets/Fonts/`, and `AfterburnSansGold.fnt` / `AfterburnSansWhite.fnt` generated from their `.asset` glyph tables. `hud.tscn` now binds Gold to the three labels and White to the two counts. |

---

## 8 — Verification

```
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 600
```

```
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

WARNING: 4 ObjectDB instances were leaked at exit (run with `--verbose` for details).
   at: cleanup (core/object/object.cpp:2536)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:822)
```

**Zero script errors and zero parse errors.** The two remaining lines are
Godot's headless shutdown accounting, emitted for the autoload singletons that
are still referenced when the tree tears down; they are not script faults.

A temporary in-scene probe (added, run, removed) exercised the loop for six
seconds and then killed every enemy:

```
enemies alive: 5
killed=5 score=4151 hits=5
tomcat pose=CC
sky pos=(0.012453, 20.63672) alt=10245.5192957307
speedlines parent=Tomcat
after explosion window, enemies=0
```

Waves spawn, hits score, kills register, explosions run their lifetime and free
their aircraft, and speedlines is parented to Tomcat.

## 9 — The four remaining items, resolved

### Fonts (D54, D55) — resolved

`Level One.unity` names a font asset guid per TextMeshPro. Grepped straight out
of the scene:

| Object | line | `m_fontAsset` guid | Face |
|---|---|---|---|
| TextScoreCount | 686 | `cc07a18d965e14505aeb1168f5ded753` | Afterburn Sans White |
| TextHitCount | 910 | `cc07a18d965e14505aeb1168f5ded753` | Afterburn Sans White |
| TextAltitude | 1308 | `aedd7b5e924774486b7976622e1ebdce` | Afterburn Sans Gold |
| TextHits | 2543 | `aedd7b5e924774486b7976622e1ebdce` | Afterburn Sans Gold |
| TextScore | 2681 | `aedd7b5e924774486b7976622e1ebdce` | Afterburn Sans Gold |

Both guids resolve in `Assets/Fonts/*.asset.meta`. Each `.asset`'s material
`_MainTex` names its own atlas guid — Sans Gold →
`7a66a7084670648c3b368b548a63b53e` = `Afterburn Sans Gold Atlas.png`, Sans
White → `d5f54e96ab536404c84f9819a7191ae3` = `Afterburn Sans White Atlas.png`
— so the two faces do **not** share an atlas. Both are 128 × 64, read from the
PNG IHDR.

Both atlases were copied into `assets/fonts/`, and a BMFont descriptor was
generated per face from `m_GlyphTable` and `m_CharacterTable`:

| Field | Source |
|---|---|
| `size` | `m_PointSize` = 8 |
| `lineHeight` | `m_LineHeight` = 8 |
| `base` | `m_CapLine` − `m_Baseline` = 8 |
| `scaleW`/`scaleH` | `m_AtlasWidth`/`m_AtlasHeight` = 128 × 64 |
| `x`, `width`, `height` | `m_GlyphRect` |
| `y` | `m_AtlasHeight − m_GlyphRect.m_Y − m_GlyphRect.m_Height` |
| `xoffset` | `m_HorizontalBearingX` |
| `yoffset` | `base − m_HorizontalBearingY` |
| `xadvance` | `m_HorizontalAdvance` |
| char → glyph | `m_CharacterTable` `m_Unicode` → `m_GlyphIndex` |

95 glyphs and 95 characters per face.

Two details the tables force:

- **`base` is `m_CapLine`, not `m_AscentLine`.** The face declares
  `m_AscentLine: 6`, but the largest `m_HorizontalBearingY` over the glyph
  table is **8**, which is `m_CapLine`. Using the ascent would put every cap at
  `yoffset = −2`, above the line box. With CapLine every `yoffset` is ≥ 0.
- **The space glyph is degenerate.** Glyph index 2 carries a 1 × 1
  `m_GlyphRect` at (22, 61) with `m_Width`/`m_Height` 0 and
  `m_HorizontalAdvance` 1. The 1 × 1 rect is a placeholder, not ink, so U+0020
  is emitted with a zero-size source region and the advance of 1 kept.

`Afterburn Sans White.asset` carries `m_FamilyName: Afterburn Sans Gold` — the
family name was not updated when the white variant was made. Two fonts under
one family name collide in Godot's font cache, so the white descriptor's
`face=` is written as `Afterburn Sans White`. Glyph data is untouched.

The three atlas `.import` files were rewritten from `importer="skip"` to the
`texture` importer, structured on `assets/sprites/Mig28.png.import`, with
`mipmaps/generate=false`. The project already sets
`textures/canvas_textures/default_texture_filter=0` (Nearest), matching the
source's `filterMode: 0`.

**Verified by rendering.** A temporary probe screenshotted the running game
after two seconds and read each label back:

```
PROBE label TextAltitude   text='ALTITUDE' font=Afterburn Sans Gold  rect=[P: (185.5, 11.0), S: (64.0, 120.0)]
PROBE label TextHits       text='HITS'     font=Afterburn Sans Gold  rect=[P: (10.0, 21.0),  S: (31.0, 110.0)]
PROBE label TextScore      text='SCORE'    font=Afterburn Sans Gold  rect=[P: (10.0, 11.0),  S: (41.0, 120.0)]
PROBE label TextHitCount   text='0'        font=Afterburn Sans White rect=[P: (43.0, 21.0),  S: (8.0, 110.0)]
PROBE label TextScoreCount text='0'        font=Afterburn Sans White rect=[P: (52.0, 11.0),  S: (8.0, 120.0)]
```

`ALTITUDE` measures 64 px = 8 characters × advance 8, and the screenshot shows
the three gold words and the two white counts drawn. The probe was removed.

### MiG sprite frame — resolved, `Mig28_Frame_0`

Both prefabs name `m_Sprite: {fileID: 6167915509708134240, guid:
d00b81c0dd60542eea9f2aea1e6671e6}`. `Mig28.aseprite.meta` has
`internalIDToNameTable: []` and no `m_SpriteSheetMetaData` / `m_Sprites`
array, so the meta carries no id→name mapping; and no byte order, nibble swap,
half, or xor fold of any of the twelve `spriteID` guids produces that fileID.

It resolves in the imported artifact. Scanning `Library/` for the fileID as
raw bytes finds it in `Library/Artifacts/d7/d70ac36773824ce86a3c48be0aa9f2b1`
at offset 73324, inside an object table of 24-byte records
`(fileID:i64, offset:i64, size:u32, classID:u32)`. Twelve records carry
`classID 2, size 820` — the twelve sprites. Their offsets and the twelve
length-prefixed `Mig28_Frame_N` name strings in the file's data section are in
one-to-one correspondence with a constant delta:

| Name | Object start | Table offset | delta |
|---|---|---|---|
| Mig28_Frame_10 | 5666216 | 0x555630 | 73592 |
| Mig28_Frame_7 | 5667048 | 0x555970 | 73592 |
| Mig28_Frame_8 | 5668328 | 0x555e70 | 73592 |
| Mig28_Frame_1 | 5669160 | 0x5561b0 | 73592 |
| Mig28_Frame_6 | 5673720 | 0x557380 | 73592 |
| Mig28_Frame_3 | 5674552 | 0x5576c0 | 73592 |
| Mig28_Frame_4 | 5675496 | 0x557a70 | 73592 |
| Mig28_Frame_9 | 5676328 | 0x557db0 | 73592 |
| Mig28_Frame_2 | 5677416 | 0x5581f0 | 73592 |
| **Mig28_Frame_0** | **5679016** | **0x558830** | **73592** |
| Mig28_Frame_5 | 5679976 | 0x558bf0 | 73592 |
| Mig28_Frame_11 | 5680808 | 0x558f30 | 73592 |

The eleven inter-object gaps match the eleven inter-offset gaps exactly
(832, 1280, 832, 4560, 832, 944, 832, 1088, 1600, 960, 832), so the alignment
is not a coincidence. fileID `6167915509708134240` sits at `0x558830`, which is
**`Mig28_Frame_0`**.

Confirmed independently from the object's own body: the 820 bytes at 5679016
decode to name `Mig28_Frame_0`, floats `643, 336, 254, 128` (the rect),
`32` (pixels-to-units) and `0.4843, 0.6172` (the pivot), and contain the ascii
guid `fad2cb079575e4a7d9485daf0e5313eb`. All four match Frame_0's entry in
`Mig28.aseprite.meta` exactly.

`mig.tscn` and `rear_mig.tscn` already drew region `Rect2(0, 0, 320, 156)` —
frame 0 — so no region changed. The `; NOT VERIFIED` comments were replaced
with the derivation.

### `Ocean Animation.controller` — read, and the gate is real

One layer, one state, no transitions.

| Field | Value |
|---|---|
| state `m_Name` | `Ocean_Clip` |
| state `m_Speed` | **1** |
| state `m_SpeedParameterActive` | **1** |
| state `m_SpeedParameter` | **`speed`** |
| state `m_Motion` | fileID `-1158855765760348317`, guid `d0a0e2a9c53eb4deb939fd328d7aa828` (Ocean.aseprite) |
| controller parameter | `speed`, `m_Type: 1` (float), `m_DefaultFloat: 1` |
| `m_DefaultState` | `Ocean_Clip` |

So the ocean **is** gated on the parameter `TomcatController.cs:145` writes:
its effective playback rate is the clip's own rate × `m_Speed` (1) ×
`speed`. `TomcatController.speed` is serialized **1** in the scene, so at the
authored value the ocean runs at exactly the aseprite rate of 1000/42 ms =
23.8095 fps, which is what `game.tscn` already sets.

The gate itself was missing from the port and is now applied:
`tomcat.gd:_bank_world()` writes `ocean.speed_scale = SPEED` alongside the sky
slide and roll, so the rate follows `speed` rather than being fixed. Probe
readback: `PROBE ocean speed_scale=1.0 playing=true`.

### Engine stereo pan (D26) — the prior claim was half right; now implemented

`TomcatController.cs:195` does `audioEngine.panStereo = newPosition.x / 6`.

The claim that no `AudioStreamPlayer` exposes a stereo pan is **correct for the
players themselves** and was re-checked by listing their properties in Godot
4.7.2:

- `AudioStreamPlayer` — `stream, volume_db, volume_linear, pitch_scale,
  playing, autoplay, stream_paused, mix_target, max_polyphony, bus,
  playback_type`. No pan.
- `AudioStreamPlayer2D` — adds `max_distance, attenuation, panning_strength,
  area_mask`. `panning_strength` scales a **positional** pan derived from the
  node's distance to the listener; it is an attenuating 2D emitter, not a
  direct pan, so reproducing `x / 6` through it would mean inventing a listener
  geometry the source does not have.

But the claim's conclusion does not follow, because the pan does not have to
live on the player. **`AudioEffectPanner` exposes `pan`**, property hint
`-1,1,0.01` — the same range and sense as Unity's `panStereo` — and it is
settable at runtime on a bus.

Implemented that way:

- `audio.gd` creates a bus named `Engine` in `_ready()`, sends it to `Master`,
  and adds an `AudioEffectPanner`. `set_engine_pan()` writes the effect's
  `pan`, clamped to ±1.
- `tomcat.tscn`'s `Engine` player is routed to that bus by
  `tomcat.gd:_ready()` (`engine_sfx.bus = Audio.ENGINE_BUS`).
- `_update_engine_note()` writes `Audio.set_engine_pan(_aim.x /
  ENGINE_PAN_DIVISOR)` with `ENGINE_PAN_DIVISOR = 6.0`.

`_aim` is already held in the source's world units, and x is unaffected by the
y-axis flip, so the expression is the source's verbatim.

**Verified through the real path**, by driving `_update_engine_note()` on the
live Tomcat and reading the bus effect back:

```
PROBE pan at aim.x=3.2  ->  0.53333336114883
PROBE pan at aim.x=-3.2 -> -0.53333336114883
PROBE engine player bus=Engine
PROBE engine bus index=1 effect=():<AudioEffectPanner#...>
```

3.2 / 6 = 0.5333…, at both stick extremes. **D26 is closed.** Whether it
*sounds* right is not something this audit can judge.

---

## 10 — Verification after these four

```
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 600
```

```
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

WARNING: 4 ObjectDB instances were leaked at exit (run with `--verbose` for details).
ERROR: 2 resources still in use at exit (run with --verbose for details).
```

**Zero script errors and zero parse errors** — the two lines are Godot's
headless shutdown accounting for the autoload singletons, unchanged from §8.

A temporary probe (added, run, removed) screenshotted the running game after
two seconds. The image shows the three gold labels and two white counts drawn,
the MiGs on the frame-0 silhouette, and the speedlines over the ocean under the
Tomcat. Probe readback:

```
PROBE speedlines=Speedlines:<AnimatedSprite2D#...> parent=Tomcat visible=true playing=true
PROBE ocean speed_scale=1.0 playing=true
```

## Values that still could not be verified

| Value | Where | Why |
|---|---|---|
| Which explosion sprite each of `explosionSprites[1..9]` is | both MiG prefabs | Not chased through the artifact object table. The **order** is fixed by the array, and `Explosion.prefab`'s own `m_Sprite` equals `explosionSprites[0]`, so index 0 is anchored; 1–9 are taken to run in import order `Frame_1`…`Frame_9`. The same artifact-table method that resolved the MiG frame would settle these. |
| Which tomcat sprite fileID `-1909522266106633135` is | scene Tomcat SpriteRenderer | Not chased. It is the idle pose the editor shows; the Animator overrides it at runtime, so it does not affect play. |
| Which crosshair sprite fileID `-5168256213217209183` is | scene Crosshairs SpriteRenderer | Not chased. All four Crosshairs frames are identical in size and pivot, and the port animates all four. |
| Sorting-layer numbers | prefabs and scene | The numeric layers (582728797, 1006858939, −296194247, −1526996339, −360740805) are Unity layer IDs. The port reproduces the *order* through tree order; the numbers themselves have no Godot equivalent and were not translated. |
| The Missiles UI decoration | scene, under the canvas | Its transform is verified (scale 32.8125, position `{-130, -107.4}`) but it is not present in the port's HUD. |
