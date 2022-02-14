using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class BattleManager : MonoBehaviour
{
    public Slider enemyHealthBar;
    public Image fade;
    public Text winText;
    public void DoDamage(){
        enemyHealthBar.value = Mathf.Clamp01(enemyHealthBar.value - Random.Range(0.1f, 0.4f));
        if(enemyHealthBar.value <= 0 ){
            print("You Win!");
            enemyHealthBar.gameObject.SetActive(false);
            fade.color = Color.black;
            winText.gameObject.SetActive(true);
        }
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
