### 🧠 Project Identity
* **Title:** *The Geometric Gap: Quantifying the Indispensability of Occupancy in Sparse End-to-End Driving.*
* **The Thesis:** Sparse models (Map+Agents) are highly efficient but "semantically blind" to unstructured obstacles. A lightweight **Geometric Veto** is the only way to achieve 100% safety.

---

### 📅 The Master Schedule (18 Weeks)

#### Phase 1: The Infrastructure Heist (April 10 – April 25)
**Goal:** Get the car moving
1.  **Repo Setup:** Clone `SparseDriveV2` and `Bench2Drive-VL`.
2.  **The Bridge:** Connect SparseDrive's output waypoints to a PID controller (lifted from `Carla Garage`). 
3.  **Visual Proof:** Use the CARLA `debug.draw_point` API to draw the waypoints. If they appear on the road in front of the car, move to Phase 2.
    * **Rule:** If you are still fighting coordinate transforms by April 20, use the **Bench2Drive-VL** integrated evaluator—don't write your own.

#### Phase 2: The Failure Atlas (April 26 – May 20)
**Goal:** Prove that the $30,000 GPU is blind to a $5 box.
1.  **Scenario Scripting:** Use the CARLA Python API to create a "Stress Test" script.
2.  **The Anomalies:**
    * **The Fallen Tree:** A static mesh prop that isn't a "car" or "pedestrian."
    * **The Debris Field:** 10 random cardboard boxes scattered across a high-speed turn.
3.  **The Result:** Record SparseDrive crashing into these. This is your "Motivation" video.

#### Phase 3: The Geometric Veto (May 21 – June 30)
**Goal:** The actual engineering contribution.
1.  **The "Fake" Occupancy Hack:** To save time, start with a **Point Cloud Veto**. If the LiDAR points in the path of the trajectory exceed a density threshold, trigger the brake.
2.  **The "Real" Upgrade:** Integrate the `SparseOcc` voxel head. Compare its performance to your "Fake" veto.
3.  **Ablation:** Run three versions:
    * *Vanilla:* SparseDrive only (Crashes).
    * *Semantic:* SparseDrive + Map Head Veto (Still crashes on trees).
    * *Geometric:* SparseDrive + Occupancy Veto (**Success**).

#### Phase 4: Data Grinding (July 1 – July 25)
**Goal:** Hard numbers for the paper.
1.  **The Benchmark:** Run all 200+ scenarios in `Bench2Drive-VL`.
2.  **Metrics:** Compare **Driving Score (DS)** and **Infraction Score (IS)**. Prove that your Veto increases safety without lowering the Driving Score.

#### Phase 5: The "Hero" Wrap-up (July 26 – August 15)
**Goal:** Polish and Publish.
1.  **The Video:** 60-second side-by-side comparison. "Sparse Intelligence vs. Geometric Reality."
2.  **The Paper:** Use the CVPR LaTeX template. Focus on the **Scenario B** results—this is your novelty.
3.  **Final Polish:** Clean up the GitHub README. Ensure anyone can `git clone` and reproduce your "Fallen Tree" save.

---

### 🛠️ The "No-Reinvention" Tooling

| Task | DO NOT BUILD | USE THIS INSTEAD |
| :--- | :--- | :--- |
| **Backbone/Weights** | Training | **SparseDriveV2** (Official .pth) |
| **PID/Controller** | Physics Math | **Carla Garage** (`team_code/pid.py`) |
| **Evaluator** | Logging/Loops | **Bench2Drive-VL** (`eval.py`) |
| **Occupancy** | Voxel Logic | **SparseOcc** (Decoder layers only) |
| **Visualization** | Custom UI | **ViDAR** (Open-source BEV viz) |

---

### 🛑 Strategic Constraints (To Finish on Time)
1.  **No Backbone Training:** You have a 3090. Do not try to finetune ResNet. It is a "frozen" feature extractor.
2.  **Logic-Over-Architecture:** A 10-line "If-Then" Veto is better than a complex Transformer fusion that takes 2 months to debug.
3.  **Simplicity Wins:** Your project is a **study**, not a product. If the car stops safely, you win.

---
