"""把 YouBike 即時資訊 JSON 轉成 GeoJSON，欄位改成簡短的小寫名稱，方便匯入 PostGIS。

用法：python -I scripts/youbike_to_geojson.py <輸入.json> <輸出.geojson>
"""
import json
import sys
from pathlib import Path

PREFIX = "YouBike2.0_"


def strip_prefix(name: str) -> str:
    return name[len(PREFIX):] if name.startswith(PREFIX) else name


def to_feature(s: dict) -> dict:
    return {
        "type": "Feature",
        "geometry": {
            "type": "Point",
            # GeoJSON 座標順序是 [經度, 緯度]
            "coordinates": [float(s["longitude"]), float(s["latitude"])],
        },
        "properties": {
            "sno": s["sno"],
            "name": strip_prefix(s["sna"]),
            "name_en": strip_prefix(s["snaen"]),
            "district": s["sarea"],
            "address": s["ar"],
            "total": int(s["Quantity"]),
            "bikes": int(s["available_rent_bikes"]),
            "docks": int(s["available_return_bikes"]),
            "active": int(s["act"]),
            "updated": s["updateTime"],
        },
    }


def main(src: Path, dst: Path) -> None:
    stations = json.loads(src.read_text(encoding="utf-8"))
    features = [to_feature(s) for s in stations if s.get("latitude") and s.get("longitude")]
    dst.write_text(
        json.dumps({"type": "FeatureCollection", "features": features}, ensure_ascii=False),
        encoding="utf-8",
    )
    print(f"{len(features)} / {len(stations)} 站 -> {dst}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    main(Path(sys.argv[1]), Path(sys.argv[2]))
