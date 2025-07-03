"""Convenience class wrapping typical DuckDB functionality."""

from dataclasses import dataclass
from multiprocessing import connection
import duckdb
from pathlib import Path

@dataclass
class DuckDB:
    """Convenience class for DuckDB operations."""
    db_path: Path
    connection: duckdb.DuckDBPyConnection | None = None

    def connect(self):
        """Establish a connection to the DuckDB database."""
        if self.connection is None:
            self.connection = duckdb.connect(str(self.db_path))

    def query(self, sql: str):
        """Execute a SQL query and return the result."""
        return self.connection.execute(sql).fetchdf()

    def close(self):
        """Close the DuckDB connection."""
        self.connection.close()

    def __enter__(self):
        """Enter the runtime context related to this object."""
        self.connect()
        return self.connection

    def __exit__(self, exc_type, exc_value, traceback):
        """Exit the runtime context related to this object."""
        self.close()
        if exc_type is not None:
            raise exc_value
        
    def query(self, query: str):
        """Execute a SQL query and return the result."""
        with self as db:
            result = db.sql(query)
            try:
                return result.pl().lazy()
            except Exception as e:
                return str(e)

    def __call__(self, query: str):
        """Execute a SQL query using the call method."""
        return self.query(query)


        