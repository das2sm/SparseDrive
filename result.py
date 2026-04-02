import pickle
import numpy as np
import matplotlib.pyplot as plt
import torch

res_path = './work_dirs/sparsedrive_small_stage2/results.pkl'

with open(res_path, 'rb') as f:
    data = pickle.load(f)

# Extract the planning tensor
planning_tensor = data[0]['img_bbox']['final_planning']

# Convert from Torch Tensor to Numpy for plotting
if isinstance(planning_tensor, torch.Tensor):
    path = planning_tensor.detach().cpu().numpy()
else:
    path = np.array(planning_tensor)

# --- Visualization ---
# Try swapping the axes to see if it looks like a real road path
plt.figure(figsize=(8, 8))

# Experiment: Swap X and Y, and flip the signs if necessary
# In nuScenes/MMDet3D, often:
# Forward = path[:, 0]
# Lateral = path[:, 1] (Positive is Left)
forward = path[:, 1] # Treat the large values as Forward
lateral = path[:, 0] # Treat the small values as Lateral

plt.figure(figsize=(8, 8))
plt.plot(lateral, forward, 'ro-', label='Planned Path')
plt.scatter(0, 0, color='blue', s=200, label='Ego Car')

plt.title("Coordinate System Verification")
plt.xlabel("Lateral (meters)")
plt.ylabel("Forward (meters)")
plt.axis('equal') # Keep the grid 1:1 so we see true geometry
plt.grid(True)
plt.savefig('planning_final_v3.png')