# The Optimized VAD Safety Guardian Roadmap

## The Core Research Thesis
**"Neuro-Symbolic Safety Grounding: Restoring class-agnostic obstacle awareness to vectorized autonomous driving through lightweight fuzzy arbitration"**

**Why this matters:** VAD achieves 9.3x speed-up by eliminating dense representations, but creates a safety paradox—objects outside its learned query vocabulary become "invisible." This contribution proves safety doesn't require expensive retraining or dense models.

---

## Phase 1: Diagnostic Foundation (April 23 – May 15)
**Objective:** Establish quantitative proof of VAD's geometric blind spot + achieve simulation efficiency

### Week 1-2: Infrastructure Hardening (April 23 – May 6)
**Critical path items:**

1. **Minimal Scenario Setup** (Day 3-5):
   - Modify `routes_testing.xml` to create 5 "canonical failure" scenarios:
     - Scenario A: Static crate in straight lane
     - Scenario B: Traffic cone mid-turn
     - Scenario C: Fallen debris (branch/barrel)
     - Scenario D: Unexpected static vehicle (perpendicular)
     - Scenario E: Construction barrier cluster
   - Use `--num-vehicles 0` for initial testing
   - **Success metric:** Each scenario runs to completion at ≥0.3x ratio
   - Note: Fail2Drive already has scenarios like these, can just reuse them.

### Week 3: Quantitative Failure Analysis (May 7 – May 15)

4. **Entropy Metric Validation** (Critical for Phase 2):
   ```python
   # Compute attention entropy at each timestep
   attention_weights = output_dict['cross_attention']  # [num_heads, N_queries, N_features]
   entropy = -torch.sum(attention_weights * torch.log(attention_weights + 1e-9), dim=-1)
   avg_entropy = entropy.mean()
   
   # Hypothesis: High entropy correlates with imminent failures
   ```
   - Run baseline VAD on all 5 scenarios
   - Log: collision_frame, entropy_at_collision, entropy_5s_before, entropy_10s_before
   - **Success metric:** Entropy increases by ≥30% in 10s window before OOD collisions

5. **Baseline Metrics Collection**:
   - Run VAD on 20 diverse Bench2Drive routes (representative sample)
   - Run VAD on 10-20 Fail2Drive OOD routes to capture the "blind spot" baseline
   - Record: Success Rate, Collision Count, Route Completion %, Avg FPS
   - **Target baseline:** ~60-70% success rate (typical for OOD scenarios)

**Phase 1 Deliverables:**
- [ ] 1 "smoking gun" video with BEV visualization
- [ ] Entropy correlation analysis (scatter plot: entropy vs. collision probability)
- [ ] Baseline performance table (20 routes)

---

## Phase 2: Guardian Integration (May 16 – June 15)
**Objective:** Build the fuzzy arbitration layer without training neural components

### Week 4-5: Occupancy Integration (May 16 – May 29)

1. **Frozen Occupancy Setup** (Day 1-3):
   - Download pre-trained OccNet or BEVFormer weights (nuScenes checkpoint)
   - **Fallback option:** Use CARLA's ground-truth occupancy API initially
   ```python
   # CARLA ground-truth (for initial tuning):
   world = self.client.get_world()
   occupancy_grid = world.get_occupancy_grid(ego_location, grid_size=50)
   
   # Later swap to neural:
   occupancy_pred = occnet_model(sensor_inputs)
   ```
   - **Decision point:** If neural occupancy causes VRAM issues, proceed with ground-truth for Phases 2-3, defer neural swap to Phase 4

2. **Geometric Conflict Detector** (Day 4-7):
   ```python
   def compute_conflict_score(waypoints, occupancy_grid, vehicle_footprint):
       """
       waypoints: [6, 3] - VAD's predicted path (x, y, yaw)
       occupancy_grid: [H, W, D] - probability voxels
       Returns: conflict_score in [0, 1]
       """
       total_conflict = 0
       for wp in waypoints:
           # Project vehicle footprint at this waypoint
           voxel_indices = project_footprint_to_voxels(wp, vehicle_footprint)
           # Sum occupancy probabilities
           total_conflict += occupancy_grid[voxel_indices].sum()
       return min(total_conflict / threshold, 1.0)
   ```
   - Test on 5 canonical scenarios
   - **Success metric:** Conflict score >0.7 for all actual collisions, <0.3 for safe routes

3. **Entropy Feature Extraction** (Day 8-10):
   ```python
   def compute_situational_awareness(attention_maps):
       """
       Low entropy = model is confident/focused
       High entropy = model is confused/uncertain
       Returns: SA score in [0, 1], where 0=confused, 1=confident
       """
       entropy = compute_entropy(attention_maps)
       # Normalize: typical VAD entropy range is [0.5, 3.5]
       SA = 1 - normalize(entropy, min=0.5, max=3.5)
       return SA
   ```

### Week 6-7: Fuzzy Arbitration Engine (May 30 – June 15)

4. **FIS Design** (Day 1-4):
   ```python
   import skfuzzy as fuzz
   from skfuzzy import control as ctrl
   
   # Input variables
   conflict = ctrl.Antecedent(np.arange(0, 1.1, 0.01), 'conflict')
   SA = ctrl.Antecedent(np.arange(0, 1.1, 0.01), 'situational_awareness')
   TTC = ctrl.Antecedent(np.arange(0, 10, 0.1), 'time_to_collision')
   
   # Output variable
   safety_weight = ctrl.Consequent(np.arange(0, 1.1, 0.01), 'safety_weight')
   
   # Membership functions
   conflict['negligible'] = fuzz.trimf(conflict.universe, [0, 0, 0.3])
   conflict['low'] = fuzz.trimf(conflict.universe, [0.2, 0.4, 0.6])
   conflict['significant'] = fuzz.trimf(conflict.universe, [0.5, 0.7, 0.9])
   conflict['critical'] = fuzz.trimf(conflict.universe, [0.8, 1.0, 1.0])
   
   # Define 12-15 fuzzy rules
   rule1 = ctrl.Rule(conflict['critical'] & SA['low'], safety_weight['maximum'])
   rule2 = ctrl.Rule(conflict['negligible'] & SA['high'], safety_weight['minimum'])
   # ... etc
   ```

5. **Plan Blending Implementation** (Day 5-7):
   ```python
   def blend_trajectories(vad_traj, safe_traj, safety_weight):
       """
       vad_traj: [6, 3] - nominal VAD waypoints
       safe_traj: [6, 3] - emergency maneuver (brake/swerve)
       safety_weight: scalar in [0, 1]
       """
       return (1 - safety_weight) * vad_traj + safety_weight * safe_traj
   
   # Emergency maneuver options:
   # Option 1: Hard brake (decelerate to zero)
   # Option 2: Gentle deceleration (coast)
   # Option 3: Lane-keeping swerve (if space available)
   ```

6. **Integration Testing** (Day 8-14):
   - Run full pipeline on 5 canonical scenarios
   - Visualize: FIS inputs (Gc, SA, TTC) and output (ws) over time
   - **Success metric:** System prevents all 5 collisions while maintaining trajectory smoothness (jerk <4 m/s³)

**Phase 2 Deliverables:**
- [ ] Conflict detection module (unit tested)
- [ ] Fuzzy arbitration engine (12+ rules defined)
- [ ] Integrated VAD+Guardian running on 5 scenarios
- [ ] Preliminary smoothness analysis

---

## Phase 3: Validation & Optimization (June 16 – July 15)
**Objective:** Prove Guardian superiority through systematic comparison

### Week 8-9: Parameter Tuning (June 16 – June 29)

1. **Fuzzy Rule Optimization** (Grid search approach):
   ```python
   # Parameter space:
   param_space = {
       'conflict_thresholds': [[0.2,0.4,0.6], [0.3,0.5,0.7], [0.25,0.45,0.65]],
       'SA_boundaries': [[0.3,0.6], [0.4,0.7], [0.35,0.65]],
       'safety_weight_max': [0.8, 0.9, 1.0]
   }
   
   # Objective function: 
   # Maximize: collision_avoidance_rate + route_completion_rate
   # Minimize: jerk + phantom_brake_count
   
   best_params = grid_search(param_space, scenarios=5, objective=combined_metric)
   ```
   - **Success metric:** ≥90% collision avoidance on 5 scenarios, jerk <3 m/s³

2. **Ablation Components Setup** (Day 8-10):
   - **Baseline:** Pure VAD (no guardian)
   - **Hard-Switch:** Binary brake (if conflict >0.7: full brake, else: none)
   - **Fuzzy-Guardian:** Your system
   - **Oracle:** CARLA ground-truth + perfect planning (upper bound)

### Week 10-11: Full Benchmark Evaluation (June 30 – July 15)

3. **The 220-Route Stress Test**:
   ```bash
   # Run all three systems on full Bench2Drive
   python eval_agent.py --agent=vad_baseline --routes=all
   python eval_agent.py --agent=hard_switch --routes=all  
   python eval_agent.py --agent=fuzzy_guardian --routes=all
   ```
   - **Target metrics:**
     - Success Rate: Fuzzy ≥ Hard-Switch +5% ≥ Baseline +15%
     - Driving Score: Fuzzy ≥ Hard-Switch +10% (smoother)
     - Inference FPS: Fuzzy ≥10 FPS (prove real-time capable)
     - Collision Reduction: Fuzzy reduces OOD collisions by ≥60% vs. baseline

4. **Statistical Significance**:
   - Run each configuration 3 times (different random seeds)
   - Use paired t-tests to prove Fuzzy vs. Hard-Switch difference is significant (p<0.05)

**Phase 3 Deliverables:**
- [ ] Optimized fuzzy parameters
- [ ] Ablation study results (3 systems × 220 routes × 3 seeds)
- [ ] Statistical analysis report
- [ ] Performance comparison table

---

## Phase 4: Documentation & Positioning (July 16 – August 15)
**Objective:** Transform code into a compelling research narrative

### Week 12-13: Qualitative Evidence (July 16 – July 29)

1. **Highlight Reel Creation**:
   - Select 8 "hero scenarios" where:
     - Baseline crashes
     - Hard-Switch brakes jerkily
     - Fuzzy-Guardian smoothly avoids
   - Create professional videos with:
     - Multi-view (camera, BEV, occupancy grid, FIS dashboard)
     - Real-time metrics overlay (ws, Gc, SA, speed)
     - Slow-motion collision avoidance moments

2. **Interpretability Showcase**:
   ```
   Frame 245: CONFLICT DETECTED
   - Occupancy Conflict: 0.82 (Critical)
   - Situational Awareness: 0.31 (Low - model confused)
   - Time-to-Collision: 1.2s (Short)
   → Fuzzy Rule Activated: R7 (Critical+Low+Short → ws=0.95)
   → Action: Emergency deceleration initiated
   ```

### Week 14-15: Paper/Thesis Writing (July 30 – August 10)

3. **Positioning Strategy**:

   **Title:** "Class-Agnostic Safety Grounding for Vectorized Autonomous Driving via Neuro-Symbolic Arbitration"

   **Abstract framework:**
   - Problem: VAD's speed comes at safety cost (geometric blind spots)
   - Gap: Dense retraining is computationally prohibitive
   - Solution: Lightweight fuzzy guardian using frozen occupancy + attention entropy
   - Result: 60% OOD collision reduction, 10% smoother driving, <1 FPS overhead
   - Impact: Proves safety doesn't require expensive model scaling

   **Key sections:**
   - Introduction: The vectorized planning safety paradox
   - Related Work: Position against UniAD (too heavy), SparseDrive (incomplete), pure-neural safety filters (black-box)
   - Method: Your neuro-symbolic architecture
   - Experiments: The ablation study is your centerpiece
   - Discussion: Interpretability + computational efficiency + Taiwan industry relevance

4. **Code & Data Release**:
   - Clean GitHub repo with:
     - `fuzzy_guardian/` module (plug-and-play)
     - `scenarios/` (your 5 canonical test cases)
     - `results/` (all 220-route logs)
     - `visualization/` (BEV rendering tools)
   - **Contribution:** First open-source class-agnostic safety layer for VAD

### Week 16: Buffer & Polish (August 11 – August 15)

5. **Contingency Week:**
   - Fix any failed reviews
   - Re-run experiments if needed
   - Prepare presentation/defense

**Phase 4 Deliverables:**
- [ ] 8-video highlight reel
- [ ] Complete paper draft (6-8 pages)
- [ ] Public GitHub repository
- [ ] Presentation slides

---

## Risk Mitigation & Decision Points

### Critical Checkpoints

**May 1 Checkpoint:** If sim ratio still <0.2x → Abandon 220-route goal, focus on 20 high-quality scenarios

**May 15 Checkpoint:** If entropy doesn't correlate with failures → Drop SA metric, use only Gc + TTC (still publishable)

**June 1 Checkpoint:** If neural occupancy causes VRAM overflow → Stick with ground-truth for main results, neural occupancy becomes "future work"

**July 1 Checkpoint:** If fuzzy isn't beating hard-switch → Debug membership functions, consider PID-based blending as fallback

### Technical Fallbacks

| Risk | Trigger | Mitigation |
|------|---------|------------|
| VRAM overflow | >22GB usage | Use FP16, reduce batch size to 1, process frames sequentially |
| Low FPS | <5 FPS | Reduce occupancy grid resolution (50m → 30m), use sparse voxels |
| Entropy unreliable | Correlation <0.3 | Drop SA, focus on Gc + TTC (simpler but still novel) |
| Hard to tune fuzzy | >100 iterations needed | Use Bayesian optimization or evolutionary algorithm |

---

## Success Metrics Summary

### Must-Have (Required for August 15):
- ✅ 1 "smoking gun" video proof of VAD blind spot
- ✅ Fuzzy Guardian prevents ≥80% of baseline OOD collisions
- ✅ System runs at ≥10 FPS on RTX 3090
- ✅ Ablation shows Fuzzy > Hard-Switch in smoothness

### Should-Have (Strong paper):
- ✅ Entropy-SA metric validated
- ✅ Full 220-route evaluation completed
- ✅ Statistical significance proven (p<0.05)
- ✅ 5+ hero scenario videos

### Nice-to-Have (Exceptional impact):
- ⭐ Neural occupancy working (vs. ground-truth)
- ⭐ Tested on Fail2Drive OOD assets
- ⭐ Real-world transfer experiment (if hardware available)

---
