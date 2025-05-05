"""Define a neural network model for the task."""
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
import numpy as np

from dataclasses import dataclass, field

class CircleClassifier(nn.Module):
    """Define a simple feedforward neural network for binary classification."""
    def __init__(self, input_size=2, hidden_sizes=[10, 5], output_size=1):
        """Initialize the model with two hidden layers."""
        super(CircleClassifier, self).__init__()
        
        self.fc1 = nn.Linear(input_size, hidden_sizes[0])
        self.fc2 = nn.Linear(hidden_sizes[0], hidden_sizes[1])
        self.fc3 = nn.Linear(hidden_sizes[1], output_size)
        self.relu = nn.ReLU()
        self.sigmoid = nn.Sigmoid()

    def forward(self, x):
        x = self.fc1(x)
        x = self.relu(x)
        x = self.fc2(x)
        x = self.relu(x)
        x = self.fc3(x)
        x = self.sigmoid(x)
        return x

@dataclass
class CircleModel:
    """Class to hold the model and training parameters."""
    epochs: int = 1000
    batch_size: int = 32
    device: str = 'cpu'
    learning_rate: float = 0.001
    optimizer_type: str = 'sgd'
    model: nn.Module | None = None
    criterion: nn.Module = field(default_factory=lambda: nn.BCELoss())
    optimizer: optim.Optimizer | None = None

    def _init_model(self):
        """Initialize the model."""
        if self.model is None:
            self.model = CircleClassifier()
        self.model.to(self.device)

    def _init_optimizer(self):
        """Initialize the optimizer."""
        if self.optimizer is None:
            if self.optimizer_type == 'sgd':
                self.optimizer = optim.SGD(self.model.parameters(), lr=self.learning_rate)
            elif self.optimizer_type == 'adam':
                self.optimizer = optim.Adam(self.model.parameters(), lr=self.learning_rate)
            else:
                raise ValueError(f"Unsupported optimizer type: {self.optimizer_type}")
        self.optimizer.to(self.device)

    def __post_init__(self):
        """Initialize the model and optimizer."""
        self._init_model()
        self._init_optimizer()

        self.criterion.to(self.device)
