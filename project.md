# 🎯 Project Overview: Closed-Loop Sparse Perception

The objective of this project is to move beyond passive, open-loop perception and build a **closed-loop autonomous driving system**.

Instead of evaluating models like SparseOcc on static datasets, the system will use sparse perception outputs to directly inform **real-time control decisions** (steering, braking, acceleration) inside a simulation environment.

The pipeline will integrate:

* **Perception + Planning** via SparseDrive
* **Control algorithms** (Pure Pursuit / PID)
* **Simulation** via CARLA

Your primary compute platform will be the **NVIDIA GeForce RTX 3090**.

---

# 🗓️ 5-Month Roadmap (April – August)

---

## 📍 Month 1 (April): SparseDrive Setup & Baseline
March 31st Baseline:

    Model: SparseOcc (ResNet-50)

    Hardware: NVIDIA RTX 3090 (24GB)

    Inference Speed: 16.0 FPS / 62.5ms

    Accuracy: 0.368 (RayIoU)

**Goal:** Establish a working perception + planning backbone.

### Core Tasks:

* Clone the SparseDrive repository
* Resolve dependencies using your existing Docker environment
* Compile any required CUDA extensions
* Run **inference first**, then validation on the nuScenes dataset
* Understand model outputs:

  * instance queries
  * trajectories
  * occupancy representations

### Deliverable:

* A verified SparseDrive pipeline running locally
* Baseline performance metrics and successful inference outputs

---

## 📍 Month 2 (May): Perception-to-Control Mapping

**Goal:** Convert model outputs into actionable vehicle commands.

### Core Tasks:

* Extract planned trajectories / waypoints from SparseDrive outputs
* Implement a control module:

  * Start with **Pure Pursuit** (trajectory following)
  * Optionally compare with **PID control**
* Map trajectory → steering, throttle, braking

### Deliverable:

* A working control module that converts perception outputs into real vehicle commands

---

## 📍 Month 3 (June): Closing the Loop in Simulation

**Goal:** Build a real-time closed-loop system.

### Core Tasks:

* Integrate with **CARLA simulator**:

  * Camera → model input
  * Model output → control commands
* Establish full pipeline:

  ```
  CARLA → camera → SparseDrive → trajectory → controller → CARLA vehicle
  ```
* Ensure stable real-time operation

### Deliverable:

* First successful **closed-loop autonomous driving demo**
* Vehicle navigates using live model predictions

---

## 📍 Month 4 (July): Stress Testing & Evaluation

**Goal:** Evaluate system robustness under realistic conditions.

### Core Tasks:

* Run simulations across varied conditions:

  * weather (rain, fog, night)
  * traffic density
  * occlusions
* Log and analyze:

  * end-to-end latency (ms)
  * control frequency (Hz)
  * trajectory deviation
  * collision rate
* Identify failure cases:

  * small objects
  * dynamic obstacles
  * perception degradation

### Deliverable:

* A structured dataset of logs and failure cases
* Quantitative and qualitative evaluation of system performance

---

## 📍 Month 5 (August): Final Report & Portfolio Output

**Goal:** Package your work into strong, presentable deliverables.

### Core Tasks:

* Write a **Robustness Report**:

  * system architecture
  * evaluation metrics
  * failure analysis
  * key insights
* Produce a **“Hero Video”**:

  * simulator view
  * sparse 3D perception visualization
  * trajectory + control overlay
* (Optional) Draft a research-style paper

### Deliverable:

* Final report documenting your findings
* Polished demo video showcasing the full closed-loop system

---

# 🧠 Core Research Question

> **Can sparse 3D perception enable faster and more robust closed-loop control compared to traditional dense representations?**

---

# 🏁 Final Outcome

By the end of this project, you will have built a complete system:

```
Perception → Planning → Control → Simulation → Evaluation
```

This demonstrates:

* understanding of modern perception models
* integration with control systems
* real-time system design
* robustness analysis under realistic conditions

👉 This is directly aligned with industry roles in:

* autonomous driving
* robotics
* intelligent systems engineering

---
