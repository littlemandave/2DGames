using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Breakable : MonoBehaviour
{
    public GameObject brokenPrefab;
    void OnDamage(float damage){
        Instantiate(brokenPrefab, gameObject.transform.position, gameObject.transform.rotation);
        Destroy(gameObject);
    }
}
