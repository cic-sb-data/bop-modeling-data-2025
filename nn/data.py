import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.datasets import make_circles
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, roc_auc_score, roc_curve

import torch
from torch import nn
from torch.utils.data import DataLoader, TensorDataset
from dataclasses import dataclass, field


def generate_data(n_samples=1000, noise=0.1, train_size=0.6, val_size=0.2, random_state=42):
    """Generate a synthetic dataset using make_circles."""
    X, y = make_circles(n_samples=n_samples, noise=noise, factor=0.5)
    X_train, X_temp, y_train, y_temp = train_test_split(X, y, train_size=train_size, random_state=random_state)
    X_val, X_test, y_val, y_test = train_test_split(X_temp, y_temp, test_size=val_size/(1-train_size), random_state=random_state)

    return X_train, y_train, X_val, y_val, X_test, y_test
    
def preprocess_data(X_train, X_val, X_test):
    """Standardize the data."""
    scaler = StandardScaler()
    X_train = scaler.fit_transform(X_train)
    X_val = scaler.transform(X_val)
    X_test = scaler.transform(X_test)

    return X_train, X_val, X_test

@dataclass
class ModelData:
    """Class to hold the model data."""
    n: int = 1000
    p: int = 2
    X: np.ndarray = field(default_factory=lambda: np.empty((0, 0)))
    y: np.ndarray = field(default_factory=lambda: np.empty((0, 0)))

class CircleLoader(DataLoader):
    """Custom DataLoader for the circle dataset."""
    def __init__(self, X, y, batch_size=32, shuffle=True):
        data = TensorDataset(torch.tensor(X, dtype=torch.float32), torch.tensor(y, dtype=torch.float32))
        super().__init__(dataset, batch_size=batch_size, shuffle=shuffle)

    def __len__(self):
        """Return the number of batches."""
        return len(self.dataset) // self.batch_size

    def __iter__(self):
        """Return an iterator over the dataset."""
        for i in range(0, len(self.dataset), self.batch_size):
            yield self.dataset[i:i+self.batch_size]

    def __getitem__(self, idx):
        """Return a batch of data."""
        return self.dataset[idx]
    
    def __next__(self):
        """Return the next batch of data."""
        return next(self.iter)
    

