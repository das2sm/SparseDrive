# The Geometric Safety Project

---

### Project Identity

* **Title:** *The Geometric Gap: Evaluating and Mitigating Out-of-Distribution Failures in Sparse End-to-End Driving.*
* **The Thesis:** Sparse end-to-end driving models are highly efficient but exhibit **systematic degradation in out-of-distribution (OOD) scenarios involving unstructured obstacles**. Introducing a lightweight **Geometric Safety Filter**—based on explicit geometric reasoning—can significantly improve safety without sacrificing real-time performance.

---

### The Master Schedule

---

#### Phase 1: The Infrastructure Heist (April 13 – May 3)

**Goal:** Get the system running + define the problem correctly

1. **Repo Setup:** Clone `SparseDriveV2` and `Bench2Drive-VL`, install CARLA 0.9.15, verify GPU + FPS (≥7 FPS target).
2. **The Bridge:** Connect SparseDrive trajectory outputs to a PID controller (from `Carla Garage`).
3. **Baseline Runs:** Execute 20 Bench2Drive routes, record:

   * Driving Score (DS)
   * Collision Rate (CR)
   * Success Rate (SR)
4. **Define the Problem:**

   * Clearly define **in-distribution vs. OOD scenarios**
   * Formalize **unsafe trajectory**:

     > A trajectory is unsafe if it intersects occupied space within horizon (T)
5. **The Metric (Key Contribution):**

   * **Geometric Gap (Scenario-Level):**
     [
     GG_{scenario} = CR_{OOD} - CR_{ID}
     ]
   * **Geometric Gap (Decision-Level):**
     [
     GG_{decision} = \frac{\text{Unsafe Plans Accepted}}{\text{Total Unsafe Plans}}
     ]

---

#### Phase 2: The Failure Atlas (May 4 – May 25)

**Goal:** Build the benchmark that exposes the problem

1. **Scenario Scripting:** Use CARLA Python API to create reproducible stress tests.
2. **Scenario Taxonomy (Important for paper):**

   * **Unknown Object:** Fallen Tree
   * **Fragmented Geometry:** Debris Field
   * **Misplaced Known Object:** Stalled vehicle (no signals)
   * **Partial Visibility:** Occluded barrier
3. **The Anomalies:**

   * **The Fallen Tree:** Large object not represented as a semantic class
   * **The Debris Field:** Multiple small obstacles breaking “free space”
4. **The Result:**

   * Run SparseDrive (≥5 runs per scenario)
   * Measure CR, GG, and failure patterns
   * Record BEV + ego-view videos
5. **Outcome:**

   * Establish that sparse models exhibit **higher failure rates in OOD scenarios (H1)**
   * Package as **Failure Atlas (benchmark contribution)**

---

#### Phase 3: The Geometric Safety Filter (May 26 – June 30)

**Goal:** Introduce and validate geometric reasoning

1. **The “Simple Geometry” Baseline (Point Cloud)**

   * Project trajectory into 3D space
   * Count LiDAR points in safety region
   * If density > threshold → brake
   * Tests: Does geometry alone improve safety?

2. **The “Learned Geometry” Upgrade (Occupancy)**

   * Integrate `SparseOcc` decoder (no retraining)
   * Predict occupancy probabilities along trajectory
   * If ( p_{occ} > 0.7 ) → trigger safety filter

3. **The Core Experiment (Critical)**

   * **Config A:** Vanilla SparseDrive
   * **Config B:** Semantic Safety (map-based)
   * **Config C:** Geometric (point cloud)
   * **Config D:** Geometric (occupancy)

4. **Hypothesis Testing:**

   * **H2:** Geometric filtering reduces OOD failures
   * **H3:** Improvement holds across representations (C vs D)

5. **Expected Result:**

   * Semantic-only safety still fails on OOD
   * Geometric filtering significantly reduces collisions

---

#### Phase 4: Data Grinding (July 1 – July 25)

**Goal:** Turn results into publishable evidence

1. **The Benchmark:**

   * Run all 200+ scenarios in `Bench2Drive-VL`
   * Evaluate both baseline and filtered models

2. **Metrics:**

   * Driving Score (DS)
   * Infraction Score (IS)
   * Collision Rate (CR)
   * Geometric Gap (GG)

3. **Statistical Rigor (Non-negotiable):**

   * ≥5 runs per configuration
   * Report mean ± std
   * Perform significance testing (t-test / bootstrap)

4. **Key Result:**

   * OOD safety improves significantly
   * Standard driving performance remains within ~5%

5. **Failure Analysis:**

   * False positives (over-braking)
   * False negatives (missed obstacles)

---

#### Phase 5: The “Hero” Wrap-up (July 26 – August 15)

**Goal:** Make it publishable + memorable

1. **The Killer Visualization:**

   * Side-by-side comparison:
     **“Semantic Intelligence vs. Geometric Reality”**

     * Sparse model drives into obstacle
     * Safety filter stops safely

2. **The Paper (CVPR/CoRL style):**

   * Emphasize:

     * Geometric Gap metric
     * Failure Atlas benchmark
     * Hypothesis-driven evaluation
   * Avoid absolute claims:

     > “improves robustness” (not “solves safety”)

3. **The Insight Section (Important):**

   * Why not fully learned?

     * Long-tail events are underrepresented
     * Learned systems lack guarantees
     * Geometric filtering provides a **deterministic safety layer**

4. **Final Polish:**

   * Clean GitHub repo
   * Reproducible scripts (one-command scenario runs)
   * 60-second demo video

---

### The "No-Reinvention" Tooling

| Task                 | DO NOT BUILD      | USE THIS INSTEAD                      |
| :------------------- | :---------------- | :------------------------------------ |
| **Backbone/Weights** | Training          | **SparseDriveV2** (Official .pth)     |
| **PID/Controller**   | Physics Math      | **Carla Garage** (`team_code/pid.py`) |
| **Evaluator**        | Logging/Loops     | **Bench2Drive-VL** (`eval.py`)        |
| **Occupancy**        | Voxel Logic       | **SparseOcc** (Decoder layers only)   |
| **Visualization**    | Custom UI         | **ViDAR** (Open-source BEV viz)       |
| **Point Cloud**      | Manual processing | **Open3D** (density checks)           |

---

### Strategic Constraints (To Finish on Time)

1. **No Backbone Training:** Keep feature extractor frozen—this is an evaluation study, not a training project.
2. **Evaluation > Engineering:** Your main contribution is **measuring a gap**, not building a new architecture.
3. **Geometry Over Semantics:** The key comparison is **semantic vs geometric reasoning**, not model complexity.
4. **Statistical Rigor is Mandatory:** Every claim must be backed by repeated runs + significance.
5. **Failure Atlas is First-Class:** Treat it as a **benchmark contribution**, not just a test script.
6. **Defensible Claims Only:** Avoid “always” or “fails”—use “higher failure rate” and “improves robustness.”

---

### The Winning Framing

> *“We expose a blind spot in how autonomous driving systems are evaluated—and show a simple, effective way to mitigate it.”*


* a **full CVPR-style Introduction section**, or
* your **Method section with equations + diagrams** (that’s the next big step)
