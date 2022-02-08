using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlePlayer : MonoBehaviour
{
    public void PlayParticles()
    {
        GetComponent<ParticleSystem>().Play();
    }
}