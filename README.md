# 📶 Multi-Cell Channel Allocation & Handover Simulator (MATLAB)

This MATLAB-based project simulates **call allocation, blocking, dropping, and handover behavior** in a 3-cell cellular network (A → B → C). It features both a **console-based visual simulation** and a **simple GUI for parameter control**.

---

## 🚀 Features

- 📡 **3-cell simulation** with dynamic call arrival and departure
- 🔄 **Handover logic** with probabilistic control
- ❌ **Call blocking and dropping** when no channels are available
- 📈 **Utilization plots** for each cell
- 🧮 **Event timeline plots** for visualization of arrivals, handovers, and departures
- 🖱️ **Simple MATLAB GUI** to run simulations with custom parameters

---

## 📁 Files

| File | Description |
|------|-------------|
| `runSimulation.m` | Main simulation function with timeline and plots |
| `run_simulator_gui.m` | GUI to input simulation parameters and run the simulator |
| `README.md` | Project overview and instructions |

---

## 🧠 Simulation Model

- **Call Arrivals** follow a Poisson process with rate `λ`
- **Call Durations** are exponentially distributed with mean `1/μ`
- Each call:
  - Starts in **Cell A**
  - Can handover to **Cell B** and then to **Cell C** with probability `p_handover`
- If a cell has no free channels:
  - 🚫 Call is **blocked** (on arrival)
  - ❌ Call is **dropped** (on handover)

---

## 📌 How to Run

### ▶️ GUI Version

1. Open MATLAB.
2. Place both `.m` files in the same directory.
3. Run in the Command Window:
   ```matlab
   run_simulator_gui
