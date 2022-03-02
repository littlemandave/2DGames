using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Tilemaps;
using UnityEngine.InputSystem;

public class Builder : MonoBehaviour
{
    [SerializeField]
    public GameObject prefabToBuild;
    [SerializeField]
    bool printTileInfoOnClick = true;
    Vector3 clickPosition;
    [SerializeField]
    Tilemap GroundLayer;
    [SerializeField]
    Transform BuildingParent;
    [SerializeField]
    int BuildingOrderInLayer;
    [SerializeField]
    List<Tile> BuildableTileTypes;
    Vector3 buildOffset;
    List<Vector3Int> OccupiedPositions;

    public void Start(){
        buildOffset = new Vector3(0, 0.25f, 0);
        OccupiedPositions = new List<Vector3Int>();
    }

    public void OnClick(){
        Vector3Int tilemapPos = GroundLayer.WorldToCell(Camera.main.ScreenToWorldPoint(Mouse.current.position.ReadValue()));
        Tile tile = GroundLayer.GetTile<Tile>(tilemapPos);
        if(printTileInfoOnClick){
            if(tile == null){
                print("No tile at position.");
                return;
            }
            if(BuildableTileTypes.Contains(tile)){
                print("'" + tile.name + "'." + " This tile is in the buildable list.");
                BuildPrefab(tilemapPos);
            }else{
                print("'" + tile.name + "'." + " This tile is NOT in the buildable list.");
            }
        }
    }

    void BuildPrefab(Vector3Int cellPos){
        if(OccupiedPositions.Contains(cellPos)){
            print("Tilemap position is already occupied");
            return;
        }
        var worldPos = GroundLayer.CellToWorld(cellPos);
        var building = Instantiate(prefabToBuild, worldPos + buildOffset, Quaternion.identity);
        building.transform.SetParent(BuildingParent.transform);
        building.GetComponent<SpriteRenderer>().sortingOrder = BuildingOrderInLayer;
        OccupiedPositions.Add(cellPos);
    }
}
