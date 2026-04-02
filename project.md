
---

# 🎯 Project Overview: Hybrid Sparse Closed-Loop Systems

The goal is to build a **Hybrid Sparse Perception** system that combines instance-based tracking (SparseDrive) with geometry-based occupancy (SparseOcc) to drive a vehicle in CARLA. By using sparse queries for both, we keep the compute cost low enough for high-frequency control on the RTX 3090.

---

# 🗓️ Revised 5-Month Roadmap (April 2 – August 15)

---

## 📍 Phase 1: The Occupancy Pivot (April)
**Goal:** Integrate SparseOcc and establish the "Dual-Stream" perception backbone.

*   **SparseOcc Integration:** Clone and configure the SparseOcc repository. Since you already have the SparseDrive environment, focus on shared CUDA extensions (like `Deformable Attention`).
*   **The Hybrid Head:** Modify the inference script to run SparseDrive (for "Who" is there) and SparseOcc (for "What" is the general geometry) in parallel.
*   **Coordinate Sync:** Ensure both models are outputting in the same Voxel/Ego coordinate space.

**Deliverable:** A unified inference script that outputs 3D Bounding Boxes **and** a 3D Occupancy Grid at >15 FPS.

---

## 📍 Phase 2: The Control Bridge (May)
**Goal:** Transform "Imagined" paths into physical steering/throttle commands.

*   **Pure Pursuit Implementation:** Use the 0.60m L2-accurate waypoints to calculate steering angle $\delta$:
    $$\delta = \arctan\left(\frac{2L \sin(\alpha)}{l_d}\right)$$
*   **PID Tuning:** Implement a longitudinal PID controller for throttle/brake to maintain the target velocity predicted by the planning head.
*   **CARLA Client Setup:** Build the bridge to send images from CARLA's 6-camera rig into your model and receive the `VehicleControl` object back.



**Deliverable:** A standalone Python controller that can "drive" a CARLA vehicle using pre-recorded model trajectories.

---

## 📍 Phase 3: Closing the Hybrid Loop (June)
**Goal:** First full "Eyes-to-Actuators" run in simulation.

*   **The Conflict Resolver:** Write logic to handle discrepancies. 
    *   *Example:* If SparseDrive says "Path is Clear" but SparseOcc detects an occupancy voxel (like a fallen tree), the controller must prioritize the Occupancy grid for braking.
*   **Latency Optimization:** Profile the "Photon-to-Control" latency. Aim for <100ms total round-trip to ensure the 3090 can keep up with a 20km/h cruise.
*   **SWNet Integration:** Use SparseDrive’s instance queries to populate the "Sparse World" for the simulator's reasoning.

**Deliverable:** First successful video of the car navigating a simple CARLA "Town" using live Hybrid Sparse Perception.

---

## 📍 Phase 4: Stress Testing & "Sparse-Only" Robustness (July)
**Goal:** Prove the thesis that sparse is better/faster than dense.

*   **Environmental Stress:** Test in CARLA’s "Epic" weather (Heavy Rain/Night). Observe how SparseOcc handles visibility degradation compared to Bounding Boxes.
*   **Edge Case Collection:** Focus on "The Un-classifiables"—obstacles that aren't in the nuScenes categories (e.g., a stroller, a box in the road).
*   **Comparison Study:** Quantify the CPU/GPU usage of this Sparse+Sparse approach vs. a traditional Dense Occupancy approach.

**Deliverable:** A "Failure Atlas" documenting exactly where the sparse representation breaks down.

---

## 📍 Phase 5: Synthesis & Portfolio (August 1 – August 15)
**Goal:** Finalize documentation and high-quality visualization.

*   **The "Hero Video":** A split-screen masterpiece showing:
    1.  CARLA Third-Person View.
    2.  6-Camera SparseDrive Overlays.
    3.  3D SparseOcc Voxel Grid.
    4.  Real-time Planning/Control Graphs.
*   **Final Report:** Summarize the NDS/AMOTA metrics from April and the "Success Rate" metrics from the July CARLA trials.

**Deliverable:** A GitHub-ready repository and a technical report suitable for a research portfolio or a pre-print paper.

---

# 🧠 Core Research Question
> **"Does combining Sparse Instance Tracking with Sparse Occupancy provide a sufficient safety margin for closed-loop control without the overhead of dense 3D cost maps?"**

---
