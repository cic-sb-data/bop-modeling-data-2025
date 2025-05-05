"""Model fitter for neural networks."""
from __future__ import annotations
from dataclasses import dataclass, field

import torch
import torch.nn as nn
import torch.optim as optim