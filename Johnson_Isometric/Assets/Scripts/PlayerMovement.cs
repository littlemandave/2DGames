using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMovement : MonoBehaviour
{
    private PlayerInput input;
    private InputAction move;
    private Vector2 moveVector;
    private Vector3 goalPosition;
    [SerializeField]
    float CameraMoveSpeed = 1.0f;
    // Start is called before the first frame update
    void Start()
    {
        input = GetComponent<PlayerInput>();
        move = input.actions["Move"];
        goalPosition = gameObject.transform.position; 
    }
    // Update is called once per frame
    void Update()
    {
        gameObject.transform.position = goalPosition;
        
    }
    void FixedUpdate(){
        moveVector = move.ReadValue<Vector2>();
        goalPosition = gameObject.transform.position + (Camera.main.transform.right * moveVector.x + Camera.main.transform.up * moveVector.y) * CameraMoveSpeed * Time.fixedDeltaTime;
    }
}