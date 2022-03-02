using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BuildPrefabSelector : MonoBehaviour
{
    [SerializeField]
    Builder builderComponent;
    [SerializeField]
    GameObject prefabToBuild;
    
    public void SetBuildingType(){
        builderComponent.prefabToBuild = prefabToBuild;
    }
}
