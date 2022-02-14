using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GridUtilities
{
    private static Vector3Int cellPosition3d;
    public static bool IsGridCellOccupied(Grid grid, Vector2Int position, GameObject gameObjectToIgnore = null)
    {
        cellPosition3d.x = position.x;
        cellPosition3d.y = position.y;
        cellPosition3d.z = Mathf.RoundToInt(grid.transform.position.z);
        
        Vector3 worldCellPosition = grid.CellToWorld(cellPosition3d);
        Collider2D overlap = Physics2D.OverlapCircle(new Vector3(worldCellPosition.x + (grid.cellSize.x / 2), worldCellPosition.y + (grid.cellSize.y / 2) ), 0.1f);
        if (overlap)
        {
            if(gameObjectToIgnore == null){return true;}
            if(overlap.gameObject == gameObjectToIgnore){return false;}
            return true;
        }
        else
        {
            return false;
        }
    }
}
