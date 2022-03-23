using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawner : MonoBehaviour
{
    public GameObject spawnLocation;
    public GameObject enemyToSpawn;
    public void SpawnEnemy(){
        GameObject.Instantiate(enemyToSpawn, spawnLocation.transform.position, Quaternion.identity);
    }

    void Start(){
        GetComponent<Animator>().Play("SharpenerSpawn");
    }

}
