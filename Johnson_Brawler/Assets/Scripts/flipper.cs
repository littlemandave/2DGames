using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class flipper : MonoBehaviour
{

  public SpriteRenderer sprite;

  void FixedUpdate(){
      if(sprite.flipX){
          gameObject.transform.localRotation = Quaternion.Euler(0, 180, 0);
      }else{
          gameObject.transform.localRotation = Quaternion.identity;
      }

  }

}
