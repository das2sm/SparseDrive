# 🎯 **Hybrid Sparse Perception: The Fast-Track Plan**
### **Leveraging Open-Source Infrastructure**

---

## 🧠 **Core Thesis**
> *"Does fusing SparseDrive's instance queries with SparseOcc's geometry provide better closed-loop safety than either model alone, while maintaining sub-100ms latency?"*

---

## 📅 **Execution Plan**

---

### **Phase 1: Foundation Theft (April 2-20) — 3 Weeks**
**Goal:** Replace custom code with battle-tested infrastructure.

#### **Week 1: Steal the Control Stack**
- [ ] Clone [Carla Garage](https://github.com/autonomousvision/carla_garage) *(TransFuser's PID controller)*
- [ ] Copy `team_code/autopilot.py` → Replace your `sim.py` controller logic
- [ ] **Test:** Car follows SparseDrive waypoints without braking
- **Deliverable:** 30-second video of smooth driving in Town01

#### **Week 2: Steal the Evaluation Pipeline**
- [ ] Clone [Bench2Drive](https://github.com/Thinklab-SJTU/Bench2Drive)
- [ ] Replace `SensorGrabber` with `agents/sensor_interface.py`
- [ ] Import `leaderboard/evaluator.py` for automatic metrics
- **Deliverable:** Baseline metrics (Route Completion %, Collision Rate) for SparseDrive-only

#### **Week 3: Upgrade to SparseDriveV2**
- [ ] Download [SparseDriveV2 checkpoint](https://github.com/swc-17/SparseDrive/releases) *(ResNet-34 backbone)*
- [ ] Swap config: `sparsedrive_small_stage2.py` → `sparsedrive_v2_r34.py`
- [ ] **Benchmark:** Measure FPS gain (should jump from 22 → 60+ FPS)
- **Deliverable:** Latency comparison table (V1 vs V2)

**✅ Phase 1 Success Criteria:** You have a car driving at 60 FPS using industry-standard evaluation metrics.

---

### **Phase 2: Occupancy Integration (April 21 - May 15) — 4 Weeks**

#### **Week 4: Clone SparseOcc Environment**
- [ ] Clone [SparseOcc](https://github.com/MCG-NJU/SparseOcc) into `/workspace/`
- [ ] Download `sparseocc_r50_nuimg.pth` checkpoint
- [ ] Verify standalone inference works (test on nuScenes samples)

#### **Week 5: Build the Dual-Head Inference Server**
- [ ] **DO NOT merge models**—run them in **parallel inference**
- [ ] Modify `inference_server.py`:
  ```python
  # Parallel execution (both share ResNet backbone features)
  with torch.no_grad():
      features = backbone(img_tensor)
      drive_out = sparsedrive_head(features, metas)
      occ_out = sparseocc_head(features, metas)
  ```
- [ ] Output format: `{'waypoints': [...], 'occupancy': np.array(200,200,16)}`

#### **Week 6-7: The Fusion Logic (Your Novel Contribution)**
**This is the research component—everything else is plumbing.**

Implement 3 fusion strategies and A/B test them:

**Strategy A: "Veto System"** *(Simplest)*
```python
if occupancy_grid.check_collision(waypoints):
    waypoints = emergency_brake_trajectory()
```

**Strategy B: "Cost Map Fusion"** *(Medium complexity)*
```python
# Weight waypoint costs by occupancy density
for waypoint in candidates:
    cost = distance_cost + occupancy_penalty(occ_grid, waypoint)
waypoints = min_cost_trajectory
```

**Strategy C: "Query-Level Attention Fusion"** *(Your thesis differentiator)*
```python
# Fuse instance queries with occupancy queries BEFORE trajectory decoding
fused_queries = cross_attention(
    instance_queries=drive_out['queries'],
    occupancy_queries=occ_out['queries']
)
waypoints = planning_head(fused_queries)
```

- **Deliverable:** 3 versions of `fusion_controller.py`, each implementing one strategy

---

### **Phase 3: Comparative Study (May 16 - June 30) — 6 Weeks**

#### **Week 8-9: Build the Test Suite**
**Steal from Bench2Drive scenarios:**
- [ ] Use their `leaderboard/data/routes_*.xml` files
- [ ] 3 difficulty levels:
  - **Easy:** Town01, clear weather, sparse traffic
  - **Medium:** Town03, rain, moderate traffic
  - **Hard:** Town05, night + fog, dense traffic

#### **Week 10-11: Run Experiments**
**Configurations to test:**
1. **Baseline 1:** SparseDrive V2 only
2. **Baseline 2:** SparseOcc only (geometry-based planning)
3. **Hybrid A:** Veto System
4. **Hybrid B:** Cost Map Fusion
5. **Hybrid C:** Query-Level Fusion

**Per configuration, log:**
- Route Completion %
- Collision Rate
- Avg Latency (ms)
- GPU Memory (MB)
- Driving Score (Bench2Drive's metric)

#### **Week 12-13: The "Sparse vs Dense" Ablation**
**This proves your efficiency claim.**

Compare your best hybrid (likely Strategy C) against:
- **Dense Baseline:** BEVFormer + Dense Occupancy *(steal from [OpenOccupancy](https://github.com/JeffWang987/OpenOccupancy))*
- **Metric:** FPS @ same accuracy, or Accuracy @ same latency

**Deliverable:** Table showing "Hybrid Sparse C achieves 95% of Dense accuracy at 3x the speed"

---

### **Phase 4: Visualization & Packaging (July 1-31) — 4 Weeks**

#### **Week 14-15: Steal Visualization Tools**
- [ ] Use [ViDAR's visualization](https://github.com/OpenDriveLab/ViDAR) for occupancy rendering
- [ ] Use Bench2Drive's `scenario_runner` for automated recording
- [ ] Generate side-by-side comparison videos:
  - Left: SparseDrive-only (shows instance boxes)
  - Middle: SparseOcc-only (shows voxel grid)
  - Right: Your Hybrid (shows both + fusion confidence)

#### **Week 16-17: Failure Analysis**
**Document the 3 edge cases where fusion helps most:**
1. **The Unclassifiable Object** *(fallen tree, trash can)*
   - SparseDrive misses it → SparseOcc detects geometry → Fusion brakes
2. **The Phantom Detection** *(shadow, reflection)*
   - SparseDrive hallucinates box → SparseOcc shows no occupancy → Fusion ignores
3. **The Occluded Pedestrian** *(behind parked car)*
   - SparseDrive tracks last-seen position → SparseOcc fills in geometry → Fusion predicts emergence

**Deliverable:** 3 annotated video clips demonstrating each scenario

---

### **Phase 5: Final Polish (August 1-15) — 2 Weeks**

#### **Week 18: GitHub Repository**
Structure:
```
hybrid-sparse-perception/
├── configs/           # Stolen from SparseDrive/SparseOcc
├── models/            # Your fusion_controller.py
├── scripts/           # Bench2Drive evaluation wrappers
├── results/           # Tables + videos
└── README.md          # "Standing on shoulders of giants" acknowledgments
```

#### **Week 19: Write-Up**
**Paper-style report (6-8 pages):**
1. **Intro:** Why sparse > dense for real-time systems
2. **Related Work:** "We combine SparseDrive [1] and SparseOcc [2] using Bench2Drive [3]"
3. **Method:** The 3 fusion strategies
4. **Experiments:** Your comparative study results
5. **Conclusion:** "Query-level fusion achieves X% safety improvement with Y% latency overhead"

---

## 📊 **Success Metrics**

| Metric | Target |
|--------|--------|
| **Route Completion** | >85% on Bench2Drive Hard scenarios |
| **Collision Rate** | <5% (lower than SparseDrive-only) |
| **Latency** | <100ms end-to-end @ 20 FPS |
| **FPS Advantage** | 2-3x faster than Dense baselines |
| **Novel Contribution** | Prove Query-Level Fusion > Veto System |

---

## 🎬 **Hero Video (August 10)**

**90-second split-screen:**
- 0:00-0:30: Baseline fails (SparseDrive-only crashes into trash can)
- 0:30-0:60: Your Hybrid detects + avoids same obstacle
- 0:60-0:90: Side-by-side metrics comparison

**Narration overlay:**
> "By fusing sparse instance tracking with sparse geometry, we achieve dense-level safety at 3x the speed."

---
