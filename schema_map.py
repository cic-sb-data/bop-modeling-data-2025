import json
import yaml
from pathlib import Path

DBT_PROJECT_DIR = Path("bop_modeling_data")
MANIFEST_PATH = DBT_PROJECT_DIR / "target" / "manifest.json"
OUTPUT_YAML_PATH = Path("schema_map.yml")


def parse_manifest(manifest_path: Path) -> dict:
    """Loads and parses the dbt manifest.json file."""
    if not manifest_path.exists():
        print(f"Error: manifest.json not found at {manifest_path}")
        print(
            "Please ensure you have run 'dbt compile' or 'dbt docs generate' in your dbt project."
        )
        return {}
    with open(manifest_path, "r") as f:
        manifest = json.load(f)
    return manifest


def extract_schema_info(manifest: dict) -> dict:
    """Extracts and structures schema information from the manifest."""
    schema_map = {"models": [], "sources": []}

    # Process Nodes (Models, Seeds, Snapshots, etc.)
    for node_id, node_info in manifest.get("nodes", {}).items():
        if node_info["resource_type"] in ["model", "seed", "snapshot"]:
            model_data = {
                "unique_id": node_id,
                "name": node_info["name"],
                "resource_type": node_info["resource_type"],
                "schema": node_info["schema"],
                "alias": node_info.get("alias", node_info["name"]),
                "description": node_info.get("description", ""),
                "columns": [],
            }
            for col_name, col_info in node_info.get("columns", {}).items():
                model_data["columns"].append(
                    {
                        "name": col_name,
                        "data_type": col_info.get("data_type", "N/A"),
                        "description": col_info.get("description", ""),
                    }
                )
            schema_map["models"].append(model_data)

    # Process Sources
    for source_id, source_info in manifest.get("sources", {}).items():
        source_data = {
            "unique_id": source_id,
            "source_name": source_info["source_name"],
            "name": source_info["name"],  # Table name
            "resource_type": source_info["resource_type"],
            "schema": source_info["schema"],  # Source schema
            "description": source_info.get("description", ""),
            "columns": [],
        }
        for col_name, col_info in source_info.get("columns", {}).items():
            source_data["columns"].append(
                {
                    "name": col_name,
                    "data_type": col_info.get("data_type", "N/A"),
                    "description": col_info.get("description", ""),
                }
            )
        schema_map["sources"].append(source_data)

    # Sort for consistent output
    schema_map["models"].sort(key=lambda x: x["unique_id"])
    schema_map["sources"].sort(key=lambda x: x["unique_id"])

    return schema_map


def save_to_yaml(schema_map: dict, output_path: Path):
    """Saves the schema map to a YAML file."""
    if not schema_map.get("models") and not schema_map.get("sources"):
        print("No schema information extracted. YAML file will not be created.")
        return

    with open(output_path, "w") as f:
        yaml.dump(schema_map, f, sort_keys=False, indent=2, default_flow_style=False)
    print(f"Schema map successfully generated at {output_path}")


def main():
    print(f"Attempting to load manifest from: {MANIFEST_PATH.resolve()}")
    manifest_data = parse_manifest(MANIFEST_PATH)
    if manifest_data:
        schema_information = extract_schema_info(manifest_data)
        save_to_yaml(schema_information, OUTPUT_YAML_PATH)


if __name__ == "__main__":
    main()
